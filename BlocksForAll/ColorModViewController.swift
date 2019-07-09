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
    
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var whiteButton: UIButton!
    
    
    
    
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
    
    
    @IBAction func blackButtonPressed(_ sender: UIButton) {
        colorSelected = "black"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
    }
    
    @IBAction func redButtonPressed(_ sender: UIButton) {
        colorSelected = "red"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func orangeButtonPressed(_ sender: UIButton) {
        colorSelected = "orange"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func yellowButtonPressed(_ sender: UIButton) {
        colorSelected = "yellow"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func greenButtonPressed(_ sender: UIButton) {
        colorSelected = "green"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func blueButtonPressed(_ sender: UIButton) {
        colorSelected = "blue"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    @IBAction func purpleButtonPressed(_ sender: UIButton) {
        colorSelected = "purple"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    
    @IBAction func whiteButtonPressed(_ sender: UIButton) {
        colorSelected = "white"
        //Border when button is selected
        
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0

                
            } else {
                deselectAll()
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] = colorSelected
        }
    }
}
