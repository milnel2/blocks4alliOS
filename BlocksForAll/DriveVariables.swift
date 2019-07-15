//
//  DriveVariables.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit


class DriveVariables: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableSelectedTwo: String = "orange"
    
    //distance variable buttons
    @IBOutlet weak var orangeDistanceButton: UIButton!
    @IBOutlet weak var bananaDistanceButton: UIButton!
    @IBOutlet weak var appleDistanceButton: UIButton!
    @IBOutlet weak var cherryDistanceButton: UIButton!
    @IBOutlet weak var watermelonDistanceButton: UIButton!
    
    //speed variable buttons
    @IBOutlet weak var orangeSpeedButton: UIButton!
    @IBOutlet weak var bananaSpeedButton: UIButton!
    @IBOutlet weak var appleSpeedButton: UIButton!
    @IBOutlet weak var cherrySpeedButton: UIButton!
    @IBOutlet weak var watermelonSpeedButton: UIButton!
    
    
    
    func deselectAllDistance(){
        orangeDistanceButton.layer.borderWidth = 0
        bananaDistanceButton.layer.borderWidth = 0
        cherryDistanceButton.layer.borderWidth = 0
        watermelonDistanceButton.layer.borderWidth = 0
        appleDistanceButton.layer.borderWidth = 0
    }
    
    func deselectAllSpeed(){
        orangeSpeedButton.layer.borderWidth = 0
        bananaSpeedButton.layer.borderWidth = 0
        cherrySpeedButton.layer.borderWidth = 0
        watermelonSpeedButton.layer.borderWidth = 0
        appleSpeedButton.layer.borderWidth = 0
    }
    
    //Reference for knowing which button is selected
    // https://stackoverflow.com/questions/33906060/select-deselect-buttons-swift-xcode-7
    //distance buttons
    @IBAction func orangeDistancePressed(_ sender: Any) {
        variableSelected = "orange"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllDistance()
//                variableValue = variableDict["orange"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    

    @IBAction func bananaDistancePressed(_ sender: Any) {
        variableSelected = "banana"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllDistance()
//                variableValue = variableDict["banana"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleDistancePressed(_ sender: Any) {
        variableSelected = "apple"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllDistance()
//                variableValue = variableDict["apple"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherryDistancePressed(_ sender: Any) {
        variableSelected = "cherry"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllDistance()
//                variableValue = variableDict["cherry"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    @IBAction func watermelonDistancePressed(_ sender: Any) {
        variableSelected = "melon"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllDistance()
//                variableValue = variableDict["watermelon"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func orangeSpeedPressed(_ sender: Any) {
        variableSelectedTwo = "orange"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllSpeed()
//                variableValueTwo = variableDict["orange"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func bananaSpeedPressed(_ sender: Any) {
        variableSelectedTwo = "banana"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllSpeed()
//                variableValueTwo = variableDict["banana"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func appleSpeedPressed(_ sender: Any) {
        variableSelectedTwo = "apple"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllSpeed()
//                variableValueTwo = variableDict["apple"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func cherrySpeedPressed(_ sender: Any) {
        variableSelectedTwo = "cherry"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllSpeed()
//                variableValueTwo = variableDict["cherry"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func watermelonSpeedPressed(_ sender: Any) {
        variableSelectedTwo = "melon"
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAllSpeed()
//                variableValueTwo = variableDict["watermelon"]!
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var previousSelectedVariableOne: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        var previousSelectedVariableTwo: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelectedTwo"] ?? "orange"
        
        variableSelected = previousSelectedVariableOne
        variableSelectedTwo = previousSelectedVariableTwo
        
        switch variableSelected{
        case "orange":
            orangeDistanceButton.layer.borderWidth = 10
            orangeDistanceButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "cherry":
            cherryDistanceButton.layer.borderWidth = 10
            cherryDistanceButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "melon":
            watermelonDistanceButton.layer.borderWidth = 10
            watermelonDistanceButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "apple":
            appleDistanceButton.layer.borderWidth = 10
            appleDistanceButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "banana":
            bananaDistanceButton.layer.borderWidth = 10
            bananaDistanceButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            orangeDistanceButton.layer.borderWidth = 0
        }
        switch variableSelectedTwo{
        case "orange":
            orangeSpeedButton.layer.borderWidth = 10
            orangeSpeedButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "cherry":
            cherrySpeedButton.layer.borderWidth = 10
            cherrySpeedButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "melon":
            watermelonSpeedButton.layer.borderWidth = 10
            watermelonSpeedButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "apple":
            appleSpeedButton.layer.borderWidth = 10
            appleSpeedButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        case "banana":
            bananaSpeedButton.layer.borderWidth = 10
            bananaSpeedButton.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
        default:
            orangeSpeedButton.layer.borderWidth = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelectedTwo"] = variableSelectedTwo
        }
    }
    
}
