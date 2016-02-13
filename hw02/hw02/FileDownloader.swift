//
//  FileDownloader.swift
//  hw02
//
//  Created by Jeff Fermon on 1/20/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import Foundation

// created delegate for this object. All objects that instantiate this class must 
//conform to this protocol.
protocol FileDownloaderDelegate {
    func downloadSuccessful(filepath:String)
    func downloadFailed(error:NSError)
}

//class to manage download of files
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
        //print("init called")
        //print( self )
    }
    
    
    //deinit cleans up all files that we have loaded
    deinit {
        //print("deinit called")
        //print( self )
        let fileManager = NSFileManager()
        if (filePath != nil) {
            //loop through all files that we have downloaded and saved
            for path in fileArray {
                
                //check if file exists
                if(fileManager.fileExistsAtPath(path)) {
                    do {
                        //attempt to remove file
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
    
    //helper function to determine if file exists
    func fileExists(filepath: String) -> Bool {
        let fileManager = NSFileManager()
        if (filePath != nil) {
            return fileManager.fileExistsAtPath(filepath)
        } else {
            return false
        }
    }
    
    //function to begin download of file
    func beginDownload(){
        //check if url is a file url
        //this is true when we are opening a file from the mail client
        if myUrl.fileURL {
            
            //set our filepath to the new URL
            filePath = myUrl.path!
            
            //add file path into our file array to delete it when we are done
            fileArray.append(filePath!)
            
            //alert delegate that file is ready and pass it the filepath
            if (delegate != nil){
                    delegate!.downloadSuccessful(filePath!)
            }
            
            //"else" logic is called when we are passed a web address
        } else {
            
            //create URL session configuration object for background session
            let sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.FermonJeff.hw02")
            
            //set maximum connections to 1
            sessionConfiguration.HTTPMaximumConnectionsPerHost = 1
            
            //create actual session from configuration
            self.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
            
            //set URL of file to download
            sessionDownloadTask = self.session.downloadTaskWithURL(myUrl)
            
            //start download
            sessionDownloadTask.resume()
        }
    }
    
    //NSURLSessionDownloadDelegate method. Called when file is finished downloading
    @objc func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didFinishDownloadingToURL location: NSURL){
            
            //set path to file logic
            
            //get local path for when to save file
            let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentDirectoryPath:String = path[0]
            
            let fileManager = NSFileManager()
            
            //create timestamp to add to file name
            let timestamp = NSInteger(NSDate().timeIntervalSince1970)
            
            //create full path for file
            let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/file_\(timestamp).txt"))
            
            //check if no file exists at this path
            if (!fileManager.fileExistsAtPath(destinationURLForFile.path!)){
                do {
                    //if not then move file to this location
                    try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
                } catch {
                    
                    //if move unsuccessful, call download failed called download failed delegate function
                    delegate?.downloadFailed(NSError(domain: "Download success, Error occurred while moving file to destination url",code: 0,userInfo: nil))
                }
            }
            //now check that file does exist at this path, if so set member variables of our class to reflect this
            if fileManager.fileExistsAtPath(destinationURLForFile.path!){
                filePath = destinationURLForFile.path;
                fileArray.append(filePath!)
            }
    }
    
    //NSURLSessionDownloadDelegate method. not used in this implementation
    @objc func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64){
            //print("bytes written: \(totalBytesWritten)")
            
    }
    
    //NSURLSessionDownloadDelegate method. Called as last delegate method
    @objc func URLSession(session: NSURLSession,
        task: NSURLSessionTask,
        didCompleteWithError error: NSError?) {
            
            //check if we got an error.
            //call appropriate delegate function
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
            
            //perform cleanup of session object.
            if (self.session != nil){
                self.session.invalidateAndCancel();
                self.session = nil
            }
    }
}