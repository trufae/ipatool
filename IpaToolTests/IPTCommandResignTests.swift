//
//  IPTCommandResignTests.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Cocoa
import XCTest

class IPTCommandResignTests: XCTestCase {
    var config = ITTestConfig()
    var resignCommand = IPTCommandResign()
    var output = ""
    var resignedPath = ""
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        resignCommand = IPTCommandResign()
        resignedPath = IPTCommandResign.resignedPathForPath(config.ipaFullPath!)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(resignedPath);
        } catch _ {
            /* do nothing here */
        }
        output = resignCommand.execute([config.ipaFullPath!, config.resignProvisioningProfilePath])
    }

    func testCorrectResignFilePath()
    {
        let appNameWithoutExtension = (config.appName as NSString).stringByDeletingPathExtension
        let expectedPath:String = NSURL(string:(config.ipaFullPath! as NSString)
            .stringByDeletingLastPathComponent)!.URLByAppendingPathComponent(
                "\(appNameWithoutExtension)_resigned.ipa").path!
        XCTAssertEqual(resignCommand.resignedPath, expectedPath)
    }

    func testReturnsExpectedOutput()
    {
        // let bundleId = config.bundleIdentifier
        let appNameWithoutExtension = (config.appName as NSString).stringByDeletingPathExtension
        let expectedPath:String = NSURL(string:(config.ipaFullPath! as NSString)
            .stringByDeletingLastPathComponent)!.URLByAppendingPathComponent(
                "\(appNameWithoutExtension)_resigned.ipa").path!
        let expectedOutputFirstLine = "\(config.appName): replacing existing signature"
        let expectedOutputLastLine = "Resigned ipa: \(expectedPath)"
        let lines = output.componentsSeparatedByString("\n")
        print (lines);

        XCTAssertEqual(lines[0], expectedOutputFirstLine)
        XCTAssertEqual(lines[lines.count-2], expectedOutputLastLine)
    }
    
    func testShouldHaveCorrectProvisioningAndCodeSigningAuthorityAndBundleIdentifier()
    {
        let resignedIpa = ITIpa()
        let (success,_) = resignedIpa.load(resignedPath)
        XCTAssertTrue(success)
        XCTAssertEqual(resignedIpa.provisioningProfile!.provisioningName()!, config.resignedProvisioningName)
        XCTAssertEqual(resignedIpa.provisioningProfile!.codeSigningAuthority()!, config.resignedCodeSigningAuthority)
        XCTAssertEqual(resignedIpa.bundleIdentifier, config.bundleIdentifier)
    }
}

class IPTCommandResignTests_preconditions: XCTestCase {
    var config = ITTestConfig()
    var resignCommand = IPTCommandResign()
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        resignCommand = IPTCommandResign()
    }

    func testCanFindCodesignAllocate()
    {
        let path = resignCommand.codesignAllocate
        XCTAssertNotNil(path)
        XCTAssertEqual("codesign_allocate", (path! as NSString).lastPathComponent)

        let isExecutable = NSFileManager.defaultManager().isExecutableFileAtPath(path!)
        XCTAssertTrue(isExecutable)
    }

    func testValidateArgs_none()
    {
        let (ok,_) = resignCommand.validateArgs([])
        XCTAssertFalse(ok)
    }

    func testValidateArgs_one()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!])
        XCTAssertFalse(ok)
    }

    func testValidateArgs_two()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!,config.resignProvisioningProfilePath])
        XCTAssertTrue(ok)
    }

    func testValidateArgs_three()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!,config.resignProvisioningProfilePath,"arg3"])
        XCTAssertTrue(ok)
    }

    func testValidateArgs_four()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!,config.resignProvisioningProfilePath,"arg3","arg4"])
        XCTAssertFalse(ok)
    }

    func testValidateArgs_invalidWhenFirstIsNotIpa()
    {
        let (ok,_) = resignCommand.validateArgs(["arg1",config.resignProvisioningProfilePath])
        XCTAssertFalse(ok)
    }

    func testValidateArgs_invalidWhenSecondIsNotProvisioningProfile()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!,"arg2"])
        XCTAssertFalse(ok)
    }
    
    func testExecuteCallsValidate()
    {
        let result = resignCommand.execute([])
        let range = result.rangeOfString("error", options:NSStringCompareOptions.CaseInsensitiveSearch)
        XCTAssertFalse(range == nil)
    }
}

class IPTCommandResignTests_newBundleIdentifier: XCTestCase {

    var config = ITTestConfig()
    var resignCommand = IPTCommandResign()
    var output = ""
    var resignedPath = ""
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        resignCommand = IPTCommandResign()
        resignedPath = IPTCommandResign.resignedPathForPath(config.ipaFullPath!)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(resignedPath)
        } catch _ {
            /* do nothing */
        }
        output = resignCommand.execute([config.ipaFullPath!, config.resignProvisioningProfilePath, config.resignedBundleIdentifier])
    }
    
    func testShouldHaveCorrectProvisioningAndCodeSigningAuthorityAndBundleIdentifier()
    {
        let resignedIpa = ITIpa()
        let (success,_) = resignedIpa.load(resignedPath)
        XCTAssertTrue(success)
        XCTAssertEqual(resignedIpa.provisioningProfile!.provisioningName()!, config.resignedProvisioningName)
        XCTAssertEqual(resignedIpa.provisioningProfile!.codeSigningAuthority()!, config.resignedCodeSigningAuthority)
        XCTAssertEqual(resignedIpa.bundleIdentifier, config.resignedBundleIdentifier)
    }
}

class IPTCommandResignTests_compatibilityMode: XCTestCase {
    
    var config = ITTestConfig()
    var resignCommand = IPTCommandResign()
    var output = ""
    var resignedPath = ""
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        resignCommand = IPTCommandResign()
        resignedPath = IPTCommandResign.resignedPathForPath(config.ipaFullPath!)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(resignedPath)
        } catch _ {
            /* do nothing */
        }
    }
    
    func testFirstForm()
    {
        output = resignCommand.execute([config.ipaFullPath!, "provisioning-profile", config.resignProvisioningProfilePath, "bundle-identifier", config.resignedBundleIdentifier])

        let resignedIpa = ITIpa()
        let (success,_) = resignedIpa.load(resignedPath)
        XCTAssertTrue(success)
        XCTAssertEqual(resignedIpa.provisioningProfile!.provisioningName()!, config.resignedProvisioningName)
        XCTAssertEqual(resignedIpa.provisioningProfile!.codeSigningAuthority()!, config.resignedCodeSigningAuthority)
        XCTAssertEqual(resignedIpa.bundleIdentifier, config.resignedBundleIdentifier)
    }

    func testSecondForm()
    {
        output = resignCommand.execute([config.ipaFullPath!, "bundle-identifier", config.resignedBundleIdentifier, "provisioning-profile", config.resignProvisioningProfilePath])
        
        let resignedIpa = ITIpa()
        let (success,_) = resignedIpa.load(resignedPath)
        XCTAssertTrue(success)
        XCTAssertEqual(resignedIpa.provisioningProfile!.provisioningName()!, config.resignedProvisioningName)
        XCTAssertEqual(resignedIpa.provisioningProfile!.codeSigningAuthority()!, config.resignedCodeSigningAuthority)
        XCTAssertEqual(resignedIpa.bundleIdentifier, config.resignedBundleIdentifier)
    }
}
