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
    var counterpart:Block? //start and end block counterpart for for etc.
    
    var imageName: String?
    
    //For control blocks (if and repeat blocks)
    var addedBlocks: [Block] = [] //blocks that modify the current block (e.g. two times for a repeat block)
    var type: String = "Operation" //types: Operations, Booleans, Numbers
    var acceptedTypes: [String] = [] //list of types that can be added to current block (e.g. numbers for a repeat block)
    
    var attributes = [String:String]() //dictionary that holds attribute values for block (e.g. distance and speed)
    
    
    //MARK: - json variable
    // From Paul, create a variable for creating the json encoded data, using the self data of the block in question
    var json: Data? {
        let blocksCounterpart = self.counterpart
        self.counterpart = nil
        // gets counterpart to be re-added later, then sets the counterpart to nil so its codable
        let jsonString = try? JSONEncoder().encode(self)
        // try to encode self to a JSON object
        self.counterpart = blocksCounterpart
        // adds the counterpart back to the block
        return jsonString
    }
    
    
    //MARK: - Initialization
    
    init? (json: Data){
        // initializes a block from a json format data object
        // below declarations are to provide a default so the actual initialzation could be use, needs to be removed later but can't figure out error that occurs when there is no defualt
        self.name = "hello"
        self.color = Color(uiColor: UIColor(white: 0, alpha: 0))
        self.double = true
        self.imageName = nil
        self.addedBlocks = []
        self.type = "bool"
        self.acceptedTypes = ["bool"]
        self.attributes = [String:String]()
        
        if let newValue = try? JSONDecoder().decode(Block.self, from: json){
            // tries to take the json file passed in initialization and set the placeholder block newValue to the information in the
            self.name = newValue.name
            // initializes the new block information from the place holder block newValue.... can't remember how this works since it seems the block creation of the new value is recursive....
            self.color = newValue.color
            self.double = newValue.double
            self.imageName = newValue.imageName
            self.addedBlocks = newValue.addedBlocks
            self.type = newValue.type
            self.acceptedTypes = newValue.acceptedTypes
            self.attributes = newValue.attributes
        }
    }
    
    
    init?(name: String, color: Color, double: Bool, imageName: String? = nil, addedBlocks: [Block] = [], type: String = "Operation", acceptedTypes: [String] = []){
        
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
        
    }
    
    func addImage(_ imageName: String){
        self.imageName = imageName
    }
    
    func addAttributes(key: String, value: String){
        self.attributes[key] = value
    }
    
    func copy() -> Block{
        /*Used when selecting a block from the toolbox and copying into workspace*/
        let newBlock = Block.init(name: self.name, color: self.color, double: self.double, imageName: self.imageName, addedBlocks: self.addedBlocks, type: self.type, acceptedTypes: self.acceptedTypes)
        return newBlock!
    }
    
    // from Paul
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
