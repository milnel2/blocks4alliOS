//
//  RobotTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 4/19/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

// Core Bluetooth functionality based on https://www.maissan.net/articles/dash-and-dot/4 and https://github.com/Corepox/morseapi/blob/master/drive.py

import UIKit
import CoreBluetooth
//UNCOMMENT AND CHANGE BRIDGING HEADER FILE TO DISABLE ROBOT AND USE SIMULATOR
/*
 class RobotTableViewController: UITableViewController {
 
 }*/



var robots = [Robot]()
var dotRobotIsConnected = false
var connectedRobots = [Robot]()

let dashServiceUUID = CBUUID(string: "af237777-879d-6186-1f49-deca0e85d9c1")
let dashCharacteristicUUID = CBUUID(string: "af230002-879d-6186-1f49-deca0e85d9c1")
let dashSensorUUID1 = CBUUID(string: "af230006-879d-6186-1f49-deca0e85d9c1")
let dashSensorUUID2 = CBUUID(string: "af230003-879d-6186-1f49-deca0e85d9c1")
let dashInfoUUID = CBUUID(string: "af230001-879d-6186-1f49-deca0e85d9c1")
let dotSensorUUID = CBUUID(string: "af230003-879d-6186-1f49-deca0e85d9c1")

var dashCharacteristic:CBCharacteristic? = nil
var dashSensorCharacteristic1:CBCharacteristic? = nil
var dashSensorCharacteristic2:CBCharacteristic? = nil
var dashInfoCharacteristic:CBCharacteristic? = nil

var globalCentralManager: CBCentralManager? = nil // used so that the central manager can be saved between sessions of the table view being open



class RobotTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    /* Shows the available robots to connect to in a tableView on the Add Robots screen*/


    // MARK: Properties
   
    var dashPeripheral: CBPeripheral?
    var localCentralManager: CBCentralManager!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Make table background transparent
               tableView.backgroundColor = UIColor.clear
      
        // set up Central Device to start scanning for robots
        if globalCentralManager == nil {
            localCentralManager = CBCentralManager(delegate: self, queue: nil)
            globalCentralManager = localCentralManager
        } else {
            localCentralManager = globalCentralManager
        }
        print("robots: ", robots)
        if(!robots.isEmpty) {
            print(robots[0])
        }
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
       
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    // MARK: CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            localCentralManager.scanForPeripherals(withServices: [dashServiceUUID], options: nil) //TODO: allow for dot to be connected also
        } else {
            // TODO: Handle Bluetooth not available
            print("Bluetooth not available or permission not given")
        }
    }

    /// Called when a robot is discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var alreadyInList = false
        for robot in robots {
            if (peripheral.identifier ==  robot.peripheral.identifier) {
                // Robot is already in the list
                alreadyInList = true
                print("Already in list")
            }
        }

        // if the robot isn't already in the list, add it to the list of robots
        if (!alreadyInList) {
            let newRobot = Robot(peripheral: peripheral)
            robots.append(newRobot)
        }
        
        // Reload table
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
       // TODO: add a button to scan for robots? Then we can stop scanning at other times
//        dashPeripheral = peripheral
//        dashPeripheral?.delegate = self
//        centralManager.stopScan()
//        centralManager.connect(dashPeripheral!)
        
    }
    
    func getRobotFromPeripheral(peripheral: CBPeripheral) -> Robot? {
        for robot in robots {
            if (peripheral.identifier ==  robot.peripheral.identifier) {
                return robot
            }
        }
        print("Error, robot not found")
        return nil
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        // remove disconnected robot from the list of connected robots
        guard let robot = getRobotFromPeripheral(peripheral: peripheral) else { return }
        let index = connectedRobots.firstIndex(of: robot)
        if (index != nil) {
            
            connectedRobots.remove(at: index!)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
       // TODO: handle dot versus dash
       //        // Sets global variable to track if JUST a Dot robot is connected
       //        var connectedRobotTypes = [String]()
       //        for connectedRobot in robots where connectedRobot.isConnected() {
       //            connectedRobotTypes.append(connectedRobot.robotType.description)
       //        }
       //        print("HELLO", connectedRobotTypes)
       //        if connectedRobotTypes.contains("1002") && !connectedRobotTypes.contains("1001") {
       //            dotRobotIsConnected = true
       //        } else {
       //            dotRobotIsConnected = false
       //        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard let newRobot = getRobotFromPeripheral(peripheral: peripheral) else { return }
        connectedRobots.append(newRobot)
        
        peripheral.discoverServices([dashServiceUUID])
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        // TODO: handle dot versus dash
        // Sets global variable to track if JUST a Dot robot is connected
//        var connectedRobotTypes = [String]()
//        for connectedRobot in robots where connectedRobot.state == .connected {
//            connectedRobotTypes.append(connectedRobot.robotType.description)
//        }
//        print("HELLO", connectedRobotTypes)
//        if connectedRobotTypes.contains("1002") && !connectedRobotTypes.contains("1001") {
//            dotRobotIsConnected = true
//        } else {
//            dotRobotIsConnected = false
//        }
        //refreshConnectedRobots()
    }
    
    /// Called when a robot fails to connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("failed to connect to robot: %@, with error: %@", peripheral.name as Any, error as Any)
        
    }

    // MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == dashServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
                return
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
   
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic == dashSensorCharacteristic2 {
            if characteristic.value == nil {
                print("characteristic value is nil")
                return
            }
            
            let dataString = characteristic.value!.hexEncodedString()
            //print("first hex:", dataString)
            var dataList = [Int]()
            //print(Array(dataString))
            
            //let dataList = [int(dataString[i:i + 2], 16) for i in range(0, len(dataString), 2)]
        }
        //print("-----")
        
    }
    
    // TODO: read sensor data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        //print("updated value")
        if characteristic == dashSensorCharacteristic2 {
            //print("sensor changed")
            guard let robot = getRobotFromPeripheral(peripheral: peripheral) else { return }
            let dataString = characteristic.value!.hexEncodedString()
            robot.updateSensorData2(data: dataString)
            
            if characteristic.value == nil {
                print("Sensor 2 characteristic value is nil")
                return
            }
        } else if (characteristic == dashSensorCharacteristic1) {
            guard let robot = getRobotFromPeripheral(peripheral: peripheral) else { return }
            let dataString = characteristic.value!.hexEncodedString()
            robot.updateSensorData1(data: dataString)
            if characteristic.value == nil {
                print("Sensor 1 characteristic value is nil")
                return
            }
        }
       
    }
    
   
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == dashCharacteristicUUID {
                dashCharacteristic = characteristic
                // TODO: remove this, right now it is just for testing to know when a robot is connected
                let sound = "SYSTROBOT_01"
                var data = [UInt8](repeating: 0, count: 1 + sound.count)
                data[0] = 24
                for (i, char) in sound.enumerated() {
                    data[i + 1] = UInt8(char.asciiValue!)
                }
                peripheral.writeValue(Data(data), for: characteristic, type: .withoutResponse)
            } else if characteristic.uuid == dashSensorUUID1 {
                dashSensorCharacteristic1 = characteristic
            } else if characteristic.uuid == dashSensorUUID2 {
                dashSensorCharacteristic2 = characteristic
            } else if characteristic.uuid == dashInfoUUID {
                dashInfoCharacteristic = characteristic
            }
            
        }
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

//    // MARK: Helper Methods
    // TODO: test this function
//    func sendDataToDash(data: Data) {
//        if let dashPeripheral = dashPeripheral {
//            if let characteristic = dashPeripheral.characteristics?.first(where: { $0.uuid == dashCharacteristicUUID }) {
//                dashPeripheral.writeValue(data, for: characteristic, type: .withResponse)
//            }
//        }
//    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return robots.count
    }
    
    /// Sets up robot table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "robotCell", for: indexPath)
        
        // From WW sample code
        let robot = robots[indexPath.row]
        
        //TODO: detect if robot is a dot or a dash
        // Change avatar of robot depending on type of robot
//        if robot.robotType.description == "1002" {  // The robot type of a Dot robot.
//            cell.imageView?.image = UIImage(named: "RobotAvatar_Dot")
//        } else if robot.robotType.description == "1001" {  // The robot type of a Dash robot.
//            cell.imageView?.image = UIImage(named: "RobotAvatar_Dash")
//        } else {
//            cell.imageView?.image = UIImage(named: "Robot_avatar")
//        }
        
        cell.imageView?.image = UIImage(named: "Robot_avatar")
        
        // Default Cell Layout
        cell.textLabel?.text = robot.peripheral.name
        cell.textLabel?.textColor = .white
        cell.textLabel?.textAlignment = .center
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 8
        cell.layer.borderColor = #colorLiteral(red: 0.05098039216, green: 0.07450980392, blue: 0.3294117647, alpha: 1)
        
//        if robot.state == .connecting{
//            UIProgressView()
//        }
        
        //Add highlight to cell when robot is connected
        //TODO: different indicators for connecting and connected
        if(robot.peripheral.state == .connected) {
            print("it's connected still")
            cell.layer.borderWidth = 9
            cell.layer.borderColor = #colorLiteral(red: 1, green: 0.6078431373, blue: 0.2980392157, alpha: 1)
            cell.accessibilityLabel =  (robot.peripheral.name ?? "Unnamed Robot") + "Connected"
        }else {
            cell.accessibilityLabel = "Click to connect to" + (robot.peripheral.name ?? "Unnamed Robot")
        }
       
        return cell
    }
    
    /// Called when a cell in the table is pressed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let robotPeripheral = robots[indexPath.row].peripheral
//        print(robot.state.rawValue)
        // Disconnect for robot if already connected
        if (robotPeripheral.state == .connected || robotPeripheral.state == .connecting) {
            print("already connected")
            localCentralManager.cancelPeripheralConnection(robotPeripheral)
            
        } else {
            // Otherwise, connect to the robot
            dashPeripheral = robotPeripheral
            dashPeripheral?.delegate = self
            localCentralManager.connect(dashPeripheral!)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// Data extension from Martin R. on https://stackoverflow.com/questions/39075043/how-to-convert-data-to-hex-string-in-swift
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}


