//
//  Block.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

// The code below came from https://stackoverflow.com/questions/50928153/make-uicolor-codable
// The function below makes a struct Color and creates a uiColor from it while conforming to the codable forms that swift allows for encoding and decoding
import UIKit
struct Color : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}


//Below is the actual encoding and decoding of the uiColor
struct Task: Codable {
    
    private enum CodingKeys: String, CodingKey { case content, deadline, color }
    
    var content: String
    var deadline: Date
    var color : UIColor
    
    init(content: String, deadline: Date, color : UIColor) {
        self.content = content
        self.deadline = deadline
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(String.self, forKey: .content)
        deadline = try container.decode(Date.self, forKey: .deadline)
        color = try container.decode(Color.self, forKey: .color).uiColor
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(deadline, forKey: .deadline)
        try container.encode(Color(uiColor: color), forKey: .color)
    }
}
//above code is from https://stackoverflow.com/questions/50928153/make-uicolor-codable

class Block: Codable {
    /*Block model that has all the properties describing the block*/
    
    //MARK: - Properties
    
    var name: String
    var color: Color
    var double: Bool //true if needs both beginning and end block like repeat, if
    var counterpart:Block? //start and end block counterpart for for etc.

    
    //MARK: Delete these (I think), maybe check through BlocksMenu.plist to make sure they aren't being used in any block
    var editable: Bool
    var options: [String] = []
    var optionsLabels: [String] = []
    var pickedOption: Int = 0
    
    var imageName: String?
    
    //For control blocks (if and repeat blocks)
    var addedBlocks: [Block] = [] //blocks that modify the current block (e.g. two times for a repeat block)
    var type: String = "Operation" //types: Operations, Booleans, Numbers
    var acceptedTypes: [String] = [] //list of types that can be added to current block (e.g. numbers for a repeat block)
    
    //MARK: - Initialization
    
    init?(name: String, color: Color, double: Bool, editable: Bool, imageName: String? = nil, options: [String] = [], pickedOption: Int = 0, optionsLabels: [String] = [], addedBlocks: [Block] = [], type: String = "Operation", acceptedTypes: [String] = []){
        
        //TODO: check that color is initialized as well
        if name.isEmpty {
            return nil
        }
        
        self.name = name
        self.color = color
        self.double = double
        self.editable = editable
        self.imageName = imageName
        self.options = options
        self.pickedOption = pickedOption
        self.optionsLabels = optionsLabels
        self.addedBlocks = addedBlocks
        self.type = type
        self.acceptedTypes = acceptedTypes
    }
    
    func addImage(_ imageName: String){
        self.imageName = imageName
    }
    
    func copy() -> Block{
        /*Used when selecting a block from the toolbox and copying into workspace*/
        let newBlock = Block.init(name: self.name, color: self.color, double: self.double, editable: self.editable, imageName: self.imageName, options: self.options, pickedOption: self.pickedOption, optionsLabels: self.optionsLabels, addedBlocks: self.addedBlocks, type: self.type, acceptedTypes: self.acceptedTypes)
        return newBlock!
    }

    
    
}
