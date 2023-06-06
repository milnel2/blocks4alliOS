//
//  EyeLightModifierViewController.swift
//  BlocksForAll
//
//  Created by Katie McCarthy on 6/24/19.
//  Copyright © 2019 Katie McCarthy. All rights reserved.
//

import Foundation
import UIKit

//this class switches eyelight off and on at this screen
class EyeLightModifierViewController: UIViewController{
    
    
    
    @IBOutlet weak var lightLabel: UILabel!
    var modifierBlockIndexSender: Int?
    var eyeLightStatus: String = "On"
    
    @IBOutlet weak var back: UIButton!
    
    override func viewDidLoad() {
        // default status: On or preserve last selection
        let previousSelection: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] ?? "Off"
        
        lightLabel.text = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] ?? "Off"
        
        eyeLightStatus = previousSelection
        
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    //changes status and label on screen
    @IBAction func onButtonPressed(_ sender: UIButton) {
        eyeLightStatus = "On"
        lightLabel.text = "On"
        lightLabel.accessibilityLabel = "On"
        sender.layer.borderWidth = 10
        
    }
    
    //changes status and label on screen
    @IBAction func offButtonPressed(_ sender: Any) {
        eyeLightStatus = "Off"
        lightLabel.text = "Off"
        lightLabel.accessibilityLabel = "Off"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] = "\(eyeLightStatus)"
        }
    }
}

