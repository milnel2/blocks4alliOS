//
//  ObjectNoiseModViewController.swift
//  BlocksForAll
//
//  Created by Amanda Jackson on 7/8/21.
//  Copyright © 2021 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class ObjectNoiseModViewController: UIViewController{
    /* Custom view controller for the Object Noise modifier scene */
    
    var modifierBlockIndexSender: Int?
    var objectSelected: String = "random"

    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        // default: Random or preserve last selection
        let previousObject: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["objectNoise"] ?? "random"
        
        objectSelected = previousObject
        
        //Highlights current object when mod view is entered
        for button in buttons {
            if objectSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
        back.titleLabel?.adjustsFontForContentSizeCategory = true
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
            objectSelected = buttonID
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["objectNoise"] = objectSelected
        }
    }
}
