//
//  ITCommandInfo.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITCommandInfo : ITCommand
{
    override func execute(args: [String]) -> String {
        let ipa = ITIpa()
        let (success,error) = ipa.load(args[0])

        if (success) {
            var dispName:String
            if let dn = ipa.displayName {
                dispName = dn
            }
            else {
                dispName = "[not set]"
            }
            return "  App name:            " + ipa.appName + "\n" +
                "  Display name:        " + dispName + "\n" +
                "  Version:             " + ipa.bundleShortVersionString + "\n" +
                "  Build:               " + ipa.bundleVersion + "\n" +
                "  Bundle identifier:   " + ipa.bundleIdentifier + "\n" +
                "  Code sign authority: " + ipa.provisioningProfile!.codeSigningAuthority()! + "\n" +
                "  Minimum OS version:  " + ipa.minimumOSVersion + "\n" +
                "  Device family:       " + ipa.deviceFamily + "\n" +
                "\n" +
                "Provisioning:\n" +
                "  Name:                " + ipa.provisioningProfile!.provisioningName()! + "\n" +
                "  Expiration:          " + formatDate(ipa.provisioningProfile!.expirationDate()!) + "\n" +
                "  App ID name:         " + ipa.provisioningProfile!.appIdName()! + "\n" +
                "  Team:                " + ipa.provisioningProfile!.teamName()! + "\n";
        }
        else {
            return "Error: " + error
        }
    }
    
    func formatDate(date:NSDate) -> String {
        let df = NSDateFormatter()
        df.dateFormat = "EEE MMM d HH:mm:ss v yyyy"
        return df.stringFromDate(date)
    }
}
