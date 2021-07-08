//
//  SpeakModViewController.swift
//  BlocksForAll
//
//  Created by Amanda Jackson on 7/8/21.
//  Copyright © 2021 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class SpeakModViewController: UIViewController{
    /* Custom view controller for the Speak modifier scene */
    
    var modifierBlockIndexSender: Int?
    var wordSelected: String = "hi"
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        // default: Hi or preserve last selection
        let previousWord: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speakWord"] ?? "hi"
        
        wordSelected = previousWord
        
        //Highlights current word when mod view is entered
        for button in buttons {
            if wordSelected == button.accessibilityIdentifier {
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
            wordSelected = buttonID
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speakWord"] = wordSelected
        }
    }
}
