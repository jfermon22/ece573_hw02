//
//  Hw02FileParser.swift
//  hw02
//
//  Created by Jeff Fermon on 1/24/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import Foundation
struct AccelData {
    var x:String
    var y:String
    var z:String
    init(xValue:String, yValue:String, zValue:String){
        x = xValue
        y = yValue
        z = zValue
    }
}

class Hw02FileParser {
    var fileContents:[String]!
    var dataLines:[String]!
    var comments:[String]!
    var data:[AccelData]!
    
    init(newFile:String){
        dataLines = [String]()
        comments = [String]()
        data = [AccelData]()
        
        fileContents = newFile.componentsSeparatedByString("\n")
        for line in fileContents {
            if ( line.hasPrefix("%") ){
                comments.append(line)
            } else {
                dataLines.append(line)
            }
        }
        
        for line in dataLines {
            let values = line.componentsSeparatedByString("\t")
            data.append( AccelData(xValue: values[0], yValue: values[1], zValue: values[2]))
        }
    }
}