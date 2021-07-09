//
//  EmotionModViewController.swift
//  BlocksForAll
//
//  Created by Amanda Jackson on 7/8/21.
//  Copyright © 2021 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class EmotionModViewController: UIViewController{
    /* Custom view controller for the Emotion Noise modifier scene */
    
    var modifierBlockIndexSender: Int?
    var emotionSelected: String = "bragging"
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        // default: Bragging or preserve last selection
        let previousEmotion: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["emotionNoise"] ?? "bragging"
        
        emotionSelected = previousEmotion
        
        //Highlights current emotion when mod view is entered
        for button in buttons {
            if emotionSelected == button.accessibilityIdentifier {
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
            emotionSelected = buttonID
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["emotionNoise"] = emotionSelected
        }
    }
}
