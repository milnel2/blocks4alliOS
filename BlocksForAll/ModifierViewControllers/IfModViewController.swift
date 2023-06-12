//
//  IfModViewController.swift
//  BlocksForAll
//
//  Created by Nana Adwoa Odeibea Amoah on 7/4/19.
//  Copyright © 2019 Nana Amoah. All rights reserved.
//

import Foundation
import UIKit


class IfModViewController: UIViewController{
    /* Custom view controller for the Repeat modifier scene */
    
    var modifierBlockIndexSender: Int?
    //default is always false
    var booleanSelected: String = "false"
    
    
    @IBOutlet var ifSceneView: UIView!
    
    @IBOutlet var ifTitle: UILabel!

    @IBOutlet var button1: UIButton!
    
    @IBOutlet var button2: UIButton!
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var back: UIButton!
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //Deselects all buttons but currently selected one (only one can be selected at a time)
        self.buttons.forEach { (button) in
            button.layer.borderWidth = 0
                }
        //Selects pressed button
        sender.layer.borderWidth = 10
        sender.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        if let buttonID = sender.accessibilityIdentifier {
            booleanSelected = buttonID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //VO Route to be more intuitive
        ifSceneView.accessibilityElements = [ifTitle!, button1!, button2!, back!]
        
        // default: false or preserve last selection
        let previousBooleanSelected: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["booleanSelected"] ?? "false"
        booleanSelected = previousBooleanSelected
        
        for button in buttons {
            //Highlights current selection when mod view is entered
            if booleanSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["booleanSelected"] = booleanSelected
        }
    }
}
