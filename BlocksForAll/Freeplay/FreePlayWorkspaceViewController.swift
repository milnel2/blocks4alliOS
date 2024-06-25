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
    
    @IBOutlet weak var FirstCodeLineButton: UIButton!
    
    @IBOutlet weak var SecondCodeLineButton: UIButton!
    
    
    @IBOutlet weak var thirdCodeLineButton: UIButton!
    
    var newActorToAdd: (name:String, imagePath: String)? // to be used when adding to actors
    // TODO: add custom backgrounds from camera roll
    override func viewDidLoad() {
        if (currentProject == nil) {
            print("ERROR: current project is nil")
        }
        
       
        
       
        for actor in currentProject!.actors {
            if (actor.freeplayWorkspaceVC == nil) {
                actor.addFreeplayWorkspaceVC(freeplayWorkspaceVC: self)
            }
           addActor(actor: actor)
        }
        
        isInFreeplay = true
       
        functionsDict = currentProject!.currentActor!.functionDict
        currentWorkspace = ON_RUN_STRING
        
        super.viewDidLoad()
        
        currentActorImageView.alpha = 0.3
        workspaceTitle.text = currentProject!.name
        
        updateUI()
        
        if newActorToAdd != nil {
            afterNewActorSelected(name: newActorToAdd!.name, imagePath: newActorToAdd!.imagePath)
        }
        
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
    
   
    @objc func dragActor(sender: UIPanGestureRecognizer) {

        let dragLocation = sender.location(in: freeplayOutputView)
        
        let actorHeight = sender.view!.layer.frame.height
        let actorWidth = sender.view!.layer.frame.width
      
        let backgroundTopY: CGFloat = 0
        let backgroundBottomY = freeplayOutputView.frame.height
        let backgroundLeftX: CGFloat = 0
        let backgroundRightX = freeplayOutputView.frame.width
        
        
        
               
       switch sender.state {
       case .began, .changed: // Implementation to recognize seleccted actor from ChatGPT by OpenAI. Source: https://www.openai.com
           for actor in currentProject!.actors {
               if actor.imageView.frame.contains(dragLocation) && actor.imageView == sender.view { // TODO: handle when images overlap
                   if !(dragLocation.x - actorWidth / 2 <= backgroundLeftX || dragLocation.x + actorWidth / 2 >= backgroundRightX) {
                       // within x bounds
                       actor.setCoordinates(x: dragLocation.x, y: actor.coordinates.y)
                       
                   }
                   
                   if !(dragLocation.y - actorHeight / 2 <= backgroundTopY || dragLocation.y + actorHeight / 2 >= backgroundBottomY ) {
                       // within y bounds
                       actor.setCoordinates(x: actor.coordinates.x, y: dragLocation.y)
                       
                   }
                   updateCurrentActor(newActor: actor)
                   
               }
           }
       default:
           break
       }
      
        
    }
    
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
        isInFreeplay = false
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
        
        super.prepare(for: segue, sender: sender)
       
    }
    
    func afterNewActorSelected(name: String, imagePath: String) {
        let newRobot = VirtualRobot(imagePath: imagePath, freeplayWorkspaceVC: self, name: name, project: currentProject!)
        addActor(actor: newRobot)
        updateCurrentActor(newActor: newRobot)
        newActorToAdd = nil

    }
    
    func addActor(actor: VirtualRobot) {
        // Add actor to screen
        freeplayOutputView.addSubview(actor.imageView)
        
        // Move actor to saved location
        actor.setToSavedCoordinates()
        
        actor.imageView.isUserInteractionEnabled = true
        
        
        // Add dragging interaction to actor
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragActor(sender:)))
        actor.imageView.addGestureRecognizer(dragGesture)
        
        // Tap Gesture code from https://agrawalsuneet.medium.com/uiview-clicklistener-swift-88ab5dec64b5
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(clickOnActor(sender:)))
      
        actor.imageView.addGestureRecognizer(tapGesture)
        
        
        // Add actor to the Project object
        currentProject!.addActor(actor: actor)
        
        addEventIndicatorBlocks()
    }
    
    // TODO: disable editing code when program is running
    // TODO: make actor bigger/smaller and rotate with fingers
    //TODO: ontap doesn't work if the actor is already moving
    @objc func clickOnActor(sender : UITapGestureRecognizer) {
        let tapLocation = sender.location(in: freeplayOutputView)
        for actor in currentProject!.actors {
            if actor.imageView.frame.contains(tapLocation) && actor.imageView == sender.view {
                updateCurrentActor(newActor: actor)
                print(actor.functionDict)
                if actor.isRunning {
                    actor.executingProgram?.insertBlock(blockToExecName: ON_TAP_STRING)
                    stopIsOption = true
                    changePlayTrashButton()
                } else {
                    play(functionsDictToPlay: actor.functionDict, functionNameToExecute: ON_TAP_STRING, actor: actor)
                    stopIsOption = true
                    changePlayTrashButton()
                    
                }
            }
        }
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


