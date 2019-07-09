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
    var variableValue: Int = 0
    
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
                button.layer.borderColor = UIColor.green.cgColor
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
                button.layer.borderColor = UIColor.green.cgColor
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
                button.layer.borderColor = UIColor.green.cgColor
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
                button.layer.borderColor = UIColor.green.cgColor
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
                button.layer.borderColor = UIColor.green.cgColor
            }
        }

    }
    
    @IBOutlet weak var VariableValue: UITextField!
    
    @IBAction func VariableValue(_ sender: UITextField) {
        variableValue = Int(VariableValue?.text ?? "0") ?? 0
        viewTapped()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    
    
  
    @objc override func viewDidLoad() {
        super.viewDidLoad()
        
        VariableValue!.delegate = self
        
        let tapRecogniser = UITapGestureRecognizer()
        tapRecogniser.addTarget(self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tapRecogniser)
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
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
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] = "\(Int(variableValue))"
            
            
            
        }
    }
    
    
}

//keyboard code below from https://github.com/dzungnguyen1993/KeyboardHandling
// MARK: UITextFieldDelegate
extension SetVariableModViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
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
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintHeight.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintHeight.constant -= self.keyboardHeight
            
            self.scrollView.contentOffset = self.lastOffset
        }
        
        keyboardHeight = nil
    }
}

