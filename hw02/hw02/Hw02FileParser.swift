//
//  Hw02FileParser.swift
//  hw02
//
//  Created by Jeff Fermon on 1/24/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import Foundation

//this struct contains values for a single Acceleromter reading
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

//struct to help parse file into manageble data chunks
struct Hw02FileParser {
    var fileContents:[String]!
    var dataLines:[String]!
    var comments:[String]!
    var data:[AccelData]!
    
    //accepts contents of new file as a single string
    init(newFile:String){
        dataLines = [String]()
        comments = [String]()
        data = [AccelData]()
        
        //break file into array of strings. Each line is entry
        fileContents = newFile.componentsSeparatedByString("\n")
        
        //loop through all lines
        for line in fileContents {
            
            //save lines beginning with "%" in comments array
            if ( line.hasPrefix("%") ){
                comments.append(line)
            } else {
                //else if line is not empty, save into data lines array
                if ( !line.isEmpty ) {
                    dataLines.append(line)
                }
            }
        }
        
        //loop through all of the data lines
        for line in dataLines {
            //break line up along tabs
            let values = line.componentsSeparatedByString("\t")
            
            //create new AccelData object and append to data array.
            data.append( AccelData(xValue: values[0], yValue: values[1], zValue: values[2]))
        }
    }
    
}