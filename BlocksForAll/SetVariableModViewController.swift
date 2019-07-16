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
    
    var modifierBlockIndexSender: Int?
    
    var variableSelected: String = "orange"
    var variableValue: Double = 0.0

    
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var bananaButton: UIButton!
    @IBOutlet weak var cherryButton: UIButton!
    @IBOutlet weak var watermelonButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!

    
    func deselectAll(){
        orangeButton.layer.borderWidth = 0
        bananaButton.layer.borderWidth = 0
        cherryButton.layer.borderWidth = 0
        watermelonButton.layer.borderWidth = 0
        appleButton.layer.borderWidth = 0
    }
    
    //Reference for knowing which button is selected
    // https://stackoverflow.com/questions/33906060/select-deselect-buttons-swift-xcode-7
    
    @IBAction func OrangeVariable(_ sender: Any) {
        variableSelected = "orange"
        
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    
    @IBAction func MelonVariable(_ sender: Any) {
        variableSelected = "melon"
        
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func CherryVariable(_ sender: Any) {
        variableSelected = "cherry"
        
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    
    @IBAction func BananaVariable(_ sender: Any) {
        variableSelected = "banana"
        
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }

    }
    
    
    @IBAction func AppleVariable(_ sender: Any) {
        variableSelected = "apple"
        
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }

    }
    
    @IBOutlet weak var VariableValue: UITextField!
    
    @IBAction func VariableValue(_ sender: UITextField) {
        variableValue = Double(VariableValue?.text ?? "0") ?? 0
        viewTapped()
    }
    
    var activeField: UITextField?
    
  
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        
        var previousSetVariable: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
//        var previousModifierBlockColor = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["modifierBlockColor"] ?? "purple"
        variableSelected = previousSetVariable
        
        switch variableSelected{
        case "orange":
            orangeButton.layer.borderWidth = 10
            orangeButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "cherry":
            cherryButton.layer.borderWidth = 10
            cherryButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "melon":
            watermelonButton.layer.borderWidth = 10
            watermelonButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "apple":
            appleButton.layer.borderWidth = 10
            appleButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "banana":
            bananaButton.layer.borderWidth = 10
            bananaButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            orangeButton.layer.borderWidth = 0
        }
        
        VariableValue!.delegate = self
        
        let tapRecogniser = UITapGestureRecognizer()
        tapRecogniser.addTarget(self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tapRecogniser)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add touch gesture for contentView
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    /** https://appsandbiscuits.com/getting-what-the-user-typed-ios-7-2e56a678e7a7
     help from Andy O'Sullivan regarding how to dismiss keyboard when return clicked **/
    @objc func viewTapped(){
        self.view.endEditing(true)
    }
    
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
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] = "\(Double(variableValue))"
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
}

// MARK: Keyboard Handling
extension SetVariableModViewController{
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

