//
//  UserData.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 9/30/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

/// Holds saved user data, like the custom background image paths
class UserData {
    
    private var customBackgroundPaths: [String] = []
    
    static let data = UserData() // Static instance of UserData. Use this when needing to reference user data
    
    /// Add path to the customBackgroundPaths list if it doesn't already exist in the list
    func addBackgroundPath(path: String) {
        if !customBackgroundPaths.contains(path) {
            customBackgroundPaths.append(path)
        }
    }
    
    /// Try to remove path from customBackgroundPaths list. Return true if successful.
    func removeBackgroundPath(path: String) -> Bool {
        
        var indexOfPath = -1
        for i in 0...customBackgroundPaths.count {
            if path == customBackgroundPaths[i] {
                indexOfPath = i // match found
            }
        }
        
        if indexOfPath != -1 { // if match was found
            customBackgroundPaths.remove(at: indexOfPath)
            return true
        }
        
        return false
    }
    
    public func getCustomBackgroundPaths() -> [String] {
        return customBackgroundPaths
    }
    
    public func setCustomBackgroundPaths(newList: [String]) {
        customBackgroundPaths = newList
    }
    
    
    
    
    
    
    
    
    
    
}
