//
//  VehicleModViewController.swift
//  BlocksForAll
//
//  Created by Amanda Jackson on 7/8/21.
//  Copyright © 2021 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class VehicleModViewController: UIViewController{
    /* Custom view controller for the Vehicle Noise modifier scene */
    
    var modifierBlockIndexSender: Int?
    var vehicleSelected: String = "airplane"

    @IBOutlet weak var back: UIButton!
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        // default: Airplane or preserve last selection
        let previousVehicle: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["vehicleNoise"] ?? "airplane"
        
        vehicleSelected = previousVehicle
        
        //Highlights current vehicle when mod view is entered
        for button in buttons {
            if vehicleSelected == button.accessibilityIdentifier {
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
            vehicleSelected = buttonID
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["vehicleNoise"] = vehicleSelected
        }
    }
}
