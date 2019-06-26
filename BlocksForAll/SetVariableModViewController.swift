//
//  SetVariableModViewController.swift
//  BlocksForAll
//
//  Created by Nana Adwoa Odeibea Amoah on 6/25/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

class SetVariableModViewController: UIViewController{
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableValue: Int?
    
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
        variableValue = Int(VariableValue.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] = "\(Int(variableValue!))"
            
            

        }
    }
    
    
}
