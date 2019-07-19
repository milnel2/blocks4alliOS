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
        variableSelected = "orange"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
 
    @IBAction func bananaTurnPressed(_ sender: Any) {
        variableSelected = "banana"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleTurnPressed(_ sender: Any) {
        variableSelected = "apple"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherryTurnPressed(_ sender: Any) {
        variableSelected = "cherry"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func watermelonTurnPressed(_ sender: Any) {
        variableSelected = "melon"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllTurns()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var previousSelectedVariable: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        
        variableSelected = previousSelectedVariable
        
        switch variableSelected{
        case "orange":
            orangeTurnButton.layer.borderWidth = 10
            orangeTurnButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "cherry":
            cherryTurnButton.layer.borderWidth = 10
            cherryTurnButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "melon":
            watermelonTurnButton.layer.borderWidth = 10
            watermelonTurnButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "apple":
            appleTurnButton.layer.borderWidth = 10
            appleTurnButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "banana":
            bananaTurnButton.layer.borderWidth = 10
            bananaTurnButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            orangeTurnButton.layer.borderWidth = 0
        }
    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            print(variableSelected)
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
        }
    }
    
}

