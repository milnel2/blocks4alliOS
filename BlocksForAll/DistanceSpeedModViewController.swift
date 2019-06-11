//
//  DistanceSpeedModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/11/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class DistanceSpeedModViewController: UIViewController{
    /* View controller for the Distance and Speed modifier scene */
    
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var speedSlider: UISlider!
    
    // TODO: change these numbers based on Dash API
    var distance: Double = 10 // RobotViewController.swift: 30
    var speed: Double = 10
    
    @IBAction func distanceChanged(_ sender: UISlider) {
        distance = Double(sender.value)
    }
    
    @IBAction func speedChanged(_ sender: UISlider) {
        speed = Double(sender.value)
    }
}
