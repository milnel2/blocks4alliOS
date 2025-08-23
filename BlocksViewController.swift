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
    
    var currentProject: Project? {
        get {
            return UserData.data.getCurrentProject()
        }
    }
    
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
    internal var movingBlocks = false  // True if the user is currently moving a block. Disable modifier blocks if this is true.
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
               
        endIndex = currentProject!.currentActor!.functionDict[currentWorkspace]!.count - 1
       
        updateStyling()
        
        if isWorkspaceCustomFunction(name: currentWorkspace) {
            setUpForCustomFunction()
        } else {
            setUpForMainWorkspace()
        }
        
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        
        allModifierBlocks.removeAll()
    }
    
    // MARK: Screen Setup
    
    /// Set fonts and other style options
    private func updateStyling() {
        // Fonts
        workspaceTitle.adjustsFontForContentSizeCategory = true
        workspaceTitle.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        
        // Set block size based on block size from settings or 150 by default
        blockSize = defaults.value(forKey: "blockSize") as? Int ?? 150
        
        // Other Visual Elements
        self.navigationController?.isNavigationBarHidden = true
    }
    
    /// Set up workspace to be editing a custom function.
    /// Creates the "start function" and "end function"  blocks and "back to main workspace" button
    private func setUpForCustomFunction() {
        endIndex += 2 // Move end index over two because of the "Start function" and "End function" blocks
        
        mainWorkspaceButton.isHidden = false  // Show Back to Main Workspace arrow button
        if #available(iOS 13.0, *) {
            workspaceTitle.textColor = .label
        } else {
            workspaceTitle.textColor = .black
        }
        
        workspaceTitle.text = NSLocalizedString("Return to Main Workspace", comment: "")
        
        // Add start and end function blocks
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
    }
    
    /// Set up workspace to be editing the main program
    private func setUpForMainWorkspace() {
        addEventIndicatorBlocks()
        mainWorkspaceButton.isHidden = true // Hide Back to Main Workspace arrow button. Already in Main Workspace.
        workspaceTitle.textColor = UIColor(named: "navy_text")
        workspaceTitle.text = NSLocalizedString("Main Workspace", comment: "")
    }
    
    /// Adds "Start" blocks for freeplay mode events like "On Tap"
    /// For freeplay mode only
    func addEventIndicatorBlocks() {
        if currentProject?.projectType == ProjectType.Robot { // Don't add the blocks if currently in a Robot Workspace
            return
        }
        
        for actor in currentProject!.actors {
            for function in actor.functionDict.keys {
                if PREMADE_FUNCTION_NAMES.contains(function) {
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
    
    // MARK: Navigation
    
    /// Main Menu Segue
    @IBAction func goToMainMenu(_ sender: UIButton) {
        finishMovingBlocks()
        isInFreeplay = false
        performSegue(withIdentifier: "toMainMenu", sender: self)
    }
    
    /// Main Workspace Segue
    @IBAction func goToMainWorkspace(_ sender: Any) {
        finishMovingBlocks()
        currentWorkspace = "Main Workspace"
        //Segues from the main workspace to itself to reload the view (switches from functions workspace to main)
        performSegue(withIdentifier: "mainToMain", sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save project snapshot every time the view will disappear saves an image more often than just saving it when the user goes to the main menu, since it doesn't save one when closing the app
        saveProjectSnapshot()
    }
    
    private func makeAnnouncement(_ announcement: String){
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: NSLocalizedString(announcement, comment: ""))
    }
    
    
    // MARK: Saving Data
    /// Save snapshot of the blocksProgram
    func saveProjectSnapshot() {
        // scroll to the beginning to take the snapshot
        blocksProgram.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        // rendering view as image is from: https://www.hackingwithswift.com/example-code/media/how-to-render-a-uiview-to-a-uiimage
        let renderer = UIGraphicsImageRenderer(size: blocksProgram.bounds.size)
        let image = renderer.image { ctx in
            blocksProgram.drawHierarchy(in: blocksProgram.bounds, afterScreenUpdates: true)
        }
       
        currentProject!.imageName = generateImageName()
        // Save image to  directory
        let imageURL = HelperFunctions.getDocumentsDirectory().appendingPathComponent(currentProject!.imageName)
        if let data = image.pngData() {
            do {
                try data.write(to: imageURL)
                } catch {
                    print("Unable to Write Image Data to Disk")
                }
        }
    }
    
    /// Generate a unique image name for the project snapshot
    func generateImageName() -> String {
        //TODO: make sure image names are unique and get deleted when projects are deleted
        return String(galleryType + currentProject!.name + ".png")
    }
    
    
    // MARK: Memory/Data Methods
    /// Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        // TODO: is this code redundant?
        super.didReceiveMemoryWarning()
    }
    
    /// This function gets called from the RobotControllerViewController so that the block that is currently running gets highlighted
    override func refreshScreen() {
        blocksProgram.reloadData()
       
    }
    
    //TODO: add to virtual robot
    /// Draw a bouncing arrow in the blocksProgram to indicate to user where to place the first block
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
        // TODO: currently does not work
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
        var blockPlacementInfo: String
        var modifier = blockModifier
        var movementInfo: String
        
        blockPlacementInfo =
            String.localizedStringWithFormat(
                NSLocalizedString("block_placement_info", comment: "Block placement info"),
                blockLocation,
                currentProject!.currentActor!.functionDict[currentWorkspace]!.count)

        movementInfo = NSLocalizedString(". Double tap to move block.", comment: "Block movement info")
        
        var accessibilityHint = ""
        
        if isInFreeplay {
            // slightly change when in freeplay because of event indicator blocks
            if !block.name.contains(ON_RUN_STRING) && !block.name.contains(ON_TAP_STRING) { // not the event indicator block
                accessibilityLabel = ""
                
                blockPlacementInfo =
                    String.localizedStringWithFormat(
                        NSLocalizedString("block_placement_info", comment: "Block placement info"),
                        blockLocation - 1,
                        currentProject!.currentActor!.functionDict[currentWorkspace]!.count - 1) // must shift to one less due to event indicator block
                movementInfo = NSLocalizedString(". Double tap to move block.", comment: "Block movement info")
                
                accessibilityHint = ""
                if block.name == "Custom Noise" {
                    
                    if !currentProject!.hasNoise(forSlotNumber: Int(modifier)!) {
                       modifier = "\(modifier). Empty Noise."
                    }
                }
            } else {
                blockPlacementInfo = ""
                movementInfo = ""
            }
        }
        
        if(!blocksBeingMoved.isEmpty){
            // Moving blocks, so switch labels to indicated where blocks can be placed
            if ((isWorkspaceCustomFunction(name: currentWorkspace) || isPremadeFunction(name: currentWorkspace)) && blockIndex == 1){
                
                accessibilityLabel = String.localizedStringWithFormat(
                    NSLocalizedString("place_block_at_beginning_of_function", comment: "Accessibility Label. Place (block name) at beginnning of (current workspace name) function"),
                    blocksBeingMoved[0].name.localized,
                    currentWorkspace)
            } else if (!isWorkspaceCustomFunction(name: currentWorkspace) && blockIndex == 0){
                // in main workspace and setting 1st block accessibility info
                
                accessibilityLabel = String.localizedStringWithFormat(
                    NSLocalizedString("place_block_at_beginning_before_other_block", comment: "Accessibility Label. Place (block name at beginning, before (block name) (block modifier) (block placement info)"),
                    blocksBeingMoved[0].name.localized,
                    block.name.localized,
                    modifier,
                    blockPlacementInfo)
               
            } else {
                accessibilityLabel = String.localizedStringWithFormat(
                    NSLocalizedString("place_block_before_other_block", comment: "Accessibility Label. Place (block name) before (another block name) (block modifier) (block placement info)"),
                    blocksBeingMoved[0].name.localized,
                    block.name.localized,
                    modifier,
                    blockPlacementInfo)
            }
            
            if ((isWorkspaceCustomFunction(name: currentWorkspace) || isPremadeFunction(name: currentWorkspace)) && blockIndex == 0){
                if (isPremadeFunction(name: currentWorkspace)) {
                    accessibilityLabel = String.localizedStringWithFormat(
                        NSLocalizedString("start_of_custom_function", comment: "Accessibility label. Start of (workspace name) function"),
                        currentWorkspace.localized)
                
                } else {
                    accessibilityLabel = String.localizedStringWithFormat(
                        NSLocalizedString("start_of_custom_function", comment: "Accessibility label. Start of (workspace name) function"),
                        currentWorkspace)
                }
                movementInfo = ""
            } else {
                movementInfo = String.localizedStringWithFormat(
                    NSLocalizedString("double_tap_add_block", comment: "Accessibility Label. Double tap to add (block name) block here"),
                    blocksBeingMoved[0].name.localized)
            }
           
        } else {
            accessibilityLabel =  "\(block.name.localized) \(modifier) \(blockPlacementInfo)"
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
                        blockView.accessibilityUserInputLabels = [
                            NSLocalizedString("Before Wait", comment: ""), NSLocalizedString("Before \(block.name.localized)", comment: "")] // TODO: check that this is localized
                    }
                } else {
                    blockView.accessibilityUserInputLabels = [NSLocalizedString("Wait", comment: ""), "\(block.name.localized)"]
                }

            case "green_block":  // Drive
                var voiceControlLabel = block.name
                // TODO: VoiceControl for Spanish speakers
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
                    blockView.accessibilityUserInputLabels = [NSLocalizedString("Before \(block.name)", comment: ""), NSLocalizedString("Before \(voiceControlLabel)", comment: "")]
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
                    blockView.accessibilityUserInputLabels = [NSLocalizedString("Before \(voiceControlLabel2)", comment: ""),NSLocalizedString("Before \(block.name)", comment: "")]
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
                    blockView.accessibilityUserInputLabels = [NSLocalizedString("Before \(block.name)", comment: ""), NSLocalizedString("Before \(voiceControlLabel)", comment: "")]
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
            playTrashToggleButton.accessibilityLabel = NSLocalizedString("Place in Trash", comment: "Accessibility label for trash button")
            if #available(iOS 13.0, *)
                { playTrashToggleButton.accessibilityUserInputLabels = ["Trash"] }
            playTrashToggleButton.accessibilityHint = NSLocalizedString("Delete selected blocks", comment: "Accessibility hint for trash button")
        } else if stopIsOption {
            playTrashToggleButton.setBackgroundImage(HelperFunctions.getUIImage(named: "stopSign"), for: .normal)
            playTrashToggleButton.accessibilityLabel = NSLocalizedString("Stop", comment: "Accessibility Label for stop button")
            if #available(iOS 13.0, *)
                { playTrashToggleButton.accessibilityUserInputLabels = ["Stop"] }
            playTrashToggleButton.accessibilityHint = NSLocalizedString("Stop your robot!", comment: "Accessibility hint for stop button")
        } else {
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
            playTrashToggleButton.accessibilityLabel = NSLocalizedString("Play", comment: "Accessibility Label for play (run code) button")
            if #available(iOS 13.0, *)
                { playTrashToggleButton.accessibilityUserInputLabels = [NSLocalizedString("Play", comment: "Accessibility User Input Label for play (run code) button")] }
            playTrashToggleButton.accessibilityHint = NSLocalizedString("Make your robot go!", comment: "Accessibility hint for play (run code) button")
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
        let formattedString = NSLocalizedString("block_placed_in_trash", comment: "Announcement for a block placed in trash")
        let announcement = String.localizedStringWithFormat(formattedString, blocksBeingMoved[0].name.localized)
        playTrashToggleButton.accessibilityLabel = announcement
        self.containerViewController?.popViewController(animated: false)
        blocksProgram.reloadData()
        finishMovingBlocks()
    }
    
    /// Run the actual program when the play button is clicked
    func playClicked() {
        if(!areRobotsConnected()) {
            //no robots
            let announcement = NSLocalizedString("Connect to the dash robot.", comment: "Announcement when no robots are connected")
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: announcement)
            performSegue(withIdentifier: "AddRobotSegue", sender: nil)
            
        } else if(currentProject!.currentActor!.functionDict[currentWorkspace]!.isEmpty) {
            changePlayTrashButton()
            
            playTrashToggleButton.accessibilityLabel =  NSLocalizedString("Your robot has nothing to do! Add some blocks to your workspace.", comment: "Accessibility Label for play (run code) button when there are no blocks in the workspace")
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
    
    func isPremadeFunction(name: String) -> Bool {
        return PREMADE_FUNCTION_NAMES.contains(name)
    }
    // MARK: - Blocks Methods
    
    /// Called after selecting a place to add a block to the workspace, makes accessibility announcements and place blocks in the blockProgram stack, etc...
    private func addBlocks(_ blocks: [Block], at index: Int) {
        //change for beginning
        var announcement = ""
        if blocks.count == 0 { // for some reason the app is crashing from this method with an index out of range error when accessing blocks[0]. Not sure why but this should fix it for now
            return
        }
        if (index != 0) {
            let myBlock = currentProject!.currentActor!.functionDict[currentWorkspace]![index-1]
            let formattedString = NSLocalizedString("block1_placed_after_block2", comment: "Announcement for when a block is placed after another block")
            announcement = String.localizedStringWithFormat(formattedString, blocks[0].name.localized, myBlock.name.localized)
            
        } else {
            let formattedString = NSLocalizedString("block_placed_at_beginning", comment: "Announcement for when a block is placed at the beginning of the workspace")
            announcement = String.localizedStringWithFormat(formattedString, blocks[0].name.localized)

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
    }

    private func createBlock(_ block: Block, withFrame frame: CGRect) -> UILabel {
        let myLabel = UILabel.init(frame: frame)
        myLabel.text = block.name.localized
        myLabel.textAlignment = .center
        myLabel.textColor = UIColor(named: "\(block.colorName)")
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = UIColor(named: "\(block.colorName)")
        return myLabel
    }
    
    // MARK: - Collection View Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.remembersLastFocusedIndexPath = false
        return currentProject!.currentActor!.functionDict[currentWorkspace]!.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: CGFloat(blockSize), height: collectionView.frame.height)
        collectionView.remembersLastFocusedIndexPath = false
        if indexPath.row == currentProject!.currentActor!.functionDict[currentWorkspace]!.count {
            // expands the size of the last cell in the collectionView, so it's easier to add a block at the end with VoiceOver on
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
        collectionView.remembersLastFocusedIndexPath = false
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
                    let formattedString = NSLocalizedString("place_block_at_beginning", comment: "Accessibility Label to place a block at the beginning of the workspace")
                    cell.accessibilityLabel = String.localizedStringWithFormat(formattedString, blocksBeingMoved[0].name.localized)

                    if #available (iOS 13.0, *) { cell.accessibilityUserInputLabels = [NSLocalizedString("Workspace", comment: "Accessibility User Input Label to place a block at the beginning of the workspace")] } // TODO: this label seems incorrect
                } else {
                    if !isWorkspaceCustomFunction(name: currentWorkspace) {
                        let formattedString = NSLocalizedString("place_block_at_end", comment: "Accessibility Label to place a block at the end of the workspace")
                        cell.accessibilityLabel = String.localizedStringWithFormat(formattedString, blocksBeingMoved[0].name.localized)
                        if #available (iOS 13.0, *) { cell.accessibilityUserInputLabels = [NSLocalizedString("End of workspace", comment: "Accessibility User Input Label to place a block at the end of the workspace")] }
                    } else {
                        let formattedString = NSLocalizedString("place_block_at_end_of_function", comment: "Accessibility Label to place a block at the end of the current function")
                        cell.accessibilityLabel = String.localizedStringWithFormat(formattedString, blocksBeingMoved[0].name.localized, currentWorkspace)
                       
                        if #available (iOS 13.0, *) { cell.accessibilityUserInputLabels = [NSLocalizedString("End of function workspace", comment: "Accessibility User Input Label to place a block at the end of a function")] }
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
                    let formattedString = NSLocalizedString("inside_function", comment: "Text for when within a function: 'Inside <function_name> function'")
                    let resultString = String.localizedStringWithFormat(formattedString, currentWorkspace)
                    myView.accessibilityLabel = resultString
                    myView.text = resultString
                } else {
                    let formattedString = NSLocalizedString("inside_block", comment: "Text for when within a nested block (like repeat or if blocks): 'Inside <block_name>'")
                    let resultString = String.localizedStringWithFormat(formattedString, b.name.localized)
                    myView.accessibilityLabel = resultString
                    myView.text = resultString
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
        collectionView.remembersLastFocusedIndexPath = false
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
                    guard !myBlock.name.contains("Function Start")  else { // Don't allow placing block before the start of a function
                        return
                    }
                }
                    
                if isWorkspaceCustomFunction(name: currentWorkspace) && indexPath.row >= currentProject!.currentActor!.functionDict[currentWorkspace]!.count { // Don't place blocks in the empty white space when editing custom functions. Blocks can only be placed within "Function Start" and "Function End"
                    return
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
                        playButtonClicked(self)
                        return
                    }
                    guard !myBlock.name.contains("\(ON_BUMP_STRING) Start")  else {
                        movingBlocks = false
                        return
                    }
                    guard !myBlock.name.contains("\(ON_TAP_STRING) Start")  else {
                        movingBlocks = false
                        currentProject?.currentActor?.freeplayOutputView?.runOnTapCode(forActor: (currentProject?.currentActor)!)
                        
                        return
                    }
                    selectBlock(block: myBlock, location: blocksStackIndex)
                    indexOfMovingBlock = blocksStackIndex
                    
                    let mySelectedBlockVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectedBlockViewController") as! SelectedBlockViewController
                    mySelectedBlockVC.delegate = self
                    containerViewController?.pushViewController(mySelectedBlockVC, animated: false)
                    mySelectedBlockVC.blocks = blocksBeingMoved
                    changePlayTrashButton()
                } else {
                    // clicked empty block at end
                    movingBlocks = true
                }
            }
        } else { // On tap code can run even if the robot is already running
            let blocksStackIndex = indexPath.row
            let myBlock = currentProject!.currentActor!.functionDict[currentWorkspace]![blocksStackIndex]
            if myBlock.name.contains("\(ON_TAP_STRING) Start") {
                movingBlocks = false
                currentProject?.currentActor?.freeplayOutputView?.runOnTapCode(forActor: (currentProject?.currentActor)!)
                return
            }
        }
    }
    
    //MARK: - Modifier Button Methods
    /// Use for modifier buttons. Calculates the width, height, position, and z-index of the modifier button and returns a CustomButton with those values
    func createModifierCustomButton(block: Block, modifierData: ModifierButtonData) -> ModifierButton {
        let buttonFrame = CGRect(
            x: blockSize / 11,
            y: startingHeight - ((blockSize / 5) * 4) - count * (blockSize  / 2 + blockSpacing),
            width: (blockSize / 7) * 6,
            height: (blockSize / 7) * 6)
       
        let tempButton = ModifierButton(frame: buttonFrame, block: block, modifierData: modifierData)
        tempButton.layer.zPosition = 1
        
        allModifierBlocks.append(tempButton)
        
        return tempButton
    }

    /// Sets up a modifier button based on the name inputted
    private func setUpModifierButton(block : Block, blockName name : String, indexPath : IndexPath, cell : UICollectionViewCell) {
        let dict = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties")  // holds properties of all modifier blocks
        
        let (selector, defaultValue, attributeName, accessibilityHint, imagePath, displaysText, secondAttributeName, secondDefault, showTextImage) = getModifierData(name: name, dict: dict!)  // constants taken from dict based on name
        
        let modifierButtonData = ModifierButtonData(modifierButton: nil, blockName: name, selector: selector, defaultValue: defaultValue, attributeName: attributeName, accessibilityHint: accessibilityHint, imagePath: imagePath, displaysText: displaysText, secondAttributeName: secondAttributeName, secondDefault: secondDefault, showTextImage: showTextImage)
        
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
       
       
        let button = createModifierCustomButton(block: placeHolderBlock, modifierData: modifierButtonData) // set up button sizing and layering
        
        
        button.addTarget(self, action: selector, for: .touchUpInside)  // connect what happens when the button is pressed
        

        var modifierInformation = button.getModifierInformation() // the current state of the block modifier - used for voiceOver
        
        button.tag = indexPath.row
        
        cell.addSubview(button)  // add button to cell
        
        //create blockView for the modifier
        let blockView = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockSize/2+blockSpacing), width: blockSize, height: blockSize),  block: [block],  myBlockSize: blockSize)
        
        allBlockViews.append(blockView)
        cell.addSubview(blockView)
        
        // update addedBlocks
        block.addedBlocks[0] = button.getBlock()
        
        // Accessibility
        // set voiceOver information
        button.accessibilityHint = accessibilityHint.localized
        button.isAccessibilityElement = true
        
        //TODO: this line doesn't really do anything, it is just the same as modifierInformation
        let voiceControlLabel = modifierInformation
        
        //TODO: test on different operating systems
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(modifierInformation)"]
        }
        
        addAccessibilityLabel(blockView: blockView, block: block, blockModifier: modifierInformation.localized, blockLocation: indexPath.row+1, blockIndex: indexPath.row)
        
        // the main part of the block is focused first, then the modifier button
        // if the block is nested in another block, add that item to accessibility elements
        let nestedBlock = cell.accessibilityElement(at: 0)
        if (nestedBlock != nil) {
            cell.accessibilityElements = [blockView, button, nestedBlock!]
        } else {
            cell.accessibilityElements = [blockView, button]
        }

        button.accessibilityLabel = modifierInformation.localized
    }
    
    /// Gets values for modifier blocks from a dictionary and returns them as a tuple. Prints errors if properties cannot be found
    private func getModifierData (name : String, dict : NSDictionary) -> (Selector, String, String, String, String?, Bool, String?, String?, String?) {
        
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
        let displaysText = (subDictionary.value(forKey: "displaysText") ?? "false" ) as! String == "true"
        let secondAttributeName = subDictionary.value(forKey: "secondAttributeName") ?? nil
        let secondDefault = subDictionary.value(forKey: "secondDefault") ?? nil
        let showTextImage = subDictionary.value(forKey: "showTextImage") ?? nil
        
        return (selector!, defaultValue! as! String, attributeName! as! String, accessibilityHint! as! String,  imagePath as? String, displaysText, secondAttributeName as? String, secondDefault as? String, showTextImage as? String)
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
        case "Drive Forward", "Drive Backward":
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
        case "Set Background":
            return #selector(selectBackgroundModifier(sender:))
        case "Custom Noise":
            return #selector(selectCustomNoiseModifier(sender:))
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
    
    @objc func selectBackgroundModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "SelectBackgroundModifier", sender: nil)
    }
    
    @objc func selectCustomNoiseModifier(sender: UIButton!) {
        modifierBlockIndex = sender.tag
        performSegue(withIdentifier: "toSelectCustomNoise", sender: nil)
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
            }
        }
        
        // Segue to DistanceSpeedModViewController
        if let destinationViewController = segue.destination as? DistanceSpeedModViewController {
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
        
        // Segue to SliderModifieViewController
        if let destinationViewController = segue.destination as? SliderModifierController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
        
        // Segue to SetVariableModViewController
        if let destinationViewController = segue.destination as? SetVariableModViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
        
        // Segue to DriveVariables
        if let destinationViewController = segue.destination as? DriveVariables{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }

        // Segue to EyeLightModifierViewController
        if let destinationViewController = segue.destination as? TwoOptionModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
        
        // Segue to MultipleChoiceModifierViewController
        if let destinationViewController = segue.destination as? MultipleChoiceModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
        
        // Segue to StepperModifierViewController
        if let destinationViewController = segue.destination as? StepperModifierViewController{
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
        
        // Segue to Add Robot Screen
        if  let destinationViewController = segue.destination as? AddRobotViewController {
        }
        
        // Segue to Location Selection Screen
        if let destinationViewController = segue.destination as? SelectLocationModifierViewController {
            destinationViewController.outputView = currentProject!.currentActor!.freeplayOutputView
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to Speed Modifier Screen
        if let destinationViewController = segue.destination as? SpeedModViewController {
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
            destinationViewController.parentVC = segue.source
        }
        
        // Segue to Background Selection Screen
        if let destinationViewController = segue.destination as? SelectBackgroundModifierViewController {
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
        
        // Segue to Custom Noise Selection Screen
        if let destinationViewController = segue.destination as? SelectCustomNoiseViewController {
            destinationViewController.modifierBlockIndexSender = modifierBlockIndex
        }
    }
}
