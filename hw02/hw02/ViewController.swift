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
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    var currentFile:String?
    var fileDownloader:FileDownloader?
    var isPlaying:Bool!
    
    //function for handling putting file address into address fields
    @IBAction func fileButtonPressed(sender: UIButton) {
        //check button name and set to correct file
        var buttonNum:String!
        if ( sender.currentTitle!.hasSuffix("1") ) {
            buttonNum = "1"
        } else if ( sender.currentTitle!.hasSuffix("2") ) {
            buttonNum = "2"
        } else {
            buttonNum = "3"
        }
        
        addressField.text = "http://www2.engr.arizona.edu/~sprinkjm/work/ece473-573/sampleData0" + buttonNum + "-hw02.txt"
    }
    
    //MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        isPlaying = false
        
        //set lower button to not enable playback and to tell us load a file
        enablePlayback(false,setButtonText: "Load File")
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
        //print("attempting to load file " + addressField.text!)
        
        //call function to handle file downlloading
        importFile(NSURL(string: addressField.text!)!)
        //set lower button to not enable playback and to tell user that file is downloading
        enablePlayback(false,setButtonText: "Downloading...")
    }
    
    //method to kick off file playback once playback button hit
    @IBAction func beginPlayback(sender: UIButton) {
        //check if we have saved a file to a local path
        if (currentFile != nil){
            //reading
            do {
                //save text from file to string
                let text2 = try String(contentsOfFile: currentFile!, encoding: NSASCIIStringEncoding)
                
                //update playback button
                //dispatch async calls needed to force GUI
                //updates to happen immediately
                var priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    self.enablePlayback(false,setButtonText: "Playing...")
                    self.isPlaying = true;
                }
                
                //Create object that handles parsing of file.
                //Once parsed, object contains members for comment lines, data lines,
                // and a structs called AccelData.
                let parser = Hw02FileParser(newFile: text2)
                
                var fullcomment = ""
                
                //loop to create single string from comments
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
                
                //update textview to display comments from loaded file
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    self.updateTextView( fullcomment )
                }
                
                //update values for axis readings
                priority = DISPATCH_QUEUE_PRIORITY_HIGH
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    //loop to play through all accelData values
                    for accelVal in (parser.data)! {
                        self.updateLabels(accelVal.x, yValue: accelVal.y, zValue: accelVal.z)
                        usleep(100000)
                    }
                    
                    //Once play back complete, update playback button text, and set
                    //button to diabled
                    self.enablePlayback(false,setButtonText: "Load New File")
                    //perform filedownloader cleanup
                    self.fileDownloader = nil
                    self.isPlaying = false;
                }
            }
            catch {print(error)}
            
        } else {
            print("current path is nil")
        }
    }
    
    //helper method to update axis readings on GUI
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
    
    //function to dismaiss keyboard when user clicks off oftext entry field
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        addressField.resignFirstResponder()
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
        //Configures playback button to disabled and changes text
        enablePlayback(false,setButtonText: "Downloading...")
        fileDownloader!.beginDownload()
        
    }
}

