//
//  BackgroundImage.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 9/23/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

/// Representation of a UIImage and its path. Used for change background blocks in Freeplay mode
class BackgroundImage {
    private var imagePath: String // name of the image
    private var image: UIImage // UIImage associated with the name
    
    init (imagePath: String?) {
        if imagePath == nil {
            self.imagePath = "DefaultBackground"
        } else {
            self.imagePath = imagePath!
        }
        
        self.image = HelperFunctions.getUIImage(named: self.imagePath)
    }
    
    public func getImage() -> UIImage {
        return image
    }
    
    public func getImagePath() -> String{
        return imagePath
    }
}
