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
      
    // Modifier variables
    public var modifierBlockIndexSender: Int?  // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    private var optionType = ""  // Name of options that gets used for accessing data and displaying information
    //TODO: get this dictionary from a plist
      // holds the different options for each multiple choice modifier type
      // the keys are the same as what gets put in the optionModTitle and are accessed by using optionType
      // the values are dictionaries of string : string that holds different attributes to be shown on thte screen
      // the minimum value is also the default value
    private let optionDictionary: [String:[String : String]] =
    ["Wait for Time" :  ["attributeName" : "wait", "min" : "1", "max" : "10", "unitIfSingular" : "second", "unitIfPlural" : "seconds", "increaseImage" : "orange_plus", "decreaseImage" : "orange_minus", "Default image" : "controlModifierBackground"],
     "Repeat" : ["attributeName" : "timesToRepeat", "min" : "2", "max" : "20", "unitIfSingular" : "time", "unitIfPlural" : "times", "increaseImage" : "orange_plus", "decreaseImage" : "orange_minus", "Default image" : "controlModifierBackground"]]
    private var modifierValue = 2  // current value of the stepper
    private var attributeName = ""  // Used for accessing and saving data, taken from optionDictionary (ex. if optionType = "Wait for Time", attributeName is "wait"
    private var min = "0"  // minimum value of the stepper, taken from optionDictionary
    private var max = "10" // maximum value of the stepper, taken from optionDictionary
    
    // View Controller Elements
    @IBOutlet weak var back: UIButton!  // back arrow button
    @IBOutlet var optionModView: UIView!  // view within the view controller
    @IBOutlet var optionModTitle: UILabel!  // label at top of screen
    @IBOutlet weak var decreaseButton: UIButton!  // minus button on screen
    @IBOutlet weak var modifierValueLabel: UILabel!  // label between the buttons that shows the current value
    @IBOutlet weak var increaseButton: UIButton!  // plus button on screen

    private let buttonSize = (((defaults.value(forKey: "blockSize") as! Int) * 10) / 9) // the size of each option button
      
    override func viewDidLoad() {
        // get the optionType from the button that caused this screen to open, this will be displayed at the top of the screen
        optionType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name
          
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
        configureButton(button: increaseButton, optionName: increaseImagePath)// plus button
        configureButton(button: decreaseButton, optionName: decreaseImagePath)
        // minus button
        optionModTitle.text = optionType // Set title of the screen
       
        // default value: minimum value or preserve last selection
        let previousWaitString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? min
          
        let previousWait = Int(previousWaitString)  // convert to an integer
          
        modifierValue = previousWait ?? 1
          
        updateModifierValueLabel()
        
        // Accessibility
        // VoiceOver
        optionModView.accessibilityElements = [back!, optionModTitle!, decreaseButton!, modifierValueLabel!, increaseButton!]
        optionModTitle.accessibilityLabel = optionType
        // Voice Control
        //Makes buttons easier to select with Voice Control
        if #available(iOS 13.0, *) {
            increaseButton.accessibilityUserInputLabels = ["Increase", "Plus", "Add"]
            decreaseButton.accessibilityUserInputLabels = ["Decrease", "Minus", "Subtract"]
        }
        // Dynamic Text
        setFontStyle()
    }
    
    /// Sets up button and sets image or text for the button
    func configureButton (button : UIButton, optionName : String) {
        button.setImage(nil, for: .normal) // remove any previous image
        let image = UIImage(named: optionName)
        if image != nil && defaults.value(forKey: "showText") as! Int == 0 {
           // Show Icons is on and the image was found
          let resizedImage = resizeImage(
            image: image!,
            scaledToSize: CGSize(
                width: buttonSize,
                height: buttonSize)) // resize the image to fit the button
            button.setBackgroundImage(resizedImage, for: .normal)
        } else {
            // No image was found and/or Show Text is on
            // Naming convention for color assets is (attributeName)Color
            // ex. animalNoiseColor, emotionNoiseColor
            let backgroundImagePath = optionDictionary[optionType]?["Default image"] ?? "N/A"
            checkIfValueExists(variableName: "backgroundImagePath", value: backgroundImagePath)
            let resizedImage = resizeImage(
                image: UIImage(named: backgroundImagePath)!,
                scaledToSize: CGSize(
                width: buttonSize,
                height: buttonSize)) // resize the image to fit the button
            button.setBackgroundImage(resizedImage, for: .normal)
            if button == increaseButton {
                button.setTitle("More", for: .normal)
            } else {
                button.setTitle("Less", for: .normal)
            }

            if image == nil {
                print("Image \(optionName) not found in StepperModifierViewController")
            }
        }
    }
    
    /// Takes an image and returns a resized version of it
    func resizeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Increase the modifierValue if possible and update visuals and accessibillity tools
    @IBAction func increaseButtonPressed(_ sender: Any) {
        let maxAsInt = Int(max) ?? 10
        if (modifierValue < maxAsInt) {
            modifierValue = modifierValue + 1
            updateModifierValueLabel()
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
        
        if (modifierValue == 1) {
            // singular
            modifierValueLabel.text = "\(modifierValue) \(unitIfSingular)"
        } else {
            //plural
            modifierValueLabel.text = "\(modifierValue) \(unitIfPlural)"
        }
        updateAccessibilityLabel()
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
    
    /// Update accessibliity tools
    func updateAccessibilityLabel() {
        increaseButton.accessibilityLabel = "Increase. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
        decreaseButton.accessibilityLabel = "Decrease. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
    }
    
    /// Set all labels to custom font
    private func setFontStyle() {
        modifierValueLabel.adjustsFontForContentSizeCategory = true
        modifierValueLabel.font = UIFont.accessibleBoldFont(withStyle: .title2, size: 50.0)
        optionModTitle.adjustsFontForContentSizeCategory = true
        optionModTitle.font = UIFont.accessibleFont(withStyle: .largeTitle, size: 34.0)
        increaseButton.titleLabel?.font = UIFont.accessibleFont(withStyle: .largeTitle, size: 34.0)
        decreaseButton.titleLabel?.font = UIFont.accessibleFont(withStyle: .largeTitle, size: 34.0)
    }
      
    /// Given a variable name and its value, prints out an error statement if the value is "N/A"
    private func checkIfValueExists (variableName : String, value : String) {
        if value == "N/A" {
            print("\(variableName) in StepperModifierController could not be found.")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            // Tell BlocksViewController which sound was selected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = "\(modifierValue)"
        }
    }
}
