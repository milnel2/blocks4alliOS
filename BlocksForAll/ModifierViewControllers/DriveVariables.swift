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
    
    
    @IBOutlet var buttons: [UIButton]!
    
    //speed buttons and labels
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var back: UIButton!
    
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
            speed = "Really Slow"
            speedLabel.text = speed
        default:
            print("can't be slowed")
        }
        updateAccessibilityLabel()
    }
    
    @IBAction func fastButtonPressed(_ sender: UIButton) {
        switch speed {
        case "Really Slow":
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
        updateAccessibilityLabel()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //Deselects all buttons but currently selected one (only one can be selected at a time)
        self.buttons.forEach { (button) in
            button.layer.borderWidth = 0
                }
        //Selects pressed button
        sender.layer.borderWidth = 10
        sender.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        if let buttonID = sender.accessibilityIdentifier {
            variableSelected = buttonID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Makes buttons easier to select with Voice Control
        if #available(iOS 13.0, *) {
            slowButton.accessibilityUserInputLabels = ["Slower", "Decrease", "Minus", "Subtract"]
            fastButton.accessibilityUserInputLabels = ["Faster", "Increase", "Plus", "Add"]
        }
    
        // preserves previously selected distance variable and speed value 
        speedLabel.text = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        speed = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] ?? "Normal"
        
        // default: orange or preserve last selection
        let previousSelectedVariableOne: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        
        variableSelected = previousSelectedVariableOne
        
        for button in buttons {
            //Highlights current variable when mod view is entered
            if variableSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
        
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speed"] = speed
        }
    }
    
    func updateAccessibilityLabel() {
        slowButton.accessibilityLabel = "Slower. Current speed: \(speed)"
        fastButton.accessibilityLabel = "Faster. Current speed: \(speed)"
    }
}
