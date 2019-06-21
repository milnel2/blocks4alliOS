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
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        if (wait < 10) {
            wait = wait + 1
            waitLabel.text = "\(wait)"
        }
    }
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        if (wait > 1) {
            wait = wait - 1
            waitLabel.text = "\(wait)"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["wait"] = "\(wait)"
        }
    }
}
