//
//  SettingsViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/7/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // View Controller Elements
    @IBOutlet weak var showIconsOrText: UISegmentedControl!
    @IBOutlet weak var blockSizeLabel: UILabel!
    @IBOutlet weak var blockSizeSlider: UISlider!
    @IBOutlet weak var showIconsLabel: UILabel!
    @IBOutlet var settingsView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var addRobotsButton: UIButton!
    
    override func viewDidLoad() {
        // Change fonts to custom font
        blockSizeLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        showIconsLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 26.0)
        
        // select the current setting for Show Text/Show Icons
        // show icons = 0
        // show text = 1
        if defaults.value(forKey: "showText") != nil {
            // use previously selected value
            showIconsOrText.selectedSegmentIndex = defaults.value(forKey: "showText") as! Int
        }
        else {
            // show icons by default
            defaults.setValue(0, forKey:"showText")
        }
                
        if defaults.value(forKey: "blockSize") == nil {
            // set blockSize to 150 by default
            defaults.setValue(150, forKey: "blockSize")
        }
        
        let blockSize = defaults.value(forKey: "blockSize") as! Float
        

        blockSizeSlider.setValue(blockSize, animated: false)
        
        blockSizeSlider.minimumTrackTintColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        blockSizeSlider.thumbTintColor = #colorLiteral(red: 1, green: 0.6078431373, blue: 0.2980392157, alpha: 1)
        
        
        let displayValue = ((Int(blockSize) - 100) / 10) + 1
        
        updateBlockSizeLabel(value: displayValue)
        
        blockSizeSlider.accessibilityValue = "\(Int(displayValue))"
        
        blockSizeLabel.accessibilityValue = "= \(Int(displayValue))"

        if defaults.value(forKey: "showText") as! Int == 0 {
            showIconsLabel.accessibilityValue = NSLocalizedString("Show icons selected.", comment:"Accessibility value for a show icons or text label when show icons is on")
            showIconsLabel.text = NSLocalizedString("Show Icons", comment: "Text for a show icons or text label when show icons is on")
            
        } else {
            showIconsLabel.accessibilityValue =  NSLocalizedString("Show text selected.", comment:"Accessibility value for a show icons or text label when show text is on")
            showIconsLabel.text = NSLocalizedString("Show Text", comment: "Text for a show icons or text label when show text is on")
        }
        
        blockSizeLabel.adjustsFontForContentSizeCategory = true
        showIconsLabel.adjustsFontForContentSizeCategory = true
        showIconsOrText.subviews[0].accessibilityLabel = NSLocalizedString("Show Icons", comment: "Accessibility Label for Show Icons segmented control")
        showIconsOrText.subviews[1].accessibilityLabel = NSLocalizedString("Show Text", comment: "Accessibility Label for Show Text segmented control")
    }
    /// Called when the showIconsOrText switch is pressed
    @IBAction func showIconsOrTextSelected(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        // set value to 0 to show icons and 1 to show text
        defaults.setValue(sender.selectedSegmentIndex, forKey: "showText")
        defaults.synchronize()
        if sender.selectedSegmentIndex == 0 {
            sender.accessibilityLabel = NSLocalizedString("Show Icons.", comment: "Accessibility label for a show icons or text switch button when show icons is on")
            showIconsLabel.accessibilityValue = NSLocalizedString("Show icons selected.", comment:"Accessibility value for a show icons or text label when show icons is on")
            showIconsLabel.text = NSLocalizedString("Show Icons", comment: "Text for a show icons or text label when show icons is on")
        } else {
            sender.accessibilityLabel = NSLocalizedString("Show Text.", comment: "Accessibility label for a show icons or text switch button when show text is on")
            showIconsLabel.accessibilityValue = NSLocalizedString("Show text selected.", comment:"Accessibility value for a show icons or text label when show text is on")
            showIconsLabel.text = NSLocalizedString("Show Text", comment: "Text for a show icons or text label when show text is on")
        }
    }
    
    /// Called when the blockSizeSlider is changed. Updates screen and default values
    @IBAction func blockSizeSliderChanged(_ sender: UISlider) {
        // make slider increment by 25
        // rounding from https://developer.apple.com/forums/thread/23010
        // this code is commented out because it doesn't work when using voiceOver.
        //sender.setValue(Float(roundf(sender.value * 0.04) / 0.04), animated: false)
        
        // a smaller increment size works with voiceOver. This increments by 10
        sender.setValue(Float(roundf(sender.value * 0.1) / 0.1), animated: false)

        // save value
        defaults.setValue(sender.value, forKey: "blockSize")
        
        // unccoment this to change the slider value that goes from 100-200 to go from 1-5
        //let displayValue = ((Int(sender.value) - 100) / 25) + 1
        
        // can also use this line instead so that the slider can increment by 10s using voice over
        // It increments by 10s but on the screen it increments by 1s and goes from 1-11
        let displayValue = ((Int(sender.value) - 100) / 10) + 1
        
        sender.accessibilityValue = "\(Int(displayValue))"
        // update label
        updateBlockSizeLabel(value: displayValue)
    }
    
    /// Given a float, sets text for block size label
    private func updateBlockSizeLabel (value : Float) {
        updateBlockSizeLabel(value: Int(value))
    }
    
    /// Given an int, sets text for block size label
    private func updateBlockSizeLabel (value : Int) {
        let formattedString = NSLocalizedString("block_size_equals_label", comment: "Label to display block size. 'Block Size = <int>'")
        blockSizeLabel.text = String.localizedStringWithFormat(formattedString, value)
        
        let formattedString2 = NSLocalizedString("block_size_equals_access_value", comment: "Accessibility value of a block size label. 'equals <int>.'")
        blockSizeLabel.accessibilityValue = String.localizedStringWithFormat(formattedString, value)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? AddRobotViewController {
            destinationViewController.sentFrom = .Settings
        }
    }
}
