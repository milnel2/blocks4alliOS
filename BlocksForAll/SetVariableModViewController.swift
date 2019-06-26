//
//  SetVariableModViewController.swift
//  BlocksForAll
//
//  Created by Nana Adwoa Odeibea Amoah on 6/25/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

class SetVariableModViewController: UIViewController, UITextFieldDelegate{
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableValue: Int = 0
    
    @IBAction func OrangeVariable(_ sender: Any) {
        variableSelected = "orange"
    }
    
    
    @IBAction func WatermelonVariable(_ sender: Any) {
        variableSelected = "watermelon"
    }
    
    @IBAction func CherryVariable(_ sender: Any) {
        variableSelected = "cherry"
    }
    
    
    @IBAction func BananaVariable(_ sender: Any) {
        variableSelected = "banana"
    }
    
    
    @IBAction func AppleVariable(_ sender: Any) {
        variableSelected = "apple"
    }
    
    @IBOutlet weak var VariableValue: UITextField!
    
    @IBAction func VariableValue(_ sender: UITextField) {
        variableValue = Int(VariableValue?.text ?? "0") ?? 0
        viewTapped()
    }
    
    
    /** https://appsandbiscuits.com/getting-what-the-user-typed-ios-7-2e56a678e7a7
     help from Andy O'Sullivan regarding how to dismiss keyboard when return clicked **/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == VariableValue {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VariableValue!.delegate = self
        
        let tapRecogniser = UITapGestureRecognizer()
        tapRecogniser.addTarget(self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tapRecogniser)
    }
    
    @objc func viewTapped(){
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] = "\(Int(variableValue))"
            
            
            
        }
    }
    
    
}

