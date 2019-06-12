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
    
    //TODO: change these based on Dash API
    var distance: Double = 30
    var speed: Double = 10
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBAction func distanceChanged(_ sender: UISlider) {
        distance = Double(sender.value)
        print(distance)
    }
    @IBAction func speedChanged(_ sender: UISlider) {
        speed = Double(sender.value)
        print(speed)
    }
}
