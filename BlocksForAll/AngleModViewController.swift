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
    let interval: Float = 15

    @IBOutlet weak var angleSlider: UISlider!
    
    override func viewDidLoad() {
        var previousAngleString: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] ?? "90"
        var previousAngle = Int(previousAngleString)
        angleSlider.setValue(Float(previousAngle!), animated: false)
        // MARK: preserve previously selected value 
        angle = Double(previousAngle!)
    }
    
    @IBAction func angleSliderChanged(_ sender: UISlider) {
        let roundingNumber: Float = (interval/2.0)
        angle = Double(sender.value)
        sender.accessibilityValue = "\(Int(angle)) degrees"
        //setValue(Float(angle), animated: true)
        sender.setValue(interval*floorf(((sender.value+roundingNumber)/interval)), animated:false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
        blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] = "\(Int(angle))"
        }
    }
}
