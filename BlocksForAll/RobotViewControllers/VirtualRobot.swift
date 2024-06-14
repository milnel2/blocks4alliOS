//
//  VirtualRobot.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/11/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

let movementAnimationSpeed: CGFloat = 50
class VirtualRobot {
    var imageView: UIImageView
    
    var freeplayWorkspaceVC: FreePlayWorkspaceViewController
    
    init(imageView: UIImageView, freeplayWorkspaceVC: FreePlayWorkspaceViewController) {
        self.imageView = imageView
        self.freeplayWorkspaceVC = freeplayWorkspaceVC
    }
    
    func playMove(distance: Double, xDirection: Int, yDirection: Int, executingProgram: ExecutingProgram) {
        
        if (!checkWillCollide(distance: distance, xDirection: xDirection, yDirection: yDirection, executingProgram: executingProgram)) {
            let animationDuration = distance / 50
            // Code to animate UIImage is from Dharmesh Kheni's answer on:  https://stackoverflow.com/questions/32133056/how-can-i-move-an-image-in-swift
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: {
                   // this will change Y position of your imageView center
                   // by 1 every time you press button
                self.imageView.center.y += (distance * CGFloat(yDirection)) // TODO: can't go past the walls
                self.imageView.center.x += (distance * CGFloat(xDirection))
               }, completion: nil)
            executingProgram.finishCommand(withDuration: animationDuration)
            
        }
        
       
        
        
        
        
    }
    
    func checkWillCollide(distance: Double, xDirection: Int, yDirection: Int, executingProgram: ExecutingProgram) -> Bool {
        let currentX = imageView.center.x
        let currentY = imageView.center.y
        let actorHeight = imageView.frame.height
        let actorWidth = imageView.layer.frame.width
        
        print("width = ", actorWidth)
        let actorTopY = currentY - (actorHeight / 2)
        let actorBottomY = currentY + (actorHeight / 2)
        let actorLeftX = currentX - (actorWidth / 2)
        let actorRightX = currentX + (actorWidth / 2)
        
        
        let backgroundTopY: CGFloat = 0
        let backgroundBottomY = freeplayWorkspaceVC.freeplayOutputView.frame.height
        let backgroundLeftX: CGFloat = 0
        let backgroundRightX = freeplayWorkspaceVC.freeplayOutputView.frame.width
        
        print("left x  = ", actorLeftX)
        print("right x = ", actorRightX)
        print("background right x = ", backgroundRightX)
        print("distance = ", distance)
        
        // Check if it will hit the top or bottom of the screen
        if (yDirection != 0) {
            if (actorTopY - distance <= backgroundTopY + 5 // top side
                || actorBottomY + distance >= backgroundBottomY - 5 // bottom side
                    ) {
                
                var amountCanMove: CGFloat = 0
                if yDirection < 0 {
                    amountCanMove = actorTopY
                } else if yDirection > 0 {
                    amountCanMove = backgroundBottomY - actorBottomY
                }
                let animationDuration = amountCanMove / movementAnimationSpeed
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: {
                       // move up as much as possible
                    self.imageView.center.y += (amountCanMove * CGFloat(yDirection))
                }, completion: nil)
                let bounceAmount = 10.0
                let bounceDuration = bounceAmount / movementAnimationSpeed
                UIView.animate(withDuration: bounceDuration, delay: animationDuration, options: .curveLinear, animations: {
                       // move up as much as possible
                    self.imageView.center.y += ((bounceAmount + 5) * CGFloat(-yDirection))
                }, completion: nil)
                UIView.animate(withDuration: bounceDuration, delay: animationDuration + bounceDuration, options: .curveLinear, animations: {
                       // move up as much as possible
                    self.imageView.center.y += (bounceAmount * CGFloat(yDirection))
                }, completion: nil)
        
                executingProgram.finishCommand(withDuration: animationDuration + 2 * bounceDuration)
                return true
            }
        }
        
         //Check if it will hit the left or right side of the screen
        if (xDirection != 0) {
            if (actorLeftX - distance <= backgroundLeftX + 5 // left side
                || actorRightX + distance >= backgroundRightX - 5 // right side
                    ) {
                
                var amountCanMove: CGFloat = 0
                if xDirection < 0 {
                    amountCanMove = actorLeftX
                } else if xDirection > 0 {
                    amountCanMove = backgroundRightX - actorRightX
                }
                let animationDuration = amountCanMove / movementAnimationSpeed
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: {
                       // move up as much as possible
                    self.imageView.center.x += (amountCanMove * CGFloat(xDirection))
                }, completion: nil)
                let bounceAmount = 10.0
                let bounceDuration = bounceAmount / movementAnimationSpeed
                UIView.animate(withDuration: bounceDuration, delay: animationDuration, options: .curveLinear, animations: {
                       // move up as much as possible
                    self.imageView.center.x += ((bounceAmount + 5) * CGFloat(-xDirection))
                }, completion: nil)
                UIView.animate(withDuration: bounceDuration, delay: animationDuration + bounceDuration, options: .curveLinear, animations: {
                       // move up as much as possible
                    self.imageView.center.x += (bounceAmount * CGFloat(xDirection))
                }, completion: nil)
        
                executingProgram.finishCommand(withDuration: animationDuration + 2 * bounceDuration)
                print(" X HIt")
                return true
            }
        }
           

        return false
    }
    
   
}
