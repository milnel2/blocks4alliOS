//
//  RepeatModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/20/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class RepeatModViewController: UIViewController{
    /* Custom view controller for the Repeat modifier scene */
    
    var modifierBlockIndexSender: Int?
    var timesToRepeat: Int = 2
    
    @IBOutlet weak var timesToRepeatLabel: UILabel!
    
    override func viewDidLoad() {
        // default times to repeat: 2 or preserve last selection
        var previousRepsString: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["timesToRepeat"] ?? "2"
        var previousReps = Int(previousRepsString)
        timesToRepeatLabel.text = "\(previousReps ?? 2)"
        
        // preserve previously selected value
        timesToRepeat = previousReps!
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        if (timesToRepeat < 20) {
            // prevents users from repeating more than 20 times (Blockly limit)
            timesToRepeat = timesToRepeat + 1
            timesToRepeatLabel.text = "\(timesToRepeat)"
        }
    }
    @IBAction func minusButtonPressed(_ sender: Any) {
        if (timesToRepeat > 2) {
            // prevents users from entering 1, 0 or negative times to repeat
            timesToRepeat = timesToRepeat - 1
        }
        timesToRepeatLabel.text = "\(timesToRepeat)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["timesToRepeat"] = "\(timesToRepeat)"
        }
    }
    
}
