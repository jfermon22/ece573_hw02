//
//  FileDownloader.swift
//  hw02
//
//  Created by Jeff Fermon on 1/20/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import Foundation

protocol FileDownloaderDelegate {
    func downloadSuccessful(filepath:String)
    func downloadFailed(error:NSError)
}

class FileDownloader:NSObject, NSURLSessionDownloadDelegate {
    var myUrl:NSURL!
    var session:NSURLSession!
    var sessionDownloadTask:NSURLSessionDownloadTask!
    var filePath:String?
    var delegate:FileDownloaderDelegate?
    var fileArray:[String]
    
    override init() {
        self.fileArray = [String]()
        super.init()
        print("init called")
        print( self )
    }
    
    deinit {
        print("deinit called")
        print( self )
        let fileManager = NSFileManager()
        if (filePath != nil) {
            for path in fileArray {
                if(fileManager.fileExistsAtPath(path)) {
                    do {
                        try fileManager.removeItemAtPath(path)
                        //print(path + " deleted successfully")
                    } catch {
                        print(path + " failed to delete file")
                    }
                }
            }
        }
        myUrl = nil
        session = nil
        sessionDownloadTask = nil
        filePath = nil
        delegate = nil
    }
    
    //func setUrlWithString(newUrl:String){
    //    myUrl = NSURL(string: newUrl);
    //}
    
    func setUrl(newUrl:NSURL){
        myUrl = newUrl;
    }
    
    func beginDownload(){
       let sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.FermonJeff.hw02")
        //let sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()

        sessionConfiguration.HTTPMaximumConnectionsPerHost = 1
        
        self.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        sessionDownloadTask = self.session.downloadTaskWithURL(myUrl)
        sessionDownloadTask.resume()
    }
    
    @objc func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didFinishDownloadingToURL location: NSURL){
        
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = NSFileManager()
        let timestamp = NSInteger(NSDate().timeIntervalSince1970)
        let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/file_\(timestamp).txt"))
        if (!fileManager.fileExistsAtPath(destinationURLForFile.path!)){
            do {
                try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
            } catch {
                delegate?.downloadFailed(NSError(domain: "Download success, Error occurred while moving file to destination url",code: 0,userInfo: nil))
            }
        }
        
        if fileManager.fileExistsAtPath(destinationURLForFile.path!){
            filePath = destinationURLForFile.path;
            fileArray.append(filePath!)
            }
    }
    
    @objc func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64){
        //print("bytes written: \(totalBytesWritten)")
        
    }

    
    @objc func URLSession(session: NSURLSession,
        task: NSURLSessionTask,
        didCompleteWithError error: NSError?) {
        if(error != nil) {
            if (delegate != nil){
                delegate?.downloadFailed(error!)
            }
        } else {
            if (delegate != nil){
                if (filePath != nil){
                    delegate?.downloadSuccessful(filePath!)
                }
                else
                {
                    delegate?.downloadFailed(NSError(domain: "Download success, filepath is nil",code: 0,userInfo: nil))
                }
            }
        }
        if (self.session != nil){
            self.session.invalidateAndCancel();
            self.session = nil
        }
    }
}