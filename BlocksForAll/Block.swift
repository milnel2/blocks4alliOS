//
//  Block.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class Block {
    
    //MARK: Properties
    
    var name: String
    var color: UIColor
    var double: Bool //true if needs both beginning and end block like repeat
    var counterpart: Block?
    var editable: Bool //true if has options
    var options: [String]?
    var imageName: String?
    
    //MARK: Initialization
    
    init?(name: String, color: UIColor, double: Bool, editable: Bool, imageName: String? = nil){
        
        //TODO: check that color is initialized as well
        if name.isEmpty {
            return nil
        }
        
        self.name = name
        self.color = color
        self.double = double
        self.editable = editable
        
    
    }
    
    func addImage(_ imageName: String){
        self.imageName = imageName
    }
    

}
