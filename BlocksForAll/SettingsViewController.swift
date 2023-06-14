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
    
    @IBOutlet var settingsView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var settingsLabel: UILabel!
    
    // from Paul Hegarty, lectures 13 and 14
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        // Change fonts to custom font
        settingsLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        blockSizeLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        showIconsLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        
        // select the current setitng
        // value is 0 to show icons and 1 to show text
        if defaults.value(forKey: "showText") != nil {
            showIconsOrText.selectedSegmentIndex = defaults.value(forKey: "showText") as! Int
        
        }
        else
        { defaults.setValue(0, forKey:"showText")
        }
        
//        //Orders contents of workspace to be more intuitive with Switch Control
        settingsView.accessibilityElements = [settingsLabel!, blockSizeLabel!, blockSizeSlider!, showIconsLabel!, showIconsOrText!, backButton!]
        

        if defaults.value(forKey: "blockSize") == nil {
            defaults.setValue(150, forKey: "blockSize")
        }
        
        let blockSize = defaults.value(forKey: "blockSize") as! Float
        
        
        blockSizeSlider.setValue(blockSize, animated: false)
        
        let displayValue = ((Int(blockSize) - 100) / 10) + 1
        
        updateBlockSizeLabel(value: displayValue)
        
        blockSizeSlider.accessibilityValue = "\(Int(displayValue))"
        
        blockSizeLabel.accessibilityValue = "= \(Int(displayValue))"
        
        if defaults.value(forKey: "showText") as! Int == 0 {
            showIconsLabel.accessibilityValue = "Show icons selected"
        } else {
            showIconsLabel.accessibilityValue = "Show text selected"
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
        // make slider increment by 25
        // rounding from https://developer.apple.com/forums/thread/23010
        // this code is commented out because it doesn't work when using voiceOver.
        //sender.setValue(Float(roundf(sender.value * 0.04) / 0.04), animated: false)
        
        // a smaller increment size works with voiceOver. This increments by 10
        sender.setValue(Float(roundf(sender.value * 0.1) / 0.1), animated: false)

        // save value
        defaults.setValue(sender.value, forKey: "blockSize")
        
        // change the slider value that goes from 100-200 to go from 1-5
        //let displayValue = ((Int(sender.value) - 100) / 25) + 1
        
        // can also use this line instead so that the slider can increment by 10s using voice over
        // it goes from 1-11
        let displayValue = ((Int(sender.value) - 100) / 10) + 1
        
        sender.accessibilityValue = "\(Int(displayValue))"
        // update label
        updateBlockSizeLabel(value: displayValue)
        
       
    }
    
    // given a float, sets text for block size label
    private func updateBlockSizeLabel (value : Float) {
        blockSizeLabel.text = "Block Size = \(Int(value))"
    }
    
    // given a int, sets text for block size label
    private func updateBlockSizeLabel (value : Int) {
        blockSizeLabel.text = "Block Size = \(value)"
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
