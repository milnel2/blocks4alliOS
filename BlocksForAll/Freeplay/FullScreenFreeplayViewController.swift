//
//  FullScreenFreeplayViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/25/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class FullScreenFreeplayViewController : UIViewController {
    
    
    @IBOutlet weak var outputView: FreeplayOutputView!
    
    @IBOutlet weak var exitFullScreenButton: UIButton!
    
    var currentProject: Project? = nil
    
    var smallViewSize: CGSize? = nil
    
    var screenSize = UIScreen.main.bounds.size
    
    var verticalSizeFactor = 0.0
    var horizontalSizeFactor = 0.0
    
    let ACTOR_SHRINK_MULITPLIER = 0.9 // number to make the full screen actors a tiny bit smaller
    
    var freeplayWorkspaceVC: FreePlayWorkspaceViewController? = nil
    
    var freeplayWorkspaceOriginalPlayButton: UIButton?
    
    @IBOutlet weak var fullScreenPlayButton: UIButton!
    
    override func viewDidLoad() {
        if (currentProject == nil) {
            print("ERROR: current project is nil")
        }
        if freeplayWorkspaceVC == nil {
            print("ERROR: freeplay workspace is nil")
        }
       
        freeplayWorkspaceVC!.playTrashToggleButton = fullScreenPlayButton
        calculateVerticalSizeFactor()
        calculateHorizontalSizeFactor()
        
        outputView.freeplayWorkspaceVC = freeplayWorkspaceVC
        
        outputView.accessibilityElements = []
        for actor in currentProject!.actors {
            
            actor.addFreeplayOutputView(freeplayOutputView: outputView)
            
            outputView.addActor(actor: actor)
            actor.setActorSize(size: actor.robotSize * verticalSizeFactor * ACTOR_SHRINK_MULITPLIER)
            
            let originalX = actor.coordinates.x
            let originalY = actor.coordinates.y
            actor.setCoordinates(x: originalX * horizontalSizeFactor, y: originalY * verticalSizeFactor)
            
            actor.verticalDistanceMultiplier = verticalSizeFactor
            actor.horizontalDistanceMultiplier = horizontalSizeFactor
            
            actor.setUpAccessibility()
            outputView.accessibilityElements!.append(actor.imageView)
        }
        isInFreeplay = true
       
        functionsDict = currentProject!.currentActor!.functionDict
        currentWorkspace = ON_RUN_STRING
        
        exitFullScreenButton.isUserInteractionEnabled = true
        exitFullScreenButton.isAccessibilityElement = true
        
        accessibilityElements = [outputView!, fullScreenPlayButton!, exitFullScreenButton!] 
    }
    
    func calculateVerticalSizeFactor() {
        verticalSizeFactor = screenSize.height /  smallViewSize!.height
    }
    
    func calculateHorizontalSizeFactor() {
        horizontalSizeFactor = screenSize.width /  smallViewSize!.width
    }
    
    @IBAction func fullScreenPlayPressed(_ sender: Any) {
        freeplayWorkspaceVC!.playClicked()
    }
    @IBAction func exitFullScreenPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "exitFullScreen", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "exitFullScreen") {
            let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
            freeplayWorkspaceVC.currentProject = currentProject
            freeplayWorkspaceVC.playTrashToggleButton = freeplayWorkspaceOriginalPlayButton!
            for actor in currentProject!.actors {
                actor.setActorSize(size: actor.robotSize / verticalSizeFactor / ACTOR_SHRINK_MULITPLIER)
                let fullScreenX = actor.coordinates.x
                let fullScreenY = actor.coordinates.y
                actor.setCoordinates(x: fullScreenX / horizontalSizeFactor, y: fullScreenY / verticalSizeFactor)
                actor.verticalDistanceMultiplier = 1.0
                actor.horizontalDistanceMultiplier = 1.0
                
                actor.executingProgram?.stopWasPressed = true
            }
        }
        super.prepare(for: segue, sender: sender)
        
        
       
    }
    
    
    
}
