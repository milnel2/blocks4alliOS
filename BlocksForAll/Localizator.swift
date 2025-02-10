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
        guard let localizationEntry = (localizableDictionary.value(forKey: string) as? NSDictionary) else {
            print("Missing localization entry for: \(string)")
                //assertionFailure("Missing localization entry for: \(string)") // TODO: put back once english localization is done
                return ""
                
            }
        guard let localizedString = localizationEntry.value(forKey: "value") as? String else {
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
