//
//  LookLeftRightVariables.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit


class LookLeftRightVariables: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableValue: Int = 0
    
    //left look variable buttons
    @IBOutlet weak var orangeLookLButton: UIButton!
    @IBOutlet weak var bananaLookLButton: UIButton!
    @IBOutlet weak var appleLookLButton: UIButton!
    @IBOutlet weak var cherryLookLButton: UIButton!
    @IBOutlet weak var watermelonLookLButton: UIButton!
    
    //right look variable buttons
    @IBOutlet weak var orangeLookRButton: UIButton!
    @IBOutlet weak var bananaLookRButton: UIButton!
    @IBOutlet weak var appleLookRButton: UIButton!
    @IBOutlet weak var cherryLookRButton: UIButton!
    @IBOutlet weak var watermelonLookRButton: UIButton!
    
    
    func deselectAllLeft(){
        orangeLookLButton.layer.borderWidth = 0
        bananaLookLButton.layer.borderWidth = 0
        cherryLookLButton.layer.borderWidth = 0
        watermelonLookLButton.layer.borderWidth = 0
        appleLookLButton.layer.borderWidth = 0
    }
    
    func deselectAllRight(){
        orangeLookRButton.layer.borderWidth = 0
        bananaLookRButton.layer.borderWidth = 0
        cherryLookRButton.layer.borderWidth = 0
        watermelonLookRButton.layer.borderWidth = 0
        appleLookRButton.layer.borderWidth = 0
    }
    
    
    
    //Reference for knowing which button is selected
    // https://stackoverflow.com/questions/33906060/select-deselect-buttons-swift-xcode-7
    //look left pressed
    @IBAction func orangeLeftPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                variableValue = variableDict["orange"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func bananaLeftPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                variableValue = variableDict["banana"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleLeftPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                variableValue = variableDict["apple"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func cherryLeftPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                variableValue = variableDict["cherry"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func watermelonLeftPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                variableValue = variableDict["watermelon"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    //look right pressed
    @IBAction func orangeRightPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                variableValue = variableDict["orange"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func bananaRightPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                variableValue = variableDict["banana"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func appleRightPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                variableValue = variableDict["apple"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherryRightPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                variableValue = variableDict["cherry"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func watermelonRightPressed(_ sender: Any) {
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
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


