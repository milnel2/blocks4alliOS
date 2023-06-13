//
//  EyeLightModifierViewController.swift
//  BlocksForAll
//
//  Created by Katie McCarthy on 6/24/19.
//  Copyright © 2019 Katie McCarthy. All rights reserved.
//

import Foundation
import UIKit

//this class switches eyelight off and on at this screen
class EyeLightModifierViewController: UIViewController{
    
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet var eyeLightView: UIView!

    @IBOutlet var eyeLightTitle: UILabel!
    
    @IBOutlet weak var lightLabel: UILabel!
    
    var modifierBlockIndexSender: Int?
    var eyeLightStatus: String = "On"
    
    @IBOutlet weak var back: UIButton!
    
    override func viewDidLoad() {
        //VO route to be more intuitive
        eyeLightView.accessibilityElements = [eyeLightTitle!, buttons!, lightLabel!, back!]
        
        // default status: On or preserve last selection
        
        let previousSelection: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] ?? "Off"
        
        lightLabel.text = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] ?? "Off"
        
        eyeLightStatus = previousSelection
        
        for button in buttons {
            //Highlights current option when mod view is entered
            if eyeLightStatus == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
        
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    //changes status and label on screen
    @IBAction func onButtonPressed(_ sender: UIButton) {
        eyeLightStatus = "On"
        lightLabel.text = "On"
        lightLabel.accessibilityLabel = "Eye Light is On"
        
        self.buttons.forEach { (button) in
            button.layer.borderWidth = 0
                }
        sender.layer.borderWidth = 10
        sender.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    }
    
    //changes status and label on screen
    @IBAction func offButtonPressed(_ sender: UIButton) {
        eyeLightStatus = "Off"
        lightLabel.text = "Off"
        lightLabel.accessibilityLabel = "Eye Light is Off"
        
        self.buttons.forEach { (button) in
            button.layer.borderWidth = 0
                }
        sender.layer.borderWidth = 10
        sender.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["eyeLight"] = "\(eyeLightStatus)"
        }
    }
}

