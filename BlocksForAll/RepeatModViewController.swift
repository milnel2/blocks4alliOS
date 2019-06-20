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
    var timesToRepeat: Int = 0
    
    @IBOutlet weak var timesToRepeatLabel: UILabel!
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        timesToRepeat = timesToRepeat + 1
        timesToRepeatLabel.text = "\(timesToRepeat)"
    }
    @IBAction func minusButtonPressed(_ sender: Any) {
        timesToRepeat = timesToRepeat - 1
        timesToRepeatLabel.text = "\(timesToRepeat)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            
        }
    }
    
}
