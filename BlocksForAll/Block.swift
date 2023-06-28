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
    // struct used to make a codable UIColor
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    // create variables used to construct a UIColor
    var uiColor : UIColor {
        // takes the Color object uses variables above, initialized below to create and return a UIColor object
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    init(uiColor : UIColor) {
        //initializes a color
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
    var color: Color //Color struct rather than UIColor so as to be codable
    var double: Bool //true if needs both beginning and end block like repeat, if
    var counterpart: [Block] = [] //start and end block counterpart for for etc.
    
    var imageName: String?
    
    //For control blocks (if and repeat blocks)
    var addedBlocks: [Block] = [] //blocks that modify the current block (e.g. two times for a repeat block)
    var type: String = "Operation" //types: Operations, Booleans, Numbers
    var acceptedTypes: [String] = [] //list of types that can be added to current block (e.g. numbers for a repeat block)
    
    var attributes = [String:String]() //dictionary that holds attibute values for block (e.g. distance and speed)
    var isModifiable: Bool? //true if it has a modifier block
    
    
    //MARK: - json variable
    // From Paul, create a variable for creating the json encoded data, using the self data of the block in question
    var jsonVar: Data? {
        let blocksCounterpart = self.counterpart
        self.counterpart = []
        // TODO: needs to have altered to work with IfElse blocks properly, right now their counterparts are not stored after a save, need to set each item in the array of counterparts counterparts to nil so it only saves one level and not recursively
        // gets counterpart to be re-added later, then sets the counterpart to nil so its codable
        let jsonString = try? JSONEncoder().encode(self)
        // try to encode self to a JSON object
        self.counterpart = blocksCounterpart
        // adds the counterpart back to the block
        return jsonString
    }
    
    
    //MARK: - Initialization

    init?(name: String, color: Color, double: Bool, imageName: String? = nil, addedBlocks: [Block] = [], type: String = "Operation", acceptedTypes: [String] = [], isModifiable: Bool = false){
        
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
        
    }
    
    func addImage(_ imageName: String){
        self.imageName = imageName
    }
    
    func addAttributes(key: String, value: String){
        self.attributes[key] = value
    }
    
    func copy() -> Block{
        /* Used when selecting a block from the toolbox and copying into workspace*/
        let newBlock = Block.init(name: self.name, color: self.color, double: self.double, imageName: self.imageName, addedBlocks: self.addedBlocks, type: self.type, acceptedTypes: self.acceptedTypes, isModifiable: self.isModifiable!)
        return newBlock!
    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
