//
//  main.swift
//  ipatool
//
//  Created by Stefan on 08/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

extension Array {
    var match : (head: Element, tail: [Element])? {
        return (count > 0) ? (self[0],Array(self[1..<count])) : nil
    }
}


let ipaTool = ITMain()
let (_,args) = Process.arguments.match!
print(ipaTool.run(args))

