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
    var distance: Double = 30
    var speed: String = "Normal"
    var modifierBlockIndexSender: Int?
    var robotSpeed: Double = 3
    let interval: Float = 10
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var distanceDisplayed: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet var distanceSpeedView: UIView!
    @IBOutlet var distanceTitle: UILabel!
    @IBOutlet var speedTitle: UILabel!
    
    override func viewDidLoad() {
        // Debug VO route
        distanceSpeedView.accessibilityElements = [distanceTitle!, distanceDisplayed!, distanceSlider!, speedTitle!, slowButton!, speedLabel!, fastButton!, back!]
        
        //Makes buttons easier to select with Voice Control
        if #available(iOS 13.0, *) {
            slowButton.accessibilityUserInputLabels = ["Slower", "Decrease", "Minus", "Subtract"]
            fastButton.accessibilityUserInputLabels = ["Faster", "Increase", "Plus", "Add"]
        }
        
        // default speed: Normal or preserve last selection
        let previousDistanceString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["distance"] ?? "30"
        let previousDistance = Int(previousDistanceString)
        distanceDisplayed.text = "\(previousDistance ?? 30)"
        distanceSlider.setValue(Float(previousDistance!), animated: true)
        distanceSlider.accessibilityValue = "\(previousDistance ?? 30) centimeters"
        
        // preserve previously selected value
        distance = Double(previousDistance!)
        
        speedLabel.text = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        // preserves previously selected value
        speed = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        
        distanceDisplayed.accessibilityValue = "Current distance is \(Int(distance)) centimeters"
        
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    //updates distance value when slider moved
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        let roundingNumber: Float = (interval/2.0)
        distance = Double(sender.value)
        let roundedDistance = (interval*floorf(((sender.value+roundingNumber)/interval)))
        sender.accessibilityValue = "\(Int(roundedDistance)) centimeters"
        sender.setValue(roundedDistance, animated:false)
        distanceDisplayed.text = "\(Int(roundedDistance))"
        
        distanceDisplayed.accessibilityValue = "Current distance is \(Int(roundedDistance)) centimeters"
    }
    
    
    //if minus button pressed, speed changes to one less and speed label updated with this value
    @IBAction func slowButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Really Fast":
            speed = "Fast"
            speedLabel.text = speed
        case "Fast":
            speed = "Normal"
            speedLabel.text = speed
        case "Normal":
            speed = "Slow"
            speedLabel.text = speed
        case "Slow":
            speed = "Really Slow"
            speedLabel.text = speed
        default:
            print("can't be slowed")
        }
        updateAccessibilityLabel()
    }
    
    //if plus button pressed, speed changes to one more and speed label updated with this value
    @IBAction func fastButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Really Slow":
            speed = "Slow"
            speedLabel.text = speed
        case "Slow":
            speed = "Normal"
            speedLabel.text = speed
        case "Normal":
            speed = "Fast"
            speedLabel.text = speed
        case "Fast":
            speed = "Really Fast"
            speedLabel.text = speed
        default:
            print("can't make faster")
        }
        updateAccessibilityLabel()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["distance"] = "\(Int(distance))"
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
    }
    
    func updateAccessibilityLabel() {
        slowButton.accessibilityLabel = "Slower. Current speed: \(speed)"
        fastButton.accessibilityLabel = "Faster. Current speed: \(speed)"
    }
    
}
