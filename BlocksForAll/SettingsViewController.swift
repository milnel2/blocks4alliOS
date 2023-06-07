//
//  SettingsViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/7/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var showText: UIButton!
    
    @IBOutlet weak var showIcons: UIButton!
    
    // from Paul Hegarty, lectures 13 and 14
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        showIcons.titleLabel?.adjustsFontForContentSizeCategory = true
        showText.titleLabel?.adjustsFontForContentSizeCategory = true
        
        if (defaults.integer(forKey: "showText") == 0) {
            showIcons.layer.borderWidth = 10
            showIcons.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            showIcons.accessibilityValue = "selected"
            showText.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            showText.accessibilityValue = "unselected"
            showText.accessibilityHint = "double tap to select"
        } else {
            showText.layer.borderWidth = 10
            showText.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            showText.accessibilityValue = "selected"
            showIcons.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            showIcons.accessibilityValue = "unselected"
            showIcons.accessibilityHint = "double tap to select"
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func showIconsSelected(_ sender: Any) {
        defaults.setValue(0, forKey: "showText")
        showText.layer.borderWidth = 0
        showIcons.layer.borderWidth = 10
        showIcons.accessibilityValue = "selected"
        showText.accessibilityValue = "unselected"
        showText.accessibilityHint = "double tap to select"
        defaults.synchronize()
    }
    
    
    
    @IBAction func showTextSelected(_ sender: Any) {
        defaults.setValue(1, forKey: "showText")
        showIcons.layer.borderWidth = 0
        showText.layer.borderWidth = 10
        showText.accessibilityValue = "selected"
        showIcons.accessibilityValue = "unselected"
        showIcons.accessibilityHint = "double tap to select"
        defaults.synchronize()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
