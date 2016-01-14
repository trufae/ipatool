//
//  ITCMSDecoder.swift
//  ipatool
//
//  Created by Stefan on 20/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITCMSDecoder
{
    var cmsDecoder:CMSDecoder?
    private var _decodedString:String?
    private var _decodedData:NSData?
    
    init()
    {
        var d: CMSDecoder? = nil
        //var d: UnsafeMutablePointer<CMSDecoder?> = nil;
        let status = CMSDecoderCreate(&d)
        assert(status == noErr)
        //cmsDecoder = d; // as CMSDecoder?; //.takeRetainedValue()
    }
    
    func decodeData(data:NSData)
    {
        let l = data.length
        let bytes = UnsafeMutablePointer<Void>.alloc(l)
        data.getBytes(bytes, length:l)
        var status = CMSDecoderUpdateMessage(cmsDecoder!, bytes, Int(l))
        assert(status == noErr)
        
        status = CMSDecoderFinalizeMessage(cmsDecoder!)
        assert(status == noErr)
        
        decodeString()
    }
    
    func decodeString()
    {
        let data:UnsafeMutablePointer<CFData?> = nil
        let status = CMSDecoderCopyContent(cmsDecoder!, data)
        assert(status == noErr)
        if data != nil {
            _decodedString = NSString(data: data.move()! as CFData, encoding: NSUTF8StringEncoding) as String?;
        }
    }
    
    func decodedString() -> String?
    {
        if (_decodedString != nil) { return _decodedString }
        if (cmsDecoder == nil) { return nil }
        decodeString()
        return _decodedString
    }

    func provisioningProfile() -> ITProvisioningProfile?
    {
        if let d = _decodedData {
            return ITProvisioningProfile(d)
        }
        else {
            return nil
        }
    }
}
