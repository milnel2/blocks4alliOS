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
    //default is always false
    var booleanSelected: String = "false"
    
    @IBOutlet weak var voiceButton: UIButton!
    @IBOutlet weak var senseButton: UIButton!
    
    @IBOutlet weak var back: UIButton!
    
    //function to guarantee either voiceButton or senseButton highlighted, never both
    func deselectAll(){
        voiceButton.layer.borderWidth = 0
        senseButton.layer.borderWidth = 0
    }
    
    //if hear voice is selected
    @IBAction func hearVoiceBoolean(_ sender: Any) {
        booleanSelected = "hear_voice"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    //if sense obstacle selected
    @IBAction func senseObstacleBoolean(_ sender: Any) {
        booleanSelected = "obstacle_sensed"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //saves previous selection when re-entering if mod view controller screen 
        let previousBooleanSelected: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["booleanSelected"] ?? "false"
        booleanSelected = previousBooleanSelected
        
        switch booleanSelected{
        case "obstacle_sensed":
            senseButton.layer.borderWidth = 10
            senseButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "hear_voice":
            voiceButton.layer.borderWidth = 10
            voiceButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            senseButton.layer.borderWidth = 0
        }
        
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["booleanSelected"] = booleanSelected
        }
    }
    
}
