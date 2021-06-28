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
    var blockWidth = 150
    let blockSpacing = 0
    
    //MARK: - viewDidLoad function
    override func viewDidLoad() {
    
        super.viewDidLoad()
        //self.title = "Toolbox"
        
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
        
        let myView = BlockView.init(frame: CGRect.init(x: 0, y: 0, width: blockWidth, height: blockWidth),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockWidth)
        cell.accessibilityLabel = block.name
        

        
        if #available (iOS 13.0, *)
        {
            if self.title == "Animals" {

            var voicecontrollerlabel = block.name
                let wordToRemove = "Make "
                if let range = voicecontrollerlabel.range(of: wordToRemove){
                    voicecontrollerlabel.removeSubrange(range)}

                var voicecontrollerlabel2 = voicecontrollerlabel
                let wordToRemove2 = " Noise"
                    if let range = voicecontrollerlabel2.range(of: wordToRemove2) {
                    voicecontrollerlabel2.removeSubrange(range)}

                cell.accessibilityUserInputLabels = ["\(voicecontrollerlabel)", "\(block.name)", "\(voicecontrollerlabel2)"]
    
            }
    
            else if self.title == "Control"{
                if block.name == "Wait for Time"{
                    cell.accessibilityUserInputLabels = ["Wait", "\(block.name)"]
                }
                
            }
            else if self.title == "Drive"{
                var voicecontrollerlabel = block.name
                let wordToRemove = "Drive "
                    if let range = voicecontrollerlabel.range(of: wordToRemove){
                    voicecontrollerlabel.removeSubrange(range)}
                
                cell.accessibilityUserInputLabels = ["\(voicecontrollerlabel)", "\(block.name)"]}

            else if self.title == "Lights"{
            var voicecontrollerlabel = block.name
            let wordToRemove = "Set "
                if let range = voicecontrollerlabel.range(of: wordToRemove){
                voicecontrollerlabel.removeSubrange(range)}
            
            var voicecontrollerlabel2 = voicecontrollerlabel
                if block.name != "Set All Lights"{
                    let wordToRemove2 = " Light"
                    if let range = voicecontrollerlabel2.range(of: wordToRemove2) {
                    voicecontrollerlabel2.removeSubrange(range)}
                }
            
            cell.accessibilityUserInputLabels = ["\(voicecontrollerlabel2)", "\(voicecontrollerlabel)", "\(block.name)"]

            }
            else if self.title == "Look"{
                var voicecontrollerlabel = block.name
                let wordToRemove = "Look "
                    if let range = voicecontrollerlabel.range(of: wordToRemove){
                    voicecontrollerlabel.removeSubrange(range)}
                
                cell.accessibilityUserInputLabels = ["\(voicecontrollerlabel)", "\(block.name)"]
                
            }
            else if self.title == "Sound"{
                var voicecontrollerlabel = block.name
                if block.name == "Make Random Noise"{
                    let wordToRemove2 = "Make "
                    if let range = voicecontrollerlabel.range(of: wordToRemove2) {
                    voicecontrollerlabel.removeSubrange(range)}
                }
                else if block.name.contains("Say "){
                let wordToRemove = "Say "
                    if let range = voicecontrollerlabel.range(of: wordToRemove){
                    voicecontrollerlabel.removeSubrange(range)}
                }
                cell.accessibilityUserInputLabels = ["\(voicecontrollerlabel)","\(block.name)"]
            }
            else if self.title == "Vehicle"{
                var voicecontrollerlabel = block.name
                if block.name.contains("Noise"){
                    let wordToRemove2 = " Noise"
                    if let range = voicecontrollerlabel.range(of: wordToRemove2) {
                    voicecontrollerlabel.removeSubrange(range)}
                }
                    cell.accessibilityUserInputLabels = ["\(voicecontrollerlabel)","\(block.name)"]
                }

        }
        
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
        return CGFloat(blockWidth + blockSpacing)
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
                
                //If-else
                if block.tripleCounterpart{
                    let firstBlockName = "If"
                    let firstBlock = Block(name: firstBlockName, color: block.color, double: false, tripleCounterpart: true)
                    firstBlock?.imageName = "If_Else.pdf"
                    firstBlock?.counterpart.append(block)
                    block.counterpart.append(firstBlock ?? block)
                    
                    let middleBlockName = "Else"
                    let middleBlock = Block(name: middleBlockName, color: block.color, double: false, tripleCounterpart: true)
                    middleBlock?.imageName = "Else.pdf"
                    middleBlock?.counterpart.append(block)
                    block.counterpart.append(middleBlock!)
                    print("in triple counterpart")
                    
                    let endBlockName = "End If Else"
                    let endBlock = Block(name: endBlockName, color: block.color, double: false, tripleCounterpart: true)
                    endBlock?.counterpart.append(block)
                    block.counterpart.append(endBlock!)
                    myDestination.blocks = [firstBlock!, middleBlock!, endBlock!]
                    
                }
                //let block = blocks[(tableView.indexPathForSelectedRow?.row)!].copy()
                else if block.double{
                    let endBlockName = "End " + block.name
                    let endBlock = Block(name: endBlockName, color: block.color, double: true, tripleCounterpart: false)
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
                let createFunctionBlock = Block(name: "Create/Edit Functions", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#00A6FF")), double: false, tripleCounterpart: false)!
                createFunctionBlock.type = "Function"
                functionToolBlockArray.append(createFunctionBlock)
                toolBoxBlockArray += [createFunctionBlock]
                
                for function in functionBlocks{
                    var blockBeingCreated: Block
                        blockBeingCreated = Block(name: function, color: Color.init(uiColor:UIColor.colorFrom(hexString: "#FF9300")), double: false, tripleCounterpart: false)!
                    blockBeingCreated.type = "Function"
                    functionToolBlockArray.append(blockBeingCreated)
                    toolBoxBlockArray += [blockBeingCreated]
                }
            }

            
            if let blockArray = blockType.object(forKey: "Blocks") as? NSArray{
                // creates array from the first object in blocksMenu.plist aka Animals, Controls, Drive, Sounds, etc.
                for item in blockArray{
                    print(item)
                    // for block in category Animal, Control, etc.
                    if let dictItem = item as? NSDictionary{
                        // take the block and using it as a dictionary dictItem
                        // below takes the blocks and initalizes their properties
                        let name = dictItem.object(forKey: "name")
                        if let colorString = dictItem.object(forKey: "color") as? String{
                            let color2 = Color.init(uiColor:UIColor.colorFrom(hexString: colorString))
                            if let double = dictItem.object(forKey: "double") as? Bool{
                                if let tripleCounterpart = dictItem.object(forKey: "tripleCounterpart") as? Bool{
                                    guard let block = Block(name: name as! String, color: color2 , double: double, tripleCounterpart: tripleCounterpart)else {
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
    }
    
}

