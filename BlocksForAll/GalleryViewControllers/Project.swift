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

let ON_RUN_STRING = "OnRun"
let ON_BUMP_STRING = "OnBump" // Need to add implementation for On Bump
let ON_TAP_STRING = "OnTap"

let PREMADE_FUNCTION_NAMES = [ON_RUN_STRING, ON_BUMP_STRING, ON_TAP_STRING, "Main Workspace"]

class Project : Equatable{
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name = ""
    var imageName : String
    var image: UIImage? = nil
   // var functionDict: [String : [Block]]
    var actors: [VirtualRobot] = []
    var currentActor: VirtualRobot? = nil
    var projectType: ProjectType
    
    init(name: String = "", imageName: String, projectType: ProjectType) {
        self.name = name
        self.imageName = imageName
        self.projectType = projectType
        // By default adds one actor to the project if it is an empty project
        let defaultActor = VirtualRobot(baseImagePath: "CatActor", name: "Cat", project: self)
        addActor(actor: defaultActor)
        currentActor = defaultActor
    }
    
    init(name: String = "", imageName: String, actors: [VirtualRobot], projectType: ProjectType) {
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
}

class CodeLine {
    var line: [Block]
    var actor: VirtualRobot
    var lineType: CodeLineType
    init(line: [Block], actor: VirtualRobot, lineType: CodeLineType) {
        self.line = line
        self.actor = actor
        self.lineType = lineType
    }
    
    static func CreateEmptyCodeLines(actor: VirtualRobot) -> [CodeLine]{
        return [CodeLine(line: [], actor: actor, lineType: CodeLineType.OnRun), CodeLine(line: [], actor: actor, lineType: CodeLineType.OnBump), CodeLine(line: [], actor: actor, lineType: CodeLineType.Other)]
    }
}

enum CodeLineType {
    case OnRun
    case OnBump
    case Other
}

enum ProjectType {
    case Freeplay
    case Robot
}

