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
    var colorSelected: String = "white"
    
    //color options for Dash's lights
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var back: UIButton!
    
    
    //only one color ever going to be highlighted after this function called
    func deselectAll(){
        blackButton.layer.borderWidth = 0
        redButton.layer.borderWidth = 0
        orangeButton.layer.borderWidth = 0
        yellowButton.layer.borderWidth = 0
        greenButton.layer.borderWidth = 0
        blueButton.layer.borderWidth = 0
        purpleButton.layer.borderWidth = 0
        whiteButton.layer.borderWidth = 0
    }
    
    
    override func viewDidLoad() {
        // default color: Purple or preserve last selection
        let previousLightColor: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] ?? "purple"
        let previousModifierBlockColor = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["modifierBlockColor"] ?? "purple"
        
        colorSelected = previousLightColor
        colorSelected = previousModifierBlockColor
        
        switch colorSelected{
        case "black":
            blackButton.layer.borderWidth = 10
            blackButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case "purple":
            purpleButton.layer.borderWidth = 10
            purpleButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case "green":
            greenButton.layer.borderWidth = 10
            greenButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case "red":
            redButton.layer.borderWidth = 10
            redButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case "blue":
            blueButton.layer.borderWidth = 10
            blueButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case "yellow":
            yellowButton.layer.borderWidth = 10
            yellowButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case "white":
            whiteButton.layer.borderWidth = 10
            whiteButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        case "orange":
            orangeButton.layer.borderWidth = 10
            orangeButton.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        default:
            purpleButton.layer.borderWidth = 0
        }
        
        adjustFontSizes()
    }
    
    func selectOrDeselectColor(button: UIButton){
        if button.isSelected {
            //removes border when deselected
            button.isSelected = false
            button.layer.borderWidth = 0
        } else {
            //adds border when selected
            deselectAll()
            button.isSelected = true
            button.layer.borderWidth = 10
            button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        }
    }
    
    @IBAction func blackButtonPressed(_ sender: UIButton) {
        colorSelected = "black"
        selectOrDeselectColor(button: sender)
    }
    
    @IBAction func redButtonPressed(_ sender: UIButton) {
        colorSelected = "red"
        selectOrDeselectColor(button: sender)
    }
    
    @IBAction func orangeButtonPressed(_ sender: UIButton) {
        colorSelected = "orange"
        selectOrDeselectColor(button: sender)
    }
    
    @IBAction func yellowButtonPressed(_ sender: UIButton) {
        colorSelected = "yellow"
        selectOrDeselectColor(button: sender)
    }
    
    @IBAction func greenButtonPressed(_ sender: UIButton) {
        colorSelected = "green"
        selectOrDeselectColor(button: sender)
    }
    
    @IBAction func blueButtonPressed(_ sender: UIButton) {
        colorSelected = "blue"
        selectOrDeselectColor(button: sender)
    }
    
    @IBAction func purpleButtonPressed(_ sender: UIButton) {
        colorSelected = "purple"
        selectOrDeselectColor(button: sender)
    }
    
    @IBAction func whiteButtonPressed(_ sender: UIButton) {
        colorSelected = "white"
        selectOrDeselectColor(button: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] = colorSelected
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["modifierBlockColor"] = colorSelected
        }
    }
    
    func adjustFontSizes() {
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        blackButton.titleLabel?.adjustsFontForContentSizeCategory = true
        redButton.titleLabel?.adjustsFontForContentSizeCategory = true
        orangeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        yellowButton.titleLabel?.adjustsFontForContentSizeCategory = true
        greenButton.titleLabel?.adjustsFontForContentSizeCategory = true
        blueButton.titleLabel?.adjustsFontForContentSizeCategory = true
        purpleButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
