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
    var speed: Double = 10
    var modifierBlockIndexSender: Int?
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        distance = Double(sender.value)
        blocksStack[modifierBlockIndexSender!].addedBlocks[0].addAttributes(key: "distance", value: "\(Int(distance))")
    }
    @IBAction func speedSliderChanged(_ sender: UISlider) {
        speed = Double(sender.value)
        blocksStack[modifierBlockIndexSender!].addedBlocks[0].addAttributes(key: "speed", value: "\(Int(speed))")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destinationViewController = segue.destination as? BlocksViewController{
            destinationViewController.distanceChanged = distance
            destinationViewController.speedChanged = speed
            destinationViewController.modifierBlockIndex = modifierBlockIndexSender
            
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["distance"] = "\(Int(distance))"
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = "\(Int(speed))"
            
            // MARK 06/18/2019 -- added loadSave()
            loadSave()
        }
    }
    
}
