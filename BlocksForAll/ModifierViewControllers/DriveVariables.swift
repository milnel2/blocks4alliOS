//
//  DriveVariables.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

/**
screen for selecting what variable should be used for driving forward or backward.
**/
class DriveVariables: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
    var variableSelectedTwo: String = "orange"
    var speed: String = "Normal"
    
    //distance variable buttons
    @IBOutlet weak var orangeDistanceButton: UIButton!
    @IBOutlet weak var bananaDistanceButton: UIButton!
    @IBOutlet weak var appleDistanceButton: UIButton!
    @IBOutlet weak var cherryDistanceButton: UIButton!
    @IBOutlet weak var watermelonDistanceButton: UIButton!
    
    //speed buttons and labels
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    
    
    //guarantees only one variable is visibly selected at once
    func deselectAllDistance(){
        orangeDistanceButton.layer.borderWidth = 0
        bananaDistanceButton.layer.borderWidth = 0
        cherryDistanceButton.layer.borderWidth = 0
        watermelonDistanceButton.layer.borderWidth = 0
        appleDistanceButton.layer.borderWidth = 0
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
                button.isSelected = true
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    //possible speed options for when the steppers are clicked
    @IBAction func slowButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Really Fast":
            speed = "Fast"
            speedLabel.text = speed
        case "Fast":
            speed = "Normal"
            speedLabel.text = speed
        case "Normal":
            speed = "Slow"
            speedLabel.text = speed
        case "Slow":
            speed = "Very Slow"
            speedLabel.text = speed
        default:
            print("can't be slowed")
        }
    }
    
    @IBAction func fastButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Very Slow":
            speed = "Slow"
            speedLabel.text = speed
        case "Slow":
            speed = "Normal"
            speedLabel.text = speed
        case "Normal":
            speed = "Fast"
            speedLabel.text = speed
        case "Fast":
            speed = "Really Fast"
            speedLabel.text = speed
        default:
            print("can't make faster")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // preserves previously selected distance variable and speed value 
        speedLabel.text = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        speed = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        
        let previousSelectedVariableOne: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        
        variableSelected = previousSelectedVariableOne
        
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
    }
    
}
