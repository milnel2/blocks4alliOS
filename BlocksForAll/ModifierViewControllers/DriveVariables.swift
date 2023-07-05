//
//  DriveVariables.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

class DriveVariables: UIViewController {
    /* Screen for selecting what variable should be used for driving forward or backward. */
    
    // Drive variables
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var variableSelected: String = "orange"
    var variableSelectedTwo: String = "orange"
    var speed: String = "Normal"
    
    // View Controller Elements
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var driveTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preserves previously selected distance variable and speed value
        speed = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        
        variableSelected = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        
        // Update screen
        updateScreen()
        
        // Accessiblity
        // Voice Control
        if #available(iOS 13.0, *) {
            slowButton.accessibilityUserInputLabels = ["Slower", "Decrease", "Minus", "Subtract"]
            fastButton.accessibilityUserInputLabels = ["Faster", "Increase", "Plus", "Add"]
        }
        // Dynamic Text
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        setFontStyle()
    }
    
    /// If minus button pressed, speed changes to one less and speed label updated with this value
    @IBAction func slowButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Really Fast":
            speed = "Fast"
        case "Fast":
            speed = "Normal"
        case "Normal":
            speed = "Slow"
        case "Slow":
            speed = "Really Slow"
        default:
            print("can't be slowed")
        }
        updateScreen()
    }
    
    /// If plus button pressed, speed changes to one more and speed label updated with this value
    @IBAction func fastButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Really Slow":
            speed = "Slow"
        case "Slow":
            speed = "Normal"
        case "Normal":
            speed = "Fast"
        case "Fast":
            speed = "Really Fast"
        default:
            print("can't make faster")
        }
        updateScreen()
    }
    
    /// Called when one of the variable buttons are pressed. Deselects all buttons but the currently selected one. Only one button can be selected at a time.
    @IBAction func buttonPressed(_ sender: UIButton) {
        variableSelected = sender.accessibilityIdentifier ?? ""
        updateScreen()
    }
    
    /// Call whenever data is changed to update the screen to match it
    private func updateScreen() {
        speedLabel.text = speed
        for button in buttons {
            // Highlight current variable
            if variableSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            } else {
                // Deselect all other variables
                button.layer.borderWidth = 0
            }
        }
        updateAccessibilityLabel()
    }
   
    /// Called whenever updateScreen() is called. Updates accessibility labels and values to match what is being displayed
    func updateAccessibilityLabel() {
        slowButton.accessibilityLabel = "Slower. Current speed: \(speed)"
        fastButton.accessibilityLabel = "Faster. Current speed: \(speed)"
    }
    
    /// Set all labels to custom font
    private func setFontStyle() {
        speedLabel.adjustsFontForContentSizeCategory = true
        speedLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
        
        driveTitleLabel.adjustsFontForContentSizeCategory = true
        driveTitleLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        
        distanceLabel.adjustsFontForContentSizeCategory = true
        distanceLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        
        speedTitle.adjustsFontForContentSizeCategory = true
        speedTitle.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
    }
}
