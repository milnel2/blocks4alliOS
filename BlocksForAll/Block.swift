//
//  Block.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class Block {
    /*Block model that has all the properties describing the block*/
    
    //MARK: - Properties
    
    var name: String
    var color: UIColor
    var double: Bool //true if needs both beginning and end block like repeat, if
    var counterpart: Block? //start block for end block and end block for start block for double blocks
    
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
    
    init?(name: String, color: UIColor, double: Bool, editable: Bool, imageName: String? = nil, options: [String] = [], pickedOption: Int = 0, optionsLabels: [String] = [], addedBlocks: [Block] = [], type: String = "Operation", acceptedTypes: [String] = []){
        
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
