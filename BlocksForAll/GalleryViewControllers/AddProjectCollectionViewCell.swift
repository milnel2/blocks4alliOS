//
//  AddProjectCollectionViewCell.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/24/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class AddProjectCollectionViewCell: UICollectionViewCell {
    func updateAccessibilityTools() {
        isAccessibilityElement = false
        
        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = .button
        accessibilityTraits = .allowsDirectInteraction
        
        // TODO: do we need to say double tap in our accessibility hints? Wouldn't VoiceOver users know to do that?
        contentView.accessibilityHint = "Add New Project"
        
        accessibilityElements = [contentView]
    }
}
