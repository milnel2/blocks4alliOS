//
//  TurnVariable.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/9/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit

/**
 screen for selecting what variable should be used for turning left and right.
 **/
class TurnVariable: UIViewController {
    
    var modifierBlockIndexSender: Int?
    var variableSelected: String = "orange"
   
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var turnTitle: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //Deselects all buttons but currently selected one (only one can be selected at a time)
        self.buttons.forEach { (button) in
            button.layer.borderWidth = 0
            button.isSelected = false
                }
        //Selects pressed button
        sender.layer.borderWidth = 10
        sender.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        sender.isSelected = true
        if let buttonID = sender.accessibilityIdentifier {
            variableSelected = buttonID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change to custom font
        turnTitle.adjustsFontForContentSizeCategory = true
        angleLabel.adjustsFontForContentSizeCategory = true
        turnTitle.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        angleLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        
        // default: orange or preserve last selection
        let previousSelectedVariable: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] ?? "orange"
        
        variableSelected = previousSelectedVariable
        
        for button in buttons {
            //Highlights current variable when mod view is entered
            if variableSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
                button.isSelected = true
            }else{
                button.isSelected = false
            }
        }
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            print(variableSelected)
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
        }
    }
    
}

