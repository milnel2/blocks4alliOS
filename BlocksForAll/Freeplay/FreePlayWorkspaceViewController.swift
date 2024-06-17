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

class FreePlayWorkspaceViewController: BlocksViewController {
    
    @IBOutlet weak var freeplayOutputView: FreeplayOutputView!
    
    @IBOutlet weak var currentActorImageView: UIImageView!
    
    @IBOutlet weak var outputBackgroundImageView: UIImageView!
    
    @IBOutlet weak var FirstCodeLineButton: UIButton!
    
    @IBOutlet weak var SecondCodeLineButton: UIButton!
    
    
    @IBOutlet weak var thirdCodeLineButton: UIButton!
    override func viewDidLoad() {
        if (project == nil) {
            print("ERROR: current project is nil")
        }
        
        for actor in project!.actors {
            if (actor.freeplayWorkspaceVC == nil) {
                actor.addFreeplayWorkspaceVC(freeplayWorkspaceVC: self)
            }
        }
        
        isInFreeplay = true
        currentProject = project
        functionsDict = project!.currentActor!.functionDict
        currentWorkspace = ON_RUN_STRING
        
        super.viewDidLoad()
        
        currentActorImageView.alpha = 0.3
        workspaceTitle.text = project!.name
        
        updateUI()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        isInFreeplay = false
    }
    //this function allows the blocks in the workspace to be sent to the robot
    override func play(functionsDictToPlay: [String : [Block]]){
        executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay, robotControlViewController: self)
        
        // TODO: update this
        executingProgram?.currentActor = currentProject!.currentActor //creates executing program
        executeNextCommandRobotControllVC()
        //makes initial executeNextCommandRobotControllVC call
      
        
    }
    
    override func playClicked() {
    
        stopIsOption = true
        changePlayTrashButton()
        //Calls RobotControllerViewController play function
        play(functionsDictToPlay: currentProject!.currentActor!.functionDict)
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
        currentActorImageView.image = UIImage(named: (currentProject?.currentActor!.imagePath)!)
        
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
        case THIRD_LINE_STRING:
            thirdCodeLineButton.backgroundColor = .lightGray
        default:
            break
        }
    }

    @IBAction func addActorClicked(_ sender: Any) {
        let newRobot = VirtualRobot(imagePath: "cat", freeplayWorkspaceVC: self, name: "Cat")
        currentProject!.addActor(actor: newRobot)
        updateCurrentActor(newActor: newRobot)
        print("project actors = ", currentProject!.actors)
        
    }
    
    func updateCurrentActor(newActor: VirtualRobot) {
        project?.currentActor = newActor
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
        updateCurrentWorkspace(name: THIRD_LINE_STRING)
        updateUI()
    }
    
}


