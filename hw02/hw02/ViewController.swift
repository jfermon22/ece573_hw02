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
    @IBOutlet var loadFileButton: UIButton!
    
    var fileDownloader:FileDownloader?
    
    
//MARK: methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //method to handle load of file from web
    @IBAction func loadFile(sender: UIButton) {
        print("attempting to load file " + addressField.text!)
        fileDownloader = FileDownloader(newUrl: addressField.text!);
        fileDownloader!.delegate = self
        fileDownloader!.beginDownload()
    }

    //method to kick off file playback
    @IBAction func beginPlayback(sender: UIButton) {
        
    }
    
    func updateLabels(xValue:NSNumber, yValue:NSNumber, zValue:NSNumber ) {
        xLabel.text = "\(xValue)"
        yLabel.text = "\(yValue)"
        zLabel.text = "\(zValue)"
    }
    
    func downloadSuccessful(filepath:String){
        print("downloadSuccessful:" + filepath)
        fileDownloader = nil
    }
    
    func downloadFailed(error:NSError){
         print("downloadFailed:" + error.localizedDescription)
         fileDownloader = nil
    }
    
}

