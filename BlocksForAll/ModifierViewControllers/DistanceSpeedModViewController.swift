//
//  DistanceSpeedModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/18/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class DistanceSpeedModViewController: UIViewController{
    /* View controller for the Distance and Speed modifier scene */
    
    //TODO: update these based on Dash API
    // Distance variables
    var distance: Double = 30
    var speed: String = "Normal"
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var robotSpeed: Double = 3
    let interval: Float = 10
    
    // View controller elements
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceDisplayed: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet var distanceSpeedView: UIView!
    @IBOutlet var distanceTitle: UILabel!
    @IBOutlet var speedTitle: UILabel!
    @IBOutlet weak var speedImage: UIImageView!
    
   
    var parentVC: UIViewController?
    var currentProject: Project? {
        get {
            return UserData.data.getCurrentProject()
        }
    }
    
    override func viewDidLoad() {
        // Get Speed and Distance values
        // Default Distance: 30 or preserve last selection
        let previousDistanceString: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["distance"] ?? "30"
        let previousDistance = Int(previousDistanceString)
        
        // preserve previously selected value
        distance = Double(previousDistance!)
        
        // Default Speed: Normal or preserve last selection
        let previousSpeedString: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        
        // preserves previously selected value
        speed = previousSpeedString
        
        // Update the screen
        distanceSlider.setValue(Float(distance), animated: false)
        updateScreen()
    
        // Accessibility
        // Voice Over and Switch Control
        distanceSpeedView.accessibilityElements = [back!, distanceTitle!, distanceDisplayed!, distanceSlider!, speedTitle!, slowButton!, speedLabel!, speedImage!, fastButton!]
        
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
        
        // Localization
        distanceTitle.text = "Distance".localized
        speedTitle.text = "Speed".localized
        
        
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        if let _ = parentVC as? FreePlayWorkspaceViewController {
            performSegue(withIdentifier: "backToFreeplay", sender: nil)
        } else if let _ = parentVC as? BlocksViewController {
            performSegue(withIdentifier: "backToRobotWorkspace", sender: nil)
        }
    }
  
    /// Updates distance value when slider moved
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        // Update distance
        distance = Double(sender.value)
        
        // Update the screen
        updateScreen()
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
        // Distance
        distanceDisplayed.accessibilityValue = NSLocalizedString("Current distance is \(Int(distance)) centimeter(s).", comment: "Accessibility value for a label displaying a distance")
        distanceSlider.accessibilityValue = NSLocalizedString("\(Int(distance)) centimeter(s).", comment: "Accessibility value for a slider to choose a distance")
        // Speed
        slowButton.accessibilityLabel = NSLocalizedString("Slower. Current speed is \(speed).", comment: "Accessibility label for a button to reduce speed")
        fastButton.accessibilityLabel = NSLocalizedString("Faster. Current speed is \(speed).", comment: "Accessibility label for a button to increase speed")
        speedLabel.accessibilityLabel = NSLocalizedString("Current speed is \(speed).", comment: "Accessibility label for a label that describes current speed value")
        
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
        // Distance
        // Calculate rounded value
        let roundingNumber: Float = (interval / 2.0)
        let roundedDistance = (interval * floorf(((distanceSlider.value + roundingNumber) / interval)))
        distanceDisplayed.text = "\(Int(roundedDistance))"
        distanceSlider.setValue(roundedDistance, animated: false)
        
        // Speed
        speedLabel.text = speed.localized
        // Update speed image if showIcons is on
        if defaults.value(forKey: "showText") as! Int == 0 {
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
        distanceTitle.adjustsFontForContentSizeCategory = true
        distanceTitle.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
        
        distanceDisplayed.adjustsFontForContentSizeCategory = true
        distanceDisplayed.font =  UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        
        speedTitle.adjustsFontForContentSizeCategory = true
        speedTitle.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
        
        speedLabel.adjustsFontForContentSizeCategory = true
        speedLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let destination = segue.destination as? FreePlayWorkspaceViewController{
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["distance"] = "\(Int(distance))"
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
        if let destination = segue.destination as? BlocksViewController{
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["distance"] = "\(Int(distance))"
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
    }
}
