//
//  FreeplayOutputView.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/7/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

// View that shows the scene of a freeplay project.
class FreeplayOutputView: UIView {
    var freeplayWorkspaceVC: FreePlayWorkspaceViewController? = nil // freeplay workspace view controller that the output view is a part of
    
    var actorSubviews = [UIImageView]() // all of the actor image views that are inside of this output view
    
    var backgroundImage: BackgroundImage? = nil
    
    var backgroundImageView: UIImageView? = nil
    
    //MARK: Background

    // Specifies the image view to use for this output. Important because the full screen output has a different imageview
    func setBackgroundImageView(imageView: UIImageView) {
        backgroundImageView = imageView
    }
    
    // Sets the background image of the view. If an imageView has not been specified previously, it will fail
    func setBackgroundImage(newImagePath: String?) {
        if (backgroundImageView == nil) {
            print("background image view does not exist")
            return
        }
        
        backgroundImage = BackgroundImage(imagePath: newImagePath)
        
        freeplayWorkspaceVC!.currentProject!.updateCurrentBackground(background: backgroundImage)
        
        backgroundImageView!.image = backgroundImage!.getImage()
        backgroundImageView?.contentMode = .scaleAspectFit
        
        
    }
    
    func getBackgroundImagePath() -> String? {
        return backgroundImage?.getImagePath() ?? nil
    }
    
    // MARK: Actors

    func resetActorSubviews() {
        actorSubviews = []
    }
    
    // add actor as a subview and add gestures to it
    func addActor(actor: VirtualRobot) {
        // Add actor to screen
        addSubview(actor.imageView)
        actorSubviews.append(actor.imageView)
        // Move actor to saved location
        actor.setToSavedCoordinates()
        
        actor.imageView.isUserInteractionEnabled = true
        
       //  Add dragging interaction to actor
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragActor(sender:)))
        actor.imageView.addGestureRecognizer(dragGesture)
        
        // Add actor to the Project object
        UserData.data.getCurrentProject()!.addActor(actor: actor)
        
        freeplayWorkspaceVC!.addEventIndicatorBlocks()
        freeplayWorkspaceVC!.setUpAccessibility()
    }
    
    
    // Run the on tap code line for the given actor
    public func runOnTapCode(forActor actor: VirtualRobot) {
        if actor.isRunning { // if actor is already doing something, insert the on tap blocks
            // Stop whatever is currently happening
            actor.imageView.layer.removeAllAnimations()
            actor.executingProgram?.stopCurrentBlock()
            
            actor.executingProgram?.insertBlock(blockToExecName: ON_TAP_STRING)
            
        } else {
            // if actor is idle, just play the on tap blocks
            freeplayWorkspaceVC!.play(functionsDictToPlay: actor.functionDict, functionNameToExecute: ON_TAP_STRING, actor: actor)
            freeplayWorkspaceVC!.stopIsOption = true
            freeplayWorkspaceVC!.changePlayTrashButton()
        }
    }
    
    // when an actor image view is tapped and dragged, move it around within the bounds of the output view
    @objc func dragActor(sender: UIPanGestureRecognizer) {

        let dragLocation = sender.location(in: self)
        
        let actorHeight = sender.view!.layer.frame.height
        let actorWidth = sender.view!.layer.frame.width
      
        let backgroundTopY: CGFloat = 0
        let backgroundBottomY = self.frame.height
        let backgroundLeftX: CGFloat = 0
        let backgroundRightX = self.frame.width
               
       switch sender.state {
       case .began, .changed: // Implementation to recognize selected actor from ChatGPT by OpenAI. Source: https://www.openai.com
           for actor in UserData.data.getCurrentProject()!.actors {
               if actor.imageView.frame.contains(dragLocation) && actor.imageView == sender.view {
                   if !(dragLocation.x - actorWidth / 2 <= backgroundLeftX || dragLocation.x + actorWidth / 2 >= backgroundRightX) {
                       // within x bounds
                       actor.setCoordinates(x: dragLocation.x, y: actor.coordinates.y)
                       actor.setUpAccessibility()
                   }
                   
                   if !(dragLocation.y - actorHeight / 2 <= backgroundTopY || dragLocation.y + actorHeight / 2 >= backgroundBottomY ) {
                       // within y bounds
                       actor.setCoordinates(x: actor.coordinates.x, y: dragLocation.y)
                       actor.setUpAccessibility()
                   }
                   freeplayWorkspaceVC!.updateCurrentActor(newActor: actor)
               }
           }
       default:
           break
       }
    }
}
