//
//  Localizator.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 12/9/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
// Code is originally from https://dcordero.medium.com/a-different-way-to-deal-with-localized-strings-in-swift-3ea0da4cd143


import Foundation

private class Localizator { // TODO: make sure this doesn't impact performace. If it does, make separate plists
    
    static let sharedInstance = Localizator()
    
    lazy var localizableDictionary: NSDictionary! = {
        if let dict = HelperFunctions.getPListDictionary(resourceName: "GeneralLocalizations") {
            return dict
        }
        fatalError("Localizable file NOT found")
    }()
    
    func localize(string: String) -> String {
        var localizationEntry: NSDictionary? = nil
        
        // Look for the string in the dictionary
        let localizationEntryAsIs = localizableDictionary.value(forKey: string) as? NSDictionary
        if localizationEntryAsIs != nil {
            localizationEntry = localizationEntryAsIs
        } else { // Look for a lowercase version of the string in the dictionary
            let localizationEntryLowercase = localizableDictionary.value(forKey: string.lowercased()) as? NSDictionary
            if localizationEntryLowercase != nil {
                localizationEntry = localizationEntryLowercase
            } else { // Look for a capitalized version of the string in the dictionary
                let localizationEntryCapitalized = localizableDictionary.value(forKey: string.capitalized) as? NSDictionary
                if localizationEntryCapitalized != nil {
                    localizationEntry = localizationEntryCapitalized
                } else if Int(string) != nil {
                   // string is an integer, don't localize it
                    return string
                } else if Double(string) != nil {
                    // String is a double, don't localize it
                    return string
                } else if Float(string) != nil {
                    // String is a float, don't localize it
                    return string
                } else if string.contains("\u{00B0}") {
                    // String is an amount of degrees, don't localize it
                    return string
                } else {
                    print("Missing localization entry for: \(string)")
                    //assertionFailure("Missing localization entry for: \(string)") // TODO: put back once english localization is done (but it's okay if custom function names aren't localized)
                    return string
                }
            }
        }
       
        guard let localizedString = localizationEntry!.value(forKey: "value") as? String else {
                assertionFailure("Missing translation for: \(string)")
                return ""
        }
    
        return localizedString
    }
}

extension String {
    var localized: String {
        return Localizator.sharedInstance.localize(string: self)
    }
}
