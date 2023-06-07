//
//  MainMenuViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 8/30/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var getStarted: UIButton!
    
    @IBOutlet weak var instructions: UIButton!
    
    @IBOutlet weak var addRobots: UIButton!
    
    @IBOutlet weak var showIcons: UIButton!
    
    @IBOutlet weak var showText: UIButton!
    
    // from Paul Hegarty, lectures 13 and 14
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        welcomeLabel.adjustsFontForContentSizeCategory = true
        getStarted.titleLabel?.adjustsFontForContentSizeCategory = true
        instructions.titleLabel?.adjustsFontForContentSizeCategory = true
        addRobots.titleLabel?.adjustsFontForContentSizeCategory = true
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
        
        

        
    }
    

    var blockSize = 150 /* this controls the size of the blocks you put down in the Building Screen */
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 11.0, *) {
            if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
                print("accessibility enabled")
                blockSize = 200
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let myDestination = segue.destination as? BlocksViewController{
            myDestination.blockSize = blockSize
            myDestination.blockSize = blockSize
            print("block size " , blockSize)
        }
        if let destinationViewController = segue.destination as? UINavigationController{
            if destinationViewController.topViewController is BlocksViewController{
                print("block size 2 " , blockSize)
            }
        }
        
    }
    
//    @IBAction func loadFromAddRobots(_ sender: Any) {
//        load()
//    }
//    @IBAction func loadFromGetStarted(_ sender: Any) {
//        load()
//    }
   
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
    
}
