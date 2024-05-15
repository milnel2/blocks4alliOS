//
//  RobotTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 4/19/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

// Core Bluetooth functionality based on https://www.maissan.net/articles/dash-and-dot/4
// https://github.com/Corepox/morseapi/blob/master/drive.py

import UIKit
import CoreBluetooth
//UNCOMMENT AND CHANGE BRIDGING HEADER FILE TO DISABLE ROBOT AND USE SIMULATOR
/*
 class RobotTableViewController: UITableViewController {
 
 }*/

var robotManager:WWRobotManager? = nil
var robots = [CBPeripheral]()
var dotRobotIsConnected = false


class RobotTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    /* Shows the available robots to connect to in a tableView on the Add Robots screen*/


    // MARK: Properties
    var centralManager: CBCentralManager!
    var dashPeripheral: CBPeripheral?
    let dashServiceUUID = CBUUID(string: "af237777-879d-6186-1f49-deca0e85d9c1")
    let dashCharacteristicUUID = CBUUID(string: "af230002-879d-6186-1f49-deca0e85d9c1")
    let dashSensorUUID = CBUUID(string: "af230006-879d-6186-1f49-deca0e85d9c1")
    let dotSensorUUID = CBUUID(string: "af230003-879d-6186-1f49-deca0e85d9c1")

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make table background transparent
               tableView.backgroundColor = UIColor.clear
      
        // set up Central Device to start scanning for robots
        centralManager = CBCentralManager(delegate: self, queue: nil)
       
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
            centralManager.scanForPeripherals(withServices: [dashServiceUUID], options: nil)
        } else {
            // TODO: Handle Bluetooth not available
            print("Bluetooth not available or permission not given")
        }
    }

    /// Called when a robot is discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var alreadyInList = false
        for robot in robots {
            if (peripheral.identifier ==  robot.identifier) {
                // Robot is already in the list
                alreadyInList = true
                print("Already in list")
            }
        }
        if (!robots.contains(peripheral) && !alreadyInList) {
            robots.append(peripheral)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
       // TODO: add a button to scan for robots? Then we can stop scanning at other times
//        dashPeripheral = peripheral
//        dashPeripheral?.delegate = self
//        centralManager.stopScan()
//        centralManager.connect(dashPeripheral!)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        // refresh robots list
        robots = centralManager.retrieveConnectedPeripherals(withServices: [dashServiceUUID])

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
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
         
            if characteristic.uuid == dashCharacteristicUUID {
                // TODO: remove this, right now it is just for testing to know when a robot is connected
                let sound = "SYSTBIRTHDAY"
                var data = [UInt8](repeating: 0, count: 1 + sound.count)
                data[0] = 24
                for (i, char) in sound.enumerated() {
                    data[i + 1] = UInt8(char.asciiValue!)
                }
                peripheral.writeValue(Data(data), for: characteristic, type: .withoutResponse)
                return
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
        cell.textLabel?.text = robot.name
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
        if(robot.state == .connected) {
            print("it's connected still")
            cell.layer.borderWidth = 9
            cell.layer.borderColor = #colorLiteral(red: 1, green: 0.6078431373, blue: 0.2980392157, alpha: 1)
            cell.accessibilityLabel =  (robot.name ?? "Unnamed Robot") + "Connected"
        }else {
            cell.accessibilityLabel = "Click to connect to" + (robot.name ?? "Unnamed Robot")
        }
       
        return cell
    }
    
    /// Called when a cell in the table is pressed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let robot = robots[indexPath.row]
        print(robot.state.rawValue)
        // Disconnect for robot if already connected
        if (robot.state == .connected || robot.state == .connecting) {
            print("already connected")
            centralManager.cancelPeripheralConnection(robot)
            
        } else {
            // Otherwise, connect to the robot
            dashPeripheral = robot
            dashPeripheral?.delegate = self
            centralManager.connect(dashPeripheral!)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
