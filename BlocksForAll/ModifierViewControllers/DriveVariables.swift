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
    @IBOutlet weak var speedImage: UIImageView!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var driveTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedTitle: UILabel!
    @IBOutlet var driveVariablesView: UIView!
    
    var parentVC: UIViewController?
    var currentProject: Project? {
        get {
            return UserData.data.getCurrentProject()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preserves previously selected distance variable and speed value
        speed = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        
        variableSelected = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        
        // Update screen
        updateScreen()
        
        // Accessiblity
        //Voice Control
        if #available(iOS 13.0, *) {
            slowButton.accessibilityUserInputLabels = [
                NSLocalizedString("Slower", comment: "Voice Control label"),
                NSLocalizedString("Decrease", comment: "Voice Control label"),
                NSLocalizedString("Minus", comment: "Voice Control label"),
                NSLocalizedString("Subtract", comment: "Voice Control label"),
                NSLocalizedString("Less", comment: "Voice Control label")]
            fastButton.accessibilityUserInputLabels = [
                NSLocalizedString("Faster", comment: "Voice Control label"),
                NSLocalizedString("Increase", comment: "Voice Control label"),
                NSLocalizedString("Plus", comment: "Voice Control label"),
                NSLocalizedString("Add", comment: "Voice Control label"),
                NSLocalizedString("More", comment: "Voice Control label")]
        }
        // Dynamic Text
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        setFontStyle()
        
        // Voice Over and Switch Control
        back.accessibilityLabel = "Back".localized
        driveVariablesView.accessibilityElements = [back!, driveTitleLabel!, distanceLabel!, buttons!, speedTitle!, slowButton!, speedLabel!, speedImage!, fastButton!]

        // Text
        
        driveTitleLabel.text = NSLocalizedString("Select Drive Variable", comment: "Title text for drive variable modifier view cotnroller").localizedCapitalized
        distanceLabel.text = "\("Distance".localized.localizedCapitalized):"
        speedTitle.text = "\("Speed".localized):"
    }
    
    
    @IBAction func backButtonPress(_ sender: Any) {
        if let _ = parentVC as? FreePlayWorkspaceViewController {
            performSegue(withIdentifier: "backToFreeplay", sender: nil)
        } else if let _ = parentVC as? BlocksViewController {
            performSegue(withIdentifier: "backToRobotWorkspace", sender: nil)
        }
    }
    
    /// If minus button pressed, speed changes to one less and speed label updated with this value
    @IBAction func slowButtonPressed(_ sender: Any) {
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
        speedLabel.text = speed.localized.localizedCapitalized
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
        
        // Update speed image if showIcons is on
        if HelperFunctions.showIconsIsOn() {
            let imagePath = "\(speed) Icon"
            let image = UIImage(named: imagePath)
            if image != nil {
                speedImage.image = image
                speedImage.isHidden = false
            }
        } else {
            speedImage.isHidden = true
        }
        
        updateAccessibilityLabel()
    }
   
    /// Called whenever updateScreen() is called. Updates accessibility labels and values to match what is being displayed
    private func updateAccessibilityLabel() {
        let formattedString0 = NSLocalizedString("reduce_speed_access_label", comment: "Accessibility label for a button to reduce speed")
        let resultString0 = String.localizedStringWithFormat(formattedString0, speed)
        slowButton.accessibilityLabel = resultString0
        
        let formattedString1 = NSLocalizedString("increase_speed_access_label", comment: "Accessibility label for a button to increase speed")
        let resultString1 = String.localizedStringWithFormat(formattedString1, speed)
        fastButton.accessibilityLabel = resultString1
       
        
        if !speedImage.isHidden {
            speedImage.isAccessibilityElement = true
            switch speed {
            case "Really Slow":
            // TODO: do we need these accessibility labels?
                speedImage.accessibilityLabel = NSLocalizedString("Two snails.", comment: "")
            case "Slow":
                speedImage.accessibilityLabel = NSLocalizedString("One snail.", comment: "")
            case "Normal":
                speedImage.accessibilityLabel = NSLocalizedString("One snail and one bunny.", comment: "")
            case "Fast":
                speedImage.accessibilityLabel = NSLocalizedString("One bunny.", comment: "")
            case "Really Fast":
                speedImage.accessibilityLabel = NSLocalizedString("Two bunnies.", comment: "")
            default:
                speedImage.accessibilityLabel = ""
            }
        }
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
        if let destination = segue.destination as? FreePlayWorkspaceViewController{
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
        if let destination = segue.destination as? BlocksViewController{
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
    }
}
