//
//  AddRobotViewController.swift
//  BlocksForAll
//
//  Created by lmilne on 7/11/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import UIKit

class AddRobotViewController: UIViewController {
    var sentFrom: addRobotSenderType = addRobotSenderType.NOT_SET
    
    //public var robotTableVC: RobotTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
//        while robotTableVC.isConnecting {
//            print("waiting to connect")
//        }
        switch sentFrom {
        case .Workspace:
            performSegue(withIdentifier: "robotMenuToWorkspace", sender: self)
        case .Settings:
            performSegue(withIdentifier: "robotMenuToSettings", sender: self)
        case .Xylophone:
            performSegue(withIdentifier: "addRobotToCalibrate", sender: self)
        default:
            print("ERROR: addRobotSenderType not set")
        }
       
        // reset sentFrom
        sentFrom = .NOT_SET
    }
    
}

// View Controllers that could cause the AddRobotViewController to open
enum addRobotSenderType {
    case NOT_SET
    case Workspace
    case Settings
    case Xylophone
}
