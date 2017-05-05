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

class RobotTableViewController: UITableViewController, WWRobotManagerObserver {
    var robots = [WWRobot]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if(robotManager == nil){
            robotManager = WWRobotManager()
            robotManager?.add(self)
        }
        
        robotManager?.startScanning(forRobots: 2.0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
        // #warning Incomplete implementation, return the number of rows
        return robots.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "robotCell", for: indexPath)

        // From WW sample code
        let robot = robots[indexPath.row]
        if(robot.isConnected()){
            cell.backgroundColor = UIColor.green
            cell.contentView.backgroundColor = UIColor.green
        }else{
            cell.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = UIColor.white
        }
        cell.textLabel?.text = robot.name
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let robot = robots[indexPath.row]
        if(robot.isConnected()){
            robotManager?.disconnect(from: robot)
        }else{
            robotManager?.connect(to: robot)
        }
        
    }
    // MARK: - robot manager
    func manager(_: WWRobotManager, didUpdateDiscoveredRobots: WWRobot){
        self.tableView.reloadData()
    }
    
    func manager(_: WWRobotManager, didLose robot: WWRobot){
        var i  = 0
        for r in robots{
            if(r == robot){
                robots.remove(at: i)
            }
            i += 1
        }
        self.tableView.reloadData()
    }
    
    func manager(_: WWRobotManager, didConnect robot: WWRobot){
        self.tableView.reloadData()
        //refreshConnectedRobots()
    }
    
    func manager(_: WWRobotManager, didFailToConnect robot: WWRobot, error: WWError){
        NSLog("failed to connect to robot: %@, with error: %@", robot.name, error)
    }
    
    func manager(_: WWRobotManager, didDiscover robot: WWRobot){
        if !robots.contains(robot){
            robots.append(robot)
        }
        self.tableView.reloadData()
        print("found a robot")
    }
    

}
