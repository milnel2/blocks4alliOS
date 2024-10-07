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
    
    /// Try to find an image of the given name in the assets folder and return image if successful.
    /// Otherwise, try to find the image in the documents directory and return image if successful.
    /// If both attempts fail, return a default empty image.
    public static func getUIImage(named name: String) -> UIImage {
        if name == "" {
            // Don't allow empty image paths
            print("Image file name empty string. Using default empty image asset")
            return UIImage(named: "EmptyImage")!
        }
        // Try finding the image in assets
        let regularPathImage = UIImage(named: name)
        if regularPathImage != nil {
            // Found, return the image
            return regularPathImage!
        }
        
        // Check for the image in the file directory
        let fullPathImage = checkDocumentDirectoryForImage(name: name)
        if fullPathImage != nil {
            return fullPathImage!
        }
        
        // Check for the image in the file directory, but remove any file endings
        let nameNoEndings = name.components(separatedBy: ".")[0]
        let fullPathNoEndingsImage = checkDocumentDirectoryForImage(name: nameNoEndings)
        if fullPathNoEndingsImage != nil {
            return fullPathNoEndingsImage!
        }
      

        // Image couldn't be found, return an empty image
        print("Image file not found: \(name). Using default empty image asset")
        return UIImage(named: "EmptyImage")!
    }
    
    /// Search in the document directory for an image of the given name
    private static func checkDocumentDirectoryForImage(name: String) -> UIImage?{
        let imageFullPath = HelperFunctions.getDocumentsDirectory().appendingPathComponent(name).relativePath
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: imageFullPath) {
            let fullPathImage = UIImage(contentsOfFile: imageFullPath)
            if fullPathImage != nil {
                return fullPathImage!
            }
            print("Failed to find \(name) image at full path: \(imageFullPath)")
        }
        print("File \(name) does not exist in document directory ")
        return nil
    }
    
    // from Paul Hegarty, lectures 13 and 14
    public static func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    public static func deleteImageFromDocumentDirectory(name: String) {
        // Deleting file from document directory is from Yaroslav Dukal's answer on https://stackoverflow.com/questions/32840190/delete-files-from-directory-inside-document-directory
        let fileManager = FileManager.default
        let imageFullPath = HelperFunctions.getDocumentsDirectory().appendingPathComponent(name).relativePath
        do {
            try fileManager.removeItem(atPath: imageFullPath)
        } catch let error as NSError {
            print("Could not remove item: \(error.debugDescription)")
        }
    }

}

