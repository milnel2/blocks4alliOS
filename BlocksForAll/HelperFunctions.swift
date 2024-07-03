//
//  HelperFunctions.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 7/3/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class HelperFunctions {
    
    /// Takes an image and a new CGSize and returns a resized version of it
    public static func resizeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

