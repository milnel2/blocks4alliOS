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
	//MARK: - viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Make table background transparent
        tableView.backgroundColor = UIColor.clear
        
        if(robotManager == nil){
            robotManager = WWRobotManager()
            robotManager?.add(self)

        }
        
        robotManager?.startScanning(forRobots: 2.0)
        if(!robots.isEmpty){
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
        
        let verticalPadding: CGFloat = 6

        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
        
    

        // From WW sample code
        let robot = robots[indexPath.row]
        
        if(robot.isConnected()){
            cell.layer.borderWidth = 10
            cell.layer.borderColor = #colorLiteral(red: 1, green: 0.6078431373, blue: 0.2980392157, alpha: 1)
            cell.accessibilityLabel = "Connected"
            
            
        } else{
            cell.layer.borderWidth = 10
            cell.layer.borderColor = #colorLiteral(red: 0.05098039216, green: 0.07450980392, blue: 0.3294117647, alpha: 1)
            cell.accessibilityLabel = "Disconnected"
            
        }
            
        // Default Cell Layout
        cell.textLabel?.text = robot.name
        cell.textLabel?.textColor = .white
        cell.textLabel?.textAlignment = .center
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
            
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let robot = robots[indexPath.row]
        if(robot.isConnected()){
            robotManager?.disconnect(from: robot)
        }else{
            robotManager?.connect(to: robot)
        }
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
    }
    // MARK: - robot manager
    func manager(_: WWRobotManager, didUpdateDiscoveredRobots: WWRobot){
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func manager(_: WWRobotManager, didLose robot: WWRobot){
        var i  = 0
        for r in robots{
            if(r == robot){
                robots.remove(at: i)
            }
            i += 1
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func manager(_: WWRobotManager, didConnect robot: WWRobot){
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        //refreshConnectedRobots()
    }
    
    func manager(_: WWRobotManager, didFailToConnect robot: WWRobot, error: WWError){
        NSLog("failed to connect to robot: %@, with error: %@", robot.name, error)
    }
    
    func manager(_: WWRobotManager, didDiscover robot: WWRobot){
        if !robots.contains(robot){
            robots.append(robot)
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        print("found a robot")
    }
    
    func manager(_ manager: WWRobotManager!, didDisconnectRobot robot: WWRobot!) {
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }

}
