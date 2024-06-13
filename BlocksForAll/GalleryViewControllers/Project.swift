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

class Project : Equatable{
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name = ""
    var imageName : String
    var functionDict: [String : [Block]]
    
    init(name: String = "", imageName: String, functionDict: [String : [Block]]) {
        self.name = name
        self.imageName = imageName
        self.functionDict = functionDict
    }
    
    static func FetchProjects () -> [String:[Project]]{
           
    return allProjects
//           [ Project(name: "Project 1", image: UIImage(named: "drive_backward")!, functionDict: [:]),
//        Project(name: "Project 2", image: UIImage(named: "move_left")!, functionDict: [:]),
//                Project(name: "Project 3", image: UIImage(named: "move_right")!, functionDict: [:]), Project(name: "Project 4", image: UIImage(named: "move_right")!, functionDict: [:]), Project(name: "Project 5", image: UIImage(named: "move_right")!, functionDict: [:]), Project(name: "Project 6", image: UIImage(named: "move_right")!, functionDict: [:])
//
//]
       }
}
