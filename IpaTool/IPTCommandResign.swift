//
//  IPTCommandResign.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class IPTCommandResign : ITCommand
{
    var ipaPath:String = ""
    var resignedPath:String { get { return IPTCommandResign.resignedPathForPath(ipaPath) } }
    var codesignAllocate:String? {
        get {
            let cmd = IPTSystemCommand()
            let ok = cmd.execute("/usr/bin/xcrun", ["--find", "codesign_allocate"])
            if (ok) {
                return cmd.standardOutput!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
            else {
                return nil
            }
        }
    }

    class func resignedPathForPath(path:String) -> String {
        return (path as NSString).stringByDeletingPathExtension + "_resigned.ipa"
    }

    func validateArgs(args: [String]) -> (ok:Bool, error:String?) {
        if (args.count < 2 || args.count > 3) {
            return (false, "Need parameters for ipa path and new provisioning profile")
        }

        if (!NSFileManager.defaultManager().isReadableFileAtPath(args[0])) {
            return (false, "First parameter must be path of ipa file")
        }
        
        if (!NSFileManager.defaultManager().isReadableFileAtPath(args[1])) {
            return (false, "Second parameter must be path of provisioning profile")
        }
        
        return (true, nil)
    }
    
    override func execute(arguments: [String]) -> String {
        let args = convertArgsForCompatibility(arguments)
        
        let (ok, message) = validateArgs(args)
        if (!ok) {
            return "Error: " + message!
        }
        
        let ipa = ITIpa()
        ipaPath = args[0]
        let (success, error) = ipa.load(ipaPath)
        if !success {
            return "Error: " + error
        }
        var bundleIdentifier:String? = nil
        if (args.count == 3) {
            bundleIdentifier = args[2]
        }
        
        return resign(ipa, args[1], bundleIdentifier)
    }
    
    func convertArgsForCompatibility(args:[String]) -> [String]
    {
        while (args.count >= 2 &&
            (args[1] == "provisioning-profile" || args[1] == "bundle-identifier" || args[1] == "resign")) {
            var converted:[String] = []
            converted.append(args[0])
                if (args[1] == "bundle-identifier") {
                    converted.append(args[4])
                    converted.append(args[2])
                }
                else {
                    converted.append(args[2])
                    if (args.count > 3) {
                        converted.append(args[3])
                    }
                }
            return converted
        }
        return args
    }
    
    func resign(ipa:ITIpa, _ provPath:String, _ bundleIdentifier:String? = nil) -> String {
        if let alloc = codesignAllocate {
            let prof = ITProvisioningProfile.loadFromPath(provPath)
            if prof == nil {
                return "Error: could not load provisioning profile from path \(provPath)"
            }
            
            if (bundleIdentifier != nil) {
                let ok = replaceBundleIdentifier((ipa.appPath as NSString).stringByAppendingPathComponent("Info.plist"), bundleIdentifier!)
                if (!ok) {
                    return "Error: failed to replace bundle identifier in Info.plist"
                }
            }

            copyProvisioningProfileToExtractedIpa(ipa, provPath)
            let signer = prof!.codeSigningAuthority()!
            let cmd = IPTSystemCommand()
            let appName = ipa.appName
            let args:[String] = ["-f", "-vv", "-s", signer, appName]
            let env:[String:String] = ["CODESIGN_ALLOCATE":alloc, "EMBEDDED_PROFILE_NAME":"embedded.mobileprovision"]
            let payloadDir = (ipa.appPath as NSString).stringByDeletingLastPathComponent
            cmd.workingDirectory = payloadDir
            var ok = cmd.execute("/usr/bin/codesign", args, env)
            
            if !ok {
                return "Cannot execute /usr/bin/codesign";
            }
            
            ok = SSZipArchive.createZipFileAtPath(resignedPath, withContentsOfDirectory: (payloadDir as NSString).stringByDeletingLastPathComponent)
            if ok {
                return "\(ipa.appName): replacing existing signature\n" + "\n" + "Resigned ipa: \(resignedPath)\n"
            }
            else {
                return "Failed to create resigned IPA archive"
            }
        }
        else {
            return "Could not find codesign_allocate"
        }
    }
    
    func copyProvisioningProfileToExtractedIpa(ipa:ITIpa, _ provPath:String)
    {
        let dest = (ipa.appPath as NSString).stringByAppendingPathComponent("embedded.mobileprovision")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(dest);
            try NSFileManager.defaultManager().copyItemAtPath(provPath, toPath: dest);
        } catch _ {
            assert(false, "Cannot copyProvisioningProfileFromIPA");
        }
    }
    
    func replaceBundleIdentifier(infoPlistPath:String, _ bundleIdentifier:String) -> Bool
    {
        let d:NSDictionary? = NSDictionary(contentsOfFile: infoPlistPath) as NSDictionary?
        if (d == nil) {
            return false
        }
        
        let plist:NSMutableDictionary = d!.mutableCopy() as! NSMutableDictionary
        plist["CFBundleIdentifier"] = bundleIdentifier

        do {
            let data:NSData? = try NSPropertyListSerialization.dataWithPropertyList(plist, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0);
            if (data == nil) {
                return false
            }
            return data!.writeToFile(infoPlistPath, atomically: true)
        } catch _ {
            print ("ListSerialization issue");
            return false;
        }
    }

}
