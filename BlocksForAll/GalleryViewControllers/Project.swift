//
//  Workspace.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

var allProjects: [String : [Project]] = ["Freeplay Projects":[], "Robot Projects": []] //["Freeplay Projects" : [Project(name: "hi", imageName: "drive_backwards", functionDict: ["Main Workspace" : []])], "Robot Projects" : [Project(name: "hello", imageName: "drive_backwards", functionDict: ["Main Workspace": []])]]
let ON_RUN_STRING = "OnRun"
let ON_BUMP_STRING = "OnBump"
let THIRD_LINE_STRING = "thirdLine"

let PREMADE_FUNCTION_NAMES = [ON_RUN_STRING, ON_BUMP_STRING, THIRD_LINE_STRING]

class Project : Equatable{
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name = ""
    var imageName : String
   // var functionDict: [String : [Block]]
    var actors: [VirtualRobot] = []
    var currentActor: VirtualRobot? = nil
    
    init(name: String = "", imageName: String) {
        self.name = name
        self.imageName = imageName
        let defaultActor = VirtualRobot(imagePath: "dog", name: "Dog")
        addActor(actor: defaultActor)
        currentActor = defaultActor
       // self.functionDict = [ON_RUN_STRING : [], ON_BUMP_STRING: [], THIRD_LINE_STRING: []]
    }
    
    init(name: String = "", imageName: String, actors: [VirtualRobot]) {
        self.name = name
        self.imageName = imageName
        self.actors = actors
        if actors.count < 1 {
            let defaultActor = VirtualRobot(imagePath: "dog", name: "Dog")
            addActor(actor: defaultActor)
            currentActor = defaultActor
        }
        currentActor = actors[0]
       // self.functionDict = [ON_RUN_STRING : [], ON_BUMP_STRING: [], THIRD_LINE_STRING: []]
    }
    
//    init(name: String = "", imageName: String, functionDict: [String : [Block]]) {
//        self.name = name
//        self.imageName = imageName
//        self.functionDict = functionDict
//    }
//    
    func addActor(actor: VirtualRobot) {
        
        if !actors.contains(actor) {
            print("appending new actor")
            actors.append(actor)
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

