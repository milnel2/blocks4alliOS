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
    
    /// Takes the name of a PList and returns it as an NSDictionary
    public static func getPListDictionary (resourceName: String) -> NSDictionary?{
        // this code to access a plist as a dictionary is from https://stackoverflow.com/questions/24045570/how-do-i-get-a-plist-as-a-dictionary-in-swift
        let dict: NSDictionary?
         if let path = Bundle.main.path(forResource: resourceName, ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
         } else {
             print("could not access \(resourceName) plist")
             return nil
         }
        return dict!
    }
}

