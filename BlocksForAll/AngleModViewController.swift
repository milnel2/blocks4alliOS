
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
    var angle: Double = 90
    var modifierBlockIndexSender: Int?
    let interval: Float = 15
    var roundedAngle: Float = 90
    
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleDisplayed: UILabel!
    
    override func viewDidLoad() {        
        // default angle: 90 or preserve last selection
        var previousAngleString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] ?? "90"
        var previousAngle = Int(previousAngleString)
        angleDisplayed.text = "\(previousAngle ?? 90)"
        angleSlider.setValue(Float(previousAngle!), animated: false)
        // preserves previously selected value
        
        roundedAngle = Float(Double(previousAngle!))
        angleDisplayed.accessibilityValue = "Current angle is \(Int(angle))degrees"
    }
    
    
    //when angle slider moved, get rounded value and convert to degrees 
    @IBAction func angleSliderChanged(_ sender: UISlider) {
        let roundingNumber: Float = (interval/2.0)
        angle = Double(sender.value)
        roundedAngle = (interval*floorf(((sender.value+roundingNumber)/interval)))
        sender.accessibilityValue = "\(Int(roundedAngle)) degrees"
        sender.setValue(roundedAngle, animated:false)
        angleDisplayed.text = "\(Int(roundedAngle))"
        
        angleDisplayed.accessibilityValue = "Current angle is \(Int(roundedAngle)) degrees"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            print("\(roundedAngle)")
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] = "\(Int(roundedAngle))"
        }
    }
}
