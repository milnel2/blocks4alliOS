//
//  MainMenuViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 8/30/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
 
let defaults = UserDefaults.standard  // Used to know block size and if in showIcons or in showText mode. Global so that all files can access it. From Paul Hegarty, lectures 13 and 14

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var getStarted: UIButton!
    
    @IBOutlet weak var instructions: UIButton!
    
    @IBOutlet weak var addRobots: UIButton!
    
    override func viewDidLoad() {
//        welcomeLabel.adjustsFontForContentSizeCategory = true
//
//        welcomeLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 40.0)
        
        getStarted.titleLabel?.adjustsFontForContentSizeCategory = true
        instructions.titleLabel?.adjustsFontForContentSizeCategory = true
        addRobots.titleLabel?.adjustsFontForContentSizeCategory = true
        
        if  defaults.value(forKey: "showText") == nil {
            defaults.setValue(0, forKey: "showText")  // set showText to showIcons by default
        }
        
        if defaults.value(forKey: "blockSize") == nil {
            defaults.setValue(150, forKey: "blockSize")  // set blockSize to be 150 by default
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
   }
