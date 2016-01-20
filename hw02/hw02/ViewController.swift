//
//  ViewController.swift
//  hw02
//
//  Created by Jeff Fermon on 1/18/16.
//  Copyright © 2016 Jeff Fermon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
//MARK: members
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    @IBOutlet var playbackButton: UIButton!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var loadFileButton: UIButton!
    
    
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
        
    }

    //method to kick off file playback
    @IBAction func beginPlayback(sender: UIButton) {
        
    }

}

