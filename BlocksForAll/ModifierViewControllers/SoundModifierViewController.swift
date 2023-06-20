//
//  SoundModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/20/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class SoundModifierViewController: UIViewController{
    /* Custom view controller for the sound modifier scenes (ex. Animal Noise, Emotion Noise, etc.*/
    
    var modifierBlockIndexSender: Int?
    var soundSelected: String = "cat"
    var soundType = "animalNoise"
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet var soundModView: UIView!
    
    @IBOutlet var soundModTitle: UILabel!
    
    
    override func viewDidLoad() {
        
        //reroute VO Order to be more intuitive
        //animalModView.accessibilityElements = [animalTitle!,buttons!, back!]
        
        // default: Cat or preserve last selection
        let previousSound: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[soundType] ?? "cat"
        
        soundSelected = previousSound
        
        for button in buttons {
            //Highlights current animal when mod view is entered
            if soundSelected == button.accessibilityIdentifier {
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
        if let buttonID = sender.accessibilityIdentifier {
            soundSelected = buttonID
            sender.isSelected = true
        }
    }
    
    func createVoiceControlLabels(button: UIButton) {
        var voiceControlLabel = button.accessibilityLabel!
        let wordToRemove = " Noise"
        if let range = voiceControlLabel.range(of: wordToRemove){
            voiceControlLabel.removeSubrange(range)
        }
        
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(button.accessibilityLabel!)"]
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[soundType] = soundSelected
        }
    }
}

