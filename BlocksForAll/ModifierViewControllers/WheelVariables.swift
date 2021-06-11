//
//  WheelVariables.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

/**
 screen for selecting what variables should be used for the left and right wheel speeds of robot.
 **/
class WheelVariables: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableSelectedTwo: String = "orange"

    
    //left wheel buttons
    @IBOutlet weak var orangeWheelLButton: UIButton!
    @IBOutlet weak var bananaWheelLButton: UIButton!
    @IBOutlet weak var appleWheelLButton: UIButton!
    @IBOutlet weak var cherryWheelLButton: UIButton!
    @IBOutlet weak var watermelonWheelLButton: UIButton!
    
    //right wheel buttons
    @IBOutlet weak var orangeWheelRButton: UIButton!
    @IBOutlet weak var bananaWheelRButton: UIButton!
    @IBOutlet weak var appleWheelRButton: UIButton!
    @IBOutlet weak var cherryWheelRButton: UIButton!
    @IBOutlet weak var watermelonWheelRButton: UIButton!
    
    
    
    func deselectAllLeft(){
        orangeWheelLButton.layer.borderWidth = 0
        bananaWheelLButton.layer.borderWidth = 0
        cherryWheelLButton.layer.borderWidth = 0
        watermelonWheelLButton.layer.borderWidth = 0
        appleWheelLButton.layer.borderWidth = 0
    }
    
    func deselectAllRight(){
        orangeWheelRButton.layer.borderWidth = 0
        bananaWheelRButton.layer.borderWidth = 0
        cherryWheelRButton.layer.borderWidth = 0
        watermelonWheelRButton.layer.borderWidth = 0
        appleWheelRButton.layer.borderWidth = 0
    }
    
    //Reference for knowing which button is selected
    //https://stackoverflow.com/questions/33906060/select-deselect-buttons-swift-xcode-7
    
    //when left wheel pressed
    @IBAction func orangeLeftPressed(_ sender: Any) {
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
    
    @IBAction func bananaLeftPressed(_ sender: Any) {
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
    
    @IBAction func appleLeftPressed(_ sender: Any) {
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
    
    @IBAction func cherryLeftPressed(_ sender: Any) {
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
    @IBAction func watermelonLeftPressed(_ sender: Any) {
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
    
    
    //when right wheel pressed
    @IBAction func orangeRightPressed(_ sender: Any) {
        variableSelectedTwo = "orange"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func bananaRightPressed(_ sender: Any) {
        variableSelectedTwo = "banana"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleRightPressed(_ sender: Any) {
        variableSelectedTwo = "apple"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherryRightPressed(_ sender: Any) {
        variableSelectedTwo = "cherry"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func watermelonRightPressed(_ sender: Any) {
        variableSelectedTwo = "melon"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllRight()
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    //saves previous selected variables when re-entering wheel variable page
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let previousSelectedVariableOne: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        let previousSelectedVariableTwo: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelectedTwo"] ?? "orange"
        
        variableSelected = previousSelectedVariableOne
        variableSelectedTwo = previousSelectedVariableTwo
        
        switch variableSelected{
        case "orange":
            orangeWheelLButton.layer.borderWidth = 10
            orangeWheelLButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "cherry":
            cherryWheelLButton.layer.borderWidth = 10
            cherryWheelLButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "melon":
            watermelonWheelLButton.layer.borderWidth = 10
            watermelonWheelLButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "apple":
            appleWheelLButton.layer.borderWidth = 10
            appleWheelLButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "banana":
            bananaWheelLButton.layer.borderWidth = 10
            bananaWheelLButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            orangeWheelLButton.layer.borderWidth = 0
        }
        switch variableSelectedTwo{
        case "orange":
            orangeWheelRButton.layer.borderWidth = 10
            orangeWheelRButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "cherry":
            cherryWheelRButton.layer.borderWidth = 10
            cherryWheelRButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "melon":
            watermelonWheelRButton.layer.borderWidth = 10
            watermelonWheelRButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "apple":
            appleWheelRButton.layer.borderWidth = 10
            appleWheelRButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "banana":
            bananaWheelRButton.layer.borderWidth = 10
            bananaWheelRButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            orangeWheelRButton.layer.borderWidth = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelectedTwo"] = variableSelectedTwo
        }
    }
    
}


