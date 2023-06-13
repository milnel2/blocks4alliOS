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
    var objectSelected: String = "buzz"

    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet var objectView: UIView!
    
    @IBOutlet var objectTitle: UILabel!
    override func viewDidLoad() {
        // VO route to be intuitive
        objectView.accessibilityElements = [objectTitle!, buttons!, back!]
        // default: Buzz or preserve last selection
        let previousObject: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["objectNoise"] ?? "buzz"
        
        objectSelected = previousObject
        
        for button in buttons {
            //Highlights current object when mod view is entered
            if objectSelected == button.accessibilityIdentifier {
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
            objectSelected = buttonID
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
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["objectNoise"] = objectSelected
        }
    }
}
