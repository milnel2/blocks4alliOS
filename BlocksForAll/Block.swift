//  Block.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//
//
// The code below came from:
//      https://stackoverflow.com/questions/50928153/make-uicolor-codable

import UIKit
//MARK: - Codable Color Class
/// Makes a struct Color and creates a uiColor from it while conforming to the codable forms that swift allows for encoding and decoding.
struct Color : Codable {
    
    // Struct used to make a codable UIColor.
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    // Creates variables used to construct a UIColor.
    var uiColor : UIColor {
        // Takes the Color object uses variables above, initialized below to create and return a UIColor object.
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor : UIColor) {
        // Initializes a color.
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}

/// This is the actual encoding and decoding of the uiColor.
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
// Above code is from https://stackoverflow.com/questions/50928153/make-uicolor-codable

//MARK: - Block Class
/// Block model that has all the properties describing the block
class Block: Codable {
    
    //MARK: Properties
    
    var name: String
    var color: Color  // Color struct rather than UIColor so as to be codable.
    var imageName: String?  // The block's image in assets.
    
    var double: Bool  // True if the block needs both beginning and end blocks, like repeat and if blocks.
    var counterpart: [Block] = []  // Start and end block counterpart for For, etc.
    
    //For control blocks (if and repeat blocks).
    var addedBlocks: [Block] = []  // Blocks that modify the current block (e.g. two times for a repeat block).
    var type: String = "Operation"  // Types: Operations, Booleans, Numbers
    var acceptedTypes: [String] = []  // List of types that can be added to current block (e.g. numbers for a repeat block).
    
    var attributes = [String : String]()  // Dictionary that holds attribute values for block (e.g. distance and speed).
    var isModifiable: Bool?  // True if it has a modifier block.
    var isInToolBox: Bool?  // True if this block is being shown in the toolbox. False for blocks in the workspace.
    var isRunning: Bool = false // True if the block is currently running. False if not. Used to highlight the block that is running. 
    
    
    //MARK: - JSON Variable
    // From Paul: Create a variable for creating the json encoded data, using the self data of the block in question.
    var jsonVar: Data?
    {
        // Gets counterpart to be re-added later, then sets the counterpart to nil so it's codable
        let blocksCounterpart = self.counterpart
        self.counterpart = []
        
        let jsonString = try? JSONEncoder().encode(self)  // Tries to encode self to a JSON object
        self.counterpart = blocksCounterpart  // Adds the counterpart back to the block
        
        return jsonString
    }
    
    
    //MARK: - Initialization
    /// If isInToolbox is not initialized, it will be set to false.
    init?(name: String,
          color: Color,
          double: Bool,
          imageName: String? = nil,
          addedBlocks: [Block] = [],
          type: String = "Operation",
          acceptedTypes: [String] = [],
          isModifiable: Bool = false)
    {
        
        //TODO: check that color is initialized as well
        if name.isEmpty{
            return nil
        }
        
        self.name = name
        self.color = color
        self.double = double
        self.imageName = imageName
        self.addedBlocks = addedBlocks
        self.type = type
        self.acceptedTypes = acceptedTypes
        self.isModifiable = isModifiable
        self.isInToolBox = false  // Assumes the block is not in the toolbox on initialization.
        self.isRunning = false
    }
    init?(name: String,
          color: Color,
          double: Bool,
          imageName: String? = nil,
          addedBlocks: [Block] = [],
          type: String = "Operation",
          acceptedTypes: [String] = [],
          isModifiable: Bool = false,
          isInToolBox: Bool)
    {
        
        //TODO: check that color is initialized as well
        if name.isEmpty {
            return nil
        }
        
        self.name = name
        self.color = color
        self.double = double
        self.imageName = imageName
        self.addedBlocks = addedBlocks
        self.type = type
        self.acceptedTypes = acceptedTypes
        self.isModifiable = isModifiable
        self.isInToolBox = isInToolBox
        self.isRunning = false
    }
    
    //MARK: - Public Functions
    /// Adds an image to the block using a file name.
    func addImage(_ imageName: String)
    {
        self.imageName = imageName
    }
    
    func addAttributes(key: String, value: String)
    {
        self.attributes[key] = value
    }
    
    /// Used when selecting a block from the toolbox and copying into workspace.
    func copy() -> Block
    {
        let newBlock = Block.init(name: self.name, color: self.color, double: self.double, imageName: self.imageName, addedBlocks: self.addedBlocks, type: self.type, acceptedTypes: self.acceptedTypes, isModifiable: self.isModifiable!)
        
        return newBlock!
    }
    
    func getDocumentsDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
