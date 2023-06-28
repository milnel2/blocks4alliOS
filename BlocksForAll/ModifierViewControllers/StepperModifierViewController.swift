//
//  StepperModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/26/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class StepperModifierViewController: UIViewController {
    /* Custom view controller for the stepper modifier scenes (ex. Repeat, Wait for Time, etc.)*/
      
    public var modifierBlockIndexSender: Int?  // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
      
    private var optionType = ""  // Name of options that gets used for accessing data and displaying information
      
    @IBOutlet weak var back: UIButton!  // back arrow button
      
    @IBOutlet var optionModView: UIView!  // view within the view controller
      
    @IBOutlet var optionModTitle: UILabel!  // label at top of screen
      
    @IBOutlet weak var decreaseButton: UIButton!  // minus button on screen
    
    @IBOutlet weak var modifierValueLabel: UILabel!  // label between the buttons that shows the current value
    
    @IBOutlet weak var increaseButton: UIButton!  // plus button on screen

    private var modifierValue = 2  // current value of the stepper
    
    //TODO: get this dictionary from a plist
      // holds the different options for each multiple choice modifier type
      // the keys are the same as what gets put in the optionModTitle and are accessed by using optionType
      // the values are dictionaries of string : string that holds different attributes to be shown on thte screen
      // the minimum value is also the default value

    private let optionDictionary: [String:[String : String]] =
    ["Wait for Time" :  ["attributeName" : "wait", "min" : "1", "max" : "10", "unitIfSingular" : "second", "unitIfPlural" : "seconds", "increaseImage" : "orange_plus", "decreaseImage" : "orange_minus"],
     "Repeat" : ["attributeName" : "timesToRepeat", "min" : "2", "max" : "20", "unitIfSingular" : "time", "unitIfPlural" : "times", "increaseImage" : "orange_plus", "decreaseImage" : "orange_minus"]]
            
    private var attributeName = ""  // Used for accessing and saving data, taken from optionDictionary (ex. if optionType = "Wait for Time", attributeName is "wait"
      
    private var min = "0"  // minimum value of the stepper, taken from optionDictionary
    private var max = "10" // maximum value of the stepper, taken from optionDictionary
     
    // TODO: should buttonSize be the same value as blockSize?
    //private let buttonSize = 150 // the size of each stepper button
      
    override func viewDidLoad() {
        
          optionType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name  // get the optionType from the button that caused this screen to open, this will be displayed at the top of the screen
          
          // get values from optionDictionary
          attributeName = optionDictionary[optionType]?["attributeName"] ?? "N/A"
          min = optionDictionary[optionType]?["min"] ?? "N/A"
          max = optionDictionary[optionType]?["max"] ?? "N/A"
          let increaseImagePath = optionDictionary[optionType]?["increaseImage"] ?? "N/A"
          let decreaseImagePath = optionDictionary[optionType]?["decreaseImage"] ?? "N/A"
          
          // check if these values actually exist. If they don't, print error messages
          checkIfValueExists(variableName: "attributeName", value: attributeName)
          checkIfValueExists(variableName: "min", value: min)
          checkIfValueExists(variableName: "max", value: max)
          checkIfValueExists(variableName: "increaseImage", value: increaseImagePath)
          checkIfValueExists(variableName: "decreaseImage", value: decreaseImagePath)
          
          // Formatting and design of screen
          increaseButton.setImage(UIImage(named: increaseImagePath), for: .normal)  // plus button
          decreaseButton.setImage(UIImage(named: decreaseImagePath), for: .normal)  // minus button
          optionModTitle.text = optionType // Set title of the screen
          
          // Adding custom font
          modifierValueLabel.adjustsFontForContentSizeCategory = true
          modifierValueLabel.font = UIFont.accessibleBoldFont(withStyle: .title2, size: 50.0)
          optionModTitle.adjustsFontForContentSizeCategory = true
          optionModTitle.font = UIFont.accessibleFont(withStyle: .largeTitle, size: 34.0)
       
          // default value: minimum value or preserve last selection
          let previousWaitString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? min
          
          let previousWait = Int(previousWaitString)  // convert to an integer
          
          modifierValue = previousWait ?? 1
          
          updateModifierValueLabel()

          
          // accessibility
          
          //reroute VO Order to be more intuitive
          optionModView.accessibilityElements = [back!, optionModTitle!, decreaseButton!, modifierValueLabel!, increaseButton!]
          
          //Makes buttons easier to select with Voice Control
          if #available(iOS 13.0, *) {
              increaseButton.accessibilityUserInputLabels = ["Increase", "Plus", "Add"]
              decreaseButton.accessibilityUserInputLabels = ["Decrease", "Minus", "Subtract"]
          }
          optionModTitle.accessibilityLabel = optionType
      }
    
    /// given a variable name and its value, prints out an error statement if the value is "N/A"
    private func checkIfValueExists (variableName : String, value : String) {
        if value == "N/A" {
            print("\(variableName) in StepperModifierController could not be found.")
        }
    }
    
    /// Increase the modifierValue if possible and update visuals and accessibillity tools
    @IBAction func increaseButtonPressed(_ sender: Any) {
        let maxAsInt = Int(max) ?? 10
        if (modifierValue < maxAsInt) {
            modifierValue = modifierValue + 1
            updateModifierValueLabel()
            updateAccessibilityLabel()
        } else {
            increaseButton.accessibilityLabel = "At maximum value. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
        }
        
    }
    /// Decrease the modifierValue if possible and update visuals and accessibillity tools
    @IBAction func decreaseButtonPressed(_ sender: Any) {
        let minAsInt = Int(min) ?? 0
        if (modifierValue > minAsInt) {
            modifierValue = modifierValue - 1
            updateModifierValueLabel()
            updateAccessibilityLabel()
        } else {
            decreaseButton.accessibilityLabel = "At minimum value. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
        }
    }
    
    /// Set text value of modifierValueLabel which is between the two stepper buttons
    private func updateModifierValueLabel () {
        let unitIfSingular = optionDictionary[optionType]?["unitIfSingular"] ?? "N/A"
        let unitIfPlural = optionDictionary[optionType]?["unitIfPlural"] ?? "N/A"
        
        checkIfValueExists(variableName: "unitIfSingular", value: unitIfSingular)
        checkIfValueExists(variableName: "unitIfPlural", value: unitIfPlural)
        
        if (modifierValue == 1){
            // singular
            modifierValueLabel.text = "\(modifierValue) \(unitIfSingular)"
        } else {
            //plural
            modifierValueLabel.text = "\(modifierValue) \(unitIfPlural)"
        }
    }
    
      //TODO: test and finish this method
    func createVoiceControlLabels(button: UIButton) {
        var voiceControlLabel = button.accessibilityLabel!
        let wordToRemove = " Noise"
        if let range = voiceControlLabel.range(of: wordToRemove){
            voiceControlLabel.removeSubrange(range)
        }
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(button.accessibilityLabel!)"]
        }
    }
    
    func updateAccessibilityLabel() {
        increaseButton.accessibilityLabel = "Increase. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
        decreaseButton.accessibilityLabel = "Decrease. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
    }
      
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
          if segue.destination is BlocksViewController{
              // TODO: update so that just an array is used for images, so that soundSelected can be passed instead
              functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = "\(modifierValue)" // Tell BlocksViewController which sound was selected
          }
    }
}
