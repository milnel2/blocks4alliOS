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
    
    @IBOutlet weak var increaseButton: UIButton!
    
    @IBOutlet weak var decreaseButton: UIButton!
    
    override func viewDidLoad() {
        // default times to repeat: 2 or preserve last selection
        let previousRepsString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["timesToRepeat"] ?? "2"
        let previousReps = Int(previousRepsString)
        timesToRepeatLabel.text = "\(previousReps ?? 2)"
        
        // preserve previously selected value
        timesToRepeat = previousReps!
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        if (timesToRepeat < 20) {
            // prevents users from repeating more than 20 times (Blockly limit)
            timesToRepeat = timesToRepeat + 1
            timesToRepeatLabel.text = "\(timesToRepeat)"
            updateAccessibilityLabel()
        }
    }
    @IBAction func minusButtonPressed(_ sender: Any) {
        if (timesToRepeat > 2) {
            // prevents users from entering 1, 0 or negative times to repeat
            timesToRepeat = timesToRepeat - 1
        }
        timesToRepeatLabel.text = "\(timesToRepeat)"
        updateAccessibilityLabel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["timesToRepeat"] = "\(timesToRepeat)"
        }
    }
    
    func updateAccessibilityLabel() {
        increaseButton.accessibilityLabel = "Increase. Current value: \(timesToRepeat)"
        decreaseButton.accessibilityLabel = "Decrease. Current value: \(timesToRepeat)"
    }
}
