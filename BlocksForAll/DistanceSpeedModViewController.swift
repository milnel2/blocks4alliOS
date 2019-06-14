//
//  DistanceSpeedModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/12/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class DistanceSpeedModViewController: UIViewController{
    /* View controller for the Distance and Speed modifier scene */
    
    //TODO: update these based on Dash API
    var distance: Double = 30
    var speed: Double = 10
    var modifierBlockSender: Block?
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        distance = Double(sender.value)
    }
    @IBAction func speedSliderChanged(_ sender: UISlider) {
        speed = Double(sender.value)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destinationViewController = segue.destination as? BlocksViewController{
            
            destinationViewController.distanceChanged = distance
            destinationViewController.speedChanged = speed
            
            destinationViewController.modifierBlock = modifierBlockSender
            destinationViewController.distanceDisplay(modifierBlockSender!, setTo: "Distance: \(Int(distance)), Speed: \(Int(speed))")
        }
    }
    
}
