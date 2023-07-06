//
//  RobotTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 4/19/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
//UNCOMMENT AND CHANGE BRIDGING HEADER FILE TO DISABLE ROBOT AND USE SIMULATOR
/*
 class RobotTableViewController: UITableViewController {
 
 }*/

var robotManager:WWRobotManager? = nil
var robots = [WWRobot]()

class RobotTableViewController: UITableViewController, WWRobotManagerObserver {
    /* Shows the available robots to connect to in a tableView on the Add Robots screen*/
    //MARK: - viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Make table background transparent
        tableView.backgroundColor = UIColor.clear
        
        if(robotManager == nil) {
            robotManager = WWRobotManager()
            robotManager?.add(self)
        }
        
        robotManager?.startScanning(forRobots: 2.0)
        if(!robots.isEmpty) {
            print(robots[0])
        }
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return robots.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "robotCell", for: indexPath)
        
        // Spacing between each cell
        let verticalPadding: CGFloat = 6
        
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding / 2)
        cell.layer.mask = maskLayer
        
        // From WW sample code
        let robot = robots[indexPath.row]
        
        // Change avatar of robot depending on type of robot
        if robot.name == "Dot" {
            cell.imageView?.image = UIImage(named: "RobotAvatar_Dot")
        } else if robot.name == "Dash" || robot.name == "Coby" {
            cell.imageView?.image = UIImage(named: "RobotAvatar_Dash")
        } else {
            cell.imageView?.image = UIImage(named: "Robot_avatar")
        }
        
        // Default Cell Layout
        cell.textLabel?.text = robot.name
        cell.textLabel?.textColor = .white
        cell.textLabel?.textAlignment = .center
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.layer.borderWidth = 8
        cell.layer.borderColor = #colorLiteral(red: 0.05098039216, green: 0.07450980392, blue: 0.3294117647, alpha: 1)
        
        // Add highlight to cell when robot is connected
        if(robot.isConnected()) {
            cell.layer.borderWidth = 8
            cell.layer.borderColor = #colorLiteral(red: 1, green: 0.6078431373, blue: 0.2980392157, alpha: 1)
            cell.accessibilityLabel = "Robot Connected"
        } else {
            cell.accessibilityLabel = "Click to connect Robot"
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
       
        return cell
    }
    
    /// Called when a cell in the table is pressed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let robot = robots[indexPath.row]
        // Disconnect for robot if already connected
        if (robot.isConnected()) {
            robotManager?.disconnect(from: robot)
            self.tableView.reloadData()
        } else {
            // Otherwise, connect to the robot
            robotManager?.connect(to: robot)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // MARK: - robot manager
    func manager(_: WWRobotManager, didUpdateDiscoveredRobots: WWRobot) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func manager(_: WWRobotManager, didLose robot: WWRobot) {
        var i  = 0
        for r in robots {
            if(r == robot) {
                robots.remove(at: i)
            }
            i += 1
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// Called when a robot is connected
    func manager(_: WWRobotManager, didConnect robot: WWRobot) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        //refreshConnectedRobots()
    }
    
    /// Called when a robot fails to connect
    func manager(_: WWRobotManager, didFailToConnect robot: WWRobot, error: WWError) {
        NSLog("failed to connect to robot: %@, with error: %@", robot.name, error)
    }
    
    /// Called when a robot is discovered
    func manager(_: WWRobotManager, didDiscover robot: WWRobot) {
        if !robots.contains(robot) {
            robots.append(robot)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("found a robot")
    }
    
    /// Called when a robot is disconnected
    func manager(_ manager: WWRobotManager!, didDisconnectRobot robot: WWRobot!) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
