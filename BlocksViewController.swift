//  BlocksViewController.swift
//  BlocksForAll
//
// ViewController for the workspace where the block program is being created
//
//  Created by Lauren Milne on 5/9/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AVFoundation

/// dictionary containing the different functions (composed as a list of Blocks) in the program
var functionsDict = [String : [Block]]()

/// workspace you are currently editing on screen (i.e. the main workspace or a user-defined function)
var currentWorkspace = String()

// from Paul Hegarty, lectures 13 and 14
let defaults = UserDefaults.standard

let startIndex = 0
var endIndex: Int{
    return functionsDict[currentWorkspace]!.count - 1
}

//MARK: - Block Selection Delegate Protocol
/// Sends information about which blocks are selected to SelectedBlockViewController when moving blocks in workspace.
protocol BlockSelectionDelegate{
    func beginMovingBlocks(_ blocks:[Block])
    func finishMovingBlocks()
    func setParentViewController(_ myVC:UIViewController)
}

//For creating voice control labels (source: https://stackoverflow.com/questions/41292671/separating-camelcase-string-into-space-separated-words-in-swift)
extension String {
    func titleCased() -> String {
        return self.replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression, range: self.range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
}

class BlocksViewController:  RobotControlViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BlockSelectionDelegate {
    
    //Larger views
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var workspaceContainerView: UIView!
    @IBOutlet weak var toolboxView: UIView!

    //The three main workspace menu buttons
    @IBOutlet weak var mainMenuButton: CustomButton!
    @IBOutlet weak var clearAllButton: CustomButton!
    
    @IBOutlet weak var playTrashToggleButton: UIButton!
    
    @IBOutlet weak var workspaceNameLabel: UILabel!
    
    /// view on bottom of screen that shows blocks in workspace
    @IBOutlet weak var blocksProgram: UICollectionView!

    
    var movingBlocks = false
    /// blocks currently being moved (includes nested blocks)
    var blocksBeingMoved = [Block]()
    /// Top-level controller for toolbox view controllers
    var containerViewController: UINavigationController?
    
    // TODO: the blockWidth and blockHeight are not the same as the variable blockSize (= 100)
    var blockSize = 150
    let blockSpacing = 1
    
    // TODO: what are these variables?
    var modifierBlockIndex: Int?
    var tappedModifierIndex: Int?
    
    // from Paul Hegarty, lectures 13 and 14
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /// Saves each block as a json object cast as a String to a file. Uses fileManager to add and remove blocks from previous saves to stay up to date.
    func save(){
        let fileManager = FileManager.default

        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
        do{
            //Deletes previous save in order to rewrite for each save action
            try fileManager.removeItem(at: filename)
        }catch{
            print("couldn't delete previous Blocks4AllSave")
        }
        
        // string that json text is appended too
        var writeText = String()
        /** block represents each block belonging to the global array of blocks in the workspace. blocksStack holds all blocks on the screen. **/
        let funcNames = functionsDict.keys
        //gets all the function names in functionsDict as an array of strings
        
        for name in funcNames{
        // for all functions
            writeText.append("New Function \n")
            writeText.append(name)
            //adds name of function immediately after the new function and prior to the next object so that it can be parsed same way as blocks
            writeText.append("\n Next Object \n")
            // allows name to be handled in load at the same time as blocks
            for block in functionsDict[name]!{
                // for block in the current fuctionsDict function's array of blocks
                if let jsonText = block.jsonVar{
                    // sets jsonText to block.jsonVar which removes counterparts so it doesn't wind up with an infite amount of counterparts
                    writeText.append(String(data: jsonText, encoding: .utf8)!)
                    //adds the jsonText as .utf8 as a string to the writeText string
                    writeText.append("\n Next Object \n")
                    //marks next object
                }
                do{
                    try writeText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                    // writes the accumlated string of json objects to a single file
                }catch{
                    print("couldn't create json for", block)
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Orders contents of workspace to be more intuitive with Switch Control
        workspaceContainerView.accessibilityElements = [workspaceNameLabel!, blocksProgram!, playTrashToggleButton!, mainMenuButton!, clearAllButton!]

        workspaceContainerView.bringSubviewToFront(workspaceNameLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if currentWorkspace != "Main Workspace" {
            workspaceNameLabel.text = "\(currentWorkspace) Function"
            mainMenuButton.setTitle("Main Workspace", for: .normal)
        }
        self.navigationController?.isNavigationBarHidden = true
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        
        //Makes buttons rounded
        mainMenuButton.layer.cornerRadius = 10
        clearAllButton.layer.cornerRadius = 10
        
        if workspaceNameLabel.text != "Main Workspace" && functionsDict[currentWorkspace]!.isEmpty{
            let startBlock = Block.init(name: "\(currentWorkspace) Function Start", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#FF9300")), double: true, isModifiable: false)
            let endBlock = Block.init(name: "\(currentWorkspace) Function End", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#FF9300")), double: true, isModifiable: false)
            startBlock!.counterpart = [endBlock!]
            endBlock!.counterpart = [startBlock!]
            functionsDict[currentWorkspace]?.append(startBlock!)
            functionsDict[currentWorkspace]?.append(endBlock!)
        }
        // Below causes issues with memory and cause app to die if not used frequently enough leave the app alone for too long and it dies and has to be reinstalled, even if you comment this out the issue still happens
        
        // I think this is used for when you have function that has been renamed and you go back to the main workspace that the rename action is shown up on all of the blocks properly????
        
//        var keyExists = false
//        if workspaceLabel.text == "Main Workspace"{
//            for i in 0..<functionsDict[currentWorkspace]!.count{
//                if functionsDict[currentWorkspace]![i].type == "Function"{
//                    var block = functionsDict[currentWorkspace]![i]
//                    for j in 0..<oldKey.count{
//                        if block.name == oldKey[j]{
//                            keyExists = true
//                            block.name = newKey[j]
//                        }
//                    }
//                }
//            }
//        }
  
        // Rewrote the way block names are changed when a function is renamed, the changes are in functionTableViewController rename function at the very bottom
        

    
    }
    
    @IBAction func goToMainMenuOrWorkspace(_ sender: CustomButton) {
        
        //If user is in the main workspace, main menu button takes them to the main menu
        if currentWorkspace == "Main Workspace" {
            performSegue(withIdentifier: "toMainMenu", sender: self)
        }
        //If user is in a function workspace, main workspace button takes them to the main workspace
        else {
            currentWorkspace = "Main Workspace"
            //Segues from the main workspace to itself to reload the view (switches from functions workspace to main)
            performSegue(withIdentifier: "mainToMain", sender: self)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - - Block Selection Delegate functions
    /// Called when blocks are placed in workspace, so clears blocksBeingMoved
    func finishMovingBlocks() {
        movingBlocks = false
        blocksBeingMoved.removeAll()
        changePlayTrashButton() //Toggling the play/trash button
        save()
    }
    
    /// Called when blocks have been selected to be moved, saves them to blocksBeingMoved
    /// - Parameter blocks: blocks selected to be moved
    func beginMovingBlocks(_ blocks: [Block]) {
        /*Called when moving blocks*/
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
    
    /// Removes blocks from current function and updates the saved data file.
    func clearAllBlocks(){
        if currentWorkspace == "Main Workspace"{
            functionsDict[currentWorkspace] = []
            blocksProgram.reloadData()
            save()
        }
        else{
            functionsDict[currentWorkspace]!.removeSubrange(1..<functionsDict[currentWorkspace]!.count-1)
            blocksProgram.reloadData()
            save()
        }
    }
    
    
    
    /// Alerts the user that all the blocks will be deleted. If user selects yes, blocks in current function are delected
    /// - Parameter sender: Clear All button
    @IBAction func clearAll(_ sender: Any) {
        clearAllButton.accessibilityLabel = "Clear all"
        clearAllButton.accessibilityHint = "Clear all blocks on the screen"
        
        let alert = UIAlertController(title: "Do you want to clear all?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            self.clearAllBlocks()
            let announcement = "All blocks cleared."
            self.makeAnnouncement(announcement)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    /* Changes the play button back and forth from trash to play */
    func changePlayTrashButton(){
        if movingBlocks{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "Trashcan"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Place in Trash"
            if #available(iOS 13.0, *) {
                playTrashToggleButton.accessibilityUserInputLabels = ["Trash"]
            }
            playTrashToggleButton.accessibilityHint = "Delete selected blocks"
        }else if stopIsOption{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "stop"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Stop"
            if #available(iOS 13.0, *) {
                playTrashToggleButton.accessibilityUserInputLabels = ["Stop"]
            }
            playTrashToggleButton.accessibilityHint = "Stop your robot!"
        }else{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Play"
            if #available(iOS 13.0, *) {
                playTrashToggleButton.accessibilityUserInputLabels = ["Play"]
            }
            playTrashToggleButton.accessibilityHint = "Make your robot go!"
        }
    }
    
    var stopIsOption = false
    
    // run the actual program when the play button is clicked
    @IBAction func playButtonClicked(_ sender: Any) {
        //play
        print("in playButtonClicked")
        if(movingBlocks){
            trashClicked()
        }else if stopIsOption{
            stopClicked()
        }else{
            print("in play clicked")
            playClicked()
        }
    }
    
    override func programHasCompleted(){
        movingBlocks = false
        stopIsOption = false
        changePlayTrashButton()
    }

    // run the actual program when the trash button is clicked
    func trashClicked() {
        //trash
        let announcement = blocksBeingMoved[0].name + " placed in trash."
        playTrashToggleButton.accessibilityLabel = announcement
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.containerViewController?.popViewController(animated: false)})
        print("put in trash")
        blocksProgram.reloadData()
        finishMovingBlocks()
    }
    
    func playClicked(){
        if(!connectedRobots()){
            //no robots
            let announcement = "Connect to the dash robot. "
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: announcement)
            print("No robots")
            performSegue(withIdentifier: "AddRobotSegue", sender: nil)
            
        }else if(functionsDict[currentWorkspace]!.isEmpty){
            changePlayTrashButton()
            let announcement = "Your robot has nothing to do! Add some blocks to your workspace."
            playTrashToggleButton.accessibilityLabel = announcement
            
        }else{
            stopIsOption = true
            changePlayTrashButton()
            play(functionsDictToPlay: functionsDict)
            //Calls RobotControllerViewController play function
        }
    }
    
    func stopClicked(){
        print("in stop clicked")
        self.executingProgram = nil
        programHasCompleted()
    }
    
    // MARK: - Blocks Methods
    
    func addBlocks(_ blocks:[Block], at index:Int){
        /*Called after selecting a place to add a block to the workspace, makes accessibility announcements
         and place blocks in the blockProgram stack, etc...*/
        
        //change for beginning
        var announcement = ""
        if(index != 0){
            let myBlock = functionsDict[currentWorkspace]![index-1]
            announcement = blocks[0].name + " placed after " + myBlock.name
        }else{
            announcement = blocks[0].name + " placed at beginning"
        }
        makeAnnouncement(announcement)
//        delay(announcement, 2)
        
        //add a completion block here
        if(blocks[0].double){
            if currentWorkspace != "Main Workspace" && index > endIndex {
                functionsDict[currentWorkspace]!.insert(contentsOf: blocks, at: endIndex)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }else if currentWorkspace != "Main Workspace" && index <= startIndex {
                functionsDict[currentWorkspace]!.insert(contentsOf: blocks, at: startIndex+1)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }
            else{
            functionsDict[currentWorkspace]!.insert(contentsOf: blocks, at: index)
            blocksBeingMoved.removeAll()
            blocksProgram.reloadData()
            }
        }
        else{
            if currentWorkspace != "Main Workspace" && index > endIndex {
                functionsDict[currentWorkspace]!.insert(blocks[0], at: endIndex)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }else if currentWorkspace != "Main Workspace" && index <= startIndex {
                functionsDict[currentWorkspace]!.insert(blocks[0], at: startIndex+1)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }
            else{
                functionsDict[currentWorkspace]!.insert(blocks[0], at: index)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()

            }
            }
    }
    
  
    func makeAnnouncement(_ announcement: String){
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: NSLocalizedString(announcement, comment: ""))
    }
    
//    func delay(_ announcement: String, _ seconds: Int){
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: {
//            self.makeAnnouncement(announcement)
//        })
//    }
    
    func createViewRepresentation(FromBlocks blocksRep: [Block]) -> UIView {
        /*Given a list of blocks, creates the views that will be displayed in the blocksProgram*/
        let myViewWidth = (blockSize + blockSpacing)*blocksRep.count
        let myViewHeight = blockSize
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        var count = 0
        for block in blocksRep{
            let xCoord = count*(blockSize + blockSpacing)
            
            let blockView = BlockView(frame: CGRect(x: xCoord, y: 0, width: blockSize, height: blockSize),  block: [block], myBlockSize: blockSize)
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
        collectionView.remembersLastFocusedIndexPath = true
        return functionsDict[currentWorkspace]!.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: CGFloat(blockSize), height: collectionView.frame.height)
        collectionView.remembersLastFocusedIndexPath = true
        //        print(indexPath)
        if indexPath.row == functionsDict[currentWorkspace]!.count {
            // expands the size of the last cell in the collectionView, so it's easier to add a block at the end
            // with VoiceOver on
            if functionsDict[currentWorkspace]!.count < 8 {
                // TODO: eventually simplify this section without blocksStack.count < 8
                // blocksStack.count < 8 means that the orignal editor only fit up to 8 blocks of a fixed size horizontally, but we may want to change that too
                let myWidth = collectionView.frame.width
                size = CGSize(width: myWidth, height: collectionView.frame.height)
            }else{
                size = CGSize(width: CGFloat(blockSize), height: collectionView.frame.height)
            }
        }
        return size
    }
    
   
    func setUpModifierButton(withStartingHeight startingHeight : Int, withCount count : Int) -> CustomButton {
        /* Use for non-sound modifier buttons. Calculates the width, height, position, and z-index of the modifier button and returns a CustomButton with those values*/
        
        let tempButton = CustomButton(frame: CGRect(x: (blockSize / 7), y:startingHeight-((blockSize / 5) * 4)-count*(blockSize/2+blockSpacing), width: (blockSize / 4) * 3, height: (blockSize / 4) * 3))
        
        tempButton.layer.zPosition = 1
        
        
        return tempButton
    }

    
    private func setUpSoundModifierButton(block : Block, blockName name : String,  defaultValue : String, withStartingHeight startingHeight : Int, withCount count : Int, indexPath : IndexPath) -> CustomButton {
        /* Sets up and returns a modifier button for sound blocks*/
        
        // generate the regular english name for accessibility tool purposes
        let regularEnglishName = name.lowercased()
        let arrayOfNameWords = name.split(separator: " ")
        
        // generate attribute name based on block name
        var attributeName = ""
        
        for index in arrayOfNameWords.indices {
            if index != 0 {
                attributeName.append(arrayOfNameWords[index].capitalized)
            } else {
                attributeName.append(arrayOfNameWords[index].lowercased())
            }
        }
        
        if block.addedBlocks.isEmpty{
            let initialNoise = defaultValue

            let placeholderBlock = Block(name: name, color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)

            block.addedBlocks.append(placeholderBlock!)
            placeholderBlock?.addAttributes(key: attributeName, value: "\(initialNoise)")
        }

        let tempButton = CustomButton(frame: CGRect(x: (blockSize / 7), y:startingHeight-((blockSize / 5) * 4)-count*(blockSize/2+blockSpacing), width: (blockSize / 4) * 3, height: (blockSize / 4) * 3))

        tempButton.layer.zPosition = 1

        let sound = block.addedBlocks[0].attributes[attributeName]
        let imagePath = "\(sound ?? "cat").pdf"

        let image: UIImage?
        image = UIImage(named: imagePath)
        if image != nil {
            tempButton.setBackgroundImage(image, for: .normal)
        } else {
            tempButton.backgroundColor =  UIColor(displayP3Red: 5/255, green: 137/255, blue: 0/255, alpha: 1)
        }
        
        tempButton.tag = indexPath.row
    
        tempButton.accessibilityHint = "Double tap to choose \(regularEnglishName)"
        tempButton.isAccessibilityElement = true
        let modifierInformation: String
        
        // handle speak blocks versus noise blocks
        if regularEnglishName.contains("noise") {
            modifierInformation = ("\(block.addedBlocks[0].attributes[attributeName]!) Noise".titleCased())
        } else {
            // contains say
            modifierInformation = ("Say \(block.addedBlocks[0].attributes["speakWord"]!)".titleCased())
        }
        
        var voiceControlLabel = modifierInformation
        let wordToRemove: String
        
        if regularEnglishName.contains("noise"){
            wordToRemove = " Noise"
        } else {
            // contains say
            wordToRemove = "Say "
        }
        if let range = voiceControlLabel.range(of: wordToRemove){
            voiceControlLabel.removeSubrange(range)
        }
        if #available(iOS 13.0, *) {
            tempButton.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(modifierInformation)"]
        }
        return tempButton
    }
    

    
    /// Adds VoiceOver label to blockView, which changes to placement info if blocks are being moved
    /// - Parameters:
    ///   - blockView: view to be given the label
    ///   - block:  block being displayed
    ///   - blockModifier:  describes the state of the block modifier (e.g. 2 times for repeat 2 times)
    ///   - blockLocation: location of block in workspace (e.g. 2 of 4)
    
    func addAccessibilityLabel(blockView: UIView, block:Block, blockModifier:String, blockLocation: Int, blockIndex: Int){
        
        blockView.isAccessibilityElement = true
        var accessibilityLabel = ""
        let blockPlacementInfo = ". Workspace block " + String(blockLocation) + " of " + String(functionsDict[currentWorkspace]!.count)
        var accessibilityHint = ""
        var movementInfo = ". Double tap to move block."
        
        if(!blocksBeingMoved.isEmpty){
            //Moving blocks, so switch labels to indicated where blocks can be placed
            if (currentWorkspace != "Main Workspace" && blockIndex == 0){
                accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at beginning of " + currentWorkspace + " function."
            } else if (currentWorkspace == "Main Workspace" && blockIndex == 0){
                //in main workspace and setting 1st block accessibility info
                accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at beginning, before "
                accessibilityLabel +=  block.name + " " + blockModifier + " " + blockPlacementInfo
            } else {
                accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " before "
                accessibilityLabel +=  block.name + " " + blockModifier + " " + blockPlacementInfo
            }
            movementInfo = ". Double tap to add " + blocksBeingMoved[0].name + " block here"
        } else {
            accessibilityLabel =  block.name + " " + blockModifier + " " + blockPlacementInfo
        }
        
        accessibilityHint += movementInfo
        
        blockView.accessibilityLabel = accessibilityLabel
        createVoiceControlLabels(for: block, in: blockView)
        blockView.accessibilityHint = accessibilityHint
    }
    
    
    /* CollectionView contains the actual collection of blocks (i.e. the program that is being created with the blocks)
     This method creates and returns the cell at a given index
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.remembersLastFocusedIndexPath = true
        let collectionReuseIdentifier = "BlockCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        cell.isAccessibilityElement = false
        if indexPath.row == functionsDict[currentWorkspace]!.count {
            // The last cell in the collectionView is an empty cell so you can place blocks at the end
            if !blocksBeingMoved.isEmpty{
                cell.isAccessibilityElement = true
                
                if functionsDict[currentWorkspace]!.count == 0 {
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at Beginning"
                    if #available (iOS 13.0, *){
                        cell.accessibilityUserInputLabels = ["Workspace"]
                    }
                }
                else{
                    if currentWorkspace == "Main Workspace" {
                        cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at End"
                        if #available (iOS 13.0, *){
                            cell.accessibilityUserInputLabels = ["End of workspace"]
                        }
                    } else {
                        cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at End of " + currentWorkspace + " function"
                        if #available (iOS 13.0, *){
                            cell.accessibilityUserInputLabels = ["End of function workspace"]
                        }
                    }
                }
            }
        }else{
            
            let startingHeight = Int(cell.frame.height)-blockSize
            
            let block = functionsDict[currentWorkspace]![indexPath.row]
            var blocksToAdd = [Block]()
            
            //check if block is nested (or nested multiple times) and adds in "inside" repeat/if blocks
            for i in 0...indexPath.row {
                if functionsDict[currentWorkspace]![i].double{
                    if(!functionsDict[currentWorkspace]![i].name.contains("End")){
                        if(i != indexPath.row){
                            blocksToAdd.append(functionsDict[currentWorkspace]![i])
                        }
                    }else{
                        if !blocksToAdd.isEmpty{
                            blocksToAdd.removeLast()
                        }
                    }
                }
            }
            
            var count = 0
            for b in blocksToAdd{
                let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockSize/2-count*(blockSize/2+blockSpacing), width: blockSize+2*blockSpacing, height: blockSize/2))
                
                if b.name.contains("Function Start") {
                    myView.accessibilityLabel = "Inside \(currentWorkspace) function"
                    myView.text = "Inside \(currentWorkspace) function"
                }
                else {
                    myView.accessibilityLabel = "Inside " + b.name
                    myView.text = "Inside " + b.name
                }
                
                cell.addSubview(myView)
                count += 1
            }
            
            let name = block.name
            var modifierInformation = ""

            
            switch name{
            case "Animal Noise":
             
                let animalNoiseButton = setUpSoundModifierButton(block: block, blockName : "Animal Noise", defaultValue: "cat", withStartingHeight: startingHeight, withCount: count, indexPath: indexPath)
                
                animalNoiseButton.addTarget(self, action: #selector(animalModifier(sender:)), for: .touchUpInside)
                        
                cell.addSubview(animalNoiseButton)
                save()
                
            case "Vehicle Noise":
                let vehicleNoiseButton = setUpSoundModifierButton(block: block, blockName : "Vehicle Noise", defaultValue: "airplane", withStartingHeight: startingHeight, withCount: count, indexPath: indexPath)
                
                vehicleNoiseButton.addTarget(self, action: #selector(vehicleModifier(sender:)), for: .touchUpInside)
                
                cell.addSubview(vehicleNoiseButton)
                save()
                
            case "Object Noise":
               
                let objectNoiseButton = setUpSoundModifierButton(block: block, blockName : "Object Noise", defaultValue: "laser", withStartingHeight: startingHeight, withCount: count, indexPath: indexPath)
                
                objectNoiseButton.addTarget(self, action: #selector(objectNoiseModifier(sender:)), for: .touchUpInside)
                
                cell.addSubview(objectNoiseButton)
                save()
                
            case "Emotion Noise":
                
                let emotionNoiseButton = setUpSoundModifierButton(block: block, blockName : "Emotion Noise", defaultValue: "bragging", withStartingHeight: startingHeight, withCount: count, indexPath: indexPath)
                
                emotionNoiseButton.addTarget(self, action: #selector(emotionModifier(sender:)), for: .touchUpInside)
                
                cell.addSubview(emotionNoiseButton)
                save()
                
            case "Speak":
                
                let speakButton = setUpSoundModifierButton(block: block, blockName : "Speak Word", defaultValue: "hi", withStartingHeight: startingHeight, withCount: count, indexPath: indexPath)
            
                speakButton.addTarget(self, action: #selector(speakModifier(sender:)), for: .touchUpInside)
                
                cell.addSubview(speakButton)
                save()
            // TODO: if
            case "If":
                if block.addedBlocks.isEmpty{
                    let initialBoolean = "false"
                    
                    let placeholderBlock = Block(name: "If Modifier", color: Color.init(uiColor:UIColor.lightGray), double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "booleanSelected", value: "\(initialBoolean)")
                    modifierInformation = " false"
                    
                }
                let ifButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)

                ifButton.tag = indexPath.row
                switch block.addedBlocks[0].attributes["booleanSelected"]{
                case "hear_voice":
                    let image = UIImage(named: "hear_voice.pdf")
                    ifButton.setBackgroundImage(image, for: .normal)
                    modifierInformation = " robot hears voice"
                case "obstacle_sensed":
                    let image = UIImage(named: "sense_obstacle")
                    ifButton.setBackgroundImage(image, for: .normal)
                    modifierInformation = " robot senses obstacle"
                default:
                    let image = UIImage(named: "false.pdf")
                    ifButton.setBackgroundImage(image, for: .normal)
                    modifierInformation = " false"
                }
                ifButton.backgroundColor = .lightGray
                ifButton.addTarget(self, action: #selector(ifModifier(sender:)), for: .touchUpInside)
                
                ifButton.accessibilityHint = "Double tap to set Boolean Condition for If"
                ifButton.isAccessibilityElement = true
                
                cell.addSubview(ifButton)
                save()
            case "Repeat":
                if block.addedBlocks.isEmpty{
                    // Creates repeat button for modifier.
                    let initialTimesToRepeat = 2
                   
                    let placeholderBlock = Block(name: "Repeat Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "timesToRepeat", value: "\(initialTimesToRepeat)")
                }
                let repeatNumberButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                repeatNumberButton.tag = indexPath.row
                
                let imagePath = "controlModifierBackground.pdf"
                let image: UIImage?
                image = UIImage(named: imagePath)
                if image != nil {
                    repeatNumberButton.setBackgroundImage(image, for: .normal)
                } else {
                    repeatNumberButton.backgroundColor = UIColor(displayP3Red: 49/255, green: 227/255, blue: 132/255, alpha: 1)
                }
                
                // TODO: replace block.addedBlocks[0] with placeholderBlock variable? Same for other modifiers.
                let numberOfTimesToRepeat =  "\(block.addedBlocks[0].attributes["timesToRepeat"] ?? "1")"
                repeatNumberButton.setTitle(numberOfTimesToRepeat, for: .normal)
                repeatNumberButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
                repeatNumberButton.setTitleColor(.black, for: .normal)

                repeatNumberButton.titleLabel?.numberOfLines = 0
                repeatNumberButton.addTarget(self, action: #selector(repeatModifier(sender:)), for: .touchUpInside)
               
                repeatNumberButton.accessibilityHint = "Double tap to Set number of times to repeat"
                repeatNumberButton.isAccessibilityElement = true
                modifierInformation = numberOfTimesToRepeat + " times"
                
                cell.addSubview(repeatNumberButton)
                save()
            // TODO: repeat forever
            case "Repeat Forever":
                if block.addedBlocks.isEmpty{
                    _ = Block(name: "forever", color: Color.init(uiColor:UIColor.red ) , double: false, type: "Boolean", isModifiable: false)
                }
                
            case "Drive Forward", "Drive Backward":
                
                if block.addedBlocks.isEmpty{
                    let initialDistance = 30
                    let initialSpeed = "Normal"
                    // Creates distance button for modifier.
                    // TODO: change the Distance and Speed values in the placeholderBlock name according to Dash API
                    let placeholderBlock = Block(name: "Distance Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "distance", value: "\(initialDistance)")
                    placeholderBlock?.addAttributes(key: "speed", value: initialSpeed)

                }
                let distanceSpeedButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                let distanceSet = "\(block.addedBlocks[0].attributes["distance"]!)"
                let speedSet = "\(block.addedBlocks[0].attributes["speed"]!)"
                
                
                distanceSpeedButton.tag = indexPath.row
                
                if defaults.integer(forKey: "showText") == 0 {
                    let imagePath = "\(speedSet).pdf"
                    let image: UIImage?
                    image = UIImage(named: imagePath)
                    if image != nil {
                        distanceSpeedButton.setBackgroundImage(image, for: .normal)
                    } else {
                        distanceSpeedButton.backgroundColor = UIColor(displayP3Red: 49/255, green: 227/255, blue: 132/255, alpha: 1)
                    }
                    distanceSpeedButton.setTitle("\(block.addedBlocks[0].attributes["distance"]!) cm \n", for: .normal)
                    
                    distanceSpeedButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
                   
                } else {
                    let imagePath = "driveModifierBackground.pdf"
                    let image: UIImage?
                    image = UIImage(named: imagePath)
                    if image != nil {
                        distanceSpeedButton.setBackgroundImage(image, for: .normal)
                    } else {
                        distanceSpeedButton.backgroundColor = UIColor(displayP3Red: 49/255, green: 227/255, blue: 132/255, alpha: 1)
                    }
                    distanceSpeedButton.setTitle("\(block.addedBlocks[0].attributes["distance"]!) cm, \(speedSet)", for: .normal)
                    
                    // smaller font
                    distanceSpeedButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
                }
                
              
                distanceSpeedButton.setTitleColor(.black, for: .normal)

                distanceSpeedButton.titleLabel?.numberOfLines = 0
                distanceSpeedButton.addTarget(self, action: #selector(distanceSpeedModifier(sender:)), for: .touchUpInside)
                distanceSpeedButton.accessibilityHint = "Double tap to Set distance and speed"
                distanceSpeedButton.isAccessibilityElement = true
                modifierInformation = distanceSet + " centimeters at " + speedSet + "Speed"
                
                cell.addSubview(distanceSpeedButton)
                save()
                
            case "Turn Left", "Turn Right":
                if block.addedBlocks.isEmpty{
                    //Creates angle button for modifier
                    let initialAngle = 90
                    
                    let placeholderBlock = Block(name: "Distance Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "angle", value: "\(initialAngle)")
                    
                }
                let angleButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                angleButton.tag = indexPath.row
                
                let imagePath = "driveModifierBackground.pdf"
                let image: UIImage?
                image = UIImage(named: imagePath)
                if image != nil {
                    angleButton.setBackgroundImage(image, for: .normal)
                } else {
                    angleButton.backgroundColor = UIColor(displayP3Red: 49/255, green: 227/255, blue: 132/255, alpha: 1)
                }
                
                //Title: <angle>°
                angleButton.setTitle("\(block.addedBlocks[0].attributes["angle"]!)\u{00B0}", for: .normal)
                
                angleButton.addTarget(self, action: #selector(angleModifier(sender:)), for: .touchUpInside)
                angleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
                angleButton.setTitleColor(.black, for: .normal)

               
                angleButton.titleLabel?.numberOfLines = 0
                angleButton.accessibilityHint = "Double tap to Set turn angle"
                angleButton.isAccessibilityElement = true
                modifierInformation = "\(block.addedBlocks[0].attributes["angle"]!) degrees"
                
                cell.addSubview(angleButton)
                save()
                
            case "Set Left Ear Light", "Set Right Ear Light", "Set Chest Light", "Set All Lights":
                if block.addedBlocks.isEmpty{
                    // Creates button to allow light color change.
                    // MARK: Blockly default color is yellow
                    let initialColor = "yellow"
                    
                    let placeholderBlock = Block(name: "Light Color Modifier", color: Color.init(uiColor:UIColor.yellow) , double: false, type: "Boolean", isModifiable: true)
                    
                    placeholderBlock?.addAttributes(key: "lightColor", value: initialColor)
                    // MARK: modifier block color changes to what was selected
                    placeholderBlock?.addAttributes(key: "modifierBlockColor", value: initialColor)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "lightColor", value: "\(initialColor)")

                }
                let lightColorButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                
                let color = block.addedBlocks[0].attributes["modifierBlockColor"]!
               
                lightColorButton.tag = indexPath.row
                
                let imagePath = "\(color).pdf"
                let image: UIImage?
                image = UIImage(named: imagePath)
                if image != nil {
                    lightColorButton.setBackgroundImage(image, for: .normal)
                } else {
                    lightColorButton.backgroundColor = UIColor(displayP3Red: 49/255, green: 227/255, blue: 132/255, alpha: 1)
                }
                
               
                lightColorButton.addTarget(self, action: #selector(lightColorModifier(sender:)), for: .touchUpInside)
    
                lightColorButton.accessibilityLabel = block.addedBlocks[0].attributes["modifierBlockColor"] ?? ""
                lightColorButton.accessibilityHint = "Double tap to Set light color"
                lightColorButton.isAccessibilityElement = true
                
                modifierInformation = " " + (block.addedBlocks[0].attributes["modifierBlockColor"] ?? "")
                
                cell.addSubview(lightColorButton)
                save()
                
            case "Set Eye Light":
                if block.addedBlocks.isEmpty{
                    let initialEyeLightStatus = "Off"
                    let placeholderBlock = Block(name: "Eye Light Modifier", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "eyeLight", value: "\(initialEyeLightStatus)")
                
                }
                let eyeLightButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                
                modifierBlockIndex = indexPath.row
                
                eyeLightButton.tag = indexPath.row
                
                let imagePath = "eyeLightModifierBackground.pdf"
                let image: UIImage?
                image = UIImage(named: imagePath)
                if image != nil {
                    eyeLightButton.setBackgroundImage(image, for: .normal)
                } else {
                    eyeLightButton.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8509803922, blue: 0.2431372549, alpha: 1)
                }
                
                eyeLightButton.setTitle("\(block.addedBlocks[0].attributes["eyeLight"]!)", for: .normal)
                eyeLightButton.addTarget(self, action: #selector(setEyeLightModifier(sender:)), for: .touchUpInside)
                eyeLightButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
                eyeLightButton.setTitleColor(.black, for: .normal)
                eyeLightButton.titleLabel?.numberOfLines = 0
                eyeLightButton.accessibilityHint = "Double tap to turn eye light on or off"
                eyeLightButton.isAccessibilityElement = true
                modifierInformation = "\(block.addedBlocks[0].attributes["eyeLight"]!)"
                
                cell.addSubview(eyeLightButton)
                save()
            
            case "Wait for Time":
                if block.addedBlocks.isEmpty{
                    let initialWait = 1
                    let placeholderBlock = Block(name: "Wait Time", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    placeholderBlock?.addAttributes(key: "wait", value: "\(initialWait)")

                }
                let waitTimeButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                waitTimeButton.tag = indexPath.row
                
                let imagePath = "controlModifierBackground.pdf"
                let image: UIImage?
                image = UIImage(named: imagePath)
                if image != nil {
                    waitTimeButton.setBackgroundImage(image, for: .normal)
                } else {
                    waitTimeButton.backgroundColor = UIColor(displayP3Red: 49/255, green: 227/255, blue: 132/255, alpha: 1)
                }
                
                if (block.addedBlocks[0].attributes["wait"] == "1"){
                    waitTimeButton.setTitle("\(block.addedBlocks[0].attributes["wait"]!) second", for: .normal)
                } else{
                    waitTimeButton.setTitle("\(block.addedBlocks[0].attributes["wait"]!) seconds", for: .normal)
                }
                waitTimeButton.addTarget(self, action: #selector(waitModifier(sender:)), for: .touchUpInside)
                waitTimeButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
                waitTimeButton.setTitleColor(.black, for: .normal)

                waitTimeButton.titleLabel?.numberOfLines = 0
               
                
                waitTimeButton.accessibilityHint = "Double tap to set wait time"
                waitTimeButton.isAccessibilityElement = true
                modifierInformation = "\(block.addedBlocks[0].attributes["wait"]!) seconds"
                
                cell.addSubview(waitTimeButton)
                save()
            
            case "Set Variable":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    let initialVariableValue = 0

                    let placeholderBlock = Block(name: "Set Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    placeholderBlock?.addAttributes(key: "variableValue", value: "\(initialVariableValue)")

                }
                let setVariableButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                setVariableButton.tag = indexPath.row
                //setVariableButton.backgroundColor = #colorLiteral(red: 0.6745098039, green: 0.5215686275, blue: 0.9568627451, alpha: 1)
                setVariableButton.setTitle(" \(block.addedBlocks[0].attributes["variableSelected"]!) =  \(block.addedBlocks[0].attributes["variableValue"]!)", for: .normal)
                setVariableButton.addTarget(self, action: #selector(variableModifier(sender:)), for: .touchUpInside)
                setVariableButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
                setVariableButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
                setVariableButton.titleLabel?.numberOfLines = 0
//               setVariableButton.titleLabel?.textColor = UIColor.black

//                setVariableButton.layer.borderWidth = 2.0
//                setVariableButton.layer.borderColor = UIColor.black.cgColor
                
                setVariableButton.accessibilityHint = "Double tap to set variable value"
                setVariableButton.isAccessibilityElement = true
                modifierInformation = "\(block.addedBlocks[0].attributes["variableSelected"]!) set to  \(block.addedBlocks[0].attributes["variableValue"]!)"
                cell.addSubview(setVariableButton)
                save()
                
            case "Drive":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Set Drive Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    
                }
                let setDriveVariableButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                
                switch block.addedBlocks[0].attributes["variableSelected"]{
                case "orange":
                    setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                case "cherry":
                    setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                case "banana":
                    setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                case "melon":
                    setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                case "apple":
                    setDriveVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                default:
                      setDriveVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                }
                
                setDriveVariableButton.tag = indexPath.row
                
                setDriveVariableButton.addTarget(self, action: #selector(driveModifier(sender:)), for: .touchUpInside)
                
//                setDriveVariableButton.layer.borderWidth = 2.0
//                setDriveVariableButton.layer.borderColor = UIColor.black.cgColor
                
                setDriveVariableButton.accessibilityHint = "Double tap to set Drive variable"
                setDriveVariableButton.isAccessibilityElement = true
                modifierInformation = (block.addedBlocks[0].attributes["variableSelected"] ?? " blank") + " centimeters"
                cell.addSubview(setDriveVariableButton)
                save()
                
            case "Look Up or Down":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Set Look Left or Right Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                    
                }
                let setLookUpDownVariableButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                 
                 setLookUpDownVariableButton.tag = indexPath.row
                 switch block.addedBlocks[0].attributes["variableSelected"]{
                 case "orange":
                     setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                 case "cherry":
                     setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                 case "banana":
                     setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                 case "melon":
                     setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                 case "apple":
                     setLookUpDownVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                 default:
                     setLookUpDownVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                 }
                
                 setLookUpDownVariableButton.addTarget(self, action: #selector(lookUpDownModifier(sender:)), for: .touchUpInside)
//                 setLookUpDownVariableButton.layer.borderWidth = 2.0
//                 setLookUpDownVariableButton.layer.borderColor = UIColor.black.cgColor
                 
                 setLookUpDownVariableButton.accessibilityHint = "Double tap to set Look Up or Down variable"
                 setLookUpDownVariableButton.isAccessibilityElement = true
                modifierInformation = (block.addedBlocks[0].attributes["variableSelected"] ?? " blank") + " degrees"
                 
                 cell.addSubview(setLookUpDownVariableButton)
                save()
                
            case "Look Left or Right":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Set Look Left or Right Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                    placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")

                }
                let setLookLeftRightVariableButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                setLookLeftRightVariableButton.tag = indexPath.row
                switch block.addedBlocks[0].attributes["variableSelected"]{
                case "orange":
                    setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Orange"), for: .normal)
                case "cherry":
                    setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Cherry"), for: .normal)
                case "banana":
                    setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Banana"), for: .normal)
                case "melon":
                    setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Watermelon"), for: .normal)
                case "apple":
                    setLookLeftRightVariableButton.setBackgroundImage(#imageLiteral(resourceName: "Apple"), for: .normal)
                default:
                    setLookLeftRightVariableButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                }
                
                setLookLeftRightVariableButton.addTarget(self, action: #selector(lookLeftRightModifier(sender:)), for: .touchUpInside)
//                setLookLeftRightVariableButton.layer.borderWidth = 2.0
//                setLookLeftRightVariableButton.layer.borderColor = UIColor.black.cgColor
                
                setLookLeftRightVariableButton.accessibilityHint = "Double tap to set Look Left or Right variable"
                setLookLeftRightVariableButton.isAccessibilityElement = true
                modifierInformation = (block.addedBlocks[0].attributes["variableSelected"] ?? " blank") + " degrees"
                cell.addSubview(setLookLeftRightVariableButton)
                save()
                
            case "Turn":
                if block.addedBlocks.isEmpty{
                    let initialVariable = "orange"
                    
                    let placeholderBlock = Block(name: "Choose Turn Variable", color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)
                    
                    block.addedBlocks.append(placeholderBlock!)
                    
                   placeholderBlock?.addAttributes(key: "variableSelected", value: "\(initialVariable)")
                }
                let setTurnButton = setUpModifierButton(withStartingHeight: startingHeight, withCount: count)
                
                setTurnButton.tag = indexPath.row
                switch block.addedBlocks[0].attributes["variableSelected"]{
                case "orange":
                    let image = UIImage(named: "Orange.pdf")
                    setTurnButton.setBackgroundImage(image, for: .normal)
                case "cherry":
                    let image = UIImage(named: "Cherry.pdf")
                    setTurnButton.setBackgroundImage(image, for: .normal)
                case "banana":
                    let image = UIImage(named: "Banana.pdf")
                    setTurnButton.setBackgroundImage(image, for: .normal)
                case "melon":
                    let image = UIImage(named: "Watermelon.pdf")
                    setTurnButton.setBackgroundImage(image, for: .normal)
                case "apple":
                    let image = UIImage(named: "Apple.pdf")
                    setTurnButton.setBackgroundImage(image, for: .normal)
                default:
                    setTurnButton.backgroundColor =  #colorLiteral(red: 0.4666666667, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
                }
                
                setTurnButton.addTarget(self, action: #selector(turnModifier(sender:)), for: .touchUpInside)
//                setTurnButton.layer.borderWidth = 2.0
//                setTurnButton.layer.borderColor = UIColor.black.cgColor
//                
                setTurnButton.accessibilityHint = "Double tap to set Turn variable"
                setTurnButton.isAccessibilityElement = true
                modifierInformation = (block.addedBlocks[0].attributes["variableSelected"] ?? " blank") + " degrees"
                
                cell.addSubview(setTurnButton)
                save()
                
            default:
                save()
            }
            
            //add main label
            
            let myLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
            addAccessibilityLabel(blockView: myLabel, block: block, blockModifier: modifierInformation, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
            cell.addSubview(myLabel)
        }
        cell.accessibilityElements = cell.accessibilityElements?.reversed()

        return cell
    }
    
    @objc func distanceSpeedModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "DistanceSpeedModifier", sender: nil)
    }
    
    @objc  func waitModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "WaitModifier", sender: nil)
    }
    
    @objc func angleModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "TurnRightModifier", sender: nil)
    }
    
    @objc func lightColorModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "ColorModifier", sender: nil)
    }
    
    @objc func setEyeLightModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "EyeLightModifier", sender: nil)
    }
    
    @objc func repeatModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "RepeatModifier", sender: nil)
    }
    
    @objc func variableModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "VariableModifier", sender: nil)
    }
    
    @objc func ifModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "IfModifier", sender: nil)
    }
    
    @objc func turnModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "turnModifier", sender: nil)
    }
    
    @objc func lookUpDownModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "lookUpDownModifier", sender: nil)
    }
    
    @objc func lookLeftRightModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "lookLeftRightModifier", sender: nil)
    }
    
    @objc func driveModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "driveModifier", sender: nil)
    }
    
    @objc func animalModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "AnimalModifier", sender: nil)
    }
    
    @objc func vehicleModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "VehicleModifier", sender: nil)
    }
    
    @objc func objectNoiseModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "ObjectNoiseModifier", sender: nil)
    }
    
    @objc func emotionModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "EmotionModifier", sender: nil)
    }
    
    @objc func speakModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "SpeakModifier", sender: nil)
    }
    
    @objc func buttonClicked(sender: UIButton!){
        print ("Button clicked")
    }
    
    
    func changeModifierBlockColor(color: String) -> UIColor {
        // test with black
        if color.elementsEqual("black"){
            return UIColor.black
        }
        if color.elementsEqual("red"){
            return UIColor.red
        }
        if color.elementsEqual("orange"){
            return UIColor.orange
        }
        if color.elementsEqual("yellow"){
            return UIColor.yellow
        }
        if color.elementsEqual("green"){
            return UIColor.green
        }
        if color.elementsEqual("blue"){
            // RGB values from Storyboard source code
            return UIColor(displayP3Red: 0, green: 0.5898, blue: 1, alpha: 1)
        }
        if color.elementsEqual("purple"){
            return UIColor(displayP3Red: 0.58188, green: 0.2157, blue: 1, alpha: 1)
        }
        if color.elementsEqual("white"){
            return UIColor.white
        }
        return UIColor.yellow //default color
    }
    
    func createBlock(_ block: Block, withFrame frame:CGRect)->UILabel{
        let myLabel = UILabel.init(frame: frame)
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = block.color.uiColor
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = block.color.uiColor
        return myLabel
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.remembersLastFocusedIndexPath = true
        /*Called when a block is selected in the collectionView, so either selects block to move or places blocks*/
        if(movingBlocks){
                addBlocks(blocksBeingMoved, at: indexPath.row)
                containerViewController?.popViewController(animated: false)
                finishMovingBlocks()
        }else{
            if(indexPath.row < functionsDict[currentWorkspace]!.count){ //otherwise empty block at end
                movingBlocks = true
                let blocksStackIndex = indexPath.row
                let myBlock = functionsDict[currentWorkspace]![blocksStackIndex]
                guard !myBlock.name.contains("Function Start") else{
                    movingBlocks = false
                    return
                }
                guard !myBlock.name.contains("Function End") else{
                    movingBlocks = false
                    return
                }
                
                if myBlock.double == true{
                    var indexOfCounterpart = -1
                    var blockcounterparts = [Block]()
                    for i in 0..<functionsDict[currentWorkspace]!.count {
                        for block in myBlock.counterpart{
                            if block === functionsDict[currentWorkspace]![i]{
                                indexOfCounterpart = i
                                blockcounterparts.append(block)
                            }
                        }
                    }
                    var indexPathArray = [IndexPath]()
                    var tempBlockStack = [Block]()
                    for i in min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex){
                        indexPathArray += [IndexPath.init(row: i, section: 0)]
                        tempBlockStack += [functionsDict[currentWorkspace]![i]]
                    }
                    blocksBeingMoved = tempBlockStack
                    functionsDict[currentWorkspace]!.removeSubrange(min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex))
                }else{ //only a single block to be removed
                    blocksBeingMoved = [functionsDict[currentWorkspace]![blocksStackIndex]]
                    functionsDict[currentWorkspace]!.remove(at: blocksStackIndex)
                }
                blocksProgram.reloadData()
                
                
                let mySelectedBlockVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectedBlockViewController") as! SelectedBlockViewController
                
                containerViewController?.pushViewController(mySelectedBlockVC, animated: false)
                mySelectedBlockVC.blocks = blocksBeingMoved
                changePlayTrashButton()
            }
        }
    }
    
    func createVoiceControlLabels(for block: Block, in blockView: UIView) {
        if #available (iOS 13.0, *) {
            let color = block.color.uiColor
            
            switch color {
            //Control
            case UIColor.colorFrom(hexString: "#B30DCB"):
                if movingBlocks {
                    if block.name == "Wait for Time"{
                        blockView.accessibilityUserInputLabels = ["Before Wait", "Before \(block.name)"]
                    }
                }
                else {
                    blockView.accessibilityUserInputLabels = ["Wait", "\(block.name)"]
                }
                
            //Drive
            case UIColor.colorFrom(hexString: "#B15C13"):
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
                
                if movingBlocks {
                    blockView.accessibilityUserInputLabels = ["Before \(block.name)", "Before \(voiceControlLabel)"]
                }
                else {
                    blockView.accessibilityUserInputLabels = ["\(block.name)", "\(voiceControlLabel)"]
                }
                
            //Lights
            case UIColor.colorFrom(hexString: "#6700C1"):
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
                
                if movingBlocks {
                    blockView.accessibilityUserInputLabels = ["Before \(voiceControlLabel)", "Before \(voiceControlLabel2)", "Before \(block.name)"]
                }
                else {
                    blockView.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(voiceControlLabel2)", "\(block.name)"]
                }
                
            //Look
            case UIColor.colorFrom(hexString: "#836F53"):
                var voiceControlLabel = block.name
                let wordToRemove = "Look "
                if let range = voiceControlLabel.range(of: wordToRemove){
                    voiceControlLabel.removeSubrange(range)
                }
                
                if movingBlocks {
                    blockView.accessibilityUserInputLabels = ["Before \(block.name)", "Before \(voiceControlLabel)"]
                }
                else {
                    blockView.accessibilityUserInputLabels = ["\(block.name)", "\(voiceControlLabel)"]
                }
                
            default:
                blockView.accessibilityUserInputLabels = ["\(block.name)"]
            }
        }
    }
   
    // MARK: - - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segue to Toolbox
        if let destinationViewController = segue.destination as? UINavigationController{
            if let myTopViewController = destinationViewController.topViewController as? BlocksTypeTableViewController{
                myTopViewController.delegate = self
                myTopViewController.blockSize = 150
            }
        }
        
        // Segue to DistanceSpeedModViewController
        if let destinationViewController = segue.destination as? DistanceSpeedModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to AngleModViewController
        if let destinationViewController = segue.destination as? AngleModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to ColorModViewController
        if let destinationViewController = segue.destination as? ColorModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to RepeatModViewController
        if let destinationViewController = segue.destination as? RepeatModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to WaitModViewController
        if let destinationViewController = segue.destination as? WaitModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to SetVariableModViewController
        if let destinationViewController = segue.destination as? SetVariableModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to IfModViewController
        if let destinationViewController = segue.destination as? IfModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to TurnVariable
        if let destinationViewController = segue.destination as? TurnVariable{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to LookLeftRightVariables
        if let destinationViewController = segue.destination as? LookLeftRightVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to LookUpDownVariables
        if let destinationViewController = segue.destination as? LookUpDownVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to DriveVariables
        if let destinationViewController = segue.destination as? DriveVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }

        // Segue to EyeLightModifierViewController
        if let destinationViewController = segue.destination as? EyeLightModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to AnimalModViewController
        if let destinationViewController = segue.destination as? AnimalModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to VehicleModViewController
        if let destinationViewController = segue.destination as? VehicleModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to ObjectNoiseModViewController
        if let destinationViewController = segue.destination as? ObjectNoiseModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to EmotionModViewController
        if let destinationViewController = segue.destination as? EmotionModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to SpeakModViewController
        if let destinationViewController = segue.destination as? SpeakModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
    }
}

