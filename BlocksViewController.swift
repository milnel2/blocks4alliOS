//
//  BlocksViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 5/9/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AVFoundation

//collection of blocks that are part of the program
var blocksStack = [Block]()

func loadSave() {
    print("load save called")
    //    print("contents of filename")
    //    print( try? String(contentsOf: filename))
    
    var blockStackFromSave: [Block] = []
    //array of blocks loaded from the save
    
    do{
        let jsonString = try String(contentsOf: filename)
        // creates a string type of the entire json file
        let jsonStrings = jsonString.components(separatedBy: "\n Next Object \n")
        // the string of the json file parsed out into each object in the file
        var doesPreviousNeedCounter = false
        // if this is true that means the previous block needed a counter part, and the current object needs to be created as the
        
        for part in jsonStrings {
            //            print("part to be processed")
            //            print(part)
            if part == "" {
                break
            }
            // this covers the last string parsed out that's just a new line
            
            let jsonPart = part.data(using: .utf8)
            // this takes the json object as a string and turns it into a data object named jsonPart
            let blockBeingCreated = Block(json: jsonPart!)
            // this is the block being made, it's created using the block initializer that takes a data format json
            
            if blockBeingCreated?.name == "Repeat"{
                // for some reason the || or statement doesn't work in these conditionals and I wonder if "End Repeat" is accepted here
                doesPreviousNeedCounter = true
                // lets the function know that on the next block it will be initialized and then added as a counter part in the 2nd to last else statment
                blockStackFromSave.append(blockBeingCreated!)
                // adds the block created to the end of the stack that is being created and later set to the global blocksStack
            }else if blockBeingCreated?.name == "If"{
                doesPreviousNeedCounter = true
                blockStackFromSave.append(blockBeingCreated!)
                // mirrors Repeat clause
            }else if doesPreviousNeedCounter == true{
                blockStackFromSave.last?.counterpart = blockBeingCreated
                doesPreviousNeedCounter = false
                // if the last block was something with a counterpart
                // sets last block's counter part to the block created
                // resets the counterpart var
                // does not added the created block to the block stack
            }else{
                //            print("blockBeingCreated")
                //            print(blockBeingCreated?.name)
                blockStackFromSave.append(blockBeingCreated!)
                // catch for all blocks without counterparts just adds block to the stack
            }
        }
        //        print("blockStackFromSave")
        //        for block in blockStackFromSave{
        //            print(block.name)
        //        }
        //        print("blocksStack Below")
        //        for block in blocksStack{
        //            print(block.name)
        //        }
        blocksStack = blockStackFromSave
        // blockStackFrom save is array of blocks created from save file in this function, sets it to the global array of blocks used
        print("load completed")
    }catch{
        print("load Failed")
    }
}

// from Paul
func getDocumentsDirectory() -> URL{
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
// gets the path for the sandbox we're in

public let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
// global var for the location of the save file

//MARK: - Block Selection Delegate Protocol
protocol BlockSelectionDelegate{
    /*Used to send information to SelectedBlockViewController when moving blocks in workspace*/
    func setSelectedBlocks(_ blocks:[Block])
    func unsetBlocks()
    func setParentViewController(_ myVC:UIViewController)
}

class BlocksViewController:  RobotControlViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BlockSelectionDelegate {
    
    
    
    
    @IBOutlet weak var blocksProgram: UICollectionView!
    //View on the bottom of the screen that shows blocks in worksapce
    @IBOutlet weak var playTrashToggleButton: UIButton!
    
    var blocksBeingMoved = [Block]() /* List of blocks that are currently being moved (moving repeat and if blocks
     also move the blocks nested inside */
    var movingBlocks = false    //True if currently moving blocks in the workspace
    
    var containerViewController: UINavigationController? //Top-level controller for toolbox view controllers
    
    // FIXME: the blockWidth and blockHeight are not the same as the variable blockSize (= 100) - discuss
    var blockWidth = 150
    var blockHeight = 150
    let blockSpacing = 1
    
    
    
    @IBOutlet weak var menuButton: UIButton!
    
    
    func save(){
        print("save called")
        
        let fileManager = FileManager.default
        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
        do{
            try fileManager.removeItem(at: filename)
            //Deletes previous save to rewrite later on for each save action
        }catch{
            print("couldn't delete")
        }
        
        //        print("blocks in block stack:")
        //        print(blocksStack)
        
        var writeText = String()
        // string that json text is appended too
        for block in blocksStack{
            // blocks is each block as iterated through the array of the global variable of the array of blocks in the workspace
            //            print("in for loop")
            if block.name == "If"{
                // catch for it the block being and If block not sure if it catches if end block
                if block.counterpart != nil{
                    if let jsonText = block.jsonCounter{
                        // lets jsonText take the form of jsonCounter var in block, which takes a 2 tuple of optional data types
                        writeText.append(String(data: jsonText.0!, encoding: .utf8)!)
                        // adds the block data in the index 0 of the tuple string form and appends it to the end of the string later encoded to the save file
                        writeText.append("\n Next Object \n")
                        // marker for seperating and parsing the blocks in the json file later in the loadSave() function
                        writeText.append(String(data: jsonText.1!, encoding: .utf8)!)
                        // does the same as the one above but for the second data in the tuple of jsonCounter
                        writeText.append("\n Next Object \n")
                        // marker for seperating for parsing later
                    }
                } else if block.name == "Repeat"{
                    // catch for Repeat not sure if it catches End Repeat
                    if let jsonText = block.jsonCounter{
                        writeText.append(String(data: jsonText.0!, encoding: .utf8)!)
                        writeText.append("\n Next Object \n")
                        writeText.append(String(data: jsonText.1!, encoding: .utf8)!)
                        writeText.append("\n Next Object \n")
                    }
                }
            }else{
                // catch for all blocks without a counterpart(everything but repeat and if)
                if let jsonText = block.json {
                    // sets jsonText to the var type json in block that takes a Data object
                    writeText.append(String(data: jsonText, encoding: .utf8)!)
                    // appends the data from jsonText in string form to the string writeText later saved as json ssave file
                    writeText.append("\n Next Object \n")
                }
                //                    print("wrote")
            }
            
            do{
                try writeText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                // writes the accumlated string of json objects to a single file
                try print(String(contentsOf: filename))
            }catch {
                print("couldn't print json")
            }
        }
        print("\n end of save")
    }
    
    
    // MARK: - - View Set Up
    // MARK: - viewDidLoad
    
    
    override func viewDidLoad() {
        //        let fileManager = FileManager.default
        //        print("save called")
        //        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
        //        do{
        //            try fileManager.removeItem(at: filename)
        //            //Deletes previous save to rewrite later on for each save action
        //        }catch{
        //            print("couldn't delete")
        //        }
        ////    uncomment and get started once don't place blocks then stop the program to clear the save file to empty
        
        super.viewDidLoad()
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        print("before loadSave blocksStack")
        for block in blocksStack{
            print(block.name)
        }
        loadSave()
        save()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - - Block Selection Delegate functions
    // MARK: add save function to function
    func unsetBlocks() {
        /*Called after Blocks have been placed in final destination, so unset everything*/
        movingBlocks = false
        blocksBeingMoved.removeAll()
        changePlayTrashButton() //Toggling the play/trash button
        save()
    }
    
    // MARK: add save function to function
    func setSelectedBlocks(_ blocks: [Block]) {
        /*Called when moving moving blocks*/
        movingBlocks = true
        blocksBeingMoved = blocks
        blocksProgram.reloadData()
        changePlayTrashButton()
        save()
    }
    
    //TODO: LAUREN, figure out what this code is for
    func setParentViewController(_ myVC: UIViewController) {
        containerViewController = myVC as? UINavigationController
    }
    
    
	
	//MARK: - Trash Button Play Button
	/*
     Changes the play button back and forth from trash to play
     */
    func changePlayTrashButton(){
        if movingBlocks{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "Trashcan"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Place in Trash"
            playTrashToggleButton.accessibilityHint = "Delete selected blocks"
        }else{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Play"
            playTrashToggleButton.accessibilityHint = "Make your robot go!"
        }
    }
    
    // run the actual program when the play button is clicked or put blocks in trash
    @IBAction func playButtonClicked(_ sender: Any) {
        if(movingBlocks){
            //trash
            changePlayTrashButton()
            let announcement = blocksBeingMoved[0].name + " placed in trash."
            playTrashToggleButton.accessibilityLabel = announcement
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.containerViewController?.popViewController(animated: false)
            })
            blocksProgram.reloadData()
            movingBlocks = false
            blocksBeingMoved.removeAll()
            print("put in trash")
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
        }else{
            //play
            if(!connectedRobots()){
                //no robots
                let announcement = "Connect to the dash robot. "
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, NSLocalizedString(announcement, comment: ""))
                print("No robots")
                performSegue(withIdentifier: "AddRobotSegue", sender: nil)
                
            }else if(blocksStack.isEmpty){
                changePlayTrashButton()
                let announcement = "Your robot has nothing to do!  Add some blocks to your workspace. "
                playTrashToggleButton.accessibilityLabel = announcement
                
            }else{
                let commands = createCommandSequence(blocksStack)
                play(commands)
            }
        }
    }
	
    //MARK: Complier methods, converts from Blocks4All to robot code
    //MARK: Clean this up!!
    //Unrolls the repeat loops in the blocks program: converts to a list of commands to run
    func unrollLoop(times: Int, blocks:[Block])->[String]{
        var commands = [String]() //list of commands so far
        for _ in 0..<times{
            var i = 0
            while i < blocks.count{
                if blocks[i].name.contains("Repeat") {
                    var timesToRepeat = 1
                    if !blocks[i].addedBlocks.isEmpty {
                        if blocks[i].addedBlocks[0].name == "two times"{
                            timesToRepeat = 2
                        }else if blocks[i].addedBlocks[0].name == "three times"{
                            timesToRepeat = 3
                        }else if blocks[i].addedBlocks[0].name == "four times"{
                            timesToRepeat = 4
                        }else if blocks[i].addedBlocks[0].name == "five times"{
                            timesToRepeat = 5
                        }
                    }else{
                        //default
                        timesToRepeat = 2
                    }

                    var ii = i+1
                    var blocksToUnroll = [Block]()
                    while blocks[i].counterpart !== blocks[ii]{
                        blocksToUnroll.append(blocks[ii])
                        ii += 1
                    }
                    i = ii
                    let items = unrollLoop(times: timesToRepeat, blocks: blocksToUnroll)
                    //add items
                    for item in items{
                        commands.append(item)
                    }

                }else{
                    var myCommand = blocks[i].name
                    if blocks[i].name.contains("If"){
                        if !blocks[i].addedBlocks.isEmpty {
                            myCommand.append(blocks[i].addedBlocks[0].name)
                        }
                    }
                    
                    if blocks[i].name.contains("Distance"){
                        let distance = blocks[i].options[blocks[i].pickedOption]
                        myCommand.append(distance)
                    }
                    commands.append(myCommand)
                }
                i+=1
            }
        }
        return commands
    }
    
    //turns the blocks into robot commands
    func createCommandSequence(_ blocks: [Block])->[String]{
        let commands = unrollLoop(times: 1, blocks: blocks)
        for c in commands{
            print(c)
        }
        return commands
    }
    
    // MARK: - Blocks Methods
    
    func addBlocks(_ blocks:[Block], at index:Int){
        /*Called after selecting a place to add a block to the workspace, makes accessibility announcements
         and place blocks in the blockProgram stack, etc...*/
        
        //change for beginning
        var announcement = ""
        if(index != 0){
            let myBlock = blocksStack[index-1]
            announcement = blocks[0].name + " placed after " + myBlock.name
        }else{
            announcement = blocks[0].name + " placed at beginning"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
           self.makeAnnouncement(announcement)
        })
        
        //add a completion block here
        if(blocks[0].double){
            blocksStack.insert(contentsOf: blocks, at: index)
            blocksBeingMoved.removeAll()
            blocksProgram.reloadData()
        }else{
            blocksStack.insert(blocks[0], at: index)
            //NEED TO DO THIS?
            blocksBeingMoved.removeAll()
            blocksProgram.reloadData()
        }
    }
    
    func makeAnnouncement(_ announcement: String){
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
    }
    
    func createViewRepresentation(FromBlocks blocksRep: [Block]) -> UIView {
        /*Given a list of blocks, creates the views that will be displayed in the blocksProgram*/
        let myViewWidth = (blockWidth + blockSpacing)*blocksRep.count
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        var count = 0
        for block in blocksRep{
            let xCoord = count*(blockWidth + blockSpacing)
            
            let blockView = BlockView(frame: CGRect(x: xCoord, y: 0, width: blockWidth, height: blockHeight),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
            count += 1

            myView.addSubview(blockView)
            
        }
        myView.alpha = 0.75
        return myView
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocksStack.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: CGFloat(blockWidth), height: collectionView.frame.height)
        print(indexPath)
        if indexPath.row == blocksStack.count {
            // expands the size of the last cell in the collectionView, so it's easier to add a block at the end
            // with VoiceOver on
            if blocksStack.count < 8 {
                // TODO: eventually simplify this section without blocksStack.count < 8
                // blocksStack.count < 8 means that the orignal editor only fit up to 8 blocks of a fixed size horizontally, but we may want to change that too
                let myWidth = collectionView.frame.width
                size = CGSize(width: myWidth, height: collectionView.frame.height)
            }else{
                size = CGSize(width: CGFloat(blockWidth), height: collectionView.frame.height)
            }
        }
        return size
    }

    
    /* adds in label for voiceOver
     */
    func addAccessibilityLabel(myLabel: UIView, block:Block, number: Int, blocksToAdd: [Block], spatial: Bool, interface: Int){
        //TODO: if condition change accessibility label
        myLabel.isAccessibilityElement = true
        var accessibilityLabel = ""
        //is blocksStack.count always correct?
        let blockPlacementInfo = ". Workspace block " + String(number) + " of " + String(blocksStack.count)
        var accessibilityHint = ""
        var movementInfo = ". Double tap to move block."

        if(!blocksBeingMoved.isEmpty){
            //Moving blocks, so switch labels to indicated where blocks can be placed
            if(interface == 0){
                accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " before "
            }else{
                accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " after "
            }
            movementInfo = ". Double tap to add " + blocksBeingMoved[0].name + " block here"
            
            if(blocksBeingMoved[0].type == "Boolean" || blocksBeingMoved[0].type == "Number"){
                //if block being moved is a boolean or number, announces information about where it can and cannot go
                var acceptsNumbers = false
                var acceptsBooleans = false
                for type in block.acceptedTypes{
                    if type == "Boolean"{
                        acceptsBooleans = true
                    }
                    if type == "Number"{
                        acceptsNumbers = true
                    }
                }
                if acceptsNumbers && blocksBeingMoved[0].type == "Number"{
                    accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " as number of times "
                }else if acceptsBooleans && blocksBeingMoved[0].type == "Boolean"{
                    accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " as condition of "
                }else{
                    accessibilityLabel = "Cannot place in "
                    movementInfo = ""
                }
            }
        }
     
        if(interface == 1){
            movementInfo = ". tap and hold to move block."
        }
        
        accessibilityLabel +=  block.name + blockPlacementInfo
        accessibilityHint += movementInfo
        
        myLabel.accessibilityLabel = accessibilityLabel
        myLabel.accessibilityHint = accessibilityHint
    }
    
    /* CollectionView contains the actual collection of blocks (i.e. the program that is being created with the blocks)
      This method creates and returns the cell at a given index
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionReuseIdentifier = "BlockCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        cell.isAccessibilityElement = false
        if indexPath.row == blocksStack.count {
            // The last cell in the collectionView is an empty cell so you can place blocks at the end
            if !blocksBeingMoved.isEmpty{
                cell.isAccessibilityElement = true
                
                if blocksStack.count == 0 {
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at Beginning"
                }else{
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at End"
                }
                if(blocksBeingMoved[0].type == "Boolean" || blocksBeingMoved[0].type == "Number"){
                        cell.accessibilityLabel = "Cannot place at end "
                }
            }
        }else{
        
            let startingHeight = Int(cell.frame.height)-blockHeight
            
            let block = blocksStack[indexPath.row]
            var blocksToAdd = [Block]()
            
            //check if block is nested (or nested multiple times) and adds in "inside" repeat/if blocks
            for i in 0...indexPath.row {
                if blocksStack[i].double {
                    if(!blocksStack[i].name.contains("End")){
                        if(i != indexPath.row){
                            blocksToAdd.append(blocksStack[i])
                        }
                    }else{
                        blocksToAdd.removeLast()
                    }
                }
            }
            var count = 0
            for b in blocksToAdd{
                let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))

                myView.accessibilityLabel = "Inside " + b.name
                myView.text = "Inside " + b.name

                cell.addSubview(myView)
                count += 1
            }

            var name = block.name
            print(name)
            switch name{
            case "If":
                if block.addedBlocks.isEmpty{
                    //draw false block
                    var placeholderBlock = Block(name: "False", color: Color.init(uiColor:UIColor.red ) , double: false, editable: false, imageName: "false.pdf", type: "Boolean")
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [placeholderBlock!], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = "False"
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                } else {
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block.addedBlocks[0]], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = block.addedBlocks[0].name
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }
            case "Repeat":
                if block.addedBlocks.isEmpty{
                    //draw false block
                    var placeholderBlock = Block(name: "False", color: Color.init(uiColor:UIColor.red ) , double: false, editable: false, imageName: "false.pdf", type: "Boolean")
                    if block.name == "Repeat"{
                        placeholderBlock = Block(name: "two times", color: Color.init(uiColor:UIColor.red ) , double: false, editable: false, imageName: "2.pdf", type: "Number")
                    }
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [placeholderBlock!], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = "False"
                    if block.name == "Repeat"{
                        myConditionLabel.accessibilityLabel = "two times"
                    }
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                } else {
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block.addedBlocks[0]], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = block.addedBlocks[0].name
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }
            case "Drive Forward", "Drive Backward":
                if block.addedBlocks.isEmpty{
                    var placeholderBlock = Block(name: "two times", color: Color.init(uiColor:UIColor.red ) , double: false, editable: false, imageName: "2.pdf", type: "Number")
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [placeholderBlock!], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = "Distance"
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                } else {
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block.addedBlocks[0]], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = block.addedBlocks[0].name
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }
            case "Turn Left", "Turn Right":
                if block.addedBlocks.isEmpty{
                    var placeholderBlock = Block(name: "two times", color: Color.init(uiColor:UIColor.red ) , double: false, editable: false, imageName: "2.pdf", type: "Number")
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [placeholderBlock!], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = "Distance"
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                } else {
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block.addedBlocks[0]], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = block.addedBlocks[0].name
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }
            case "Set Eye Light", "Set Left Ear Light", "Set Right Ear Light":
                if block.addedBlocks.isEmpty{
                    var placeholderBlock = Block(name: "two times", color: Color.init(uiColor:UIColor.red ) , double: false, editable: false, imageName: "2.pdf", type: "Number")
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [placeholderBlock!], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = "Distance"
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                } else {
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block.addedBlocks[0]], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = block.addedBlocks[0].name
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }
            default:
                print("This block does not need a modifier")
            }
            
            //add main label
            
            let myLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
            addAccessibilityLabel(myLabel: myLabel, block: block, number: indexPath.row+1, blocksToAdd: blocksToAdd, spatial: true, interface: 0)
            cell.addSubview(myLabel)
        }
        cell.accessibilityElements = cell.accessibilityElements?.reversed()
        return cell
    }

    
    func createBlock(_ block: Block, withFrame frame:CGRect)->UILabel{
        let myLabel = UILabel.init(frame: frame)
        //let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: blockHeight))
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = block.color.uiColor
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = block.color.uiColor
        return myLabel
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*Called when a block is selected in the collectionView, so either selects block to move or places blocks*/
        if(movingBlocks){
            if blocksBeingMoved[0].type == "Boolean" || blocksBeingMoved[0].type == "Number"{
                //TODO: can only be added above conditional
                var acceptsBooleans = false
                var acceptsNumbers = false
                if(indexPath.row < blocksStack.count){//otherwise empty block at end
                    let myBlock = blocksStack[indexPath.row]
                    for type in myBlock.acceptedTypes{
                        if type == "Boolean"{
                            acceptsBooleans = true
                        }
                        if type == "Number"{
                            acceptsNumbers = true
                        }
                    }
                    if blocksBeingMoved[0].type == "Boolean" && acceptsBooleans{
                        //add it here
                        myBlock.addedBlocks.removeAll()
                        myBlock.addedBlocks.append(blocksBeingMoved[0])
                        containerViewController?.popViewController(animated: false)
                        let condition = myBlock.addedBlocks[0].name
                        let announcement = condition + "placed in if statement"
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            self.makeAnnouncement(announcement)
                        })
                        blocksProgram.reloadData()
                        unsetBlocks()
                    }else if blocksBeingMoved[0].type == "Number" && acceptsNumbers{
                        //add it here
                        myBlock.addedBlocks.removeAll()
                        myBlock.addedBlocks.append(blocksBeingMoved[0])
                        containerViewController?.popViewController(animated: false)
                        let condition = myBlock.addedBlocks[0].name
                        let announcement = condition + "placed in repeat statement"
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        self.makeAnnouncement(announcement)
                        })
                        blocksProgram.reloadData()
                        unsetBlocks()
                    }else{
                        //say you can't add it here
                        print("you can't add it here")
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                            self.makeAnnouncement("you can't add it here")
                        })
                        
                    }
                }else{
                    //say you can't add it here
                    print("you can't add it here")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        self.makeAnnouncement("you can't add it here")
                    })
                }
            }else{
                addBlocks(blocksBeingMoved, at: indexPath.row)
                containerViewController?.popViewController(animated: false)
                unsetBlocks()
            }
        }else{
            if(indexPath.row < blocksStack.count){ //otherwise empty block at end
                movingBlocks = true
                let blocksStackIndex = indexPath.row
                let myBlock = blocksStack[blocksStackIndex]
                //remove block from collection and program
                if myBlock.double == true{
                    var indexOfCounterpart = -1
                    for i in 0..<blocksStack.count {
                        if blocksStack[i] === myBlock.counterpart! {
                            indexOfCounterpart = i
                        }
                    }
                    var indexPathArray = [IndexPath]()
                    var tempBlockStack = [Block]()
                    for i in min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex){
                        indexPathArray += [IndexPath.init(row: i, section: 0)]
                        tempBlockStack += [blocksStack[i]]
                    }
                    blocksBeingMoved = tempBlockStack
                    
                    blocksStack.removeSubrange(min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex))
                    
                }else{ //only a single block to be removed
                    blocksBeingMoved = [blocksStack[blocksStackIndex]]
                    blocksStack.remove(at: blocksStackIndex)
                }
                blocksProgram.reloadData()
                let mySelectedBlockVC = SelectedBlockViewController()
                mySelectedBlockVC.blocks = blocksBeingMoved
                containerViewController?.pushViewController(mySelectedBlockVC, animated: false)
                changePlayTrashButton()
            }
        }
    }
    
    // MARK: - - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? UINavigationController{
            if let myTopViewController = destinationViewController.topViewController as? BlocksTypeTableViewController{
                myTopViewController.delegate = self
                myTopViewController.blockWidth = 150
            }
        }
        
    }
    

}
