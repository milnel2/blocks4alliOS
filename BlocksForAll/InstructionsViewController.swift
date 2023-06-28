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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set custom text font
        helpLabel.adjustsFontForContentSizeCategory = true
        helpLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        
        instructionsText.adjustsFontForContentSizeCategory = true
        instructionsText.font = UIFont.accessibleFont(withStyle: .body, size: 26.0)
        
        instructionsText.isAccessibilityElement = true
        
        
        let attributedString = NSMutableAttributedString(attributedString: instructionsText.attributedText)
        let websiteURL = URL(string: "https://milnel2.github.io/blocks4alliOS/")!
        let privPolicyURL = URL(string: "https://milnel2.github.io/privacyPolicy")!
        
        // Set the substring 'website' and 'Privacy Policy' to be the link
        attributedString.setAttributes([.link: websiteURL], range: NSMakeRange(2535, 7))
        attributedString.setAttributes([.link: privPolicyURL], range: NSMakeRange(2603, 14))
        
        self.instructionsText.attributedText = attributedString
        self.instructionsText.isUserInteractionEnabled = true
        self.instructionsText.isEditable = false
        
        // Set link appearance
        self.instructionsText.linkTextAttributes = [
            .font: UIFont.accessibleFont(withStyle: .body, size: 26.0),
            .foregroundColor: UIColor.colorFrom(hexString: "#52b2bf"),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
}
