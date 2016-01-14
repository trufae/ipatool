//
//  ITTestConfig.swift
//  ipatool
//
//  Created by Stefan on 15/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITTestConfig
{
    private var config:NSDictionary? = nil

    var ipaPath:String { get { return "SampleApp.ipa" } }
    var ipaFullPath:String? { get {
        let ipaDir = config!["ipaDir"] as! String
        return (ipaDir as NSString).stringByAppendingPathComponent(ipaPath)
        } }
    var appName:String { get { return "SampleApp.app" } }
    var displayName:String { get { return "Sample!" } }
    var bundleShortVersionString:String { get { return "1.0" } }
    var bundleVersion:String { get { return "1" } }
    var bundleIdentifier:String { get { return config!["bundleIdentifier"] as! String } }
    var minimumOSVersion:String { get { return "8.0" } }
    var deviceFamily:String { get { return "iphone ipad" } }
    var codeSigningAuthority:String { get { return config!["codeSigningAuthority"] as! String } }
    var provisioningName:String { get { return config!["provisioningName"] as! String } }
    var provisioningExpiration:NSDate? { get {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df.dateFromString(config!["provisioningExpiration"] as! String)
        } }
    var provisioningAppIdName:String { get { return config!["provisioningAppIdName"] as! String } }
    var provisioningTeam:String { get { return config!["provisioningTeam"] as! String } }
    var resignedProvisioningName:String { get { return config!["resignedProvisioningName"] as! String } }
    var resignedCodeSigningAuthority:String { get { return config!["resignedCodeSigningAuthority"] as! String } }
    var resignProvisioningProfilePath:String { get { return config!["resignProvisioningProfilePath"] as! String } }
    var resignedBundleIdentifier:String { get { return config!["resignedBundleIdentifier"] as! String } }

    func load() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let configFilePath:String? = bundle.pathForResource("testConfig", ofType: "json")
        assert(configFilePath != nil)
        
        do {
            let jsonData = try NSData(contentsOfFile:configFilePath!, options:NSDataReadingOptions(rawValue: 0))
            let config: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
            assert(config != nil)
            self.config = config
        } catch _ {
            // nothing here
            assert(false);
        }
    }
    
   
}
