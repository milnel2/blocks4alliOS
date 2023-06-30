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
    
    // Angle variables
    var angle: Double = 90
    var modifierBlockIndexSender: Int?
    var roundedAngle: Float = 90
    let interval: Float = 15
    
    // View controller elements
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleDisplayed: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet var turnView: UIView!
    @IBOutlet weak var angleTitle: UILabel!
    
    override func viewDidLoad() {
        // default angle: 90 or preserve last selection
        let previousAngleString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] ?? "90"
        let previousAngle = Int(previousAngleString)
        
        // Update the values on the screen
        angleDisplayed.text = "\(previousAngle ?? 90)"
        angleSlider.setValue(Float(previousAngle!), animated: false)
        angleSlider.accessibilityValue = "\(previousAngle ?? 90) degrees"
        angleDisplayed.accessibilityValue = "Current angle is \(Int(angle))degrees"
        
        roundedAngle = Float(Double(previousAngle!))
        
        // Accessibility
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        turnView.accessibilityElements = [back!, angleTitle!, angleDisplayed!, angleSlider!]
        setFontStyle()
    }
    
    /// When angle slider moved, get rounded value and convert to degrees 
    @IBAction func angleSliderChanged(_ sender: UISlider) {
        // Calculate rounded value
        let roundingNumber: Float = (interval / 2.0)
        angle = Double(sender.value)
        roundedAngle = (interval*floorf(((sender.value + roundingNumber) / interval)))
        
        // Update the screen
        sender.setValue(roundedAngle, animated:false)
        angleDisplayed.text = "\(Int(roundedAngle))"
        
        // Accessibility
        sender.accessibilityValue = "\(Int(roundedAngle)) degrees"
        angleDisplayed.accessibilityValue = "Current angle is \(Int(roundedAngle)) degrees"
    }
    
    /// Set all labels to custom font
    private func setFontStyle() {
        angleTitle.adjustsFontForContentSizeCategory = true
        angleTitle.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
        
        angleDisplayed.adjustsFontForContentSizeCategory = true
        angleDisplayed.font =  UIFont.accessibleFont(withStyle: .title2, size: 26.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController {
            
            print("Set angle to \(roundedAngle) degrees")
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["angle"] = "\(Int(roundedAngle))"
        }
    }
}
