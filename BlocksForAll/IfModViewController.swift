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
    }
    
    @IBAction func senseObstacleBoolean(_ sender: Any) {
        booleanSelected = "obstacle_sensed"
    }
    
    
}
