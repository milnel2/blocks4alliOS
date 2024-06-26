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

//var actors: [VirtualRobot] = []
var backgroundImage: UIImage?
class FreePlayWorkspaceViewController: BlocksViewController {
    
    @IBOutlet weak var freeplayOutputView: FreeplayOutputView!
    
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var currentActorImageView: UIImageView!
    
    @IBOutlet weak var outputBackgroundImageView: UIImageView!
    
    @IBOutlet weak var enterFullScreenButton: UIButton!
    @IBOutlet weak var FirstCodeLineButton: UIButton!
    
    @IBOutlet weak var SecondCodeLineButton: UIButton!
    
    
    @IBOutlet weak var thirdCodeLineButton: UIButton!
    
    var newActorToAdd: (name:String, imagePath: String)? // to be used when adding to actors
    // TODO: add custom backgrounds from camera roll
    override func viewDidLoad() {
        if (currentProject == nil) {
            print("ERROR: current project is nil")
        }
        freeplayOutputView.freeplayWorkspaceVC = self
        
        for actor in currentProject!.actors {
            
            actor.addFreeplayOutputView(freeplayOutputView: freeplayOutputView)
            
           addActor(actor: actor)
        }
        
        isInFreeplay = true
       
        functionsDict = currentProject!.currentActor!.functionDict
        currentWorkspace = ON_RUN_STRING
        
        super.viewDidLoad()
        
        currentActorImageView.alpha = 0.3
        workspaceTitle.text = currentProject!.name
        workspaceTitle.layer.cornerRadius = 10.0 // TODO: corner radius isn't showing up
        
        updateUI()
        
        if newActorToAdd != nil {
            afterNewActorSelected(name: newActorToAdd!.name, imagePath: newActorToAdd!.imagePath)
        }
        
    }
    
    @IBAction func enterFullScreenPressed(_ sender: Any) {
        performSegue(withIdentifier: "enterFullScreen", sender: nil)
    }
    // save snapshot of the output view
    override func saveProjectSnapshot() {
        
        // rendering view as image is from: https://www.hackingwithswift.com/example-code/media/how-to-render-a-uiview-to-a-uiimage
        let renderer = UIGraphicsImageRenderer(size: freeplayOutputView.bounds.size)
        let image = renderer.image { ctx in
            freeplayOutputView.drawHierarchy(in: freeplayOutputView.bounds, afterScreenUpdates: true)
        }
       
        currentProject!.image = image
        currentProject!.imageName = generateImageName()
    }
    
   
   
   
    
    
    //this function allows the blocks in the workspace to be sent to the robot
    override func play(functionsDictToPlay: [String : [Block]], functionNameToExecute: String? = nil, actor: VirtualRobot? = nil){
        let newRobotControlVC = RobotControlViewController()
        
        executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay, robotControlViewController: newRobotControlVC, functionNameToExecute: functionNameToExecute, actor: actor)
        newRobotControlVC.executingProgram = executingProgram
        newRobotControlVC.blocksViewController = self
        actor?.executingProgram = executingProgram
        executingProgram?.currentProject = currentProject
        
        executingProgram?.robotControlViewController.executeNextCommandRobotControllVC()
        //makes initial executeNextCommandRobotControllVC call
      
        
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
        // reset button colors
        FirstCodeLineButton.backgroundColor = .clear
        SecondCodeLineButton.backgroundColor = .clear
        thirdCodeLineButton.backgroundColor = .clear
        
        // highlight the active code line button
        switch currentWorkspace {
        case ON_RUN_STRING:
            FirstCodeLineButton.backgroundColor = .lightGray
        case ON_BUMP_STRING:
            SecondCodeLineButton.backgroundColor = .lightGray
        case ON_TAP_STRING:
            thirdCodeLineButton.backgroundColor = .lightGray
        default:
            break
        }
    }

    @IBAction func addActorClicked(_ sender: Any) {
        performSegue(withIdentifier: "toChooseActor", sender: nil)
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
        
        
        super.prepare(for: segue, sender: sender)
       
    }
    
    func afterNewActorSelected(name: String, imagePath: String) {
        let newRobot = VirtualRobot(imagePath: imagePath, freeplayOutputView: freeplayOutputView, name: name, project: currentProject!)
        addActor(actor: newRobot)
        updateCurrentActor(newActor: newRobot)
        newActorToAdd = nil

    }
    
    func addActor(actor: VirtualRobot) {
        freeplayOutputView.addActor(actor: actor)

    }
    
    func updateCurrentActor(newActor: VirtualRobot) { // TODO: after adding a new actor, tapping on actors to switch doesn't always work
        currentProject!.currentActor = newActor
        functionsDict = currentProject!.currentActor!.functionDict
        
        
        refreshScreen()
        updateUI()
        //executingProgram?.actorImage =
    }
    
    
    @IBAction func firstCodeLinePressed(_ sender: Any) {
        updateCurrentWorkspace(name: ON_RUN_STRING)
        updateUI()
    }
    @IBAction func secondCodeLinePressed(_ sender: Any) {
        updateCurrentWorkspace(name: ON_BUMP_STRING)
        updateUI()
    }
    @IBAction func thirdCodeLinePressed(_ sender: Any) {
        updateCurrentWorkspace(name: ON_TAP_STRING)
        updateUI()
    }
    
}


