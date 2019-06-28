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
    var angle: Double = 90
    var modifierBlockIndexSender: Int?
    let interval: Float = 45

    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleDisplayed: UILabel!
    
    override func viewDidLoad() {
        var previousAngleString: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] ?? "90"
        var previousAngle = Int(previousAngleString)
        angleDisplayed.text = "\(previousAngle ?? 90)"
        angleSlider.setValue(Float(previousAngle!), animated: false)
        // preserves previously selected value 
        angle = Double(previousAngle!)
        angleDisplayed.accessibilityValue = "The current angle selected is \(Int(angle))degrees"
    }
    
    @IBAction func angleSliderChanged(_ sender: UISlider) {
        let roundingNumber: Float = (interval/2.0)
        angle = Double(sender.value)
        var roundedAngle = (interval*floorf(((sender.value+roundingNumber)/interval)))
        sender.accessibilityValue = "\(Int(roundedAngle)) degrees"
        sender.setValue(roundedAngle, animated:false)
        angleDisplayed.text = "\(Int(roundedAngle))"
        
        angleDisplayed.accessibilityValue = "The current angle selected is \(Int(roundedAngle)) degrees"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
        blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] = "\(Int(angle))"
        }
    }
}
