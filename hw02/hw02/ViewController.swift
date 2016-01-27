//
//  ViewController.swift
//  hw02
//
//  Created by Jeff Fermon on 1/18/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import UIKit


class ViewController: UIViewController, FileDownloaderDelegate {
//MARK: members
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    @IBOutlet var playbackButton: UIButton!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var commentView: UILabel!
    
    var currentFile:String?
    //var parser:Hw02FileParser?
    var fileDownloader:FileDownloader?
    
    //THIS IS DEBUG CODE
    //REMOVE AND REMOVE BUTTONS FOR FINAL PRODUCT
    @IBAction func file1pressed(sender: UIButton) {
        addressField.text = "http://m.uploadedit.com/ba3s/1453598953263.txt"
    }
    @IBAction func file2pressed(sender: UIButton) {
       addressField.text = "http://m.uploadedit.com/ba3s/145359923777.txt"
    }
    

//MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        enablePlayback(false,setButtonText: "Load File")        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidDisappear( animated: Bool){
          fileDownloader = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //method to handle load of file from web
    @IBAction func loadFile(sender: UIButton) {
        print("attempting to load file " + addressField.text!)
        importFile(NSURL(string: addressField.text!)!)
        enablePlayback(false,setButtonText: "Downloading...")
    }

    //method to kick off file playback
    @IBAction func beginPlayback(sender: UIButton) {
        if (currentFile != nil){
            //reading
            do {
                //save text from file to string
                let text2 = try String(contentsOfFile: currentFile!, encoding: NSASCIIStringEncoding )
                
                //update playback button
                var priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    self.enablePlayback(false,setButtonText: "Playing...")
                }
                
                //parse file
                let parser = Hw02FileParser(newFile: text2)
                
                
                var fullcomment = ""
                //create single string from comments
                for comment in (parser.comments)! {
                    //append text and separate each line with /n
                    //unless line is last line
                    var lineEnding = ""
                    if comment != parser.comments.last {
                        lineEnding = "\n"
                    }
                    fullcomment.appendContentsOf(comment + lineEnding)
                }
                
                //remove %
                fullcomment = fullcomment.stringByReplacingOccurrencesOfString("%", withString: "")
                
                //update textview
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    self.updateTextView( fullcomment )
                }
                
                //update values for axis readings
                priority = DISPATCH_QUEUE_PRIORITY_HIGH
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    for accelVal in (parser.data)! {
                        self.updateLabels(accelVal.x, yValue: accelVal.y, zValue: accelVal.z)
                        sleep(1)
                    }
                    
                //update playback button text
                self.enablePlayback(false,setButtonText: "Load New File")
                //perform filedownloader cleanup
                self.fileDownloader = nil
                }
            }
            catch {print(" ")}
           
        } else {
            print("current path is nil")
        }
    }
    
    //helper method to update axis readings
    func updateLabels(xValue:String, yValue:String, zValue:String ) {
        dispatch_async(dispatch_get_main_queue()) {
            self.xLabel.text = xValue
            self.yLabel.text = yValue
            self.zLabel.text = zValue
        }
    }
    
    //delegate method called when download of new file is successful
    func downloadSuccessful(filepath:String){
        enablePlayback(true, setButtonText: "Begin Playback")
        currentFile = filepath
        //print("downloadSuccessful:" + filepath)
    }
    
    //delegate method called when download of new file is unsuccessful
    func downloadFailed(error:NSError){
        enablePlayback(false,setButtonText: "Download Failed")
        dispatch_async(dispatch_get_main_queue()) {
            //create popup alert to alert user to failed download
           let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            //add button
           alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            //show alert
           self.presentViewController(alert, animated: true, completion: nil)
        }
        //print("downloadFailed:" + error.localizedDescription)
    }
    
    //helper method to get main queue and update comment label
    func updateTextView(comments:String){
        //run logic in main queue
       dispatch_async(dispatch_get_main_queue()) {
            //set comment view text
            self.commentView.text = comments
        }
    }
    
    //helper method to get main queue and update playback button text/selectability
    func enablePlayback(isEnabled:Bool, setButtonText buttonText:String = "")
    {
        //run logic in main queue
       dispatch_async(dispatch_get_main_queue()) {
            var controlState:UIControlState
            //Checks if button should be enabled and sets control state to appropriate state
            if (isEnabled){
                controlState = UIControlState.Normal;
            } else {
                controlState = UIControlState.Disabled;
            }
            //sets state playback button. Different states have different appearances
            self.playbackButton.enabled = isEnabled
            //sets user interaction ability of playback button
            self.playbackButton.userInteractionEnabled = isEnabled
            //if a new text is received, update the button text
            if (!buttonText.isEmpty )
            {
                self.playbackButton.setTitle(buttonText, forState: controlState)
            }
        }
    }
    
    //helper method to begin download of new file
    func importFile(newURL:NSURL){
        if fileDownloader == nil {
            fileDownloader = FileDownloader();
            //sets NSURLSessionDownloadDelegate to this
            fileDownloader!.delegate = self
        }
        //sets url to download from
        fileDownloader!.setUrl(newURL)
        fileDownloader!.beginDownload()
        //Configures playback button to diabled and chanes text
        enablePlayback(false,setButtonText: "Downloading...")
    }
}

