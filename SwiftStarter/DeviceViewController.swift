//
//  DeviceViewController.swift
//  SwiftStarter
//
//  Created by Brian House on 1/5/16.
//  Copyright © 2016 Brian House. All rights reserved.
//

import UIKit
import Starscream
import Foundation

class DeviceViewController: UITableViewController, WebSocketDelegate {
    
    @IBOutlet weak var connectionState: UILabel!
    @IBOutlet weak var serverState: UILabel!
//    @IBOutlet weak var deviceName: UILabel!
//    @IBOutlet weak var deviceID: UILabel!
//    @IBOutlet weak var mfgNameLabel: UILabel!
    @IBOutlet weak var serialNumLabel: UILabel!
//    @IBOutlet weak var hwRevLabel: UILabel!
    @IBOutlet weak var fwRevLabel: UILabel!
//    @IBOutlet weak var modelNumberLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var rssiLevelLabel: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var accelerometerGraph: APLGraphView!    // implicitly imported via Bridging-Header.h
    @IBOutlet weak var startAccelerometer: UIButton!
    @IBOutlet weak var stopAccelerometer: UIButton!
    
    
    var device: MBLMetaWear!
    var socket: WebSocket!
    var socket_id: String? = nil
    
    var accelerometerDataArray: [MBLAccelerometerData] = [];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.socket = WebSocket(url: NSURL(string: "ws://granu.local:5280/websocket")!)
        self.socket.delegate = self
    }
    
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
//        self.deviceName.text = device.name;
        switch (device.state) {
            case .Connected:
                NSLog("State: connected");
                self.connectionState.text = "Connected";
            case .Connecting:
                NSLog("State: connecting");
                self.connectionState.text = "Connecting";
            case .Disconnected:
                NSLog("State: disconnected");
                self.connectionState.text = "Disconnected";
            case .Disconnecting:
                NSLog("State: disconnecting");
                self.connectionState.text = "Disconnecting";
            case .Discovery:
                NSLog("State: discovery");
                self.connectionState.text = "Discovery";
        }
        // do something if disconnected?
    }
    
    func deviceConnected() {
        NSLog("deviceConnected");
        self.connectionState.text = "Connected";
//        self.deviceID.text = self.device.identifier.UUIDString;
        if let deviceInfo = self.device.deviceInfo {
//            self.mfgNameLabel.text = deviceInfo.manufacturerName;
            self.serialNumLabel.text = deviceInfo.serialNumber;
//            self.hwRevLabel.text = deviceInfo.hardwareRevision;
            self.fwRevLabel.text = deviceInfo.firmwareRevision;
//            self.modelNumberLabel.text = deviceInfo.modelNumber;
        }
        self.readBatteryPressed();
        self.readRSSIPressed();
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("readBatteryPressed:"), userInfo: nil, repeats: true) // note the colon
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("readRSSIPressed:"), userInfo: nil, repeats: true) // note the colon
        
        
//        self.device.mechanicalSwitch?.switchValue.readAsync().success({ (obj:AnyObject?) in
//            if let result = obj as? MBLNumericData {
//                if result.value.boolValue {
//                    self.switchLabel.text = "ON";
//                } else {
//                    self.switchLabel.text = "OFF";
//                }
//            }
//        });

        // update settings
        self.updateAccelerometerSettings();
        
        // set up handlers
//        self.device.mechanicalSwitch?.switchUpdateEvent.startNotificationsWithHandlerAsync(mechanicalSwitchUpdate);

        
        // https://github.com/mbientlab/Metawear-iOSAPI/blob/master/MetaWear.framework/Versions/A/Headers/MBLEvent.h
    
//        self.device.mechanicalSwitch!.switchUpdateEvent.programCommandsToRunOnEventAsync({
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
//            self.device.led?.flashLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0, numberOfFlashes: 1);

//             so did this! not now.
//            self.device.hapticBuzzer!.startHapticWithDutyCycleAsync(248, pulseWidth: 500, completion: nil);
            
            // self.device.led?.setLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0);
            // self.device.led?.setLEDOnAsync(false, withOptions: 1);
            
            // moving on.
            
//        });

        // connect to server
        NSLog("Connecting to socket...")
        self.socket.connect()
        
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
//        NSLog("mechnicalSwitchUpdate");
//        if let result = obj as? MBLNumericData {
//            NSLog("Switch: " + result.value.stringValue);
//            if result.value.boolValue {
//                self.switchLabel.text = "ON";
//                self.device.led?.setLEDColorAsync(UIColor.blueColor(), withIntensity: 1.0);
//            } else {
//                self.switchLabel.text = "OFF";
//                self.device.led?.setLEDOnAsync(false, withOptions: 1);
//            }
//        }
    }
    
    // accelerometer
    // will have to set sample frequency. 60hz is 16.67ms. rats are quick. 1.56ms is ideal, 6.25 is ok.
    // -- what is auto sleep? low noise?
    func updateAccelerometerSettings() {
        NSLog("updateAccelerometerSettings");

        self.accelerometerGraph.fullScale = 2;
        
        let MMA8452Q = self.device.accelerometer as! MBLAccelerometerMMA8452Q;
        MMA8452Q.sampleFrequency = 100;
        MMA8452Q.fullScaleRange = MBLAccelerometerRange.Range2G;
        MMA8452Q.highPassFilter = true;
        MMA8452Q.highPassCutoffFreq = MBLAccelerometerCutoffFreq.Higheset;
        MMA8452Q.lowNoise = false;
        
//        MMA8452Q.autoSleep = false;
//        MMA8452Q.sleepPowerScheme = MBLAccelerometerPowerScheme.Normal;
//        MMA8452Q.sleepSampleFrequency = MBLAccelerometerSleepSampleFrequency.Frequency50Hz;

        NSLog("--> done")
    }
    
    
    @IBAction func startAccelerationPressed(sender: AnyObject?=nil) {
        NSLog("startAccelerationPressed");
        self.startAccelerometer.enabled = false;
        self.stopAccelerometer.enabled = true;
        self.device.accelerometer?.dataReadyEvent.startNotificationsWithHandlerAsync({ (obj:AnyObject?, error:NSError?) in
            if let acceleration = obj as? MBLAccelerometerData {
//                NSLog(String(acceleration.x) + "," + String(acceleration.y) + "," + String(acceleration.z) + " " + String(acceleration.RMS));
//                self.accelerometerGraph.addX(Double(acceleration.x), y: Double(acceleration.y), z: Double(acceleration.z))
                self.accelerometerGraph.addX(Double(acceleration.RMS), y: 0.0, z: 0.0);
                self.accelerometerDataArray.append(acceleration);
                if Double(self.accelerometerDataArray.count) / Double(self.device.accelerometer!.sampleFrequency) > 5 {   // send every 5 seconds
                    self.sendData();
                    self.accelerometerDataArray = [];
                }
            }
        });
    }

    @IBAction func stopAccelerationPressed(sender: AnyObject?=nil) {
        NSLog("stopAccelerationPressed");
        self.startAccelerometer.enabled = true;
        self.stopAccelerometer.enabled = false;
        self.device.accelerometer?.dataReadyEvent.stopNotificationsAsync();
    }
    
    func sendData(sender: AnyObject?=nil) {
        NSLog("sendData");
        
        // create a temp file
        // let firstEntry = self.accelerometerDataArray[0];
        // let filename = String(firstEntry.timestamp.timeIntervalSince1970).stringByReplacingOccurrencesOfString(".", withString: "-") + ".csv";
        // let fileURL = NSURL.fileURLWithPath(NSTemporaryDirectory()).URLByAppendingPathComponent(filename);
        // NSLog("--> " + fileURL.path!);
        
        // assemble data
        var data: [String] = [];
        for element in self.accelerometerDataArray {
            data.append(String(format: "%f,%f,%f,%f,%f", element.timestamp.timeIntervalSince1970, element.x, element.y, element.z, element.RMS));
        }
        let postString = data.joinWithSeparator("\n");
        
        let request = NSMutableURLRequest(URL: NSURL(string: "http://granu.local:5280")!);
        request.HTTPMethod = "POST"
//        let postString = "id=13&name=Jack"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil && data != nil else { // check for fundamental networking error
                NSLog("error=\(error)");
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                NSLog("statusCode should be 200, but is \(httpStatus.statusCode)")
                NSLog("response = \(response)");
            }
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding);
            NSLog("responseString = \(responseString)");
        }
        task.resume();
        NSLog("--> sent");
    }
    
    func websocketDidConnect(socket: WebSocket) {
        NSLog("websocketDidConnect")
        self.serverState.text = "Contacted";
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        NSLog("websocketDidDisconnect: \(error?.localizedDescription)")
        self.serverState.text = "Disconnected";
        self.delay(5.0) {
            self.socket.connect();
            self.serverState.text = "Connecting";
        }
        NSLog("--> disconnect done")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        NSLog("websocketDidReceiveMessage: \(text)")
        
        var data: [String: AnyObject]? = nil;
        do {
            data = try NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding)!, options: .MutableLeaves) as? [String: AnyObject] // how do I do no options? nil fails
        } catch {
            NSLog("--> error serializing JSON: \(error)")
        }
        NSLog("--> received data")
        
        if data != nil {
            for (key, value) in data! {
                NSLog("\(key): \(value)");
                
                // handshake sequence
                if key == "socket_id" {
                    self.socket_id = value as? String;
                    // send the deviceID back
                    self.socket.writeString("{\"device_id\": \"\(self.device.deviceInfo!.serialNumber)\"}");
                }
                if key == "linked" {
                    if value as? Bool == true {
                        NSLog("--> link established")
                        self.serverState.text = "Connected";
                    } else {
                        NSLog("--> link failed")
                        self.serverState.text = "Failed";
                    }
                }
                
            }
        }
        
    }

    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        NSLog("websocketDidReceiveData: \(data.length)")
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}
