//
//  IfModViewController.swift
//  BlocksForAll
//
//  Created by Nana Adwoa Odeibea Amoah on 7/4/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

class IfModViewController: UIViewController{
    /* Custom view controller for the Repeat modifier scene */
    
    var modifierBlockIndexSender: Int?
    var booleanSelected: String = "hear_voice"
    
    
    @IBAction func hearVoiceBoolean(_ sender: Any) {
        booleanSelected = "hear_voice"
        
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                button.isSelected = true
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    
    @IBAction func obstacleSensed(_ sender: Any) {
        booleanSelected = "obstacle_sensed"
        
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                button.isSelected = true
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["booleanSelected"] = booleanSelected
            
        }
    }
    
}
