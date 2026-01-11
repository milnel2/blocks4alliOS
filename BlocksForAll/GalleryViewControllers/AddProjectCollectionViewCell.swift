//
//  AddProjectCollectionViewCell.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/24/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

/// UICollectionViewCell used in a gallery for adding a new project
class AddProjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var newProjectLabel: UILabel!
    
    func updateUI() {
        newProjectLabel.adjustsFontForContentSizeCategory = true
        newProjectLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 30.0)
    }
    
    func updateAccessibilityTools() {
        isAccessibilityElement = false
        
        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = .button
        accessibilityTraits = .allowsDirectInteraction
        
        contentView.accessibilityHint = NSLocalizedString( "Add New Project.", comment: "Accessibility hint for Add New Project Button")
        
        accessibilityElements = [contentView]
        
        
        if #available(iOS 13.0, *) { // Voice Control
            contentView.accessibilityUserInputLabels = [
                NSLocalizedString("Add", comment: "Voice Control label"),
                NSLocalizedString("Add project", comment: "Voice Control label"),
                NSLocalizedString("New project", comment: "Voice Control label"),
                NSLocalizedString("New", comment: "Voice Control label"),
                NSLocalizedString("Plus", comment: "Voice Control label")
            ]
        }
        
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
    }
}
