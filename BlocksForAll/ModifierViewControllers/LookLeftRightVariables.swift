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
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet var lookLRView: UIView!
    
    @IBOutlet var LRvalue: UILabel!
    
    @IBOutlet var maxminTitle: UILabel!
    
    @IBOutlet var lookLRLabel: UILabel!
    
    @IBOutlet var lookLRTitle: UILabel!
    
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
            print(variableSelected)
//            print(variableValue)
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["variableSelected"] = variableSelected
        }
    }
}


