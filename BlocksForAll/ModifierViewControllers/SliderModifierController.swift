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
    var roundedSliderValue: Int = 90
    var sliderInterval: Int = 1
    
    private var optionType = ""  // Name of options that gets used for accessing data and displaying information
   
    
      // holds the different options for each slider modifier type
      // the keys are the same as what gets put in the optionModTitle and are accessed by using optionType
      // the values are dictionaries of string : string that holds different attributes to be shown on thte screen
      // the minimum value is also the default value
    private let dict = HelperFunctions.getPListDictionary(resourceName: "SliderModifierOptionsDictionary")!

    
    var optionDict = NSDictionary() // the specific dictionary for the chosen modifier (ex. Move Up)
    
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
    var currentProject: Project? {
        get {
            return UserData.data.getCurrentProject()
        }
    }
    
   
   
    override func viewDidLoad() {
        // get the optionType from the button that caused this screen to open, this will be displayed at the top of the screen
        optionType = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name
        
        // get values from dict
        
        optionDict = dict.value(forKey: optionType) as! NSDictionary
        
        attributeName = optionDict.value(forKey: "attributeName") as? String ?? "N/A"
        min = optionDict.value(forKey: "min") as? String ?? "N/A"
        max = optionDict.value(forKey: "max") as? String ?? "N/A"
        let sliderIntervalString = optionDict.value(forKey: "Slider Interval") as? String ?? "N/A"
        
        // check if these values actually exist. If they don't, print error messages
        checkIfValueExists(variableName: "attributeName", value: attributeName)
        checkIfValueExists(variableName: "min", value: min)
        checkIfValueExists(variableName: "max", value: max)
        checkIfValueExists(variableName: "sliderInterval", value: sliderIntervalString)
        
        sliderInterval = Int(sliderIntervalString)!
        
        
        optionModTitle.text = optionType.localized // Set title of the screen
       
        // default value: minimum value or preserve last selection
        let previousValueString: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? min
          
        let previousValue = Int(previousValueString)  // convert to an integer
        
        // Update the values on the screen
        valueDisplayed.text = "\(previousValue!)"
        slider.setValue(Float(previousValue!), animated: false)
        slider.maximumValue = Float(max) ?? 90
        slider.minimumValue = Float(min) ?? 1
        
        sliderValue = Double(previousValue!)
        roundedSliderValue = Int(Double(previousValue!))
        
        
        
        
        // Accessibility
        updateAccessibilityTools()
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        back.accessibilityLabel = "Back".localized
        turnView.accessibilityElements = [back!, optionModTitle!, valueDisplayed!, slider!]
        setFontStyle()
    }
    
    /// Called whenever angleSliderChanged() is called. Updates accessibility labels and values to match what is being displayed
    private func updateAccessibilityTools() {
        if attributeName == "angle" {
            
            let formattedString = NSLocalizedString("num_degrees", comment: "Accessibility value for a slider to choose angle")
            let resultString = String.localizedStringWithFormat(formattedString, roundedSliderValue)
            slider.accessibilityValue = resultString
            
            let formattedString2 = NSLocalizedString("current_value_is_degrees", comment: "Accessibility value for a label describing the value of a slider to choose angle")
            let resultString2 = String.localizedStringWithFormat(formattedString2, roundedSliderValue)
            valueDisplayed.accessibilityValue = resultString2
            
        } else {
            slider.accessibilityValue = NumberFormatter.localizedString(from: roundedSliderValue as NSNumber, number: .none)
            let formattedString = NSLocalizedString("current_value_is_int", comment: "Accessibility value for a label describing the value of a slider")
            let resultString = String.localizedStringWithFormat(formattedString, roundedSliderValue)
            valueDisplayed.accessibilityValue = resultString
        }
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
        roundedSliderValue = Int((Float(sliderInterval) * floorf(((sender.value + roundingNumber) / Float(sliderInterval)))))
        
        // Update the screen
        sender.setValue(Float(roundedSliderValue), animated:false)
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
        if let destination = segue.destination as? FreePlayWorkspaceViewController {
            
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = "\(Int(roundedSliderValue))"
            
        }
        if let destination = segue.destination as? BlocksViewController {
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = "\(Int(roundedSliderValue))"            
        }
    }
    /// Given a variable name and its value, prints out an error statement if the value is "N/A"
    private func checkIfValueExists (variableName : String, value : String) {
        if value == "N/A" {
            print("\(variableName) in SliderModifierController could not be found.")
        }
    }
}
