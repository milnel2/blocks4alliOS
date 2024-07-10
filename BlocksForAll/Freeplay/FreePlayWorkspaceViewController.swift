//
//  FreePlayWorkspaceViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/7/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

var isInFreeplay: Bool = false // global variable for if the freeplay workspace is open

// View Controller for Freeplay Mode.
class FreePlayWorkspaceViewController: BlocksViewController {
    
    @IBOutlet weak var freeplayOutputView: FreeplayOutputView! // View where actors are located
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var currentActorImageView: UIImageView! // image view that shows which actor is currently selected and is being edited
    
    @IBOutlet weak var outputBackgroundImageView: UIImageView! // background image for output
    
    @IBOutlet weak var enterFullScreenButton: UIButton! // button to make output be in fullscreen
    @IBOutlet weak var FirstCodeLineButton: UIButton! // button to open the first code line of the blocksProgram
    
    @IBOutlet weak var secondCodeLineButton: UIButton! // button to open the second code line of the blocksProgram
    
    @IBOutlet weak var buttonsView: UIView! // view that has play button, code lines, and customize actor button
    @IBOutlet weak var addActorButton: UIButton! // button to add a new actor to the project
    
    var newActorToAdd: (name:String, baseImagePath: String, color: String)? // to be used when adding to actors
    
    override func viewDidLoad() {
        if (currentProject == nil) {
            print("ERROR: current project is nil")
        }
        
        freeplayOutputView.freeplayWorkspaceVC = self
        freeplayOutputView.resetActorSubviews()
        
        // add actors to the scene
        for actor in currentProject!.actors {
            
            actor.addFreeplayOutputView(freeplayOutputView: freeplayOutputView)
            
           addActor(actor: actor)
        }
        
        isInFreeplay = true
       
        functionsDict = currentProject!.currentActor!.functionDict
        currentWorkspace = ON_RUN_STRING
        
        super.viewDidLoad()
        
        // Styling
        currentActorImageView.alpha = 0.3
        workspaceTitle.text = currentProject!.name
        workspaceTitle.layer.cornerRadius = 10.0
        workspaceTitle.layer.masksToBounds = true
        workspaceTitle.textColor = .black
        
        freeplayOutputView.backgroundColor = #colorLiteral(red: 0.8588235294, green: 0.9490196078, blue: 1, alpha: 1)
        
        addActorButton.layer.masksToBounds = true // allows for corner radius to work
        addActorButton.layer.cornerRadius = 10
        
        updateUI()
        
        // If there is a new actor that needs to be added to the project (coming from the add actor screen), add it.
        if newActorToAdd != nil {
            afterNewActorSelected(name: newActorToAdd!.name, baseImagePath: newActorToAdd!.baseImagePath)
        }
        
        // Add tap gesture recognizer to current actor image
        // Tap Gesture code from https://agrawalsuneet.medium.com/uiview-clicklistener-swift-88ab5dec64b5
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(clickOnCurrentActorImageView(sender:)))
        
       
        currentActorImageView.addGestureRecognizer(tapGesture)
        
        setUpAccessibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpAccessibility()
    }
    
    func setUpAccessibility() {
        freeplayOutputView.isAccessibilityElement = false
        
        freeplayOutputView.accessibilityElements = []
        
        for actor in currentProject!.actors {
            actor.setUpAccessibility()
            freeplayOutputView.accessibilityElements!.append(actor.imageView)
        }
        
        currentActorImageView.isUserInteractionEnabled = true
        currentActorImageView.isAccessibilityElement = true
        
        mainMenuButton.isAccessibilityElement = true
        mainMenuButton.isUserInteractionEnabled = true
        mainMenuButton.accessibilityTraits = .button
        
        // Set the accessibility elements for the screen
        resetAccessibilityElements()
        
        addActorButton.accessibilityLabel = "Add actor to project"
        currentActorImageView.accessibilityLabel = "Current actor is " + currentProject!.currentActor!.name + ". Tap to customize or delete"
        
        // highlight the active code line button
        switch currentWorkspace {
        case ON_RUN_STRING:
            secondCodeLineButton.isSelected = false
            FirstCodeLineButton.isSelected = true
        case ON_TAP_STRING:
            secondCodeLineButton.isSelected = true
            FirstCodeLineButton.isSelected = false
        default:
            break
        }
        FirstCodeLineButton.accessibilityLabel = "On Run code line"
        FirstCodeLineButton.accessibilityHint = "Press the play button to run this code line."
        secondCodeLineButton.accessibilityLabel = "On Actor Tap code line"
        secondCodeLineButton.accessibilityHint = "Tap on " + currentProject!.currentActor!.name + " actor to run this code line."
    }
    
    
    // Update accessibility elements to make navigation easier when moving blocks
    override func beginMovingBlocks(_ blocks: [Block]) {
        super.beginMovingBlocks(blocks)
        accessibilityElements = [toolboxView!, playTrashToggleButton!, FirstCodeLineButton!, secondCodeLineButton!, blocksProgram!, mainMenuButton!]
    }
    
    override func finishMovingBlocks() {
        super.finishMovingBlocks()
        resetAccessibilityElements()
    }
    
    // reset accessibility elements for accessing the entire screen
    func resetAccessibilityElements() {
       
        accessibilityElements = [toolboxView!, freeplayOutputView!, mainMenuButton!, addActorButton!, currentActorImageView!, playTrashToggleButton!, FirstCodeLineButton!, secondCodeLineButton!, blocksProgram!] // toolbox, output, home, add actor, customize, play, line 1 line 2, blocks program
    }
    
    @objc func clickOnCurrentActorImageView(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "toCustomizeActor", sender: nil)
    }
    
    @IBAction func enterFullScreenPressed(_ sender: Any) {
        performSegue(withIdentifier: "enterFullScreen", sender: nil)
    }
    // save snapshot of the output view and link it with the current project
    override func saveProjectSnapshot() {
        
        // rendering view as image is from: https://www.hackingwithswift.com/example-code/media/how-to-render-a-uiview-to-a-uiimage
        let renderer = UIGraphicsImageRenderer(size: freeplayOutputView.bounds.size)
        let image = renderer.image { ctx in
            freeplayOutputView.drawHierarchy(in: freeplayOutputView.bounds, afterScreenUpdates: true)
        }
       
        currentProject!.image = image
        currentProject!.imageName = generateImageName()
    }
    
    //this function allows the blocks in the workspace to be sent to the virtual robot
    override func play(functionsDictToPlay: [String : [Block]], functionNameToExecute: String? = nil, actor: VirtualRobot? = nil){
        let newRobotControlVC = RobotControlViewController()
        
        executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay, robotControlViewController: newRobotControlVC, functionNameToExecute: functionNameToExecute, actor: actor)
        newRobotControlVC.executingProgram = executingProgram
        newRobotControlVC.blocksViewController = self
        actor?.executingProgram = executingProgram
        executingProgram?.currentProject = currentProject
        
        executingProgram?.robotControlViewController.executeNextCommandRobotControllVC()
      
      
        
    }
    
    override func playClicked() {
        
        stopIsOption = true
        changePlayTrashButton()
        //Calls RobotControllerViewController play function
        for actor in currentProject!.actors {
            play(functionsDictToPlay: actor.functionDict, functionNameToExecute: ON_RUN_STRING, actor: actor)
            actor.isRunning = true
        }
        robotRunning = true
        // disable modifier blocks while the robot is running
        for modifierBlock in allModifierBlocks {
            modifierBlock.isEnabled = false
            modifierBlock.isAccessibilityElement = false
        }
        refreshScreen()
    }
    
    func updateUI() {
        // Update current actor image
        let newImage = UIImage(named: (currentProject?.currentActor!.imagePath)!)
        self.currentActorImageView.image = nil
        self.currentActorImageView.image = newImage
        
        // Styling
        FirstCodeLineButton.titleLabel?.font =  UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 24.0)
        
        FirstCodeLineButton.titleLabel?.textColor = .black
        secondCodeLineButton.titleLabel?.textColor = .black
        
        secondCodeLineButton.titleLabel?.font =  UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 24.0)
        
        // reset button images
        FirstCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Blue"), for: .normal)
        secondCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Orange"), for: .normal)
       
       
        // highlight the active code line button
        switch currentWorkspace {
        case ON_RUN_STRING:
            FirstCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Blue-Highlighted"), for: .normal)
        case ON_TAP_STRING:
           
            secondCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Orange-Highlighted"), for: .normal)
        default:
            break
        }
        
        setUpAccessibility()
    }

    @IBAction func addActorClicked(_ sender: Any) {
        performSegue(withIdentifier: "toChooseActor", sender: nil)
    }
    
    func deleteActor(actor: VirtualRobot) {
        currentProject!.deleteActor(actor: actor)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "toChooseActor") {
          let chooseActorVC = segue.destination as! ChooseActorViewController
           chooseActorVC.currentProject = currentProject
           chooseActorVC.currentActorImageView = currentActorImageView
           chooseActorVC.freeplayOutputView = freeplayOutputView
       }
        if (segue.identifier == "enterFullScreen") {
            let fullscreenVC = segue.destination as! FullScreenFreeplayViewController
            
            fullscreenVC.currentProject = currentProject
            fullscreenVC.freeplayWorkspaceVC = self
            fullscreenVC.smallViewSize = freeplayOutputView.frame.size
            fullscreenVC.freeplayWorkspaceOriginalPlayButton = playTrashToggleButton
            
            for actor in currentProject!.actors {
                actor.executingProgram?.stopWasPressed = true
            }
        }
        
        if (segue.identifier == "toCustomizeActor") {
            let customizeVC = segue.destination as! CustomizeActorViewController
            customizeVC.currentActor = currentProject!.currentActor
            customizeVC.currentProject = currentProject!
            customizeVC.freeplayWorkspace = self
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
    // Called after returning from the add actor screen. Adds a new actor to the project.
    func afterNewActorSelected(name: String, baseImagePath: String) {
        let newRobot = VirtualRobot(baseImagePath: baseImagePath, freeplayOutputView: freeplayOutputView, name: name, project: currentProject!)
        addActor(actor: newRobot)
        updateCurrentActor(newActor: newRobot)
        newActorToAdd = nil
    }
    
    func addActor(actor: VirtualRobot) {
        freeplayOutputView.addActor(actor: actor)
    }
    
    // Updates the actor that is currently being edited
    func updateCurrentActor(newActor: VirtualRobot) {
        currentProject!.currentActor = newActor
        functionsDict = currentProject!.currentActor!.functionDict
        
        refreshScreen()
        updateUI()
    }
    
    
    @IBAction func firstCodeLinePressed(_ sender: Any) {
        updateCurrentWorkspace(name: ON_RUN_STRING)
        updateUI()
    }

    @IBAction func secondCodeLinePressed(_ sender: Any) {
        updateCurrentWorkspace(name: ON_TAP_STRING)
        updateUI()
    }
}
