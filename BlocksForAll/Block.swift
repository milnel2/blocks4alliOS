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
    
    // From Paul, create a variable for creating the json encoded data, using the self data of the block in question
    var json: Data? {
        //        print(self)
        var blocksCounterpart = self.counterpart
        self.counterpart = nil
        var jsonString = try? JSONEncoder().encode(self)
        //        print(self.counterpart)
        self.counterpart = blocksCounterpart
        //        print(self.counterpart)
        return jsonString
    }
    
    
    // Attempting to replicate above but for a block with a counter part creates a tuple of two data objects the first data object being a block with a counterpart and the second data object being the counter part of the first block data object in the tuple
    var jsonCounter: (Data?, Data?)? {
        let counterBlock = self.counterpart!
        // creates a constant for the counterpart of the block in question, var jsonCounter is a var in all block objects so self is the block object this is being called on
        let jsonCounterString = jsonCounterPart(counterBlock: counterBlock)!
        // calls function that returns the encoded json of the counterBlock for the self block jsonCounter is a part of
        self.counterpart = nil
        // sets the counter part of the block this is being called on to nil so that it can be encoded with out infinite recursion, also why we saved the counter part block to counterBlock
        var jsonString = try? JSONEncoder().encode(self)
        // creates the encoded data object for the block this being called on
        return (jsonString, jsonCounterString)
        // returns the data object of the json encoded block and it's counterpart
    }
    
    // used to get the encoding of the coutnerpart block of the block being called in jsonCounter
    func jsonCounterPart(counterBlock: Block) -> Data? {
        // takes the counterBlock from the block called for jsonCounter in save and returns it's json encoding as a data object
        counterBlock.counterpart = nil
        //sets the counterBlock's counterpart to nil to prevent infinite recursion, this might need to be something other than nil.... that also means nothing
        var jsonCounterPartString = try? JSONEncoder().encode(self)
        // encodes the block to a json encoding data object, not sure if it should be self or counterZBlock... will need to check
        return jsonCounterPartString
        // returns the Data object json encoding of the counterBlock
    }
    
    
    //MARK: - Initialization
    
    
    //MARK: - Initialization
    
    // initializes a block from a json format data object
    init? (json: Data){
        
        // below declarations are to provide a default so the actual initialzation could be use, needs to be removed later but can't figure out error that occurs when there is no defualt
        self.name = "hello"
        self.color = Color(uiColor: UIColor(white: 0, alpha: 0))
        self.double = true
        self.editable = true
        self.imageName = "default image name"
        self.options = ["options defualt"]
        self.pickedOption = 9
        self.optionsLabels = ["options labels defualt"]
        self.addedBlocks = []
        self.type = "bool"
        self.acceptedTypes = ["bool"]
        
        
        do{
            var newValue: Block?
            // crreates a place holder block to be used below
            var jsonToUse = try? Data(contentsOf: filename)
            // I thinkg this can be delete not sure what the purpouse of it is
            
            if let newValue = try? JSONDecoder().decode(Block.self, from: json){
                // tries to take the json file passed in initialization and set the placeholder block newValue to the information in the
                self.name = newValue.name
                // initializes the new block information from the place holder block newValue.... can't remember how this works since it seems the block creation of the new value is recursive....
                self.color = newValue.color
                self.double = newValue.double
                self.editable = newValue.editable
                self.imageName = newValue.imageName
                self.options = newValue.options
                self.pickedOption = newValue.pickedOption
                self.optionsLabels = newValue.optionsLabels
                self.addedBlocks = newValue.addedBlocks
                self.type = newValue.type
                self.acceptedTypes = newValue.acceptedTypes
                //                self.counterpart = newValue.counterpart
            }
        }catch{
            print("couldn't convert json data")
            return nil
        }
    }

    
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
    
    // from Paul
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func save(){}
    
    func loadSave() {}
   
}
