//
//  AngleModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/19/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class SliderModifierController: UIViewController {
    /* Custom view controller for the Angle modifier scene */
    
    // Angle variables
    var sliderValue: Double = 90
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var roundedSliderValue: Float = 90
    var sliderInterval: Int = 1
    
    private var optionType = ""  // Name of options that gets used for accessing data and displaying information
    //TODO: get this dictionary from a plist
      // holds the different options for each slider modifier type
      // the keys are the same as what gets put in the optionModTitle and are accessed by using optionType
      // the values are dictionaries of string : string that holds different attributes to be shown on thte screen
      // the minimum value is also the default value
    private let optionDictionary: [String:[String : String]] =
    ["Turn Left" :  ["attributeName" : "angle", "min" : "0", "max" : "360", "unitIfSingular" : "degree", "unitIfPlural" : "degrees", "Default image" : "driveModifierBackground", "Slider Interval": "15"],
     "Turn Right" : ["attributeName" : "angle", "min" : "0", "max" : "360", "unitIfSingular" : "degree", "unitIfPlural" : "degrees",  "Default image" : "driveModifierBackground", "Slider Interval": "15"],
     "Move Up" : ["attributeName" : "movement", "min" : "1", "max" : "10", "unitIfSingular" : "", "unitIfPlural" : "",  "Default image" : "driveModifierBackground", "Slider Interval": "1"],
     "Move Down" : ["attributeName" : "movement", "min" : "1", "max" : "10", "unitIfSingular" : "", "unitIfPlural" : "", "Default image" : "driveModifierBackground", "Slider Interval": "1"],
     "Move Right" : ["attributeName" : "movement", "min" : "1", "max" : "10", "unitIfSingular" : "", "unitIfPlural" : "", "Default image" : "driveModifierBackground", "Slider Interval": "1"],
     "Move Left" : ["attributeName" : "movement", "min" : "1", "max" : "10", "unitIfSingular" : "", "unitIfPlural" : "", "Default image" : "driveModifierBackground", "Slider Interval": "1"]]
    
    private var attributeName = ""  // Used for accessing and saving data, taken from optionDictionary (ex. if optionType = "Wait for Time", attributeName is "wait"
    private var min = "0"  // minimum value of the stepper, taken from optionDictionary
    private var max = "10" // maximum value of the stepper, taken from optionDictionary
    
    private var units = ""
    
    // View controller elements
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueDisplayed: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet var turnView: UIView!
    @IBOutlet weak var optionModTitle: UILabel!
    
    
    var parentVC: UIViewController?
   
    override func viewDidLoad() {
        // get the optionType from the button that caused this screen to open, this will be displayed at the top of the screen
        optionType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name
        
        // get values from optionDictionary
        attributeName = optionDictionary[optionType]?["attributeName"] ?? "N/A"
        min = optionDictionary[optionType]?["min"] ?? "N/A"
        max = optionDictionary[optionType]?["max"] ?? "N/A"
        let sliderIntervalString = optionDictionary[optionType]?["Slider Interval"] ?? "N/A"
        
        
        // check if these values actually exist. If they don't, print error messages
        checkIfValueExists(variableName: "attributeName", value: attributeName)
        checkIfValueExists(variableName: "min", value: min)
        checkIfValueExists(variableName: "max", value: max)
        checkIfValueExists(variableName: "sliderInterval", value: sliderIntervalString)
        
        sliderInterval = Int(sliderIntervalString)!
        
        
        optionModTitle.text = optionType // Set title of the screen
       
        // default value: minimum value or preserve last selection
        let previousValueString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? min
          
        let previousValue = Int(previousValueString)  // convert to an integer
        
        // Update the values on the screen
        valueDisplayed.text = "\(previousValue!)"
        slider.setValue(Float(previousValue!), animated: false)
        slider.maximumValue = Float(max) ?? 90
        slider.minimumValue = Float(min) ?? 1
        

        if previousValue! == 1 {
            units = optionDictionary[optionType]?["unitIfSingular"] ?? "N/A"
        } else {
            units = optionDictionary[optionType]?["unitIfPlural"] ?? "N/A"
        }
        sliderValue = Double(previousValue!)
        slider.accessibilityValue = "\(previousValue!) " + units
        valueDisplayed.accessibilityValue = "Current value is \(Int(sliderValue))" + units
        print("1 setting value to ", sliderValue)
        
        roundedSliderValue = Float(Double(previousValue!))
        
        // Accessibility
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        turnView.accessibilityElements = [back!, optionModTitle!, valueDisplayed!, slider!]
        setFontStyle()
    }
    
    /// Called whenever angleSliderChanged() is called. Updates accessibility labels and values to match what is being displayed
    private func updateAccessibilityTools() {
        slider.accessibilityValue = "\(Int(roundedSliderValue)) " + units
        print("setting value to ", roundedSliderValue)
        valueDisplayed.accessibilityValue = "Current value is \(Int(roundedSliderValue)) " + units
//        optionModTitle.accessibilityHint = attributeName + "Adjust slider to set amount"
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        if let _ = parentVC as? FreePlayWorkspaceViewController {
            performSegue(withIdentifier: "backToFreeplay", sender: nil)
        } else if let _ = parentVC as? BlocksViewController {
            performSegue(withIdentifier: "backToRobotWorkspace", sender: nil)
        }
    }
    
    /// When angle slider moved, get rounded value and convert to degrees
    @IBAction func angleSliderChanged(_ sender: UISlider) {
        // Calculate rounded value
        let roundingNumber: Float = (Float(sliderInterval) / 2.0)
        sliderValue = Double(sender.value)
        roundedSliderValue = (Float(sliderInterval) * floorf(((sender.value + roundingNumber) / Float(sliderInterval))))
        
        // Update the screen
        sender.setValue(roundedSliderValue, animated:false)
        sliderValue = Double(roundedSliderValue)
        valueDisplayed.text = "\(Int(roundedSliderValue))"
        
        updateAccessibilityTools()
    }
    
    /// Set all labels to custom font
    private func setFontStyle() {
        optionModTitle.adjustsFontForContentSizeCategory = true
        optionModTitle.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
        
        valueDisplayed.adjustsFontForContentSizeCategory = true
        valueDisplayed.font =  UIFont.accessibleFont(withStyle: .title2, size: 26.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController {
            
            print("Set slider value to \(roundedSliderValue) " + units)
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = "\(Int(roundedSliderValue))"
        }
    }
    /// Given a variable name and its value, prints out an error statement if the value is "N/A"
    private func checkIfValueExists (variableName : String, value : String) {
        if value == "N/A" {
            print("\(variableName) in SliderModifierController could not be found.")
        }
    }
}
