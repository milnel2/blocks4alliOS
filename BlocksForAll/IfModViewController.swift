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
    
    @IBOutlet weak var voiceButton: UIButton!
    @IBOutlet weak var senseButton: UIButton!
    
    func deselectAll(){
        voiceButton.layer.borderWidth = 0
        senseButton.layer.borderWidth = 0
    }
    
    @IBAction func hearVoiceBoolean(_ sender: Any) {
        booleanSelected = "hear_voice"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func senseObstacleBoolean(_ sender: Any) {
        booleanSelected = "obstacle_sensed"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
    blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["booleanSelected"] = booleanSelected
        }
    }
    
}
