//
//  UserData.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 9/30/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

// Global variables

var currentWorkspace = String()  // workspace you are currently editing on screen (i.e. the main workspace or a user-defined function)

/// Holds saved user data, like the custom background image paths
class UserData {
    
    private var currentProject: Project? = nil
    
    private var customBackgroundPaths: [String] = []
    private var defaultBackgroundPaths = ["DefaultBackground", "tempBackground1", "tempBackground2", "tempBackground3"]
    
    static let data = UserData() // Static instance of UserData. Use this when needing to reference user data
    
    //MARK: Projects
    func getCurrentProject() -> Project? {
        return currentProject
    }
    
    func setCurrentProject(newProject: Project?) {
        currentProject = newProject
    }

    
    //MARK:  Custom Backgrounds
    /// Add path to the customBackgroundPaths list if it doesn't already exist in the list
    func addBackgroundPath(path: String) {
        if !customBackgroundPaths.contains(path) {
            customBackgroundPaths.append(path)
        } else {
            // TODO: repeated background file
        }
    }
    
    /// Try to remove path from customBackgroundPaths list. Return true if successful.
    func removeBackgroundPath(path: String) -> Bool {
        var indexOfPath = -1
        for i in 0..<customBackgroundPaths.count {
            if path == customBackgroundPaths[i] {
                indexOfPath = i // match found
            }
        }
        
        if indexOfPath != -1 { // if match was found
            customBackgroundPaths.remove(at: indexOfPath)
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("Error deleting file: \(error)")
            }
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
    
    public func hasCustomBackgroundPath(path: String) -> Bool {
        return customBackgroundPaths.contains(path)
    }
    
    public func getDefaultBackgroundPaths() -> [String] {
        return defaultBackgroundPaths
    }
    
    public func hasDefaultBackgroundPath(path: String) -> Bool {
        return defaultBackgroundPaths.contains(path)
    }
    
    public func hasBackgroundPath(path: String) -> Bool {
        return hasCustomBackgroundPath(path: path) || hasDefaultBackgroundPath(path: path)
    }
    
    // MARK: Custom Audio
    /// Number of custom noise sound files allowed
    public func getMaxNumCustomNoises() -> Int {
        return 5
    }
    
   
}
