//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Brian House on 1/5/16.
//  Copyright © 2016 Brian House. All rights reserved.
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
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var accelerometerGraph: APLGraphView!    // implicitly imported via Bridging-Header.h
    
    var device: MBLMetaWear!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.device.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.New, context: nil)
        self.device.connectWithHandler { (error: NSError?) -> Void in
            self.deviceConnected();
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        device.removeObserver(self, forKeyPath: "state")
        device.disconnectWithHandler(nil)
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath != nil {
            NSLog("KeyPath: " + keyPath!);
        }
        self.deviceName.text = device.name;
        switch (device.state) {
            case .Connected:
                self.connectionState.text = "Connected";
            case .Connecting:
                self.connectionState.text = "Connecting";
            case .Disconnected:
                self.connectionState.text = "Disconnected";
            case .Disconnecting:
                self.connectionState.text = "Disconnecting";
            case .Discovery:
                self.connectionState.text = "Discovery";
        }
        // do something if disconnected?
    }
    
    func deviceConnected() {
        NSLog("deviceConnected");
        self.connectionState.text = "Connected";
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
        self.device.mechanicalSwitch?.switchValue.readAsync().success({ (obj:AnyObject?) in
            if let result = obj as? MBLNumericData {
                if result.value.boolValue {
                    self.switchLabel.text = "ON";
                } else {
                    self.switchLabel.text = "OFF";
                }
            }
        });        

        // set up handlers
        self.device.mechanicalSwitch?.switchUpdateEvent.startNotificationsWithHandlerAsync(mechanicalSwitchUpdate);

        
        // https://github.com/mbientlab/Metawear-iOSAPI/blob/master/MetaWear.framework/Versions/A/Headers/MBLEvent.h
    
        self.device.mechanicalSwitch!.switchUpdateEvent.programCommandsToRunOnEventAsync({
//            NSLog("switchUpdateEvent"); // shows up on connect
            // note: seems like the device needs to be reset to re-program commands
            

            // doesnt work -- maybe async commands cant be run? then how to determine switch state?
//            self.device.mechanicalSwitch?.switchValue.readAsync().success({ (obj:AnyObject?) in
//                NSLog("--> read switch value");
//                if let result = obj as? MBLNumericData {
//                    NSLog("--> result: " + result.value.stringValue);
//                }
//                
//            });

            // nothing. but this worked before!!
            self.device.led?.flashLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0, numberOfFlashes: 1);

//             so did this! not now.
//            self.device.hapticBuzzer!.startHapticWithDutyCycleAsync(248, pulseWidth: 500, completion: nil);
            
            // self.device.led?.setLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0);
            // self.device.led?.setLEDOnAsync(false, withOptions: 1);
            
            // moving on.
            
        });

        
    }
    
    @IBAction func readBatteryPressed(sender: AnyObject?=nil) {
        NSLog("readBatteryPressed");
        self.device.readBatteryLifeWithHandler({ (number: NSNumber?, error: NSError?) in
            if let n = number {
                self.batteryLevelLabel.text = n.stringValue + "%";
            }
        });
    }
    

    @IBAction func readRSSIPressed(sender: AnyObject?=nil) {
        NSLog("readRSSIPressed");
        self.device.readRSSIWithHandler({ (number: NSNumber?, error: NSError?) in
            if let n = number {
                self.rssiLevelLabel.text = n.stringValue + "";
            }
        });
    }

    @IBAction func flashBlueLEDPressed(sender: AnyObject?=nil) {
        NSLog("flashBlueLEDPressed");
        self.device.led?.flashLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0, numberOfFlashes: 5);
    }

    @IBAction func buzzPressed(sender: AnyObject?=nil) {
        NSLog("buzzPressed");
        self.device.hapticBuzzer!.startHapticWithDutyCycleAsync(248, pulseWidth: 500, completion: nil);
    }

    func mechanicalSwitchUpdate(obj: AnyObject?, error: NSError?) {
        NSLog("mechnicalSwitchUpdate");
        if let result = obj as? MBLNumericData {
            NSLog("Switch: " + result.value.stringValue);
            if result.value.boolValue {
                self.switchLabel.text = "ON";
                self.device.led?.setLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0);
            } else {
                self.switchLabel.text = "OFF";
                self.device.led?.setLEDOnAsync(false, withOptions: 1);
            }
        }
    }
    
    // accelerometer
    // will have to set sample frequency. 60hz is 16.67ms. rats are quick. 1.56ms is ideal, 6.25 is ok.
    // -- what is auto sleep? low noise?
    
    
    @IBAction func startAccelerationPressed(sender: AnyObject?=nil) {
        NSLog("startAccelerationPressed");
        self.device.accelerometer?.dataReadyEvent.startNotificationsWithHandlerAsync({ (obj:AnyObject?, error:NSError?) in
                // what.
        });
        
    }

    @IBAction func stopAccelerationPressed(sender: AnyObject?=nil) {
        NSLog("stopAccelerationPressed");
        //        self.device.accelerometer?.dataReadyEvent.startNotificationsWithHandlerAsync({
        //
        //        });
        
    }
    
}
