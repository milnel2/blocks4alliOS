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

// Global variables
var functionsDict = [String : [Block]]()  // dictionary containing the different functions (composed as a list of Blocks) in the program
var currentWorkspace = String()  // workspace you are currently editing on screen (i.e. the main workspace or a user-defined function)

//MARK: - Block Selection Delegate Protocol
/* Sends information about which blocks are selected to SelectedBlockViewController when moving blocks in workspace. */
protocol BlockSelectionDelegate{
    func beginMovingBlocks(_ blocks:[Block])
    func finishMovingBlocks()
    func setParentViewController(_ myVC:UIViewController)
}

//MARK: - BlocksViewController
/* Used to display the Main Workspace */
class BlocksViewController:  RobotControlViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BlockSelectionDelegate {
    
    var currentProject: Project? = nil
    
    //MARK: Variables
    // Views
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var workspaceContainerView: UIView!
    @IBOutlet weak var toolboxView: UIView!
    private var allBlockViews = [BlockView]()  // Top-level controller for toolbox view controllers
    private var containerViewController: UINavigationController?
    @IBOutlet weak var blocksProgram: UICollectionView!   // View on bottom of screen that shows blocks in workspace

    // Main workspace  buttons
    @IBOutlet weak var mainMenuButton: UIButton! // Home button. Brings you to main menu.
    //@IBOutlet weak var clearAllButton: CustomButton! // the clear all button has been removed
    @IBOutlet weak var mainWorkspaceButton: UIButton!  // Arrow button that shows when you are working on a function. Brings you back to the main workspace
    @IBOutlet weak var playTrashToggleButton: UIButton! // Play button
        
    // Other View Controller elements
    @IBOutlet weak var workspaceTitle: UILabel!  // Label at top of screen
    
    // Robot variables
    internal var robotRunning = false  // True if the robot is running. Used to disable code editing while robot is active.

    // Variables for display
    internal var stopIsOption = false // True if the stop button can be shown
    private var movingBlocks = false  // True if the user is currently moving a block. Disable modifier blocks if this is true.
    private var arrowToPlaceFirstBlock: UIImageView? = nil // The arrow image that gets shown when the user is about to place the first block in the workspace
    
    // Block variables
    private var blocksBeingMoved = [Block]()  // Blocks currently being moved (includes nested blocks)
    private var indexOfMovingBlock: Int? = nil  // Optional Variable that tracks where block originally was from in the workspace, used to place block back in workspace if move is stopped (navigate to a different screen) set to nil if moving block is from toolbox
    var blockSize = 150
    private let blockSpacing = 1
    private let startIndex = 0
    //private var endIndex: Int { return functionsDict[currentWorkspace]!.count - 1 } //TODO: add back in functions?
    private var endIndex: Int = 0
    
    // Modifier block variables
    private var startingHeight = 0  // A value for calculating the y position of BlockViews
    private var count = 0  // Number of blocks in the workspace
    internal var allModifierBlocks = [UIButton]()  // A list of all the modifier blocks in the workspace
    private var modifierBlockIndex: Int?  // An integer used to identify which modifier block was clicked when going to other screens.
    
    
   
    var galleryType = String()
    
   
  
    //MARK: - View Controller Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Order contents of workspace to be more intuitive with Switch Control and VoiceOver
        mainView.accessibilityElements = [toolboxView!, workspaceContainerView!]
        
        // TODO: allow scrolling in the workspace with Switch Control
            // blocksProgram.isAccessibilityElement = true // allows workspace scrolling with Switch Control, but you can no longer access the blocks inside
       
        workspaceContainerView.accessibilityElements = [blocksProgram!, playTrashToggleButton!, mainMenuButton!, mainWorkspaceButton!]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
       
       
        
        if currentProject?.projectType == ProjectType.Robot {
            currentWorkspace = "Main Workspace"
        }
       
        // TODO: next line fails in physical robot opening a new function
        endIndex = currentProject!.currentActor!.functionDict[currentWorkspace]!.count - 1
        
       
        // Change to custom font
        workspaceTitle.adjustsFontForContentSizeCategory = true
        workspaceTitle.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        
        
        // set block size based on block size from settings or 150 by default
        blockSize = defaults.value(forKey: "blockSize") as? Int ?? 150
       
        // If working on a function
        if isWorkspaceCustomFunction(name: currentWorkspace) {
            mainWorkspaceButton.isHidden = false  // Show Back to Main Workspace arrow button
            if #available(iOS 13.0, *) {
                workspaceTitle.textColor = .label
            } else {
                workspaceTitle.textColor = .black
            }
            workspaceTitle.text = "Return to Main Workspace"
            
            if currentProject!.currentActor!.functionDict[currentWorkspace]!.isEmpty{
                let startBlock = Block.init(
                    name: "\(currentWorkspace) Function Start",
                    colorName: "light_purple_block",
                    double: true,
                    isModifiable: false)
                let endBlock = Block.init(
                    name: "\(currentWorkspace) Function End",
                    colorName: "light_purple_block",
                    double: true,
                    isModifiable: false)
                startBlock!.counterpart = [endBlock!]
                endBlock!.counterpart = [startBlock!]
                currentProject!.currentActor!.functionDict[currentWorkspace]?.append(startBlock!)
                currentProject!.currentActor!.functionDict[currentWorkspace]?.append(endBlock!)
            }
        } else {
            addEventIndicatorBlocks()
            mainWorkspaceButton.isHidden = true // Hide Back to Main Workspace arrow button. Already in Main Workspace.
            workspaceTitle.textColor = UIColor(named: "navy_text")
            workspaceTitle.text = "Main Workspace"
        }
        self.navigationController?.isNavigationBarHidden = true
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        
        allModifierBlocks.removeAll()
    }
    
    func addEventIndicatorBlocks() {
        if currentProject?.projectType == ProjectType.Robot { // Don't add the blocks if currently in a Robot Workspace
            return
        }
        for actor in currentProject!.actors {
            for function in actor.functionDict.keys {
                if function == ON_RUN_STRING || function == ON_BUMP_STRING || function == ON_TAP_STRING {

                    if actor.functionDict[function]!.isEmpty{
                        let startBlock = Block.init(
                            name: "\(function) Start", //TODO: update block name
                            colorName: "light_purple_block",
                            double: false,
                            isModifiable: false)
                        actor.functionDict[function]?.append(startBlock!)
                    }
                }
            }
        }
    }
    
    /// Main Menu Segue
    @IBAction func goToMainMenu(_ sender: UIButton) {
        finishMovingBlocks()
        isInFreeplay = false
        saveProjectSnapshot()
        performSegue(withIdentifier: "toMainMenu", sender: self)
    }
    
    // save snapshot of the blocksProgram
    func saveProjectSnapshot() {
        // scroll to the beginning to take the snapshot
        blocksProgram.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        // rendering view as image is from: https://www.hackingwithswift.com/example-code/media/how-to-render-a-uiview-to-a-uiimage
        let renderer = UIGraphicsImageRenderer(size: blocksProgram.bounds.size)
        let image = renderer.image { ctx in
            blocksProgram.drawHierarchy(in: blocksProgram.bounds, afterScreenUpdates: true)
        }
       
        currentProject!.image = image
        currentProject!.imageName = generateImageName()
    }
    
    //TODO: make sure image names are unique and get deleted when projects are deleted
    func generateImageName() -> String {
        return String(galleryType + currentProject!.name + ".png")
    }
    
    /// Main Workspace Segue
    @IBAction func goToMainWorkspace(_ sender: Any) {
        finishMovingBlocks()
        currentWorkspace = "Main Workspace"
        //Segues from the main workspace to itself to reload the view (switches from functions workspace to main)
        performSegue(withIdentifier: "mainToMain", sender: self)
    }
    
    private func makeAnnouncement(_ announcement: String){
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: NSLocalizedString(announcement, comment: ""))
    }
    
    // MARK: - Memory/Data Methods
    /// Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// This function gets called from the RobotControllerViewController so that the block that is currently running gets highlighted
    override func refreshScreen() {
        blocksProgram.reloadData()
       
    }
    
    //TODO: add to virtual robot
    private func showArrowToPlaceFirstBlock() {
        let img = UIImage(named: "Back")
        let resizedImage = HelperFunctions.resizeImage(image: img!, scaledToSize: CGSize(width: blockSize, height: blockSize))  // resize the image to scale correctly
        let imv = UIImageView(image: resizedImage)
        // Turn arrow to point down
        imv.transform = imv.transform.rotated(by: -(.pi / 2))
       
        // Position arrow vertically on the screen
        imv.transform = imv.transform.translatedBy(x: -blocksProgram.frame.height / 2 , y: 0)
        
        arrowToPlaceFirstBlock = imv
        
        // Accessibility - uncomment to make the arrow an accessibility element
//        arrowToPlaceFirstBlock?.isAccessibilityElement = true
//        arrowToPlaceFirstBlock?.accessibilityLabel = "Image of arrow pointing down to show where the first block will be placed in the workspace."
//        imv.isAccessibilityElement = true
//        blocksProgram.accessibilityElements = [imv]
        
        blocksProgram.addSubview(imv)
      
        // Bounce the arrow up and down
        // got the code to repeat and autoreverse an animation from https://developer.apple.com/forums/thread/666312
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations:  {
            let amountToMove = 70.0
            imv.transform = imv.transform.translatedBy(x: amountToMove, y: 0)
        })
    }
   
    
    //MARK: - Accessibility Methods
    /// Creates the custom rotor action for SwitchControl to delete blocks
    @objc func deleteBlockCustomAction() -> Bool {
        let focusedCell = UIAccessibility.focusedElement(using: UIAccessibility.AssistiveTechnologyIdentifier.notificationVoiceOver) as! UICollectionViewCell
        if let indexPath = blocksProgram?.indexPath(for: focusedCell) {
            // perform the custom action here using the indexPath information
            selectBlock(block: currentProject!.currentActor!.functionDict[currentWorkspace]![indexPath.row], location: indexPath.row)
        }
        return true
    }
    
    /// Adds VoiceOver label to blockView, which changes to placement info if blocks are being moved
    /// - Parameters:
    ///   - blockView: view to be given the label
    ///   - block:  block being displayed
    ///   - blockModifier:  describes the state of the block modifier (e.g. 2 times for repeat 2 times)
    ///   - blockLocation: location of block in workspace (e.g. 2 of 4)
    ///
    func addAccessibilityLabel(blockView: UIView, block:Block, blockModifier:String, blockLocation: Int, blockIndex: Int){
        blockView.isAccessibilityElement = true
        
        // Add Custom Action for deleting block
//        if !block.name.contains("Function Start") && !block.name.contains("Function End") {
//            let deleteBlock = UIAccessibilityCustomAction(
//                name: "Delete Block",
//                target: self,
//                selector: #selector(deleteBlockCustomAction))
//            blockView.accessibilityCustomActions = [deleteBlock]
//        }
        
        
        var accessibilityLabel = ""
        var blockPlacementInfo = ". Workspace block " + String(blockLocation) + " of " + String(currentProject!.currentActor!.functionDict[currentWorkspace]!.count)
        var accessibilityHint = ""
        var movementInfo = ". Double tap to move block."
        if isInFreeplay {
            // slightly change when in freeplay because of event indicator blocks
            
            if !block.name.contains(ON_RUN_STRING) && !block.name.contains(ON_TAP_STRING) { // not the event indicator block
                accessibilityLabel = ""
                blockPlacementInfo = ". Workspace block " + String(blockLocation - 1) + " of " + String(currentProject!.currentActor!.functionDict[currentWorkspace]!.count - 1) // must shift to one less due to event indicator block
                accessibilityHint = ""
                
                movementInfo = ". Double tap to move block."
            } else {
                blockPlacementInfo = ""
                movementInfo = ""
            }
           
        }
        
        if(!blocksBeingMoved.isEmpty){
            // Moving blocks, so switch labels to indicated where blocks can be placed
            if (isWorkspaceCustomFunction(name: currentWorkspace) && blockIndex == 0){
                accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at beginning of " + currentWorkspace + " function."
            } else if (!isWorkspaceCustomFunction(name: currentWorkspace) && blockIndex == 0){
                // in main workspace and setting 1st block accessibility info
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
    // TODO: update for freeplay
    func createVoiceControlLabels(for block: Block, in blockView: UIView) {
        if #available (iOS 13.0, *) {
            let color = block.colorName
            switch color {
            case "orange_block":  // Control
                if movingBlocks {
                    if block.name == "Wait for Time" {
                        blockView.accessibilityUserInputLabels = ["Before Wait", "Before \(block.name)"]
                    }
                } else {
                    blockView.accessibilityUserInputLabels = ["Wait", "\(block.name)"]
                }

            case "green_block":  // Drive
                var voiceControlLabel = block.name
                if block.name.contains("Drive") {
                    let wordToRemove = "Drive "
                    if let range = voiceControlLabel.range(of: wordToRemove){
                        voiceControlLabel.removeSubrange(range)
                    }
                } else if block.name.contains("Turn") {
                    let wordToRemove = "Turn "
                    if let range = voiceControlLabel.range(of: wordToRemove){
                        voiceControlLabel.removeSubrange(range)
                    }
                }

                if movingBlocks {
                    blockView.accessibilityUserInputLabels = ["Before \(block.name)", "Before \(voiceControlLabel)"]
                } else {
                    blockView.accessibilityUserInputLabels = ["\(block.name)", "\(voiceControlLabel)"]
                }

            case "gold_block":  // Lights
                var voiceControlLabel = block.name
                let wordToRemove = "Set "
                if let range = voiceControlLabel.range(of: wordToRemove){
                    voiceControlLabel.removeSubrange(range)
                }

                var voiceControlLabel2 = voiceControlLabel
                if block.name != "Set All Lights" {
                    let wordToRemove2 = " Light"
                    if let range = voiceControlLabel2.range(of: wordToRemove2) {
                        voiceControlLabel2.removeSubrange(range)
                    }
                }

                if movingBlocks {
                    blockView.accessibilityUserInputLabels = ["Before \(voiceControlLabel)", "Before \(voiceControlLabel2)", "Before \(block.name)"]
                } else {
                    blockView.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(voiceControlLabel2)", "\(block.name)"]
                }
            
            case "red_block":  // Look
                var voiceControlLabel = block.name
                let wordToRemove = "Look "
                if let range = voiceControlLabel.range(of: wordToRemove){
                    voiceControlLabel.removeSubrange(range)
                }

                if movingBlocks {
                    blockView.accessibilityUserInputLabels = ["Before \(block.name)", "Before \(voiceControlLabel)"]
                } else {
                    blockView.accessibilityUserInputLabels = ["\(block.name)", "\(voiceControlLabel)"]
                }

            default:
                blockView.accessibilityUserInputLabels = ["\(block.name)"]
            }
        }
    }
    
    // MARK: - Block Selection Delegate functions
    /// Called when blocks are placed in workspace, so clears blocksBeingMoved
    func finishMovingBlocks() {
        if indexOfMovingBlock != nil {  // Replaces the block in the Workspace if it is from the workspace
            addBlocks(blocksBeingMoved, at: indexOfMovingBlock!)
            
        }
        movingBlocks = false
        blocksBeingMoved.removeAll()
        changePlayTrashButton()  // Toggling the play/trash button
        indexOfMovingBlock = nil

        // Remove the arrow in the workspace when blocks are done moving
        if arrowToPlaceFirstBlock != nil {
            arrowToPlaceFirstBlock?.removeFromSuperview()
            blocksProgram.accessibilityElements = []
        }
        
        
    }
    
    /// Called when blocks have been selected to be moved, saves them to blocksBeingMoved
    /// - Parameter blocks: blocks selected to be moved
    func beginMovingBlocks(_ blocks: [Block]) {
        
        movingBlocks = true
        blocksBeingMoved = blocks
        blocksProgram.reloadData()
        changePlayTrashButton()
        // If there are no blocks in the workspace, show the arrow of where the first block will go
        if currentProject!.currentActor!.functionDict[currentWorkspace]!.count == 0 {
            showArrowToPlaceFirstBlock()
        }
    }
    
    //TODO: LAUREN, figure out what this code is for
    func setParentViewController(_ myVC: UIViewController) {
        containerViewController = myVC as? UINavigationController
    }
    
    //MARK: - Play/Stop/Trash Methods
  
    /// Changes the play button back and forth from trash to play
    internal func changePlayTrashButton() {
        if movingBlocks {
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "Trashcan"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Place in Trash"
            if #available(iOS 13.0, *)
                { playTrashToggleButton.accessibilityUserInputLabels = ["Trash"] }
            playTrashToggleButton.accessibilityHint = "Delete selected blocks"
        } else if stopIsOption {
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "stop"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Stop"
            if #available(iOS 13.0, *)
                { playTrashToggleButton.accessibilityUserInputLabels = ["Stop"] }
            playTrashToggleButton.accessibilityHint = "Stop your robot!"
        } else {
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Play"
            if #available(iOS 13.0, *)
                { playTrashToggleButton.accessibilityUserInputLabels = ["Play"] }
            playTrashToggleButton.accessibilityHint = "Make your robot go!"
        }
    }
    
    /// Determine what to do based on the state of the play button when it was clicked. Delete blocks if moving blocks, stop blocks if stopIsOption, or play program.
    @IBAction func playButtonClicked(_ sender: Any) {
        if (movingBlocks)
            { trashClicked() }
        else if stopIsOption
            { stopClicked() }
        else {
            playClicked()
        }
    }

    /// Run the actual program when the trash button is clicked
    private func trashClicked() {
        indexOfMovingBlock = nil
        let announcement = blocksBeingMoved[0].name + " placed in trash."
        playTrashToggleButton.accessibilityLabel = announcement
        self.containerViewController?.popViewController(animated: false)
        blocksProgram.reloadData()
        finishMovingBlocks()
    }
    
    /// Run the actual program when the play button is clicked
    func playClicked() {
        if(!areRobotsConnected()) {
            //no robots
            let announcement = "Connect to the dash robot. "
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: announcement)
            performSegue(withIdentifier: "AddRobotSegue", sender: nil)
            
        } else if(currentProject!.currentActor!.functionDict[currentWorkspace]!.isEmpty) {
            changePlayTrashButton()
            let announcement = "Your robot has nothing to do! Add some blocks to your workspace."
            playTrashToggleButton.accessibilityLabel = announcement
        } else {
            stopIsOption = true
            changePlayTrashButton()
            //Calls RobotControllerViewController play function
            for actor in currentProject!.actors { // reset all actors stopWasPressed value
                actor.executingProgram?.stopWasPressed = false
            }
            play(functionsDictToPlay: currentProject!.currentActor!.functionDict)
            robotRunning = true
            // disable modifier blocks while the robot is running
            for modifierBlock in allModifierBlocks {
                modifierBlock.isEnabled = false
                modifierBlock.isAccessibilityElement = false
            }
        }
        refreshScreen()
    }
    
    /// Stop the program
    private func stopClicked() {
        
        self.executingProgram = nil
        programHasCompleted()
    }
    
    /// Called when the program is either stopped or finishes on its own
    override func programHasCompleted() {
        movingBlocks = false
        stopIsOption = false
        changePlayTrashButton()
        robotRunning = false
        
        // reenable modifier blocks
        for modifierBlock in allModifierBlocks {
            modifierBlock.isEnabled = true
            modifierBlock.isAccessibilityElement = true
        }
        
        for actor in currentProject!.actors {
            actor.executingProgram?.stopWasPressed = true
            actor.isRunning = false
            if actor.functionDict[currentWorkspace] != nil {
                for block in actor.functionDict[currentWorkspace]! {
                    block.isRunning = false
                }
            }
            
            
        }
        refreshScreen()
    }
    
    func updateCurrentWorkspace (name: String) {
        currentWorkspace = name
        refreshScreen()
    }
    
    /// Returns true if the given workspace name is a custom function and false if it is a premade workspace like "Main Workspace" or "On Run"
    func isWorkspaceCustomFunction(name: String) -> Bool {
        if (PREMADE_FUNCTION_NAMES.contains(name)) {
            return false
        }
        return true
    }
    
    // MARK: - Blocks Methods
    
    /// Called after selecting a place to add a block to the workspace, makes accessibility announcements and place blocks in the blockProgram stack, etc...
    private func addBlocks(_ blocks: [Block], at index: Int) {
        //change for beginning
        var announcement = ""
        if (index != 0) {
            let myBlock = currentProject!.currentActor!.functionDict[currentWorkspace]![index-1]
            announcement = blocks[0].name + " placed after " + myBlock.name
        } else {
            announcement = blocks[0].name + " placed at beginning"
        }
        indexOfMovingBlock = nil
        makeAnnouncement(announcement)
        
        //add a completion block here
        if blocks[0].double {
            if isWorkspaceCustomFunction(name: currentWorkspace) && index > endIndex {
                currentProject!.currentActor!.functionDict[currentWorkspace]!.insert(contentsOf: blocks, at: endIndex)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            } else if isWorkspaceCustomFunction(name: currentWorkspace) && index <= startIndex {
                currentProject!.currentActor!.functionDict[currentWorkspace]!.insert(contentsOf: blocks, at: startIndex+1)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            } else {
                currentProject!.currentActor!.functionDict[currentWorkspace]!.insert(contentsOf: blocks, at: index)
            blocksBeingMoved.removeAll()
            blocksProgram.reloadData()
            }
        } else {
            if isWorkspaceCustomFunction(name: currentWorkspace) && index > endIndex {
                currentProject!.currentActor!.functionDict[currentWorkspace]!.insert(blocks[0], at: endIndex)

                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            } else if isWorkspaceCustomFunction(name: currentWorkspace) && index <= startIndex {
                currentProject!.currentActor!.functionDict[currentWorkspace]!.insert(blocks[0], at: startIndex+1)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            } else {
                currentProject!.currentActor!.functionDict[currentWorkspace]!.insert(blocks[0], at: index)
                blocksBeingMoved.removeAll()
                blocksProgram.reloadData()
            }
        }
//        updateAllProjects()
    }
//
//    func updateAllProjects() {
//        for proj in allProjects[galleryType]! {
//            if (proj == currentProject) {
//                let index = allProjects[galleryType]!.firstIndex(of: proj)
//                allProjects[galleryType]![index!] = currentProject!
//            }
//        }
//        
//    }
    private func createBlock(_ block: Block, withFrame frame: CGRect) -> UILabel {
        let myLabel = UILabel.init(frame: frame)
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = UIColor(named: "\(block.colorName)")
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = UIColor(named: "\(block.colorName)")
        return myLabel
    }
    
    // MARK: - Collection View Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.remembersLastFocusedIndexPath = true
        return currentProject!.currentActor!.functionDict[currentWorkspace]!.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: CGFloat(blockSize), height: collectionView.frame.height)
        collectionView.remembersLastFocusedIndexPath = true
        if indexPath.row == currentProject!.currentActor!.functionDict[currentWorkspace]!.count {
            // expands the size of the last cell in the collectionView, so it's easier to add a block at the end
            // with VoiceOver on
            if currentProject!.currentActor!.functionDict[currentWorkspace]!.count < 8 {
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
    
    /// CollectionView contains the actual collection of blocks (i.e. the program that is being created with the blocks) This method creates and returns the cell at a given index
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.remembersLastFocusedIndexPath = true
        let collectionReuseIdentifier = "BlockCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        
        cell.isAccessibilityElement = false
        if indexPath.row == currentProject!.currentActor!.functionDict[currentWorkspace]!.count {  // The last cell in the collectionView is an empty cell so you can place blocks at the end
            if !blocksBeingMoved.isEmpty{
                cell.isAccessibilityElement = true
                if currentProject!.currentActor!.functionDict[currentWorkspace]!.count == 0 {
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at Beginning"
                    if #available (iOS 13.0, *) { cell.accessibilityUserInputLabels = ["Workspace"] }
                } else {
                    if !isWorkspaceCustomFunction(name: currentWorkspace) {
                        cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at End"
                        if #available (iOS 13.0, *) { cell.accessibilityUserInputLabels = ["End of workspace"] }
                    } else {
                        cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at End of " + currentWorkspace + " function"
                        if #available (iOS 13.0, *) { cell.accessibilityUserInputLabels = ["End of function workspace"] }
                    }
                }
            }
        } else {
            startingHeight = Int(cell.frame.height)-blockSize
            let block = currentProject!.currentActor!.functionDict[currentWorkspace]![indexPath.row]
            var blocksToAdd = [Block]()
            
            //check if block is nested (or nested multiple times) and adds in "inside" repeat/if blocks
            for i in 0...indexPath.row {
                if currentProject!.currentActor!.functionDict[currentWorkspace]![i].double {
                    if !currentProject!.currentActor!.functionDict[currentWorkspace]![i].name.contains("End") {
                        if i != indexPath.row {
                            blocksToAdd.append(currentProject!.currentActor!.functionDict[currentWorkspace]![i])
                        }
                    } else {
                        if !blocksToAdd.isEmpty {
                            blocksToAdd.removeLast()
                        }
                    }
                }
            }
            count = 0
            for b in blocksToAdd {
                let myView = createBlock(b, withFrame: CGRect(
                    x: -blockSpacing,
                    y: startingHeight + blockSize / 2 - count * (blockSize / 2 + blockSpacing),
                    width: blockSize + 2 * blockSpacing,
                    height: blockSize / 2))
                if b.name.contains("Function Start") {
                    myView.accessibilityLabel = "Inside \(currentWorkspace) function"
                    myView.text = "Inside \(currentWorkspace) function"
                } else {
                    myView.accessibilityLabel = "Inside " + b.name
                    myView.text = "Inside " + b.name
                    myView.isAccessibilityElement = true
                   
                }
                cell.addSubview(myView)
                cell.accessibilityElements = [myView]
                
                count += 1
            }
            
            let name = block.name
            let modifierInformation = ""
            if isModifierBlock(name: name) {
                setUpModifierButton(block: block, blockName : name, indexPath: indexPath, cell: cell)
            } else {
                switch name {
                    // block exists but is a non-modifier block
                case "End If", "End Repeat", "End Repeat Forever", "Repeat Forever", "Look Forward", "Look Toward Voice", "Look Right", "Look Left", "Look Straight", "Look Down", "Look Up", "Wiggle", "Nod", "Spiral Light", "Move to Center", "\(ON_RUN_STRING) Start", "\(ON_BUMP_STRING) Start", "\(ON_TAP_STRING) Start":
       
                    let blockView = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
                    
                    
                    
                    addAccessibilityLabel(blockView: blockView, block: block, blockModifier: modifierInformation, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
                    cell.addSubview(blockView)
                    
                    // if the block is nested in another block, add that item to accessibility elements
                    let nestedBlock = cell.accessibilityElement(at: 0)
                    if (nestedBlock != nil) {
                        cell.accessibilityElements = [blockView, nestedBlock!]
                    }
                    allBlockViews.append(blockView)

                default:
                    // the block is a custom function
                    let functions: [String] = Array(currentProject!.currentActor!.functionDict.keys) // All the names of the functions a user creates placed in an array
                    if (functions.contains(block.name) || block.name.contains("Function Start") || block.name.contains("Function End")) {
                        let blockView = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
                        addAccessibilityLabel(blockView: blockView, block: block, blockModifier: "function", blockLocation: indexPath.row+1, blockIndex: indexPath.row)
                        cell.addSubview(blockView)
                        allBlockViews.append(blockView)
                    } else {
                        print("Non matching case. \(name) could not be found. Check collectionView() method in BlocksViewController.")
                       
                    }
                    
                    
                    
                }
            }
        }
        
        // Deactivates all modifier blocks in the workspace while a block is being moved.
        // Switch control and VO will also skip over the modifier block.
        if (movingBlocks || robotRunning) {
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
    
    //selects a block to be moved in the workspace
    func selectBlock (block myBlock:Block, location blocksStackIndex:Int ){
        if myBlock.double == true {
            var indexOfCounterpart = -1
            var blockcounterparts = [Block]()

            for i in 0..<currentProject!.currentActor!.functionDict[currentWorkspace]!.count {
              
                for block in myBlock.counterpart{
                    if block === currentProject!.currentActor!.functionDict[currentWorkspace]![i]{
                        indexOfCounterpart = i
                        blockcounterparts.append(block)
                    }
                }
            }
            var indexPathArray = [IndexPath]()
            var tempBlockStack = [Block]()
            for i in min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex){
                indexPathArray += [IndexPath.init(row: i, section: 0)]
                tempBlockStack += [currentProject!.currentActor!.functionDict[currentWorkspace]![i]]
            }
            blocksBeingMoved = tempBlockStack
            currentProject!.currentActor!.functionDict[currentWorkspace]!.removeSubrange(min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex))
        } else { //only a single block to be removed
            blocksBeingMoved = [currentProject!.currentActor!.functionDict[currentWorkspace]![blocksStackIndex]]
            currentProject!.currentActor!.functionDict[currentWorkspace]!.remove(at: blocksStackIndex)
        }
        blocksProgram.reloadData()
    }
    
    
    /// Called when a block is selected in the collectionView, so either selects block to move or places blocks
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.remembersLastFocusedIndexPath = true
        if !robotRunning {  // disable editing while robot is running
            if movingBlocks {
                if indexPath.row < currentProject!.currentActor!.functionDict[currentWorkspace]!.count {  // clicked somewhere before the empty space at the end
                    let blocksStackIndex = indexPath.row
                    let myBlock = currentProject!.currentActor!.functionDict[currentWorkspace]![blocksStackIndex]
                    guard !myBlock.name.contains("\(ON_RUN_STRING) Start")  else { // Don't allow placing blocks before event indicators
                        return
                    }
                    guard !myBlock.name.contains("\(ON_BUMP_STRING) Start")  else { // Don't allow placing blocks before event indicators
                        return
                    }
                    guard !myBlock.name.contains("\(ON_TAP_STRING) Start")  else { // Don't allow placing blocks before event indicators
                        return
                    }
                }
                    
               
                addBlocks(blocksBeingMoved, at: indexPath.row)
                containerViewController?.popViewController(animated: false)
                finishMovingBlocks()
                
                
            } else {
               
                if indexPath.row < currentProject!.currentActor!.functionDict[currentWorkspace]!.count {  // otherwise empty block at end
                    movingBlocks = true
                    let blocksStackIndex = indexPath.row
                    let myBlock = currentProject!.currentActor!.functionDict[currentWorkspace]![blocksStackIndex]
                    guard !myBlock.name.contains("Function Start")  else {
                        movingBlocks = false
                        return
                    }
                    
                    guard !myBlock.name.contains("Function End") else {
                        movingBlocks = false
                        return
                    }
                    guard !myBlock.name.contains("\(ON_RUN_STRING) Start")  else {
                        movingBlocks = false
                        return
                    }
                    guard !myBlock.name.contains("\(ON_BUMP_STRING) Start")  else {
                        movingBlocks = false
                        return
                    }
                    guard !myBlock.name.contains("\(ON_TAP_STRING) Start")  else {
                        movingBlocks = false
                        return
                    }
                    selectBlock(block: myBlock, location: blocksStackIndex)
                    indexOfMovingBlock = blocksStackIndex
                    
                    
                    let mySelectedBlockVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectedBlockViewController") as! SelectedBlockViewController
                    mySelectedBlockVC.currentProject = currentProject
                    mySelectedBlockVC.delegate = self
                    containerViewController?.pushViewController(mySelectedBlockVC, animated: false)
                    mySelectedBlockVC.blocks = blocksBeingMoved
                    changePlayTrashButton()
                } else {
                    // clicked empty block at end
                    movingBlocks = true
                    let blocksStackIndex = indexPath.row
                }
            }
        }
    }
    
    //MARK: - Modifier Button Methods
    /// Use for modifier buttons. Calculates the width, height, position, and z-index of the modifier button and returns a CustomButton with those values
    func createModifierCustomButton() -> ModifierButton {
        let tempButton = ModifierButton(frame: CGRect(
            x: (blockSize / 11),
            y:startingHeight - ((blockSize / 5) * 4) - count * (blockSize  / 2 + blockSpacing),
            width: (blockSize / 7) * 6,
            height: (blockSize / 7) * 6))
        tempButton.layer.zPosition = 1
        
        allModifierBlocks.append(tempButton)
        return tempButton
    }

    /// Sets up a modifier button based on the name inputted
    private func setUpModifierButton(block : Block, blockName name : String, indexPath : IndexPath, cell : UICollectionViewCell) {
        let dict = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties")  // holds properties of all modifier blocks
        
        let (selector, defaultValue, attributeName, accessibilityHint, imagePath, displaysText, secondAttributeName, secondDefault, showTextImage) = getModifierData(name: name, dict: dict!)  // constants taken from dict based on name
        
        
       
        //  Create the block
        if block.addedBlocks.isEmpty{
            let placeholderBlock = Block(name: name, colorName: "gray_color", double: false, type: "Boolean", isModifiable: true)
            block.addedBlocks.append(placeholderBlock!)
            
            placeholderBlock?.addAttributes(key: attributeName, value: "\(defaultValue)")
            if secondAttributeName != nil && secondDefault != nil
                { placeholderBlock?.addAttributes(key: secondAttributeName!, value: "\(secondDefault!)") }
        }
        
        // renamed block.addedBlocks[0] for simplicity
        let placeHolderBlock = block.addedBlocks[0]
        
        
       
        var modifierInformation = placeHolderBlock.attributes[attributeName] ?? ""  // the current state of the block modifier - used for voiceOver
        let button = createModifierCustomButton() // set up button sizing and layering
        button.block = placeHolderBlock
        button.currentProject = currentProject
        
        
        // modifiers for if and repeat blocks are a bit different than other blocks
//        if name == "If" {
//            switch placeHolderBlock.attributes["booleanSelected"] {
//            case "Hear voice":
//                modifierInformation = "robot hears voice"
//            case "Obstacle sensed":
//                modifierInformation = "robot senses obstacle"
//            default:
//                modifierInformation = "false"
//                placeHolderBlock.attributes[attributeName] = "false"
//            }
//        } else
        if name == "Repeat" {
            modifierInformation = "\(placeHolderBlock.attributes[attributeName]!) times"
        }
        
        if defaults.value(forKey: "showText") as! Int == 0 || (displaysText == "true" && defaults.value(forKey: "showText") as! Int == 1) {  // show icon is on
            // choose image path
            var image: UIImage?
            if imagePath != nil && secondAttributeName != "variableValue"{ // blocks have an imagePath in the dictionary if their image is not based on the attribute (ex. controlModifierBackground)
                
                image = UIImage(named: imagePath!)
                if image != nil { // make sure that the image actually exists
                    button.setBackgroundImage(image, for: .normal)
                } else { // print error
                    print("Image file not found: \(imagePath!)")
                    button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                }
            } else {
                // blocks that don't have an imagePath in the dictionary have an image based on their attribute (ex. cat and bragging sounds)
                if secondAttributeName != "variableValue" {
                    if attributeName == "moveToActor" { // images for moveToActor modifier
                        let uuid = placeHolderBlock.attributes[attributeName] ?? ""
                       
                        let actor = VirtualRobot.getActorFromUUIDOrDefault(actorUUID: uuid, inProject: currentProject!)
                        image = UIImage(named: actor!.imagePath)
                        placeHolderBlock.attributes[attributeName] = actor!.UUID
                    } else {
                        image = UIImage(named: "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                    }
                    
                    if secondAttributeName != nil && secondDefault != nil
                    { image = UIImage(named: "\(placeHolderBlock.attributes[secondAttributeName!] ?? secondDefault!)") }
                    // handle show icon or show text for modifiers that change depending on the settings
                    if defaults.integer(forKey: "showText") == 1 && showTextImage != nil {
                        image = UIImage(named: showTextImage!) // show text image
                    }
                    if image != nil {  // make sure that the image actually exists
                        button.setBackgroundImage(image, for: .normal)
                    } else if secondAttributeName != "cellIndex"{
                        print("Image file not found: \(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                        button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                    }
                } else if defaults.value(forKey: "showText") as! Int == 0 {
                    // set variable modifier blocks are a bit different than other modifier blocks
                    image = UIImage(named: "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)Icon") // these special images are called (fruitName)Icon (ex. AppleIcon)
                    if image != nil {  // make sure that the image actually exists
                        button.setBackgroundImage(image, for: .normal)
                    } else if secondAttributeName != "cellIndex"{
                        print("Image file not found: \(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                        button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                    }
                } 
            }
        } else if displaysText != "true" {  // show text is on
            // No image was found and/or Show Text is on
            // set up fonts before setting the text
            button.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }
            
            var colorPath: String = ""
            if name.contains("Light Color") || name.contains("Lights Color") {
                // light modifiers have a different color for each button, so there is a different naming convention
                colorPath = "\(modifierInformation)OpaqueColor"
            } else {
                let backgroundImagePath = "\(attributeName)Background"
                let backgroundImage = UIImage(named: backgroundImagePath)
                if backgroundImage != nil {
                    button.setBackgroundImage(backgroundImage, for: .normal)
                } else {
                    button.backgroundColor =  UIColor(named: "whiteOpaqueColor")
                }
            }
            if colorPath != "" {
                let myUIColor = UIColor(named: colorPath)
                button.backgroundColor = myUIColor ?? UIColor(named: "whiteOpaqueColor")
            }
            
            
            button.layer.cornerRadius = 20 // add button rounded border

            
            button.setTitle(modifierInformation.capitalized, for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.lineBreakMode = .byWordWrapping
        }
        
        // modifier blocks that display text on them (ex. turn left shows the degrees)
        if displaysText == "true" {
            // set up fonts before setting the text
            button.titleLabel?.font = UIFont.accessibleBoldFont(withStyle: .title1, size: 26.0)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            
            var text = "\(placeHolderBlock.attributes[attributeName] ?? "N/A")"
            // handle text formatting based on type of block
            if attributeName == "angle" {
                // <angle>°
                text = "\(text)\u{00B0}"
                modifierInformation = text
                button.titleLabel?.font = UIFont.accessibleBoldFont(withStyle: .title1, size: 28.0)
            } 
            else if attributeName == "timesToRepeat" {
                button.titleLabel?.font = UIFont.accessibleBoldFont(withStyle: .title1, size: 42.0)
            } else if attributeName == "distance" {  // drive forward and backwards blocks
                if defaults.integer(forKey: "showText") == 0 {  // show icon mode
                    
                    if button.titleLabel?.font.pointSize ?? 26 <= 34 {
                        text = "\(placeHolderBlock.attributes["distance"]!) cm \n"
                    } else {
                        text = "\(placeHolderBlock.attributes["distance"]!)\n"
                    }
                    
                    modifierInformation = text + ", at \(placeHolderBlock.attributes["speed"]!) speed"
                } else if defaults.integer(forKey: "showText") == 1 {  // show text mode
                    if button.titleLabel?.font.pointSize ?? 26 <= 34 {
                        text = "\(placeHolderBlock.attributes["distance"]!) cm, \(placeHolderBlock.attributes["speed"]!)"
                    } else {
                        text = "\(placeHolderBlock.attributes["distance"]!) \(placeHolderBlock.attributes["speed"]!)"
                    }
                    
                    modifierInformation = text
                }
            } else if attributeName == "wait" {  // wait blocks
                if placeHolderBlock.attributes["wait"] == "1" {
                    text = "\(text) second"
                } else {
                    text = "\(text) seconds"
                }
                modifierInformation = text
            } else if attributeName == "variableSelected" {  // variable blocks
                if defaults.value(forKey: "showText") as! Int == 0 {
                    text = "\n\n= \(placeHolderBlock.attributes["variableValue"] ?? secondDefault ?? "0.0")"
                } else {
                    text = "\(placeHolderBlock.attributes["variableSelected"] ?? defaultValue ) = \(placeHolderBlock.attributes["variableValue"] ?? secondDefault ?? "0.0")"
                }
                modifierInformation = "\(placeHolderBlock.attributes["variableSelected"] ?? defaultValue ) = \(placeHolderBlock.attributes["variableValue"] ?? secondDefault ?? "0.0")"
            }
            
            button.setTitle(text, for: .normal)
        }
        
        button.tag = indexPath.row
        
        button.addTarget(self, action: selector, for: .touchUpInside)  // connect what happens when the button is pressed
        
        cell.addSubview(button)  // add button to cell
        
        //create blockView for the modifier
        let blockView = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
        
        
        allBlockViews.append(blockView)
        cell.addSubview(blockView)
        
      
        // update addedBlocks
        block.addedBlocks[0] = placeHolderBlock
        
        // Accessibility
        // set voiceOver information
        button.accessibilityHint = accessibilityHint
        button.isAccessibilityElement = true
        
        //TODO: this line doesn't really do anything, it is just the same as modifierInformation
        let voiceControlLabel = modifierInformation
        
        //TODO: test on different operating systems
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(modifierInformation)"]
        }
        
        if block.name == "Move to Location" {
            let row = placeHolderBlock.attributes["row"] ?? "Not available"
            let col = placeHolderBlock.attributes["column"] ?? "Not available"
            modifierInformation = "Row \(row) Column \(col)"
           
        }
        addAccessibilityLabel(blockView: blockView, block: block, blockModifier: modifierInformation, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
        
        // the main part of the block is focused first, then the modifier button
        // if the block is nested in another block, add that item to accessibility elements
        let nestedBlock = cell.accessibilityElement(at: 0)
        if (nestedBlock != nil) {
            cell.accessibilityElements = [blockView, button, nestedBlock!]
        } else {
            cell.accessibilityElements = [blockView, button]
        }
        
        
        
        
        button.accessibilityLabel = modifierInformation
        
    }
    
    /// Gets values for modifier blocks from a dictionary and returns them as a tuple. Prints errors if properties cannot be found
    private func getModifierData (name : String, dict : NSDictionary) -> (Selector, String, String, String, String?, String, String?, String?, String?) {
        
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
    
    /// Given the name for a modifier block, returns a Selector for the button
    private func getModifierSelector(name : String) -> Selector? {
        switch name {
        case "Animal Noise", "Vehicle Noise", "Object Noise", "Emotion Noise", "Speak", "Set Right Ear Light Color", "Set Left Ear Light Color", "Set Front Light Color", "Set All Lights Color", "Look Left or Right", "Look Up or Down", "Turn":
            return #selector(multipleChoiceModifier(sender:))
        case "Wait for Time", "Repeat", "Grow Actor", "Shrink Actor":
            return #selector(stepperModifier(sender:))
        case "If", "Set Eye Light":
            return #selector(twoOptionModifier(sender:))
        case "Turn Left", "Turn Right":
            return #selector(angleModifier(sender:))
        case "Drive":
            return #selector(driveModifier(sender:))
        case "Drive Forward", "Drive Backward": // TODO: update for freeplay
            return #selector(distanceSpeedModifier(sender:))
        case "Set Variable":
            return #selector(variableModifier(sender:))
        case "Move Up":
            return #selector(angleModifier(sender:))
        case "Move Down":
            return #selector(angleModifier(sender:))
        case "Move Left":
            return #selector(angleModifier(sender:))
        case "Move Right":
            return #selector(angleModifier(sender:))
        case "Move to Actor":
            return #selector(multipleChoiceModifier(sender:))
        case "Move to Location":
            return #selector(selectLocationModifier(sender:))
        case "Set Location":
            return #selector(selectLocationModifier(sender:))
        case "Set Speed":
            return #selector(selectSpeedModifier(sender:))
        default:
            print("Modifier Selector for \(name) could not be found. Check switch statement in getModifierSelector() method.")
            return nil
        }
    }
    
    /// Returns true if the given name correlates to a modifiable block
    private func isModifierBlock(name : String) -> Bool {
        let dict = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties")
        return dict?[name] != nil
    }
  
    // MARK: - - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    //TODO: refactor these methods? they are all the same except for the identifier
    @objc  func stepperModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "StepperModifier", sender: nil)
    }
    
    @objc func twoOptionModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "TwoOptionModifier", sender: nil)
    }
    
    @objc func multipleChoiceModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "MultipleChoiceModifier", sender: nil)
    }
    
    @objc func selectLocationModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "SelectLocationModifier", sender: nil)
    }
    
    @objc func selectSpeedModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "SelectSpeedModifier", sender: nil)
    }
    
    @objc func distanceSpeedModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        
        performSegue(withIdentifier: "DistanceSpeedModifier", sender: nil)
    }
    
    @objc func angleModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "SliderModifier", sender: nil)
    }
    
    @objc func variableModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "VariableModifier", sender: nil)
    }
  
    @objc func driveModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "driveModifier", sender: nil)
    }
    
    @objc func buttonClicked(sender: UIButton!) {
        print ("Button clicked")
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Segue to Toolbox
        if let destinationViewController = segue.destination as? UINavigationController{
            if let myTopViewController = destinationViewController.topViewController as? BlocksTypeTableViewController{
                myTopViewController.delegate = self
                myTopViewController.blockSize = 150
                myTopViewController.currentProject = currentProject
            }
        }
        
        // Segue to DistanceSpeedModViewController
        if let destinationViewController = segue.destination as? DistanceSpeedModViewController {
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
            destinationViewController.currentProject = currentProject
        }
        
        // Segue to SliderModifieViewController
        if let destinationViewController = segue.destination as? SliderModifierController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
            destinationViewController.currentProject = currentProject
        }
        
        // Segue to SetVariableModViewController
        if let destinationViewController = segue.destination as? SetVariableModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
            destinationViewController.currentProject = currentProject
        }
        
        // Segue to DriveVariables
        if let destinationViewController = segue.destination as? DriveVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
            destinationViewController.currentProject = currentProject
        }

        // Segue to EyeLightModifierViewController
        if let destinationViewController = segue.destination as? TwoOptionModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
            destinationViewController.currentProject = currentProject
        }
        
        // Segue to MultipleChoiceModifierViewController
        if let destinationViewController = segue.destination as? MultipleChoiceModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
            destinationViewController.currentProject = currentProject
        }
        
        // Segue to StepperModifierViewController
        if let destinationViewController = segue.destination as? StepperModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
            destinationViewController.currentProject = currentProject
        }
        
        // Segue to Add Robot Screen
        if  let destinationViewController = segue.destination as? AddRobotViewController {
            destinationViewController.currentProject = currentProject
        }
        
        // Segue to Location Selection Screen
        if let destinationViewController = segue.destination as? SelectLocationModifierViewController {
            destinationViewController.currentProject = currentProject
            destinationViewController.outputView = currentProject!.currentActor!.freeplayOutputView
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to Speed Modifier Screen
        if let destinationViewController = segue.destination as? SpeedModViewController {
            destinationViewController.currentProject = currentProject
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
    }
}
