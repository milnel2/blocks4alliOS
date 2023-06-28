//
//  TwoOptionModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/27/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class TwoOptionModifierViewController: UIViewController {
    /* Custom view controller for the two option modifier scenes (ex. If, Set eye light, etc.)*/
      
    public var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
      
    private var optionType = "" // Name of options that gets used for accessing data and displaying information
      
    // from Paul Hegarty, lectures 13 and 14
    private let defaults = UserDefaults.standard // used to know if in show text mode or show icon mode
      
    @IBOutlet weak var back: UIButton! // back arrow button
      
    @IBOutlet var optionModView: UIView! // view within the view controller
      
    @IBOutlet var optionModTitle: UILabel! // label at top of screen
      
    @IBOutlet weak var optionOneButton: UIButton! // left button on screen
    
    @IBOutlet weak var modifierValueLabel: UILabel! // label under the buttons that shows the current value
    
    @IBOutlet var buttons: [UIButton]! // array holding both of the buttons
    
    @IBOutlet weak var optionTwoButton: UIButton! // right button on screen

    private var modifierValue = "" // current value of the modifier
    
    //TODO: get this dictionary from a plist
      // holds the different options for each two option modifier type
      // the keys are the same as what gets put in the optionModTitle and are accessed by using optionType
      // the values are dictionaries of string : string that holds different attributes to be shown on the screen

    private let optionDictionary: [String:[String : String]] =
        ["Set Eye Light" :  ["attributeName" : "eyeLight", "Option 1" : "Off", "Option 2" : "On", "Default image" : "EyeLightModifierBackground"],
         "If" : ["attributeName" : "booleanSelected", "Option 1" : "Hear voice", "Option 2" : "Obstacle sensed", "Default image" : "controlModifierBackground"]
        ]
                
    private var attributeName = "" // Used for accessing and saving data, taken from optionDictionary (ex. if optionType = "Wait for Time", attributeName is "wait"
      
    private var optionOne = "N/A" // String value of option one
    private var optionTwo = "N/A" // String value of option two
    
    // TODO: should buttonSize be the same value as blockSize?
    private let buttonSize = 150 // the size of each option button
      
    override func viewDidLoad() {
          optionType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name // get the optionType from the button that caused this screen to open, this will be displayed at the top of the screen
          
          // get values from optionDictionary
          attributeName = optionDictionary[optionType]?["attributeName"] ?? "N/A"
          optionOne = optionDictionary[optionType]?["Option 1"] ?? "N/A"
          optionTwo = optionDictionary[optionType]?["Option 2"] ?? "N/A"
          
          
          // check if these values actually exist. If they don't, print error messages
          checkIfValueExists(variableName: "attributeName", value: attributeName)
          checkIfValueExists(variableName: "optionOne", value: optionOne)
          checkIfValueExists(variableName: "optionTwo", value: optionTwo)
        
          // Formatting and design of screen
          optionModTitle.text = optionType // Set title of the screen
          
          // Adding custom font
          modifierValueLabel.adjustsFontForContentSizeCategory = true
          modifierValueLabel.font = UIFont.accessibleBoldFont(withStyle: .title2, size: 50.0)
          optionModTitle.adjustsFontForContentSizeCategory = true
          optionModTitle.font = UIFont.accessibleFont(withStyle: .largeTitle, size: 34.0)
       
          // default value: minimum value or preserve last selection
          let previousWaitString: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? optionOne
          
          modifierValue = previousWaitString
        
          updateModifierValueLabel()
        
        configureButton(button: optionOneButton, optionName: optionOne)
        configureButton(button: optionTwoButton, optionName: optionTwo)
          
        for button in buttons {
              //Highlights current option when mod view is entered
              if modifierValue == button.accessibilityIdentifier {
                  button.layer.borderWidth = 10
                  button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
              }
          }
          
          
        
          // accessibility
          
          //reroute VO Order to be more intuitive
          optionModView.accessibilityElements = [back!, optionModTitle!, modifierValueLabel!, optionOneButton!,  optionTwoButton!]
          
        //TODO: test voice control
          //Makes buttons easier to select with Voice Control
          if #available(iOS 13.0, *) {
              optionTwoButton.accessibilityUserInputLabels = ["Right", "\(optionTwo)", "Second button"]
              optionOneButton.accessibilityUserInputLabels = ["Left", "\(optionOne)", "First button"]
          }
        
        
        optionModTitle.accessibilityLabel = optionType
        modifierValueLabel.accessibilityLabel = "Current selection: \(modifierValue)"
      }
    
    /// Sets up button and sets image or text for the button
    func configureButton (button : UIButton, optionName : String) {
        let image = UIImage(named: optionName)
        
        if image != nil && defaults.value(forKey: "showText") as! Int == 0 {
           // Show Icons is on and the image was found
          let resizedImage = resizeImage(image: image!, scaledToSize: CGSize(width: buttonSize, height: buttonSize)) // resize the image to fit the button
            button.setBackgroundImage(resizedImage, for: .normal)
          
      } else {
          // No image was found and/or Show Text is on
          // Naming convention for color assets is (attributeName)Color
          // ex. animalNoiseColor, emotionNoiseColor
          let backgroundImagePath = optionDictionary[optionType]?["Default image"] ?? "N/A"
          checkIfValueExists(variableName: "backgroundImagePath", value: backgroundImagePath)
          let resizedImage = resizeImage(image: UIImage(named: backgroundImagePath)!, scaledToSize: CGSize(width: buttonSize, height: buttonSize)) // resize the image to fit the button
          button.setBackgroundImage(resizedImage, for: .normal)
          button.setTitle(optionName, for: .normal)
          
          if image == nil {
              print("Image \(optionName) not found in TwoOptionModifierViewController")
          }
      }
        
        button.accessibilityIdentifier = optionName
        button.accessibilityLabel = optionName
    }
    
    /// Takes an image and returns a resized version of it
    func resizeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// given a variable name and its value, prints out an error statement if the value is "N/A"
    private func checkIfValueExists (variableName : String, value : String) {
        if value == "N/A" {
            print("\(variableName) in TwoOptionModifierViewController could not be found.")
        }
    }
    
    @IBAction func optionOnePressed(_ sender: Any) {
        
       modifierValue = optionOne
        updateModifierValueLabel()
        // deselect
        optionTwoButton.layer.borderWidth = 0
        
        // select
        optionOneButton.layer.borderWidth = 10
        optionOneButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        updateAccessibilityLabel()
    }
    @IBAction func optionTwoPressed(_ sender: Any) {
        
         modifierValue = optionTwo
         updateModifierValueLabel()
         //deselect
         optionOneButton.layer.borderWidth = 0
        // select
         optionTwoButton.layer.borderWidth = 10
         optionTwoButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
         updateAccessibilityLabel()
     
    }
    
    /// Set text value of modifierValueLabel which is under the two option buttons
    private func updateModifierValueLabel () {
        modifierValueLabel.text = "\(modifierValue)"
        modifierValueLabel.accessibilityLabel = "\(optionType) is \(modifierValue)"

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
    /// Call whenever things are changed on the screen
    func updateAccessibilityLabel() {
        optionTwoButton.accessibilityLabel = "\(optionTwo)."
        optionOneButton.accessibilityLabel = "\(optionOne)."
        modifierValueLabel.accessibilityLabel = "Current selection: \(modifierValue)"
    }
      
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
          if segue.destination is BlocksViewController{
              // TODO: update so that just an array is used for images, so that soundSelected can be passed instead
              functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = "\(modifierValue)" // Tell BlocksViewController which sound was selected
          }
    }
}