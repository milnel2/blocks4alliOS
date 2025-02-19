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
    
    // MARK: Custom Audio Files
    
    private var customAudioPaths: [String?] = []
    let numNoises: Int = 5 // number of custom sound files to allow
    
    /// Add path to the customAudioPaths list if it doesn't already exist in the list
    func addCustomAudio(path: String, forIndex index: Int) {
        if !customAudioPaths.contains(path) {
            customAudioPaths[index] = path
        } else {
            // TODO: repeated audio file
        }
    }
    
    /// Try to remove path from customAudioPaths list
    func clearAudio(forIndex index: Int) {
        customAudioPaths.remove(at: index)
    }
    
    public func getCustomAudioPaths() -> [String?] {
        validateCustomAudioPaths()
        return customAudioPaths
    }
    
    public func setCustomAudioPaths(newList: [String?]) {
        customAudioPaths = newList
        validateCustomAudioPaths()
    }
    
    public func hasCustomAudioPath(path: String) -> Bool {
        return customAudioPaths.contains(path)
    }
    
    public func getNumCustomAudioSaved() -> Int {
        var count = 0
        for str in customAudioPaths {
            if (str != nil && str != "") { // audio path exists
                count += 1
            }
        }
        return count
    }
    
    public func validateCustomAudioPaths () {
        if (getNumCustomAudioSaved() == 0) || customAudioPaths.count < numNoises { // if that list was empty or invalid, generate a new list
            customAudioPaths = buildNewNoiseList()
        }
    }
    
    public func buildNewNoiseList() -> [String?] {
        var newList: [String?] = []
        for _ in 0..<numNoises {
            newList.append(nil)
        }
        return newList
    }
    
    /// Compute the file name given an index of the NoiseFiles array. The result will be CustomAudio_n where n is index + 1
    public func getAudioFileName(forIndex index: Int) -> String {
        return "CustomAudio_\(index+1)"
    }
    
    public func getAudioFileURL(forIndex index: Int) -> URL {
        let path = HelperFunctions.getDocumentsDirectory().appendingPathComponent("\(getAudioFileName(forIndex: index)).m4a")
        return path as URL
    }
    
    public func getAudioFileURL(forFileName fileName: String) -> URL {
        let path = HelperFunctions.getDocumentsDirectory().appendingPathComponent("\(fileName).m4a")
        return path as URL
    }
    
}
