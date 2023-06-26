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


// modifier block global variables
// these are global so that the modifier setup methods can access them
var startingHeight = 0
var count = 0

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
    //@IBOutlet weak var clearAllButton: CustomButton!
    
    @IBOutlet weak var mainWorkspaceButton: UIButton!
    
    @IBOutlet weak var playTrashToggleButton: UIButton!
        
    @IBOutlet weak var workspaceTitle: UILabel!
    
    /// view on bottom of screen that shows blocks in workspace
    @IBOutlet weak var blocksProgram: UICollectionView!

    var robotRunning = false

    var movingBlocks = false
    /// blocks currently being moved (includes nested blocks)
    var blocksBeingMoved = [Block]()
    /// Top-level controller for toolbox view controllers
    var allModifierBlocks = [CustomButton]()
    /// A list of all the modifier blocks in the workspace
    var allBlockViews = [BlockView]()
    var containerViewController: UINavigationController?
    
    
    // TODO: the blockWidth and blockHeight are not the same as the variable blockSize (= 100)
    var blockSize = 150
    let blockSpacing = 1
    
    // TODO: what are these variables?
    var modifierBlockIndex: Int?
    var tappedModifierIndex: Int?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Orders contents of workspace to be more intuitive with Switch Control
        mainView.accessibilityElements = [toolboxView!, workspaceContainerView!]
        workspaceContainerView.accessibilityElements = [blocksProgram!, playTrashToggleButton!, mainMenuButton!, mainWorkspaceButton!]
        //workspaceContainerView.bringSubviewToFront(workspaceNameLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change to custom font
        workspaceTitle.adjustsFontForContentSizeCategory = true
        workspaceTitle.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        
        // set block size based on block size from settings
        if defaults.value(forKey: "blockSize") == nil {
            defaults.setValue(150, forKey: "blockSize")
        }
        
        blockSize = defaults.value(forKey: "blockSize") as! Int
        
        if currentWorkspace != "Main Workspace" {
            //workspaceNameLabel.text = "\(currentWorkspace) Function"
            //mainMenuButton.setTitle("Main Workspace", for: .normal)
            mainWorkspaceButton.isHidden = false
            if functionsDict[currentWorkspace]!.isEmpty{
                let startBlock = Block.init(name: "\(currentWorkspace) Function Start", color: Color.init(uiColor: UIColor(named: "light_purple_block")!), double: true, isModifiable: false)
                let endBlock = Block.init(name: "\(currentWorkspace) Function End", color: Color.init(uiColor:UIColor(named: "light_purple_block")!), double: true, isModifiable: false)
                startBlock!.counterpart = [endBlock!]
                endBlock!.counterpart = [startBlock!]
                functionsDict[currentWorkspace]?.append(startBlock!)
                functionsDict[currentWorkspace]?.append(endBlock!)
            }
        } else {
            mainWorkspaceButton.isHidden = true
        }
        self.navigationController?.isNavigationBarHidden = true
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
    }

    @IBAction func goToMainMenu(_ sender: CustomButton) {
            performSegue(withIdentifier: "toMainMenu", sender: self)
    }
    
    @IBAction func goToMainWorkspace(_ sender: Any) {
        currentWorkspace = "Main Workspace"
        //Segues from the main workspace to itself to reload the view (switches from functions workspace to main)
        performSegue(withIdentifier: "mainToMain", sender: self)
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
    }
    
    /// Called when blocks have been selected to be moved, saves them to blocksBeingMoved
    /// - Parameter blocks: blocks selected to be moved
    func beginMovingBlocks(_ blocks: [Block]) {
        /*Called when moving blocks*/
        movingBlocks = true
        blocksBeingMoved = blocks
        blocksProgram.reloadData()
        changePlayTrashButton()
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
        }
        else{
            functionsDict[currentWorkspace]!.removeSubrange(1..<functionsDict[currentWorkspace]!.count-1)
            blocksProgram.reloadData()
        }
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
        robotRunning = false
        
        // reenable modifier blocks
        for modifierBlock in allModifierBlocks {
            modifierBlock.isEnabled = true
            modifierBlock.isAccessibilityElement = true
        }
        
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
            //Calls RobotControllerViewController play function
            play(functionsDictToPlay: functionsDict)
            robotRunning = true

            // disable modifier blocks while the robot is running
            for modifierBlock in allModifierBlocks {
                modifierBlock.isEnabled = false
                modifierBlock.isAccessibilityElement = false
            }
            
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
        //delay(announcement, 2)
        
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
        } else {
            if currentWorkspace != "Main Workspace" && index > endIndex {
                functionsDict[currentWorkspace]!.insert(blocks[0], at: endIndex)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            } else if currentWorkspace != "Main Workspace" && index <= startIndex {
                functionsDict[currentWorkspace]!.insert(blocks[0], at: startIndex+1)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            } else {
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
        for block in blocksRep {
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
        if indexPath.row == functionsDict[currentWorkspace]!.count {
            // expands the size of the last cell in the collectionView, so it's easier to add a block at the end
            // with VoiceOver on
            if functionsDict[currentWorkspace]!.count < 8 {
                // TODO: eventually simplify this section without blocksStack.count < 8
                // blocksStack.count < 8 means that the orignal editor only fit up to 8 blocks of a fixed size horizontally, but we may want to change that too
                let myWidth = collectionView.frame.width
                size = CGSize(width: myWidth, height: collectionView.frame.height)
            } else {
                size = CGSize(width: CGFloat(blockSize), height: collectionView.frame.height)
            }
        }
        return size
    }
    
    func createModifierCustomButton() -> CustomButton {
        /* Use for modifier buttons. Calculates the width, height, position, and z-index of the modifier button and returns a CustomButton with those values*/
        let tempButton = CustomButton(frame: CGRect(x: (blockSize / 7), y:startingHeight-((blockSize / 5) * 4)-count*(blockSize/2+blockSpacing), width: (blockSize / 4) * 3, height: (blockSize / 4) * 3))
        tempButton.layer.zPosition = 1
        allModifierBlocks.append(tempButton)
        return tempButton
    }

    private func setUpModifierButton(block : Block, blockName name : String, indexPath : IndexPath, cell : UICollectionViewCell) {
        /* Sets up a modifier button based on the name inputted*/
        let dict = getModifierDictionary() // holds properties of all modifier blocks
        
        let (selector, defaultValue, attributeName, accessibilityHint, imagePath, displaysText, secondAttributeName, secondDefault, showTextImage) = getModifierData(name: name, dict: dict!) // constants taken from dict based on name
        
        if block.addedBlocks.isEmpty{
            let placeholderBlock = Block(name: name, color: Color.init(uiColor:UIColor.lightGray) , double: false, type: "Boolean", isModifiable: true)

            block.addedBlocks.append(placeholderBlock!)
            placeholderBlock?.addAttributes(key: attributeName, value: "\(defaultValue)")
            if secondAttributeName != nil && secondDefault != nil {
                placeholderBlock?.addAttributes(key: secondAttributeName!, value: "\(secondDefault!)")
            }
        }
        // renamed block.addedBlocks[0] for simplicity
        let placeHolderBlock = block.addedBlocks[0]
        
        // the current state of the block modifier - used for voiceOver
        var modifierInformation = placeHolderBlock.attributes[attributeName] ?? ""
        
        // set up button sizing and layering
        let button = createModifierCustomButton()
        
        // modifiers for if and repeat blocks are a bit different than other blocks
        if name == "If" {
            switch placeHolderBlock.attributes["booleanSelected"]{
            case "hear_voice":
                modifierInformation = "robot hears voice"
            case "obstacle_sensed":
                modifierInformation = "robot senses obstacle"
            default:
                modifierInformation = "false"
                placeHolderBlock.attributes[attributeName] = "false"
            }
        } else if name == "Repeat" {
            modifierInformation = "\(placeHolderBlock.attributes[attributeName]!) times"
        }
        
        // choose image path
        var image: UIImage?
        if imagePath != nil { // blocks have an imagePath in the dictionary if their image is not based on the attribute (ex. controlModifierBackground)
            image = UIImage(named: imagePath!)
            if image != nil { // make sure that the image actually exists
                button.setBackgroundImage(image, for: .normal)
            } else { // print error
                print("Image file not found: \(imagePath!)")
                button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
            
        } else {
            // blocks that don't have an imagePath in the dictionary have an image based on their attribute (ex. cat and bragging sounds)
            image = UIImage(named: "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
            if secondAttributeName != nil && secondDefault != nil{
                image = UIImage(named: "\(placeHolderBlock.attributes[secondAttributeName!] ?? secondDefault!)")
            }
            // handle show icon or show text for modifiers that change depending on the settings
            if defaults.integer(forKey: "showText") == 1 && showTextImage != nil{
                // show text image
                image = UIImage(named: showTextImage!)
            }
            if image != nil { // make sure that the image actually exists
                button.setBackgroundImage(image, for: .normal)
            } else {
                print("Image file not found: \(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        }
        
        if displaysText == "true" { // modifier blocks that display text on them (ex. turn left)
            var text = "\(placeHolderBlock.attributes[attributeName] ?? "N/A")"
            // handle text formatting based on type of block
            if attributeName == "angle" {
                //<angle>°
                text = "\(text)\u{00B0}"
                modifierInformation = text
            } else if attributeName == "distance" {
                //drive forward and backwards blocks
                if defaults.integer(forKey: "showText") == 0 {
                    // show icon mode
                    text = "\(placeHolderBlock.attributes["distance"]!) cm \n"
                    modifierInformation = text + ", \(placeHolderBlock.attributes["speed"]!)"
                } else {
                    // show text mode
                    text = "\(placeHolderBlock.attributes["distance"]!) cm, \(placeHolderBlock.attributes["speed"]!)"
                    modifierInformation = text
                }
            } else if attributeName == "wait" {
                // wait blocks
                if placeHolderBlock.attributes["wait"] == "1" {
                    text = "\(text) second"
                } else {
                    text = "\(text) seconds"
                }
                modifierInformation = text
            } else if attributeName == "variableSelected" {
                // variable blocks
                text = "\(text) = \(placeHolderBlock.attributes["variableValue"]!)"
                modifierInformation = text
            }
            
            button.setTitle(text, for: .normal)
            
            // TODO: allow for font to be either .title1 or .title2 depending on what fits best
            button.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }
            button.titleLabel?.numberOfLines = 0
        }
        
        button.tag = indexPath.row
        
        // set voiceOver information
        button.accessibilityHint = accessibilityHint
        button.isAccessibilityElement = true
        
        //TODO: this line doesn't really do anything, it is just the same as modifierInformation
        let voiceControlLabel = modifierInformation
        
        //TODO: test on different operating systems
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(modifierInformation)"]
        }
        
        // connect what happens when the button is pressed
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        // add button to cell
        cell.addSubview(button)

        //create blockView
        let blockView = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
        addAccessibilityLabel(blockView: blockView, block: block, blockModifier: modifierInformation, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
        
        allBlockViews.append(blockView)
        cell.addSubview(blockView)
        
        // the main part of the block is focused first, then the modifier button
        cell.accessibilityElements = [blockView, button]
        
        // update addedBlocks
        block.addedBlocks[0] = placeHolderBlock
    }
    
    private func getModifierData (name : String, dict : NSDictionary) -> (Selector, String, String, String, String?, String, String?, String?, String?) {
        /* gets values for modifier blocks from a dictionary and returns them as a tuple. Prints errors if properties cannot be found */
        
        if dict[name] == nil {
            print("\(name) could not be found in modifier block dictionary")
        }
    
        let selector = getModifierSelector(name: name) ?? nil // getModifierSelector() has an error statement built in already
        
        let subDictionary = dict.value(forKey: name) as! NSDictionary // renamed for simplicity
        
        let defaultValue = subDictionary.value(forKey: "default")
        if defaultValue == nil {
            print("default value for \(name) could not be found")
        }
        let attributeName = subDictionary.value(forKey: "attributeName")
        if attributeName == nil {
            print("attributeName for \(name) could not be found")
        }
        let accessibilityHint = subDictionary.value(forKey: "accessibilityHint")
        if accessibilityHint == nil {
            print("accessibilityHint for \(name) could not be found")
        }
        // these properties are all optional, so they don't need an error message
        let imagePath = subDictionary.value(forKey: "imagePath") ?? nil
        let displaysText = subDictionary.value(forKey: "displaysText") ?? "false"
        let secondAttributeName = subDictionary.value(forKey: "secondAttributeName") ?? nil
        let secondDefault = subDictionary.value(forKey: "secondDefault") ?? nil
        let showTextImage = subDictionary.value(forKey: "showTextImage") ?? nil
        
        return (selector!, defaultValue! as! String, attributeName! as! String, accessibilityHint! as! String,  imagePath as? String, displaysText as! String, secondAttributeName as? String, secondDefault as? String, showTextImage as? String)
    }
    
    private func getModifierSelector(name : String) -> Selector? {
        /* Given the name for a modifier block, returns a Selector for the button*/
        switch name {
        case "Animal Noise", "Vehicle Noise", "Object Noise", "Emotion Noise", "Speak", "Set Right Ear Light Color", "Set Left Ear Light Color", "Set Chest Light Color", "Set All Lights Color":
            return #selector(soundModifier(sender:))
        case "If":
            return #selector(ifModifier(sender:))
        case "Turn Left", "Turn Right":
            return #selector(angleModifier(sender:))
        case "Set Eye Light":
            return #selector(setEyeLightModifier(sender:))
        case "Drive":
            return #selector(driveModifier(sender:))
        case "Look Up or Down":
            return #selector(lookUpDownModifier(sender:))
        case "Look Left or Right":
            return #selector(lookLeftRightModifier(sender:))
        case "Turn":
            return #selector(turnModifier(sender:))
        case "Drive Forward", "Drive Backward":
            return #selector(distanceSpeedModifier(sender:))
        case "Wait for Time", "Repeat":
            return #selector(waitModifier(sender:))
        case "Set Variable":
            return #selector(variableModifier(sender:))
        default:
            print("Modifier Selector for \(name) could not be found. Check switch statement in getModifierSelector() method.")
            return nil
        }
    }
    
    private func isModifierBlock(name : String) -> Bool {
        /* returns true if the given name correlates to a modifiable block*/
        let dict = getModifierDictionary()
        return dict?[name] != nil
    }
    
    private func getModifierDictionary () -> NSDictionary?{
        /* converts ModifierProperties plost to a NSDictionary*/
        // this code to access a plist as a dictionary is from https://stackoverflow.com/questions/24045570/how-do-i-get-a-plist-as-a-dictionary-in-swift
        let dict: NSDictionary?
         if let path = Bundle.main.path(forResource: "ModifierProperties", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
         } else {
             print("could not access ModifierProperties plist")
             return nil
         }
        return dict!
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
    
    // TODO: rewrite this method
    func createVoiceControlLabels(for block: Block, in blockView: UIView) {
        if #available (iOS 13.0, *) {
            let color = block.color.uiColor
            let name = block.name
            switch color {
            //Control
            case UIColor(named: "orange_block"):
                if movingBlocks {
                    if block.name == "Wait for Time"{
                        blockView.accessibilityUserInputLabels = ["Before Wait", "Before \(block.name)"]
                    }
                } else {
                    blockView.accessibilityUserInputLabels = ["Wait", "\(block.name)"]
                }

            //Drive
            case UIColor(named: "green_block"):
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
            case UIColor(named: "gold_block"):
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
            case UIColor(named: "red_block"):
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
                } else {
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
        } else {
            startingHeight = Int(cell.frame.height)-blockSize
            let block = functionsDict[currentWorkspace]![indexPath.row]
            var blocksToAdd = [Block]()
            
            //check if block is nested (or nested multiple times) and adds in "inside" repeat/if blocks
            for i in 0...indexPath.row {
                if functionsDict[currentWorkspace]![i].double{
                    if(!functionsDict[currentWorkspace]![i].name.contains("End")){
                        if(i != indexPath.row){
                            blocksToAdd.append(functionsDict[currentWorkspace]![i])
                        }
                    } else {
                        if !blocksToAdd.isEmpty{
                            blocksToAdd.removeLast()
                        }
                    }
                }
            }
            count = 0
            for b in blocksToAdd{
                let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockSize/2-count*(blockSize/2+blockSpacing), width: blockSize+2*blockSpacing, height: blockSize/2))
                
                if b.name.contains("Function Start") {
                    myView.accessibilityLabel = "Inside \(currentWorkspace) function"
                    myView.text = "Inside \(currentWorkspace) function"
                } else {
                    myView.accessibilityLabel = "Inside " + b.name
                    myView.text = "Inside " + b.name
                }
                cell.addSubview(myView)
                count += 1
            }
            let name = block.name
            let modifierInformation = ""
            if isModifierBlock(name: name) {
                setUpModifierButton(block: block, blockName : name, indexPath: indexPath, cell: cell)
            } else {
                switch name {
                    // block exists but is a non-modifier block
                case "End If", "End Repeat", "End Repeat Forever", "Repeat Forever", "Look Forward", "Look Toward Voice", "Look Right", "Look Left", "Look Straight", "Look Down", "Look Up", "Wiggle", "Nod":
                    // TODO: unsure if this code needs to be run as well. It was there when I started refactoring but it doesn't seem to be needed
//                    //            case "Repeat Forever":
//                    if block.addedBlocks.isEmpty{
//                        _ = Block(name: "forever", color: Color.init(uiColor:UIColor.red ) , double: false, type: "Boolean", isModifiable: false)
//                    }
                    let blockView = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
                    addAccessibilityLabel(blockView: blockView, block: block, blockModifier: modifierInformation, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
                    cell.addSubview(blockView)
                    allBlockViews.append(blockView)

                default:
                    print("Non matching case. \(name) could not be found. Check collectionView() method in BlocksViewController.")
                   // TODO: handle if the non-matching case is actually a function, then these next lines can be removed after that is fixed
                    let blockView = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
                    addAccessibilityLabel(blockView: blockView, block: block, blockModifier: "function", blockLocation: indexPath.row+1, blockIndex: indexPath.row)
                    cell.addSubview(blockView)
                    allBlockViews.append(blockView)

                }
            }
        }
        
        
        // Deactivates all modifier blocks in the workspace while a block is being moved.
        // Switch control and VO will also skip over the modifier block.
        if (movingBlocks) {
            for modifierBlock in allModifierBlocks {
                modifierBlock.isEnabled = false
                modifierBlock.isAccessibilityElement = false
            }
        } else {
            for modifierBlock in allModifierBlocks {
                modifierBlock.isEnabled = true
                modifierBlock.isAccessibilityElement = true
            }
        }
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
    
    @objc func soundModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "SoundModifier", sender: nil)
    }
    
    @objc func buttonClicked(sender: UIButton!){
        print ("Button clicked")
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
        if (!robotRunning) { // disable editing while robot is running
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
        if let destinationViewController = segue.destination as? DistanceSpeedModViewController {
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to AngleModViewController
        if let destinationViewController = segue.destination as? AngleModViewController{
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
        
        // Segue to MultipleChoiceModifierViewController
        if let destinationViewController = segue.destination as? MultipleChoiceModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to StepperModifierViewController
        if let destinationViewController = segue.destination as? StepperModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
    }
}




/// Alerts the user that all the blocks will be deleted. If user selects yes, blocks in current function are delected
/// - Parameter sender: Clear All button
//    @IBAction func clearAll(_ sender: Any) {
//        clearAllButton.accessibilityLabel = "Clear all"
//        clearAllButton.accessibilityHint = "Clear all blocks on the screen"
//
//        let alert = UIAlertController(title: "Do you want to clear all?", message: "", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
//            self.clearAllBlocks()
//            let announcement = "All blocks cleared."
//            self.makeAnnouncement(announcement)
//        }))
//
//        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//        self.present(alert, animated: true)
//    }
