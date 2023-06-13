//
//  ColorModViewController.swift
//  BlocksForAll
//
//  Created by admin on 6/19/19.
//  Copyright © 2019 Jacqueline Ong. All rights reserved.
//

import Foundation
import UIKit

class ColorModViewController: UIViewController{
    /* Custom view controller for the Color modifier scene */
    
    var modifierBlockIndexSender: Int?
    var colorSelected: String = "yellow"
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var ColorTitle: UILabel!
    @IBOutlet var colorView: UIView!
    
    override func viewDidLoad() {
        // default color: Yellow or preserve last selection
        let previousLightColor: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] ?? "yellow"
        
        colorSelected = previousLightColor
        
        //Highlights current color when mod view is entered
        for button in buttons {
            //print(button.accessibilityLabel?.lowercased())
            if colorSelected == button.accessibilityLabel?.lowercased() {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
                //button.accessibilityLabel = (button.accessibilityLabel ?? colorSelected) + " selected"
                button.isSelected = true
            }else{
                button.isSelected = false
            }
        }
        adjustFontSizes()
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
            colorSelected = buttonID
            print("Color selected: \(colorSelected)")

        }
        
//        if let buttonTitle = sender.title(for: .normal) {
//            colorSelected = buttonTitle.lowercased()
//            print("Color selected: \(colorSelected)")
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] = colorSelected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["modifierBlockColor"] = colorSelected
        }
    }
    
    func adjustFontSizes() {
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        for button in buttons {
            button.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
}
