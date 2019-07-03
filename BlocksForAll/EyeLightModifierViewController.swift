//
//  EyeLightModifierViewController.swift
//  BlocksForAll
//
//  Created by Katie McCarthy on 6/24/19.
//  Copyright © 2019 Katie McCarthy. All rights reserved.
//

import Foundation
import UIKit

class EyeLightModifierViewController: UIViewController{
    
    @IBOutlet weak var lightLabel: UILabel!
    var modifierBlockIndexSender: Int?
    var eyeLightStatus: String = "On"
    
    override func viewDidLoad() {
        // default status: On or preserve last selection
        var previousSelection: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] ?? "Off"
        
        lightLabel.text = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] ?? "Off"
        
        eyeLightStatus = previousSelection
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        eyeLightStatus = "On"
        lightLabel.text = "On"
    }
    
    @IBAction func offButtonPressed(_ sender: Any) {
        eyeLightStatus = "Off"
        lightLabel.text = "Off"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] = "\(eyeLightStatus)"
        }
    }
}

