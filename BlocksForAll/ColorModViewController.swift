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
    
    @IBAction func blackButtonPressed(_ sender: UIButton) {
        colorSelected = "black"
        //Border when button is selected
        if let button = sender as? UIButton {
            if button.isSelected {
                button.isSelected = false
                button.layer.borderWidth = 0
            } else {
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0, green: 1, blue: 0.2436479628, alpha: 1)
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
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
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
                button.isSelected = true
                button.layer.borderWidth = 5
                button.layer.borderColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] = colorSelected
        }
    }
}
