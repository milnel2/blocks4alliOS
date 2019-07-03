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
    
    override func viewDidLoad() {
        // default color: Purple or preserve last selection
        var previousLightColor: String = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] ?? "purple"
        var previousModifierBlockColor = blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["modifierBlockColor"] ?? "purple"
        
        colorSelected = previousLightColor
        colorSelected = previousModifierBlockColor
    }
    
    @IBAction func blackButtonPressed(_ sender: UIButton) {
        colorSelected = "black"
    }
    @IBAction func redButtonPressed(_ sender: UIButton) {
        colorSelected = "red"
    }
    @IBAction func orangeButtonPressed(_ sender: UIButton) {
        colorSelected = "orange"
    }
    @IBAction func yellowButtonPressed(_ sender: UIButton) {
        colorSelected = "yellow"
    }
    @IBAction func greenButtonPressed(_ sender: UIButton) {
        colorSelected = "green"
    }
    @IBAction func blueButtonPressed(_ sender: UIButton) {
        colorSelected = "blue"
    }
    @IBAction func purpleButtonPressed(_ sender: UIButton) {
        colorSelected = "purple"
    }
    @IBAction func whiteButtonPressed(_ sender: UIButton) {
        colorSelected = "white"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["lightColor"] = colorSelected
            blocksStack[modifierBlockIndexSender!].addedBlocks[0].attributes["modifierBlockColor"] = colorSelected
        }
    }
}
