//
//  SetVariableModViewController.swift
//  BlocksForAll
//
//  Created by Nana Adwoa Odeibea Amoah on 6/25/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

/**
 this class allows users to select a variable and set its value
 **/
class SetVariableModViewController: UIViewController {
    
    var modifierBlockIndexSender: Int?
    
    //initialize the variable selected and variable value
    var variableSelected: String = "orange"
    var variableValue: Double = 0.0

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var back: UIButton!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //Deselects all buttons but currently selected one (only one can be selected at a time)
        self.buttons.forEach { (button) in
            button.layer.borderWidth = 0
                }
        //Selects pressed button
        sender.layer.borderWidth = 10
        sender.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        if let buttonID = sender.accessibilityIdentifier {
            variableSelected = buttonID
        }
    }
    
    @IBOutlet weak var VariableValue: UITextField!
    
    //stores variable value when entered
    @IBAction func VariableValue(_ sender: UITextField) {
        variableValue = Double(VariableValue?.text ?? "0") ?? 0
        viewTapped()
    }
    
    var activeField: UITextField?
    
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        
        //Makes text field easier to select with Voice Control
        if #available(iOS 13.0, *) {
            VariableValue.accessibilityUserInputLabels = ["Value"]
        }
        
        // default: orange or preserve last selection
        let previousSetVariable: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"

        variableSelected = previousSetVariable
        
        for button in buttons {
            //Highlights current animal when mod view is entered
            if variableSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
        
        VariableValue!.delegate = self
        
        //below code brings up number keyboard when variable value text field clicked.
        let tapRecogniser = UITapGestureRecognizer()
        tapRecogniser.addTarget(self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tapRecogniser)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add touch gesture for contentView
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    /** https://appsandbiscuits.com/getting-what-the-user-typed-ios-7-2e56a678e7a7
     help from Andy O'Sullivan regarding how to dismiss keyboard when return clicked **/
    @objc func viewTapped(){
        self.view.endEditing(true)
    }
    
    //returns actual field for the variable value text
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
//            variableDict.updateValue(variableValue, forKey: variableSelected)
//            print(variableDict)
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
    // when keyboard appears, the text on the set variable page is all shifted up so nothing is covered by the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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

