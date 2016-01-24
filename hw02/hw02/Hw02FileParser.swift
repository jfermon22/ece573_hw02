//
//  Hw02FileParser.swift
//  hw02
//
//  Created by Jeff Fermon on 1/24/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import Foundation


class Hw02FileParser {
    var fileContents:[String]!
    
    init(newFile:String){
        fileContents = newFile.componentsSeparatedByString("\n")
        print ("lines = \(fileContents.count)")
    }
    
    
}