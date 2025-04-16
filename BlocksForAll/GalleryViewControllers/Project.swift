//
//  Workspace.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

// strings used as names for different gallery types
public let FREEPLAY_GALLERY_TYPE = "Freeplay Projects"
public let ROBOT_GALLERY_TYPE = "Robot Projects"


var allProjects: [String : [Project]] = [FREEPLAY_GALLERY_TYPE:[], ROBOT_GALLERY_TYPE: []]

let ON_RUN_STRING = "On Run"
let ON_BUMP_STRING = "On Bump" // Need to add implementation for On Bump
let ON_TAP_STRING = "On Tap"

let PREMADE_FUNCTION_NAMES = [ON_RUN_STRING, ON_BUMP_STRING, ON_TAP_STRING, "Main Workspace"]

// Represents either a robot project or a freeplay project
class Project : Equatable{
    static func == (lhs: Project, rhs: Project) -> Bool {
        return (lhs.name == rhs.name) && (lhs.projectType == rhs.projectType)
    }
    
    var name = "" // Name of project
    var imageName : String // Image path for the project's image for the gallery
    var actors: [VirtualRobot] = [] // For freeplay projects. Array of all Virtual Robots associated with project
    var currentActor: VirtualRobot? = nil // For freeplay projects. Actor that is currently being edited
    var currentBackground: BackgroundImage? = nil // For freeplay projects. Background image that is currently being displayed
    var projectType: ProjectType // Either robot project or freeplay project
    
    var customAudioPaths: [String?] = [] // List of custom noise audio path for each slot. Index 0 is for slot 1, index 1 for slot 2, etc.
    
    init(name: String = "", imageName: String, projectType: ProjectType, backgroundImagePath: String? = nil) {
        self.name = name
        self.imageName = imageName
        self.projectType = projectType
        // By default adds one actor to the project if it is an empty project
        let defaultActor = VirtualRobot(baseImagePath: "CatActor", name: "Cat", project: self)
        addActor(actor: defaultActor)
        currentActor = defaultActor
        
        // Sets a default background
        currentBackground = BackgroundImage(imagePath: backgroundImagePath)
    }
    
    init(name: String = "", imageName: String, actors: [VirtualRobot], projectType: ProjectType, backgroundImagePath: String? = nil) {
        self.name = name
        self.imageName = imageName
        self.actors = actors
        self.projectType = projectType
        
        if actors.count < 1 {
            let defaultActor = VirtualRobot(baseImagePath: "CatActor", name: "Cat", project: self)
            addActor(actor: defaultActor)
            currentActor = defaultActor
        } else {
            currentActor = actors[0]
        }
        
        // Sets a default background
        currentBackground = BackgroundImage(imagePath: backgroundImagePath)
        
    }
    
    func addActor(actor: VirtualRobot) {
        if !actors.contains(actor) {
            actors.append(actor)
        }
        
    }
    
    // attempt to delete actor from project
    func deleteActor(actor: VirtualRobot) {
        let index = actors.firstIndex(of: actor)
        if index != nil {
            actors.remove(at: index!)
            if actors.count > 0 { 
                currentActor = actors[0]
            }
           
        } else {
            print("Failed to delete actor:", actor.name)
        }
        
        
    }
    
    static func FetchProjects () -> [String:[Project]]{
        return allProjects
       }
    
    public func updateCurrentBackground(background: BackgroundImage?) {
        currentBackground = background
    }
    
    // MARK: Custom Audio Files
    
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
        if (getNumCustomAudioSaved() == 0) || customAudioPaths.count < UserData.data.getMaxNumCustomNoises() { // if that list was empty or invalid, generate a new list
            customAudioPaths = buildNewNoiseList()
        }
    }
    
    /// Build a new empty custom noise list. All slots are nil.
    public func buildNewNoiseList() -> [String?] {
        var newList: [String?] = []
        for _ in 0..<UserData.data.getMaxNumCustomNoises() {
            newList.append(nil)
        }
        return newList
    }
    
    /// Compute the file name given an index of the NoiseFiles array. The result will be CustomAudio_name_n where n is slot number and name is the project name
    public func getAudioFileName(forSlotNumber slotNumber: Int) -> String {
        return "CustomAudio_\(name)_\(slotNumber)"
    }
    
    public func getCustomAudioImageFileName(forSlotNumber slotNumber: Int) -> String {
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
        return getCustomAudioPaths()[slotNumber - 1] != nil && getCustomAudioPaths()[slotNumber - 1] != "nil"
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
}

enum ProjectType {
    case Freeplay
    case Robot
}

