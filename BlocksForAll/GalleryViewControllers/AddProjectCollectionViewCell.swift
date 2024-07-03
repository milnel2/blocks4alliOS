//
//  AddProjectCollectionViewCell.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/24/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class AddProjectCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    func updateAccessibilityTools() {
        isAccessibilityElement = false
        
        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = .button
        accessibilityTraits = .allowsDirectInteraction
        
        contentView.accessibilityHint = "Add New Project"
        
        accessibilityElements = [contentView]
        
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
        
    }
}
