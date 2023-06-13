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
    
    @IBOutlet var speakModView: UIView!

    @IBOutlet var speakModTitle: UILabel!
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        
        
        // default: Hi or preserve last selection
        let previousWord: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speakWord"] ?? "hi"
        
        wordSelected = previousWord
        
        for button in buttons {
            //Highlights current word when mod view is entered
            if wordSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
                button.isSelected = true
            }else{
                button.isSelected = false
            }
            createVoiceControlLabels(button: button)
        }
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    
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
            wordSelected = buttonID
        }
    }
    
    func createVoiceControlLabels(button: UIButton) {
        var voiceControlLabel = button.accessibilityLabel!
        let wordToRemove = "Say "
        if let range = voiceControlLabel.range(of: wordToRemove){
            voiceControlLabel.removeSubrange(range)
        }
        
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(button.accessibilityLabel!)"]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["speakWord"] = wordSelected
        }
    }
}
