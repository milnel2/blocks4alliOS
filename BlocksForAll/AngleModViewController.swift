//
//  AngleModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/19/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class AngleModViewController: UIViewController {
    /* Custom view controller for the Angle modifier scene */
    
    // TODO: decide on default angle
    var angle: Double = 0
    var modifierBlockIndexSender: Int?

    @IBOutlet weak var angleSlider: UISlider!
    
    @IBAction func angleSliderChanged(_ sender: UISlider) {
        // TODO: fix in/de-crement value
        angle = Double(sender.value)
        sender.accessibilityValue = "\(Int(angle)) degrees"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] = "\(Int(angle))"
        }
    }
    
}
