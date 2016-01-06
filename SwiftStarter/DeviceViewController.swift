//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Stephen Schiffli on 10/20/15.
//  Copyright © 2015 MbientLab Inc. All rights reserved.
//

import UIKit

class DeviceViewController: UITableViewController {
    
    @IBOutlet weak var connectionState: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    
    var device: MBLMetaWear!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.New, context: nil)
        device.connectWithHandler { (error: NSError?) -> Void in
            NSLog("We are connected")
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        device.removeObserver(self, forKeyPath: "state")
        device.disconnectWithHandler(nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        deviceName.text = device.name;
        switch (device.state) {
        case .Connected:
            connectionState.text = "Connected";
        case .Connecting:
            connectionState.text = "Connecting";
        case .Disconnected:
            connectionState.text = "Disconnected";
        case .Disconnecting:
            connectionState.text = "Disconnecting";
        case .Discovery:
            connectionState.text = "Discovery";
        }
    }
}
