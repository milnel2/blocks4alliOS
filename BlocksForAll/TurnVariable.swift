//
//  TurnVariable.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit


class TurnVariable: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableValue: Int = 0
    
    @IBOutlet weak var orangeTurnButton: UIButton!
    @IBOutlet weak var bananaTurnButton: UIButton!
    @IBOutlet weak var appleTurnButton: UIButton!
    @IBOutlet weak var cherryTurnButton: UIButton!
    @IBOutlet weak var watermelonTurnButton: UIButton!
    
    
    func deselectAllTurns(){
        orangeTurnButton.layer.borderWidth = 0
        bananaTurnButton.layer.borderWidth = 0
        cherryTurnButton.layer.borderWidth = 0
        watermelonTurnButton.layer.borderWidth = 0
        appleTurnButton.layer.borderWidth = 0
    }
    
    //Reference for knowing which button is selected
    //https://stackoverflow.com/questions/33906060/select-deselect-buttons-swift-xcode-7
    
    @IBAction func orangeTurnPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                variableValue = variableDict["orange"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
 
    @IBAction func bananaTurnPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                variableValue = variableDict["banana"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleTurnPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                variableValue = variableDict["apple"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherryTurnPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                variableValue = variableDict["cherry"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func watermelonTurnPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                variableValue = variableDict["watermelon"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableValue"] = "\(Int(variableValue))"
            
            
            
        }
    }
    
}

