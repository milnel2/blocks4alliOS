//
//  FullScreenFreeplayViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/25/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

// An output view for running freeplay scenes in full screen
class FullScreenFreeplayViewController : UIViewController {
    
    @IBOutlet weak var outputView: FreeplayOutputView! // The output view where scenes are played
    
    @IBOutlet weak var outputBackgroundImageView: UIImageView! // image view for the full screen background image
    @IBOutlet weak var exitFullScreenButton: UIButton! // button to go back to the freeplay workspace
    
    var smallViewSize: CGSize? = nil // size of the output view in the regular freeplay workspace
    
    let SCREEN_SIZE = UIScreen.main.bounds.size
    
    var verticalSizeFactor = 0.0 // ratio for sizing from small size to full screen
    var horizontalSizeFactor = 0.0 // ratio for sizing from small size to full screen
    
    let ACTOR_SHRINK_MULITPLIER = 0.9 // number to make the full screen actors a tiny bit smaller
    
    var freeplayWorkspaceVC: FreePlayWorkspaceViewController? = nil // Freeplay workspace associated with this view controller
    
    var freeplayWorkspaceOriginalPlayButton: UIButton? // Used to retain the reference to the play button when going back and forth from the workspace and full screen
    
    @IBOutlet weak var fullScreenPlayButton: UIButton! // Button to run the program
    
    var backgroundImagePath: String? = nil // Path for the current background image
    
    var currentProject: Project? { // Project that is currently open
        get {
            return UserData.data.getCurrentProject()
        }
    }
    
    override func viewDidLoad() {
        if (currentProject == nil) {
            print("ERROR: current project is nil")
        }
        if freeplayWorkspaceVC == nil {
            print("ERROR: freeplay workspace is nil")
        }
       
        // Link play buttons
        freeplayWorkspaceVC!.playTrashToggleButton = fullScreenPlayButton

        calculateVerticalSizeFactor()
        calculateHorizontalSizeFactor()
        
        outputView.freeplayWorkspaceVC = freeplayWorkspaceVC
        
        // Clear accessibility elements
        outputView.accessibilityElements = []
        
        outputView.backgroundColor = UIColor(named: "whiteLightModeBlackDarkMode")
        
        // Set the background image to be the saved background. Also connects the image view to the output view
        backgroundImagePath = currentProject!.currentBackground?.getImagePath()
        outputView.setBackgroundImageView(imageView: outputBackgroundImageView)
        outputView.setBackgroundImage(newImagePath: backgroundImagePath)
        
        // Add each actor to the scene
        for actor in currentProject!.actors {
            
            actor.addFreeplayOutputView(freeplayOutputView: outputView)
            
            outputView.addActor(actor: actor)
            // resize actor
            actor.setActorSize(size: actor.robotSize * verticalSizeFactor * ACTOR_SHRINK_MULITPLIER)
            
            // put actor at adjusted coordinates
            let originalX = actor.coordinates.x
            let originalY = actor.coordinates.y
            actor.setCoordinates(x: originalX * horizontalSizeFactor, y: originalY * verticalSizeFactor)
            
            actor.verticalDistanceMultiplier = verticalSizeFactor
            actor.horizontalDistanceMultiplier = horizontalSizeFactor
            
            actor.setUpAccessibility()
            outputView.accessibilityElements!.append(actor.imageView)
        }
        isInFreeplay = true
       
        currentWorkspace = ON_RUN_STRING
        
        exitFullScreenButton.isUserInteractionEnabled = true
        exitFullScreenButton.isAccessibilityElement = true
        
        accessibilityElements = [outputView!, fullScreenPlayButton!, exitFullScreenButton!] 
    }
    
    // calculate vertical ratio of full screen to smaller output view
    func calculateVerticalSizeFactor() {
        verticalSizeFactor = SCREEN_SIZE.height /  smallViewSize!.height
    }
    
    // calculate horizontal ratio of full screen to smaller output view
    func calculateHorizontalSizeFactor() {
        horizontalSizeFactor = SCREEN_SIZE.width /  smallViewSize!.width
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
