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
            self.imagePath = "WhiteBackground"
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
    
    
    // Given an image path, return a string that can be used as an image name for VoiceOver
    public static func getUserFacingImageName(forPath path: String) -> String {
        let isCustomBackground = UserData.data.hasCustomBackgroundPath(path: path)
        let userFacingImageName: String
        
        if isCustomBackground {
            userFacingImageName = "Custom Background".localized
        } else {
            userFacingImageName = path // TODO: localize?
        }
        return userFacingImageName
    }
}
