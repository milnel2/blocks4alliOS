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
    
    @IBOutlet weak var blockSizeLabel: UILabel!
    
    @IBOutlet weak var blockSizeSlider: UISlider!
    
    @IBOutlet weak var showIconsLabel: UILabel!
    // from Paul Hegarty, lectures 13 and 14
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        // select the current setitng
        // value is 0 to show icons and 1 to show text
        if defaults.value(forKey: "showText") != nil {
            showIconsOrText.selectedSegmentIndex = defaults.value(forKey: "showText") as! Int
        }
        
        blockSizeLabel.adjustsFontForContentSizeCategory = true
        
        showIconsLabel.adjustsFontForContentSizeCategory = true
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
    
    
    @IBAction func blockSizeSliderChanged(_ sender: UISlider) {
//        defaults.setValue(sender.value, forKey: "blockSize")
        
        // make slider increment by 25
        // rounding from https://developer.apple.com/forums/thread/23010
        sender.setValue(Float(roundf(sender.value * 0.04) / 0.04), animated: false)
        
        blockSizeLabel.text = "Block Size = \(Int(sender.value))"
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
