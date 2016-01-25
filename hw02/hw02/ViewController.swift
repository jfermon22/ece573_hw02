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
    var parser:Hw02FileParser?
    
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
        enablePlayback(false,setButtonText: "Load File")
        fileDownloader = FileDownloader();
        fileDownloader!.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
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
        fileDownloader!.setUrlWithString(addressField.text!)
        fileDownloader!.beginDownload()
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
                parser = Hw02FileParser(newFile: text2)
                
                //update comments textbox
                var fullcomment = ""
                for comment in (parser!.comments)! {
                    //append text and separate each line with /n
                    fullcomment.appendContentsOf(comment + "\n")
                }
                fullcomment = fullcomment.stringByReplacingOccurrencesOfString("%", withString: "")
                
                //update textview
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    self.updateTextView( fullcomment )
                }
                
                //update values for axis readings
                priority = DISPATCH_QUEUE_PRIORITY_HIGH
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    for accelVal in (self.parser?.data)! {
                        self.updateLabels(accelVal.x, yValue: accelVal.y, zValue: accelVal.z)
                        sleep(1)
                    }
                    
                //update playback button text
                self.enablePlayback(false,setButtonText: "Load New File")
                }
            }
            catch {print(" ")}
           
        } else {
            print("current path is nil")
        }
    }
    
    func updateLabels(xValue:String, yValue:String, zValue:String ) {
        dispatch_async(dispatch_get_main_queue()) {
            self.xLabel.text = xValue
            self.yLabel.text = yValue
            self.zLabel.text = zValue
        }
    }
    
    func downloadSuccessful(filepath:String){
        enablePlayback(true, setButtonText: "Begin Playback")
        currentFile = filepath
        print("downloadSuccessful:" + filepath)
    }
    
    func downloadFailed(error:NSError){
        enablePlayback(false,setButtonText: "Download Failed")
        print("downloadFailed:" + error.localizedDescription)
    }
    
    func updateTextView(comments:String){
       dispatch_async(dispatch_get_main_queue()) {
        self.commentView.text = comments
        }
    }
    
    func enablePlayback(isEnabled:Bool, setButtonText buttonText:String = "")
    {
       dispatch_async(dispatch_get_main_queue()) {
            var controlState:UIControlState
            if (isEnabled){
                controlState = UIControlState.Normal;
            } else {
                controlState = UIControlState.Disabled;
            }
            self.playbackButton.enabled = isEnabled
            self.playbackButton.userInteractionEnabled = isEnabled
            if (!buttonText.isEmpty )
            {
                self.playbackButton.setTitle(buttonText, forState: controlState)
            }
        }
    }
    
    func importFile(newURL:NSURL){
        fileDownloader!.setUrlWithUrl(newURL)
        fileDownloader!.beginDownload()
        enablePlayback(false,setButtonText: "Downloading...")
    }
}

