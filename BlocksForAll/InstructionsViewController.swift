//
//  InstructionsViewController.swift
//  BlocksForAll
//
//  Created by Miri Leonard on 6/15/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {
    
    @IBOutlet weak var helpLabel: UILabel!
    
    @IBOutlet weak var instructionsText: UITextView!
    
    // from Paul Hegarty, lectures 13 and 14
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
       // Set custom text font
        helpLabel.adjustsFontForContentSizeCategory = true
        helpLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        
        instructionsText.adjustsFontForContentSizeCategory = true
        instructionsText.font = UIFont.accessibleFont(withStyle: .body, size: 26.0)
    }
}
