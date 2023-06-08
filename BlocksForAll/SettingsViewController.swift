//
//  SettingsViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/7/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var showIconsOrText: UISegmentedControl!
    
    // from Paul Hegarty, lectures 13 and 14
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        // select the current setitng
        // value is 0 to show icons and 1 to show text
        showIconsOrText.selectedSegmentIndex = defaults.value(forKey: "showText") as! Int
    }
    @IBAction func showIconsOrTextSelected(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        
        // set value to 0 to show icons and 1 to show text
        defaults.setValue(sender.selectedSegmentIndex, forKey: "showText")
        defaults.synchronize()
        
        if sender.selectedSegmentIndex == 0 {
            sender.accessibilityLabel = "Show icons"
        } else {
            sender.accessibilityValue = "Show text"
        }
        
        
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
