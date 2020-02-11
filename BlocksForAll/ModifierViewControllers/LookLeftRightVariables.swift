//
//  LookLeftRightVariables.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

/**
 screen for selecting what variables should be used for looking left and right.
 **/
class LookLeftRightVariables: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    
    //left/right look variable buttons
    @IBOutlet weak var orangeLookButton: UIButton!
    @IBOutlet weak var bananaLookButton: UIButton!
    @IBOutlet weak var appleLookButton: UIButton!
    @IBOutlet weak var cherryLookButton: UIButton!
    @IBOutlet weak var watermelonLookButton: UIButton!
    
    
    func deselectAllLeft(){
        orangeLookButton.layer.borderWidth = 0
        bananaLookButton.layer.borderWidth = 0
        cherryLookButton.layer.borderWidth = 0
        watermelonLookButton.layer.borderWidth = 0
        appleLookButton.layer.borderWidth = 0
    }
    
    
    //Reference for knowing which button is selected
    // https://stackoverflow.com/questions/33906060/select-deselect-buttons-swift-xcode-7
    @IBAction func orangePressed(_ sender: Any) {
        //Border when button is selected
        variableSelected = "orange"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func bananaPressed(_ sender: Any) {
        //Border when button is selected
        variableSelected = "banana"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func applePressed(_ sender: Any) {
        //Border when button is selected
        variableSelected = "apple"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func cherryPressed(_ sender: Any) {
        //Border when button is selected
        variableSelected = "cherry"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func watermelonPressed(_ sender: Any) {
        //Border when button is selected
        variableSelected = "melon"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllLeft()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let previousSelectedVariableOne: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        
        variableSelected = previousSelectedVariableOne
        
        switch variableSelected{
        case "orange":
            orangeLookButton.layer.borderWidth = 10
            orangeLookButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "cherry":
            cherryLookButton.layer.borderWidth = 10
            cherryLookButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "melon":
            watermelonLookButton.layer.borderWidth = 10
            watermelonLookButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "apple":
            appleLookButton.layer.borderWidth = 10
            appleLookButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "banana":
            bananaLookButton.layer.borderWidth = 10
            bananaLookButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            orangeLookButton.layer.borderWidth = 0
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            print(variableSelected)
//            print(variableValue)
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
    
            
        }
    }
    
}


