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
        
    /// view on bottom of screen that shows blocks in workspace
    @IBOutlet weak var blocksProgram: UICollectionView!

    
    var movingBlocks = false
    /// blocks currently being moved (includes nested blocks)
    var blocksBeingMoved = [Block]()
    /// Top-level controller for toolbox view controllers
    var allModifierBlocks = [CustomButton]()
    /// A list of all the modifier blocks in the workspace
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
                let startBlock = Block.init(name: "\(currentWorkspace) Function Start", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#F8E3FF")), double: true, isModifiable: false)
                let endBlock = Block.init(name: "\(currentWorkspace) Function End", color: Color.init(uiColor:UIColor.colorFrom(hexString: "#F8E3FF")), double: true, isModifiable: false)
                startBlock!.counterpart = [endBlock!]
                endBlock!.counterpart = [startBlock!]
                functionsDict[currentWorkspace]?.append(startBlock!)
                functionsDict[currentWorkspace]?.append(endBlock!)
            }
        }else{
            mainWorkspaceButton.isHidden = true
        }
        self.navigationController?.isNavigationBarHidden = true
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
    }
    // TODO: modifify with new buttons
    @IBAction func goToMainMenu(_ sender: CustomButton) {
        
        //If user is in the main workspace, main menu button takes them to the main menu
//        if currentWorkspace == "Main Workspace" {
            performSegue(withIdentifier: "toMainMenu", sender: self)
//        }
        //If user is in a function workspace, main workspace button takes them to the main workspace
//        else {
//            currentWorkspace = "Main Workspace"
//            //Segues from the main workspace to itself to reload the view (switches from functions workspace to main)
//            performSegue(withIdentifier: "mainToMain", sender: self)
//
//        }
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
    
    func setUpModifierButton() -> CustomButton {
        /* Use for non-sound modifier buttons. Calculates the width, height, position, and z-index of the modifier button and returns a CustomButton with those values*/
        
        let tempButton = CustomButton(frame: CGRect(x: (blockSize / 7), y:startingHeight-((blockSize / 5) * 4)-count*(blockSize/2+blockSpacing), width: (blockSize / 4) * 3, height: (blockSize / 4) * 3))
        
        tempButton.layer.zPosition = 1
        
        allModifierBlocks.append(tempButton)
        return tempButton
    }

    private func newSetUpSoundModifierButton(block : Block, blockName name : String, indexPath : IndexPath, cell : UICollectionViewCell) {
        /* Sets up a modifier button for sound blocks and if blocks*/
        //TODO: transfer dict to a plist
        // TODO: fix modifierInformation property
        let dict = getModifierDictionary()
        
        let (selector, defaultValue, attributeName, accessibilityHint, imagePath, displaysText, secondAttributeName, secondDefault, showTextImage) = getModifierData(name: name, dict: dict)
        
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
        var modifierInformation = placeHolderBlock.attributes[attributeName]!
        
        // set up button sizing and layering
        let button = setUpModifierButton()
        
        // modifiers for if blocks are a bit different than other blocks
        // TODO: test accesibility tools
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
        if imagePath != nil { // blocks have an imagePath in the dictionary if their image is not based on the attribute
            image = UIImage(named: imagePath!)!
            
            if image != nil { // make sure that the image actually exists
                button.setBackgroundImage(image, for: .normal)
            } else {
                print("Image file not found: \(imagePath!)")
                button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
            
        } else {
            // blocks that don't have an imagePath in the dictionary have an image based on their attribute
            image = UIImage(named: "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
            
            if secondAttributeName != nil && secondDefault != nil{
                image = UIImage(named: "\(placeHolderBlock.attributes[secondAttributeName!] ?? secondDefault!)")
            }
            
            // handle show icon or show text for modifiers that change depending on the settings
            if defaults.integer(forKey: "showText") == 1 && showTextImage != nil{
                // show text image
                image = UIImage(named: showTextImage!)
            }
            if image != nil { // make suer that the image actually exists
                button.setBackgroundImage(image, for: .normal)
            } else {
                print("Image file not found: \(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        }
        
        if displaysText == "true" {
            var text = "\(placeHolderBlock.attributes[attributeName] ?? "N/A")"
            
            if attributeName == "angle" {
                //Title: <angle>°
                //add degrees sign to end of text
                text = "\(text)\u{00B0}"
                modifierInformation = text
            } else if attributeName == "distance" { //drive forward and backwards blocks
                if defaults.integer(forKey: "showText") == 0 {
                    // show icon
                    text = "\(placeHolderBlock.attributes["distance"]!) cm \n"
                    modifierInformation = text + ", \(placeHolderBlock.attributes["speed"]!)"
                } else {
                    // show text
                    text = "\(placeHolderBlock.attributes["distance"]!) cm, \(placeHolderBlock.attributes["speed"]!)"
                    modifierInformation = text
                    
                }
            } else if attributeName == "wait" { // wait blocks
                if placeHolderBlock.attributes["wait"] == "1" {
                    text = "\(text) second"
                } else {
                    text = "\(text) seconds"
                }
                modifierInformation = text
            } else if attributeName == "variableSelected" { // variable blocks
                text = "\(text) = \(placeHolderBlock.attributes["variableValue"]!)"
                modifierInformation = text
            }
            button.setTitle(text, for: .normal)
            // TODO: allow for font to be either .title1 or .title2 depending on what fits best
            
            button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.numberOfLines = 0
        }
        
        button.tag = indexPath.row
        
        // set voiceOver information
        button.accessibilityHint = accessibilityHint
        button.isAccessibilityElement = true
        
        let voiceControlLabel = modifierInformation
        
        //TODO: test on different operating systems
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(modifierInformation)"]
        }

        button.addTarget(self, action: selector, for: .touchUpInside)

        cell.addSubview(button)

        //add main label
        let myLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
        addAccessibilityLabel(blockView: myLabel, block: block, blockModifier: modifierInformation, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
        
        cell.addSubview(myLabel)
        
        // update addedBlocks
        block.addedBlocks[0] = placeHolderBlock
    }
    
    private func getModifierData (name : String, dict : [String : [String : String]]) -> (Selector, String, String, String, String?, String, String?, String?, String?) {
        
        /* gets values for modifier blocks from a dictionary. Prints errors if properties cannot be found */
        
        if dict[name] == nil {
            print("\(name) could not be found in modifier block dictionary")
        }
        // getModifierSelector() has an error statement built in already
        let selector = getModifierSelector(name: name) ?? nil
        
        let defaultValue = dict[name]?["default"]
        if defaultValue == nil {
            print("default value for \(name) could not be found")
        }
        let attributeName = dict[name]?["attributeName"]
        if attributeName == nil {
            print("attributeName for \(name) could not be found")
        }
        
        let accessibilityHint = dict[name]?["accessibilityHint"]
        if accessibilityHint == nil {
            print("accessibilityHint for \(name) could not be found")
        }
        
        // these properties are all optional
        let imagePath = dict[name]?["imagePath"] ?? nil
        let displaysText = dict[name]?["displaysText"] ?? "false"
        let secondAttributeName = dict[name]?["secondAttributeName"] ?? nil
        let secondDefault = dict[name]?["secondDefault"] ?? nil
        let showTextImage = dict[name]?["showTextImage"] ?? nil
        
        return (selector!, defaultValue!, attributeName!, accessibilityHint!,  imagePath, displaysText, secondAttributeName, secondDefault, showTextImage)
    }
    
    private func getModifierSelector(name : String) -> Selector? {
        /* Given the name for a modifier block, returns a #selector for the button*/
        switch name {
        case "Animal Noise":
            return #selector(animalModifier(sender:))
        case "Vehicle Noise":
            return #selector(vehicleModifier(sender:))
        case "Object Noise":
            return #selector(objectNoiseModifier(sender:))
        case "Emotion Noise":
            return #selector(emotionModifier(sender:))
        case "Speak":
            return #selector(speakModifier(sender:))
        case "If":
            return #selector(ifModifier(sender:))
        case "Repeat":
            return #selector(repeatModifier(sender:))
        case "Turn Left", "Turn Right":
            return #selector(angleModifier(sender:))
        case "Set Eye Light":
            return #selector(setEyeLightModifier(sender:))
        case "Drive":
            return #selector(variableModifier(sender:))
        case "Look Up or Down":
            return #selector(lookUpDownModifier(sender:))
        case "Look Left or Right":
            return #selector(lookLeftRightModifier(sender:))
        case "Turn":
            return #selector(turnModifier(sender:))
        case "Drive Forward", "Drive Backward":
            return #selector(distanceSpeedModifier(sender:))
        case  "Set Left Ear Light", "Set Right Ear Light", "Set Chest Light", "Set All Lights":
            return #selector(lightColorModifier(sender:))
        case "Wait for Time":
            return #selector(waitModifier(sender:))
        case "Set Variable":
            return #selector(variableModifier(sender:))
    
        default:
            print("Modifier Selector for \(name) could not be found. Check switch statement in getModifierSelector() method.")
            return nil
        }
    }
    
    private func isModifierBlock(name : String) -> Bool {
        let dict = getModifierDictionary()
        return dict[name] != nil
    }
    
    private func getModifierDictionary () -> [String : [String : String]]{
        return [
            "Animal Noise" :
                ["attributeName" : "animalNoise",
                 "default" : "cat",
                 "accessibilityHint" : "Double tap to choose animal noise"],
            "Vehicle Noise" :
                ["attributeName" : "vehicleNoise",
                 "default" : "airplane",
                 "accessibilityHint" : "Double tap to choose vehicle noise"],
            "Object Noise" :
                ["attributeName" : "objectNoise",
                 "default" : "laser",
                 "accessibilityHint" : "Double tap to choose object noise"],
            "Emotion Noise" :
                ["attributeName" : "emotionNoise",
                 "default" : "bragging",
                 "accessibilityHint" : "Double tap to choose emotion noise"],
            "Speak Word" :
                ["attributeName" : "speakWord",
                 "default" : "hi",
                 "accessibilityHint" : "Double tap to choose word"],
            "If" :
                ["attributeName" : "booleanSelected",
                 "default" : "false",
                 "accessibilityHint" : "Double tap to set Boolean Condition for If"
                ],
            "Repeat" :
                ["attributeName" : "timesToRepeat",
                 "default" : "2",
                 "accessibilityHint" : "Double tap to set number of times to repeat",
                 "imagePath" : "controlModifierBackground",
                 "displaysText" : "true"
                ],
            "Turn Left" :
                ["attributeName" : "angle",
                 "default" : "90",
                 "accessibilityHint" : "Double tap to set left turn angle",
                 "imagePath" : "driveModifierBackground",
                 "displaysText" : "true"
                ],
            "Turn Right" :
                ["attributeName" : "angle",
                 "default" : "90",
                 "accessibilityHint" : "Double tap to set right turn angle",
                 "imagePath" : "driveModifierBackground",
                 "displaysText" : "true"
                ],
            "Set Eye Light" :
                ["attributeName" : "eyeLight",
                 "default" : "On",
                 "accessibilityHint" : "Double tap to turn eye light on or off",
                 "imagePath" : "eyeLightModifierBackground",
                 "displaysText" : "true"
                ],
            "Drive" :
                ["attributeName" : "variableSelected",
                 "default" : "Orange",
                 "accessibilityHint" : "Double tap to set drive variable",
                ],
            "Look Up or Down" :
                ["attributeName" : "variableSelected",
                 "default" : "Orange",
                 "accessibilityHint" : "Double tap to set Look Up or Down variable",
                ],
            "Look Left or Right" :
                ["attributeName" : "variableSelected",
                 "default" : "Orange",
                 "accessibilityHint" : "Double tap to set Look Left or Right variable",
                ],
            "Turn" :
                ["attributeName" : "variableSelected",
                 "default" : "Orange",
                 "accessibilityHint" : "Double tap to set Turn variable",
                ],
            "Drive Forward" :
                ["attributeName" : "distance",
                 "default" : "30",
                 "secondAttributeName" : "speed",
                 "secondDefault" : "Normal",
                 "accessibilityHint" : "Double tap to set distance and speed ",
                 "displaysText" : "true",
                 "showTextImage" : "driveModifierBackground"
                ],
            "Drive Backward" :
                ["attributeName" : "distance",
                 "default" : "30",
                 "secondAttributeName" : "speed",
                 "secondDefault" : "Normal",
                 "accessibilityHint" : "Double tap to set distance and speed",
                 "displaysText" : "true",
                 "showTextImage" : "driveModifierBackground"
                ],
            "Set Left Ear Light" :
                ["attributeName" : "modifierBlockColor",
                 "default" : "yellow",
                 "secondAttributeName" : "lightColor",
                 "secondDefault" : "yellow",
                 "accessibilityHint" : "Double tap to set light color",
                ],
            "Set Right Ear Light" :
                ["attributeName" : "modifierBlockColor",
                 "default" : "yellow",
                 "secondAttributeName" : "lightColor",
                 "secondDefault" : "yellow",
                 "accessibilityHint" : "Double tap to set light color",
                ],
            "Set Chest Light" :
                ["attributeName" : "modifierBlockColor",
                 "default" : "yellow",
                 "secondAttributeName" : "lightColor",
                 "secondDefault" : "yellow",
                 "accessibilityHint" : "Double tap to set light color",
                ],
            "Set All Lights" :
                ["attributeName" : "modifierBlockColor",
                 "default" : "yellow",
                 "secondAttributeName" : "lightColor",
                 "secondDefault" : "yellow",
                 "accessibilityHint" : "Double tap to set light color",
                ],
            "Wait for Time" :
                ["attributeName" : "wait",
                 "default" : "1",
                 "accessibilityHint" : "Double tap to set wait time",
                 "imagePath" : "controlModifierBackground",
                 "displaysText" : "true",
                ],
            "Set Variable" :
                ["attributeName" : "variableSelected",
                 "default" : "orange",
                 "secondAttributeName" : "variableValue",
                 "secondDefault" : "0",
                 "accessibilityHint" : "Double tap to set variable value",
                 "imagePath" : "variableModifierBackground",
                 "displaysText" : "true"
                ]]
    }
    /// Adds VoiceOver label to blockView, which changes to placement info if blocks are being moved
    /// - Parameters:
    ///   - blockView: view to be given the label
    ///   - block:  block being displayed
    ///   - blockModifier:  describes the state of the block modifier (e.g. 2 times for repeat 2 times)
    ///   - blockLocation: location of block in workspace (e.g. 2 of 4)
    
    // TODO: rewrite this function
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
        //createVoiceControlLabels(for: block, in: blockView)
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
                    }else{
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
            if isModifierBlock(name: name) {
                newSetUpSoundModifierButton(block: block, blockName : name, indexPath: indexPath, cell: cell)
            } else {
                switch name {
                    // block exists but is a non-modifier block
                case "End If", "End Repeat", "End Repeat Forever", "Repeat Forever", "Look Forward", "Look Toward Voice", "Look Right", "Look Left", "Look Straight", "Look Down", "Look Up", "Wiggle", "Nod":
                    //print("adding non-modifier block: \(name)")
                    // TODO: unsure if this code needs to be run as well. It was there when I started refactoring but it doesn't seem to be needed
//                    //            case "Repeat Forever":
//                    if block.addedBlocks.isEmpty{
//                        _ = Block(name: "forever", color: Color.init(uiColor:UIColor.red ) , double: false, type: "Boolean", isModifiable: false)
//                    }
                    //add main label
                    let myLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
                    addAccessibilityLabel(blockView: myLabel, block: block, blockModifier: modifierInformation, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
                    cell.addSubview(myLabel)
                default:
                    print("Non matching case. \(name) could not be found. Check collectionView() method in BlocksViewController.")
                   // TODO: handle if the non-matching case is actually a function, then these next lines can be removed after that is fixed
                    //add main label
                    let myLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
                    addAccessibilityLabel(blockView: myLabel, block: block, blockModifier: "function", blockLocation: indexPath.row+1, blockIndex: indexPath.row)
                    cell.addSubview(myLabel)
                }
            }
        }
        
        cell.accessibilityElements = cell.accessibilityElements?.reversed()
        
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
        
        //TODO: can this be refactored?
        // Segue to DistanceSpeedModViewController
        if let destinationViewController = segue.destination as? DistanceSpeedModViewController {
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


//// TODO: rewrite this method
//// TODO: find out what this method does and if it can be removed
//func createVoiceControlLabels(for block: Block, in blockView: UIView) {
//    if #available (iOS 13.0, *) {
//        let color = block.color.uiColor
//
//        switch color {
//        //Control
//        case UIColor.colorFrom(hexString: "#B30DCB"):
//            if movingBlocks {
//                if block.name == "Wait for Time"{
//                    blockView.accessibilityUserInputLabels = ["Before Wait", "Before \(block.name)"]
//                }
//            }
//            else {
//                blockView.accessibilityUserInputLabels = ["Wait", "\(block.name)"]
//            }
//
//        //Drive
//        case UIColor.colorFrom(hexString: "#B15C13"):
//            var voiceControlLabel = block.name
//            if block.name.contains("Drive") {
//                let wordToRemove = "Drive "
//                if let range = voiceControlLabel.range(of: wordToRemove){
//                    voiceControlLabel.removeSubrange(range)
//                }
//            }
//            else if block.name.contains("Turn") {
//                let wordToRemove = "Turn "
//                if let range = voiceControlLabel.range(of: wordToRemove){
//                    voiceControlLabel.removeSubrange(range)
//                }
//            }
//
//            if movingBlocks {
//                blockView.accessibilityUserInputLabels = ["Before \(block.name)", "Before \(voiceControlLabel)"]
//            }
//            else {
//                blockView.accessibilityUserInputLabels = ["\(block.name)", "\(voiceControlLabel)"]
//            }
//
//        //Lights
//        case UIColor.colorFrom(hexString: "#6700C1"):
//            var voiceControlLabel = block.name
//            let wordToRemove = "Set "
//            if let range = voiceControlLabel.range(of: wordToRemove){
//                voiceControlLabel.removeSubrange(range)
//            }
//
//            var voiceControlLabel2 = voiceControlLabel
//            if block.name != "Set All Lights"{
//                let wordToRemove2 = " Light"
//                if let range = voiceControlLabel2.range(of: wordToRemove2) {
//                    voiceControlLabel2.removeSubrange(range)
//                }
//            }
//
//            if movingBlocks {
//                blockView.accessibilityUserInputLabels = ["Before \(voiceControlLabel)", "Before \(voiceControlLabel2)", "Before \(block.name)"]
//            }
//            else {
//                blockView.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(voiceControlLabel2)", "\(block.name)"]
//            }
//
//        //Look
//        case UIColor.colorFrom(hexString: "#836F53"):
//            var voiceControlLabel = block.name
//            let wordToRemove = "Look "
//            if let range = voiceControlLabel.range(of: wordToRemove){
//                voiceControlLabel.removeSubrange(range)
//            }
//
//            if movingBlocks {
//                blockView.accessibilityUserInputLabels = ["Before \(block.name)", "Before \(voiceControlLabel)"]
//            }
//            else {
//                blockView.accessibilityUserInputLabels = ["\(block.name)", "\(voiceControlLabel)"]
//            }
//
//        default:
//            blockView.accessibilityUserInputLabels = ["\(block.name)"]
//        }
//    }
//}


//    func changeModifierBlockColor(color: String) -> UIColor {
//        // test with black
//        if color.elementsEqual("black"){
//            return UIColor.black
//        }
//        if color.elementsEqual("red"){
//            return UIColor.red
//        }
//        if color.elementsEqual("orange"){
//            return UIColor.orange
//        }
//        if color.elementsEqual("yellow"){
//            return UIColor.yellow
//        }
//        if color.elementsEqual("green"){
//            return UIColor.green
//        }
//        if color.elementsEqual("blue"){
//            // RGB values from Storyboard source code
//            return UIColor(displayP3Red: 0, green: 0.5898, blue: 1, alpha: 1)
//        }
//        if color.elementsEqual("purple"){
//            return UIColor(displayP3Red: 0.58188, green: 0.2157, blue: 1, alpha: 1)
//        }
//        if color.elementsEqual("white"){
//            return UIColor.white
//        }
//        return UIColor.yellow //default color
//    }


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
