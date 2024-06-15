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

var actors: [VirtualRobot] = []

class FreePlayWorkspaceViewController: BlocksViewController {
    
    @IBOutlet weak var freeplayOutputView: FreeplayOutputView!
    
    @IBOutlet weak var currentActorImageView: UIImageView!
    
    @IBOutlet weak var outputBackgroundImageView: UIImageView!
    
   
    override func viewDidLoad() {
        if (project == nil) {
            print("ERROR: current project is nil")
        }
        isInFreeplay = true
        currentProject = project
        functionsDict = project!.functionDict
        currentWorkspace = project!.functionDict.keys.first ?? "Main Workspace"
        print("current workspace = ", currentWorkspace)
        
        super.viewDidLoad()
        
       
        currentActorImageView.alpha = 0.3
        workspaceTitle.text = project!.name
        
        //TODO: update this
        actors = []
        let tempNewActor = VirtualRobot(imagePath: "B4A_Robot_outline", freeplayWorkspaceVC: self)
//        actors.append(tempNewActor)
        executingProgram?.actorImage = tempNewActor.imageView
        print("actors = ", actors)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isInFreeplay = false
    }
    //this function allows the blocks in the workspace to be sent to the robot
    override func play(functionsDictToPlay: [String : [Block]]){
        executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay, robotControlViewController: self)
        
        // TODO: update this
        executingProgram?.actorImage = actors[0].imageView
        //creates executing program
        executeNextCommandRobotControllVC()
        //makes initial executeNextCommandRobotControllVC call
      
        
    }
    
    override func playClicked() {
    
        stopIsOption = true
        changePlayTrashButton()
        //Calls RobotControllerViewController play function
        play(functionsDictToPlay: currentProject!.functionDict)
        robotRunning = true
        // disable modifier blocks while the robot is running
        for modifierBlock in allModifierBlocks {
            modifierBlock.isEnabled = false
            modifierBlock.isAccessibilityElement = false
        }
        refreshScreen()
    }

    @IBAction func addActorClicked(_ sender: Any) {
        let tempNewActor = VirtualRobot(imagePath: "dog", freeplayWorkspaceVC: self)
       // actors.append(tempNewActor)
        print("actors = ", actors)
    }
    
    func updateCurrentActor(newActor: VirtualRobot) {
        currentActorImageView.image = UIImage(named: newActor.imagePath)
        //executingProgram?.actorImage =
    }
    
}


