//
//  WaitModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/21/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class WaitModViewController: UIViewController{
    /* Custom view controller for the Wait modifier scene */
    
    var modifierBlockIndexSender: Int?
    var wait: Int = 1
    
    @IBOutlet weak var waitLabel: UILabel!
    
    @IBOutlet weak var increaseButton: UIButton!
    
    @IBOutlet weak var decreaseButton: UIButton!
    
    @IBOutlet weak var back: UIButton!
    
    override func viewDidLoad() {
        //Makes buttons easier to select with Voice Control
        if #available(iOS 13.0, *) {
            increaseButton.accessibilityUserInputLabels = ["Increase", "Plus", "Add"]
            decreaseButton.accessibilityUserInputLabels = ["Decrease", "Minus", "Subtract"]
        }
        
        // default wait time: 1 second or preserve last selection
        let previousWaitString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["wait"] ?? "1"
        let previousWait = Int(previousWaitString)
        
        if (previousWait == 1) {
            waitLabel.text = "\(previousWait ?? 1) second"
        }
        else {
            waitLabel.text = "\(previousWait ?? 1) seconds"
        }
        
        wait = previousWait!
        
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        if (wait < 10) {
            wait = wait + 1
            waitLabel.text = "\(wait) seconds"
        }
        updateAccessibilityLabel()
    }
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        if (wait > 1) {
            wait = wait - 1
            if (wait == 1){
                waitLabel.text = "\(wait) second"
            } else {
                waitLabel.text = "\(wait) seconds"
            }
        }
        updateAccessibilityLabel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["wait"] = "\(wait)"
        }
    }
    
    func updateAccessibilityLabel() {
        increaseButton.accessibilityLabel = "Increase. Current value: \(wait)"
        decreaseButton.accessibilityLabel = "Decrease. Current value: \(wait)"
    }
}
