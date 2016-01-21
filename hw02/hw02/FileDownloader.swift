//
//  FileDownloader.swift
//  hw02
//
//  Created by Jeff Fermon on 1/20/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import Foundation



class FileDownloader:NSObject, NSURLSessionDownloadDelegate {
    var myUrl:NSURL!
    var session:NSURLSession!
    var sessionDownloadTask:NSURLSessionDownloadTask!
    var filePath:String?
    
    init(newUrl:String) {
        super.init()
        myUrl = NSURL(string: newUrl);
    }
    
    func beginDownload(){
        let sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.FermonJeff.hw02")
        
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 5
        
        self.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        sessionDownloadTask = self.session.downloadTaskWithURL(myUrl)
        sessionDownloadTask.resume()
    }
    
    @objc func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL){
        print("DOWNLOAD FINISHED")
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = NSFileManager()
        let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/file.txt"))
        
        if fileManager.fileExistsAtPath(destinationURLForFile.path!){
            print("file successfully downloaded to" + destinationURLForFile.path! )
           // showFileWithPath(destinationURLForFile.path!)
            filePath = destinationURLForFile.path;
        }
        else{
            do {
                try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
                // show file
                //showFileWithPath(destinationURLForFile.path!)
                 print("file successfully downloaded after second attempt to" + destinationURLForFile.path! )
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    
    @objc func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        print("btes written")
        
    }
    
    @objc func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if(error != nil) {
            
            print("Download completed with error: \(error!.localizedDescription)");
            
        } else {
            
            print("Download finished successfully");
            
        }
        
    }
}