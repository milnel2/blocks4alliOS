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
class FreePlayWorkspaceViewController: BlocksViewController {
    
    @IBOutlet weak var freeplayOutputView: FreeplayOutputView!
    
    @IBOutlet weak var currentActorImageView: UIImageView!
    
    var actors: [VirtualRobot] = []
    
    @IBOutlet weak var outputBackgroundImageView: UIImageView!
    
    @IBOutlet weak var outputActorViewTemp: UIImageView!
    
    
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
        
        executingProgram?.actorImage = outputActorViewTemp
                currentActorImageView.alpha = 0.3
        workspaceTitle.text = project!.name
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isInFreeplay = false
    }
    //this function allows the blocks in the workspace to be sent to the robot
    override func play(functionsDictToPlay: [String : [Block]]){
        executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay, robotControlViewController: self)

        executingProgram?.actorImage = outputActorViewTemp
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
//    /// Play the passed sound file name
//    override func playNoise (sound: String){
//        print("new noise = ", sound)
//    }
//    
    
//    @objc override func distanceSpeedModifier(sender: UIButton!) {
//
//        performSegue(withIdentifier: "DistanceSpeedModifier", sender: nil)
//    }
//    
   
}
