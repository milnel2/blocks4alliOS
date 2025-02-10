//
//  SpeedModViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/26/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class SpeedModViewController: UIViewController{
    /* View controller for the Speed modifier scene */
    
    // Speed variables
    var speed: String = "Normal"
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var robotSpeed: Double = 3
    let interval: Float = 10
    
    // View controller elements
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet var speedView: UIView!
    @IBOutlet var speedTitle: UILabel!
    @IBOutlet weak var speedImage: UIImageView!
    
   
    var parentVC: UIViewController?
    var currentProject: Project?
    
    override func viewDidLoad() {
        // Get Speed values
        
        // Default Speed: Normal or preserve last selection
        let previousSpeedString: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        
        // preserves previously selected value
        speed = previousSpeedString
        
        // Update the screen
        updateScreen()
    
        // Accessibility
        // Voice Over and Switch Control
        speedView.accessibilityElements = [back!, speedTitle!, slowButton!, speedLabel!, speedImage!, fastButton!]
        
        // Voice Control
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
        
        // Text
        
        speedTitle.text = "Speed".localized
        
        
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        if let _ = parentVC as? FreePlayWorkspaceViewController {
            performSegue(withIdentifier: "backToFreeplay", sender: nil)
        } else if let _ = parentVC as? BlocksViewController {
            performSegue(withIdentifier: "backToRobotWorkspace", sender: nil)
        }
    }
  
    
    /// If minus button pressed, speed changes to one less and speed label updated with this value
    @IBAction func slowButtonPressed(_ sender: UIButton) {
        // Reduce the speed by one interval, if possible
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
        // Increase the speed by one interval, if possible
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
    
    /// Called whenever updateScreen() is called. Updates accessibility labels and values to match what is being displayed
    private func updateAccessibilityTools() {
        // Speed
        slowButton.accessibilityLabel = "Slower. Current speed: \(speed)"
        fastButton.accessibilityLabel = "Faster. Current speed: \(speed)"
        speedLabel.accessibilityLabel = "Current speed is \(speed)"
        
        slowButton.accessibilityLabel = NSLocalizedString("Slower. Current speed: \(speed).", comment: "Accessiblity Label for a button to decrease speed")
        fastButton.accessibilityLabel = NSLocalizedString("Faster. Current speed: \(speed).", comment: "Accessibility Label for a button to increase speed")
        speedLabel.accessibilityLabel = NSLocalizedString("Current speed is \(speed).", comment: "Accessibility Label for a label displaying current speed")
        
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
    
    /// Call whenever data is changed to update the screen to match it
    private func updateScreen() {
        // Speed
        speedLabel.text = speed.localized
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
        // Update accessibility tools each time that the screen is updated
        updateAccessibilityTools()
    }
    
    /// Set all labels to custom font
    private func setFontStyle() {
        speedTitle.adjustsFontForContentSizeCategory = true
        speedTitle.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
        
        speedLabel.adjustsFontForContentSizeCategory = true
        speedLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? FreePlayWorkspaceViewController{
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
            destination.currentProject = currentProject
        }
        if let destination = segue.destination as? BlocksViewController{
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
            destination.currentProject = currentProject
        }
    }
}

