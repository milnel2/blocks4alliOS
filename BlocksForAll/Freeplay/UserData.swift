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
    
    // MARK: Custom Audio Files
    
    private var customAudioPaths: [String?] = [] // List of custom noise audio path for each slot. Index 0 is for slot 1, index 1 for slot 2, etc.
    let numNoises: Int = 5 // number of custom sound files to allow
    
    /// Add path to the customAudioPaths list if it doesn't already exist in the list
    func addCustomAudio(path: String, forSlotNumber slotNum: Int) {
        if !customAudioPaths.contains(path) {
            customAudioPaths[slotNum - 1] = path
        } else {
            // TODO: repeated audio file
        }
    }
    
    /// Try to remove path from customAudioPaths list and from file directory
    func clearAudio(forSlotNumber slotNum: Int) {
        let audioURL = getAudioFileURL(forSlotNumber: slotNum)
        if FileManager.default.fileExists(atPath: audioURL.relativePath) { // If file exists, delete it
            do {
                try FileManager.default.removeItem(at: audioURL )
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        customAudioPaths[slotNum - 1] = nil
    }
    
    /// Check whether or not the path is already found in the list of custom audio paths
    public func hasCustomAudioPath(path: String) -> Bool {
        return customAudioPaths.contains(path)
    }
    
    /// Calculate the number of custom audio slots that are filled
    public func getNumCustomAudioSaved() -> Int {
        var count = 0
        for str in customAudioPaths {
            if (str != nil && str != "") { // audio path exists
                count += 1
            }
        }
        return count
    }
    
    /// If the list of custom noises is invalid, build a new list
    public func validateCustomAudioPaths () {
        if (getNumCustomAudioSaved() == 0) || customAudioPaths.count < numNoises { // if that list was empty or invalid, generate a new list
            customAudioPaths = buildNewNoiseList()
        }
    }
    
    /// Build a new empty custom noise list. All slots are nil.
    public func buildNewNoiseList() -> [String?] {
        var newList: [String?] = []
        for _ in 0..<numNoises {
            newList.append(nil)
        }
        return newList
    }
    
    /// Compute the file name given an index of the NoiseFiles array. The result will be CustomAudio_n where n is slot number
    public func getAudioFileName(forSlotNumber slotNumber: Int) -> String {
        return "CustomAudio_\(slotNumber)"
    }
    
    /// Return URL for a slot's audio file
    public func getAudioFileURL(forSlotNumber slotNumber: Int) -> URL {
        let path = getAudioFileURL(forFileName: getAudioFileName(forSlotNumber: slotNumber))
        return path as URL
    }
    
    /// Return URL for a a file name
    public func getAudioFileURL(forFileName fileName: String) -> URL {
        let path = HelperFunctions.getDocumentsDirectory().appendingPathComponent("\(fileName).m4a")
        return path as URL
    }
    
    /// Check if the given slot has a noise saved to it
    public func hasNoise(forSlotNumber slotNumber : Int) -> Bool{
        return getCustomAudioPaths()[slotNumber - 1] != nil
    }
    
    // Custom Noise Getters and Setters
    public func getCustomAudioPaths() -> [String?] {
        validateCustomAudioPaths()
        return customAudioPaths
    }
    
    public func setCustomAudioPaths(newList: [String?]) {
        customAudioPaths = newList
        validateCustomAudioPaths()
    }
    
    /// Number of custom noise sound files allowed
    public func getMaxNumCustomNoises() -> Int {
        return numNoises
    }
}
