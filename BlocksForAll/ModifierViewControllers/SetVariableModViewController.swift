//
//  SetVariableModViewController.swift
//  BlocksForAll
//
//  Created by Nana Adwoa Odeibea Amoah on 6/25/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

class SetVariableModViewController: UIViewController {
    /* Screen for selecting a variable and setting its value*/
    
    // Variable variables
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    // Initialize the variable selected and variable value
    var variableSelected: String = "orange"
    var variableValue: Double = 0.0

    // View Controller Elements
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var setVariableTitle: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var setVarView: UIView!
    @IBOutlet var setVarTitle: UILabel!
    @IBOutlet var variableValueInput: UITextField!
    var activeField: UITextField?
    
    /// Deselects all buttons but currently selected one (only one can be selected at a time)
    @IBAction func buttonPressed(_ sender: UIButton) {
        if let buttonID = sender.accessibilityIdentifier {
            variableSelected = buttonID
        }
        updateScreen()
    }
    
    /// Stores variable value when variableValueInput has a value entered
    @IBAction func VariableValue(_ sender: UITextField) {
        variableValue = Double(variableValueInput?.text ?? "0") ?? 0
        viewTapped()
    }
    
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        // Preserves previously selected variable or default variable (orange)
        let previousSetVariable: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        variableSelected = previousSetVariable
        
        // Preserves previously selected variable value or default value (0.0)
        let previousVariableValue: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] ?? "0.0"
        variableValue = Double(previousVariableValue) ?? 0.0
        
        variableValueInput!.delegate = self
        
        // Below code brings up number keyboard when variable value text field clicked.
        let tapRecogniser = UITapGestureRecognizer()
        tapRecogniser.addTarget(self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tapRecogniser)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add touch gesture for contentView
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        // Update screen
        updateScreen()
        
        // Accessibility
        // VoiceOver
        setVarView.accessibilityElements = [back!, setVariableTitle!, buttons!, valueLabel!, variableValueInput!, descriptionLabel!]
        // Voice Control
        if #available(iOS 13.0, *) {
            variableValueInput.accessibilityUserInputLabels = ["Value"]
        }
        // Dynamic Text
        setFontStyle()
    }
    
    /// Call whenever data is changed to update the screen to match it
    private func updateScreen() {
        for button in buttons {
            //Highlights current variable and deselects all others
            if variableSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
                button.isSelected = true
            } else {
                button.layer.borderWidth = 0
                button.isSelected = false
            }
        }
        variableValueInput.text = String(variableValue)
    }
    
    /** https://appsandbiscuits.com/getting-what-the-user-typed-ios-7-2e56a678e7a7
     Help from Andy O'Sullivan regarding how to dismiss keyboard when return clicked **/
    @objc func viewTapped(){
        self.view.endEditing(true)
    }
    
    /// Returns actual field for the variable value text
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    /// Set all labels to custom font
    private func setFontStyle() {
        setVariableTitle.adjustsFontForContentSizeCategory = true
        setVariableTitle.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController {
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] = "\(Double(variableValue))"
        }
    }
}

//keyboard code below from https://github.com/dzungnguyen1993/KeyboardHandling
// MARK: UITextFieldDelegate
extension SetVariableModViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    //can hit return when value entered into number pad
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

// MARK: Keyboard Handling
extension SetVariableModViewController{
    // When keyboard appears, the text on the set variable page is all shifted up so nothing is covered by the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    //when keyboard no longer being used, it disappears and the original set variable view is restored
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

