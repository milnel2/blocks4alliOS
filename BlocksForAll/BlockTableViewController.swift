//
//  BlockTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BlockTableViewController: UITableViewController {
    /*Toolbox menu that displays the blocks of a certain type*/
    
    //MARK: Properties
    var toolBoxBlockArray = [Block]()
    var blockTypes = NSArray()
    var typeIndex: Int! = 0
    
    //used to pass on delegate to selectedBlockViewController
    var delegate: BlockSelectionDelegate?
    
    //update these as collection view changes
    var blockSize = 150
    let blockSpacing = 0
    
//    func getDocumentsDirectory() -> URL{
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
    
    //MARK: - viewDidLoad function
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        }
        
        blockTypes = NSArray(contentsOfFile: Bundle.main.path(forResource: "BlocksMenu", ofType: "plist")!)!
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            self.title = blockType.object(forKey: "type") as? String
        }
        self.accessibilityHint = "Double tap from toolbox to add block to workspace"
        
        createBlocksArray()
        
        //self.navigationItem.backBarButtonItem?.accessibilityLabel = "Cancel"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toolBoxBlockArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "BlockTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BlockTableViewCell else {
            fatalError("The dequeued cell is not an instance of BlockTableViewCell.")
        }
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let block = toolBoxBlockArray[indexPath.row]
        
        //probably get rid of special blocktableviewcell and just add blockView to each cell
        cell.block = block
        //cell.nameLabel.text = block.name
        //cell.blockView.backgroundColor = block.color
        
        let myView = BlockView.init(frame: CGRect.init(x: 0, y: 0, width: blockSize, height: blockSize),  block: [block], myBlockSize: blockSize)
        cell.accessibilityLabel = block.name
        
        createVoiceControlLabels(for: block, in: cell)
        
        if block.name == "Create/Edit Functions" {
            cell.accessibilityHint = "Double tap to go to functions menu."
        }
        else {
            cell.accessibilityHint = "In Toolbox. Double tap to place block in workspace."
        }
        
        cell.addSubview(myView)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let height = tableView.bounds.height/CGFloat(blocks.count)
        return CGFloat(blockSize + blockSpacing)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let block = toolBoxBlockArray[(tableView.indexPathForSelectedRow?.row)!]
        //If Create/Edit Functions button is pressed, segues to functions menu
        if block.name == "Create/Edit Functions" {
            performSegue(withIdentifier: "createFunctionPressed", sender: self)
        }
        //Otherwise, segues to selectedBlockViewController
        else {
            performSegue(withIdentifier: "blockSelected", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Letting destination controller know which blocks type was picked
        if segue.identifier == "blockSelected" {
            if let myDestination = segue.destination as? SelectedBlockViewController{
                //copy to ensure that you get a new id for each block
                let b2 = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)
                var block = toolBoxBlockArray[(tableView.indexPathForSelectedRow?.row)!].copy()
                for myView in (b2?.subviews)!{
                    if let myBlockView = myView as? BlockView{
                        block = myBlockView.blocks[0].copy()
                        
                    }
                }
                
                if block.double{
                    let endBlockName = "End " + block.name
                    let endBlock = Block(name: endBlockName, color: block.color, double: true, isModifiable: false)
                    endBlock?.counterpart.append(block)
                    block.counterpart.append(endBlock ?? block)
                    myDestination.blocks = [block, endBlock!]
                }else{
                    myDestination.blocks = [block]
                }
                myDestination.delegate = self.delegate
            }
        }
    }
    
//    func save(){
//        let fileManager = FileManager.default
//
//        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave2.json")
//        do{
//            //Deletes previous save in order to rewrite for each save action
//            try fileManager.removeItem(at: filename)
//        }catch{
//            print("couldn't delete previous Blocks4AllSave")
//        }
//
//        // string that json text is appended too
//        var writeText = String()
//        /** block represents each block belonging to the global array of blocks in the workspace. blocksStack holds all blocks on the screen. **/
//        let funcNames = functionsDict.keys
//        //gets all the function names in functionsDict as an array of strings
//
//        for name in funcNames{
//        // for all functions
//            writeText.append("New Function \n")
//            writeText.append(name)
//            //adds name of function immediately after the new function and prior to the next object so that it can be parsed same way as blocks
//            writeText.append("\n Next Object \n")
//            // allows name to be handled in load at the same time as blocks
//            for block in functionsDict[name]!{
//                // for block in the current fuctionsDict function's array of blocks
//                if let jsonText = block.jsonVar{
//                    // sets jsonText to block.jsonVar which removes counterparts so it doesn't wind up with an infite amount of counterparts
//                    writeText.append(String(data: jsonText, encoding: .utf8)!)
//                    //adds the jsonText as .utf8 as a string to the writeText string
//                    writeText.append("\n Next Object \n")
//                    //marks next object
//                }
//                do{
//                    try writeText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
//                    // writes the accumlated string of json objects to a single file
//                }catch{
//                    print("couldn't create json for", block)
//                }
//            }
//        }
//
//    }
    //MARK: Private Methods
    
    //TODO: Clean this method it's a bit convoluted
    private func createBlocksArray(){
        /*Creating the toolbox by reading in from the .plist file */
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            // blockTypes is a nsArray object with the contents of the ReleaseBlocksMenu.plist file, type index is an Int Var starts at 0, so it takes the contents of ReleaseBlocksMenu.plist and sets it to blockType as an NSDictionary
            
            if (blockType.object(forKey: "type") as? String == "Functions"){
                var functionsDictToUse = functionsDict
                functionsDictToUse.removeValue(forKey: "Main Workspace")
                let functionBlocks = Array(functionsDictToUse.keys)
                var functionToolBlockArray = [Block]()
                
                //Adds Create/Edit Functions button to Functions category
                let createFunctionBlock = Block(name: "Create/Edit Functions", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#00BBE5")), double: false, isModifiable: true)!
                createFunctionBlock.type = "Function"
                functionToolBlockArray.append(createFunctionBlock)
                toolBoxBlockArray += [createFunctionBlock]
                
                for function in functionBlocks{
                    var blockBeingCreated: Block
                        blockBeingCreated = Block(name: function, color: Color.init(uiColor:UIColor.colorFrom(hexString: "#F8E3FF")), double: false, isModifiable: false)!
                    blockBeingCreated.type = "Function"
                    functionToolBlockArray.append(blockBeingCreated)
                    toolBoxBlockArray += [blockBeingCreated]
                }
            }

            
            if let blockArray = blockType.object(forKey: "Blocks") as? NSArray{
                // creates array from the first object in blocksMenu.plist aka Sounds, Controls, Drive, Sounds, etc.
                for item in blockArray{
                    print(item)
                    // for block in category Sounds, Control, etc.
                    if let dictItem = item as? NSDictionary{
                        // take the block and using it as a dictionary dictItem
                        // below takes the blocks and initalizes their properties
                        let name = dictItem.object(forKey: "name")
                        let isModifiable = dictItem.object(forKey: "isModifiable") as? Bool ?? false
                        if let colorString = dictItem.object(forKey: "color") as? String{
                            let color2 = Color.init(uiColor: UIColor(named: "\(colorString)") ?? UIColor.gray)
                            print (colorString)
                            print (color2)
                            if let double = dictItem.object(forKey: "double") as? Bool{
                                guard let block = Block(name: name as! String, color: color2 , double: double, isModifiable: isModifiable) else {
                                    fatalError("Unable to instantiate block")
                                }
                                if let imageName = dictItem.object(forKey: "imageName") as? String{
                                    block.addImage(imageName)
                                }
                                if let type = dictItem.object(forKey: "type") as? String{
                                    block.type = type
                                }
                                if let acceptedTypes = dictItem.object(forKey: "acceptedTypes") as? [String]{
                                    block.acceptedTypes = acceptedTypes
                                }
                                toolBoxBlockArray += [block]
                                // adds block to the toolbox
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createVoiceControlLabels(for block: Block, in cell: UITableViewCell) {
        if #available (iOS 13.0, *) {
            let type = self.title
        
            switch type {
            case "Control":
                if block.name == "Wait for Time"{
                    cell.accessibilityUserInputLabels = ["Wait", "\(block.name)"]
                }
//                save()
                
            case "Drive":
                var voiceControlLabel = block.name
                
                if block.name.contains("Drive") {
                    let wordToRemove = "Drive "
                    if let range = voiceControlLabel.range(of: wordToRemove){
                        voiceControlLabel.removeSubrange(range)
                    }
                }
                else if block.name.contains("Turn") {
                    let wordToRemove = "Turn "
                    if let range = voiceControlLabel.range(of: wordToRemove){
                        voiceControlLabel.removeSubrange(range)
                    }
                }
                    
                cell.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(block.name)"]
//                save()
                
            case "Lights":
                var voiceControlLabel = block.name
                let wordToRemove = "Set "
                if let range = voiceControlLabel.range(of: wordToRemove){
                    voiceControlLabel.removeSubrange(range)
                }
                
                var voiceControlLabel2 = voiceControlLabel
                if block.name != "Set All Lights"{
                    let wordToRemove2 = " Light"
                    if let range = voiceControlLabel2.range(of: wordToRemove2) {
                        voiceControlLabel2.removeSubrange(range)
                    }
                }
                
                cell.accessibilityUserInputLabels = ["\(voiceControlLabel2)", "\(voiceControlLabel)", "\(block.name)"]
//                save()
                
            case "Look":
                var voiceControlLabel = block.name
                let wordToRemove = "Look "
                if let range = voiceControlLabel.range(of: wordToRemove){
                    voiceControlLabel.removeSubrange(range)
                }
                
                cell.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(block.name)"]
//                save()
                
            default:
                cell.accessibilityUserInputLabels = ["\(block.name)"]
//                save()
            }
        }
    }
}

