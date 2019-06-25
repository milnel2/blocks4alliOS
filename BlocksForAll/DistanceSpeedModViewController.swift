//
//  DistanceSpeedModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/18/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class DistanceSpeedModViewController: UIViewController{
    /* View controller for the Distance and Speed modifier scene */
    
    //TODO: update these based on Dash API
    var distance: Double = 30
    var speed: String = "Normal"
    var modifierBlockIndexSender: Int?
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    
    override func viewDidLoad() {
        // default speed: Normal or preserve last selection
        speedLabel.text = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
    }
    
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        distance = Double(sender.value)
        sender.accessibilityValue = "\(Int(distance)) centimeters"
    }

    @IBAction func slowButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Fastest":
            speed = "Fast"
            speedLabel.text = speed
        case "Fast":
            speed = "Normal"
            speedLabel.text = speed
        case "Normal":
            speed = "Slow"
            speedLabel.text = speed
        case "Slow":
            speed = "Slowest"
            speedLabel.text = speed
        default:
            print("can't be slowed")
        }
    }
    
    @IBAction func fastButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Slowest":
            speed = "Slow"
            speedLabel.text = speed
        case "Slow":
            speed = "Normal"
            speedLabel.text = speed
        case "Normal":
            speed = "Fast"
            speedLabel.text = speed
        case "Fast":
            speed = "Fastest"
            speedLabel.text = speed
        default:
            print("can't make faster")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["distance"] = "\(Int(distance))"
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
    }
}
