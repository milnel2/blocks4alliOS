//
//  Workspace.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class Project {
    var name = ""
    var image : UIImage
    var functionDict: [String : [Block]]
    
    init(name: String = "", image: UIImage, functionDict: [String : [Block]]) {
        self.name = name
        self.image = image
        self.functionDict = functionDict
    }
    
    static func FetchProjects () -> [Project]{
           
        return [ Project(name: "Project 1", image: UIImage(named: "drive_backward")!, functionDict: [:]),
                         Project(name: "Project 2", image: UIImage(named: "move_left")!, functionDict: [:]),
                                 Project(name: "Project 3", image: UIImage(named: "move_right")!, functionDict: [:]), Project(name: "Project 4", image: UIImage(named: "move_right")!, functionDict: [:]), Project(name: "Project 5", image: UIImage(named: "move_right")!, functionDict: [:]), Project(name: "Project 6", image: UIImage(named: "move_right")!, functionDict: [:])
    
           ]
           
       }
}
