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
    /* Custom view controller for the stepper modifier scenes (ex. Repeat, Wait for Time, etc.)*/
      
    public var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
      
    private var optionType = "" // Name of options that gets used for accessing data and displaying information
      
    // from Paul Hegarty, lectures 13 and 14
    private let defaults = UserDefaults.standard // used to know if in show text mode or show icon mode
      
    @IBOutlet weak var back: UIButton! // back arrow button
      
    @IBOutlet var optionModView: UIView! // view within the view controller
      
    @IBOutlet var optionModTitle: UILabel! // label at top of screen
      
    @IBOutlet weak var optionOneButton: UIButton! // minus button on screen
    
    @IBOutlet weak var modifierValueLabel: UILabel! // label between the buttons that shows the current value
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var optionTwoButton: UIButton! // plus button on screen

    private var modifierValue = "" // current value of the stepper
    
    //TODO: get this dictionary from a plist
      // holds the different options for each multiple choice modifier type
      // the keys are the same as what gets put in the optionModTitle and are accessed by using optionType
      // the values are dictionaries of string : string that holds different attributes to be shown on thte screen
      // the minimum value is also the default value

    private let optionDictionary: [String:[String : String]] =
    ["Set Eye Light" :  ["attributeName" : "eyeLight", "Option 1" : "Off", "Option 2" : "On"],
     "If" : ["attributeName" : "booleanSelected", "Option 1" : "Hear voice", "Option 2" : "Obstacle sensed"]
    ]
            
    private var attributeName = "" // Used for accessing and saving data, taken from optionDictionary (ex. if optionType = "Wait for Time", attributeName is "wait"
      
    private var optionOne = "N/A"
    private var optionTwo = "N/A"
    
    // TODO: should buttonSize be the same value as blockSize?
    //private let buttonSize = 150 // the size of each stepper button
      
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
            
          optionOneButton.setImage(UIImage(named: optionOne), for: .normal)
          optionTwoButton.setImage(UIImage(named: optionTwo), for: .normal)
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
        optionOneButton.accessibilityIdentifier = optionOne
        optionTwoButton.accessibilityIdentifier = optionTwo
          for button in buttons {
              //Highlights current option when mod view is entered
              if modifierValue == button.accessibilityIdentifier {
                  button.layer.borderWidth = 10
                  button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
              }
          }
          
          updateModifierValueLabel()

          
          // accessibility
          
          //reroute VO Order to be more intuitive
          optionModView.accessibilityElements = [back!, optionModTitle!, optionOneButton!, modifierValueLabel!, optionTwoButton!]
          
          //Makes buttons easier to select with Voice Control
          if #available(iOS 13.0, *) {
              optionTwoButton.accessibilityUserInputLabels = ["Increase", "Plus", "Add"]
              optionOneButton.accessibilityUserInputLabels = ["Decrease", "Minus", "Subtract"]
          }
          optionModTitle.accessibilityLabel = optionType
      }
    
    /// given a variable name and its value, prints out an error statement if the value is "N/A"
    private func checkIfValueExists (variableName : String, value : String) {
        if value == "N/A" {
            print("\(variableName) in TwoOptionModifierViewController could not be found.")
        }
    }
    
    @IBAction func optionOnePressed(_ sender: Any) {
        
       modifierValue = optionOne
        modifierValueLabel.text = optionOne
        modifierValueLabel.accessibilityLabel = "\(optionType) is \(modifierValue)"
        
        optionTwoButton.layer.borderWidth = 0
        
        optionOneButton.layer.borderWidth = 10
        optionOneButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    }
    @IBAction func optionTwoPressed(_ sender: Any) {
        
        modifierValue = optionTwo
         modifierValueLabel.text = optionTwo
         modifierValueLabel.accessibilityLabel = "\(optionType) is \(modifierValue)"
         
         optionOneButton.layer.borderWidth = 0
         
         optionTwoButton.layer.borderWidth = 10
         optionTwoButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
     
    }
    
    /// Set text value of modifierValueLabel which is between the two stepper buttons
    private func updateModifierValueLabel () {
        modifierValueLabel.text = "\(modifierValue)"

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
        optionTwoButton.accessibilityLabel = "Increase. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
        optionOneButton.accessibilityLabel = "Decrease. Current value: \(modifierValueLabel.text ?? String(modifierValue))"
    }
      
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
          if segue.destination is BlocksViewController{
              // TODO: update so that just an array is used for images, so that soundSelected can be passed instead
              functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = "\(modifierValue)" // Tell BlocksViewController which sound was selected
          }
    }
}
