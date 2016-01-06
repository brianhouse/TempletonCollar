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
    @IBOutlet weak var deviceID: UILabel!
    @IBOutlet weak var mfgNameLabel: UILabel!
    @IBOutlet weak var serialNumLabel: UILabel!
    @IBOutlet weak var hwRevLabel: UILabel!
    @IBOutlet weak var fwRevLabel: UILabel!
    @IBOutlet weak var modelNumberLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var rssiLevelLabel: UILabel!
    
    var device: MBLMetaWear!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.New, context: nil)
        device.connectWithHandler { (error: NSError?) -> Void in
            self.deviceConnected()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        device.removeObserver(self, forKeyPath: "state")
        device.disconnectWithHandler(nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.deviceName.text = device.name;
        switch (device.state) {
            case .Connected:
                connectionState.text = "Connected"; // dont update this here, I guess
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
    
    func deviceConnected() {
        NSLog("deviceConnected");
        
        NSLog("ID: " + self.device.identifier.UUIDString);
        self.deviceID.text = self.device.identifier.UUIDString;
        
        if let deviceInfo = self.device.deviceInfo {
            self.mfgNameLabel.text = deviceInfo.manufacturerName;
            self.serialNumLabel.text = deviceInfo.serialNumber;
            self.hwRevLabel.text = deviceInfo.hardwareRevision;
            self.fwRevLabel.text = deviceInfo.firmwareRevision;
            self.modelNumberLabel.text = deviceInfo.modelNumber;
        }
        self.readBatteryPressed();
        self.readRSSIPressed();
        
    }
    
    @IBAction func readBatteryPressed(sender: AnyObject?=nil) {
        NSLog("readBatteryPressed");
        self.device.readBatteryLifeWithHandler({ (number: NSNumber?, error: NSError?) -> Void in
            if let n = number {
                self.batteryLevelLabel.text = n.stringValue + "%";
            }
        });
    }
    

    @IBAction func readRSSIPressed(sender: AnyObject?=nil) {
        NSLog("readRSSIPressed");
        self.device.readRSSIWithHandler({ (number: NSNumber?, error: NSError?) -> Void in
            if let n = number {
                self.rssiLevelLabel.text = n.stringValue + "";
            }
        });
    }
    
}
