//
//  VirtualRobot.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/11/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

let movementAnimationSpeed: CGFloat = 50 // The bigger the number, the faster the animation

class VirtualRobot {

    
    var imagePath: String
    var imageView: UIImageView
    var freeplayWorkspaceVC: FreePlayWorkspaceViewController?
    let robotSize: CGFloat = 120
    var functionDict: [String : [Block]]
    var name: String
    var coordinates: (x: CGFloat, y: CGFloat) = (-10, -10) // center coordinates of robot image
    
 
    
    init(imagePath: String, freeplayWorkspaceVC: FreePlayWorkspaceViewController, name: String = "Dash", coordinates: (x: CGFloat, y: CGFloat) = (-10, -10)) {
        
        
        self.imagePath = imagePath
        self.freeplayWorkspaceVC = freeplayWorkspaceVC
        self.functionDict = [ON_RUN_STRING : [], ON_BUMP_STRING: [], THIRD_LINE_STRING: []]
        self.name = name
        self.coordinates = coordinates
        
        let image = UIImage(named: imagePath)
        if (image == nil) {
            print("Error: Couldn't create image in VirtualRobot class from image path: ", imagePath)
        }
        imageView = UIImageView(image: UIImage(named: imagePath))
        
        
        imageView.frame = CGRect(x: 0, y: 0, width: robotSize, height: robotSize)
        
        setCoordinates(x: self.coordinates.x, y: self.coordinates.y)
        
        
        // Tap Gesture code from https://agrawalsuneet.medium.com/uiview-clicklistener-swift-88ab5dec64b5
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(clickOnActor(sender:)))
//        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragActor(sender:)))
//       
//       
        
      
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
//        imageView.addGestureRecognizer(dragGesture)
        
    }
    
    init(imagePath: String, name: String, coordinates: (x: CGFloat, y: CGFloat) = (-10, -10)) {
        
        self.imagePath = imagePath
        self.freeplayWorkspaceVC = nil
        self.functionDict = [ON_RUN_STRING : [], ON_BUMP_STRING: [], THIRD_LINE_STRING: []]
        self.name = name
        self.coordinates = coordinates
        
        let image = UIImage(named: imagePath)
        if (image == nil) {
            print("Error: Couldn't create image in VirtualRobot class from image path: ", imagePath)
        }
        imageView = UIImageView(image: UIImage(named: imagePath))
    }
    
    
    func addFreeplayWorkspaceVC(freeplayWorkspaceVC: FreePlayWorkspaceViewController) {
        self.freeplayWorkspaceVC = freeplayWorkspaceVC
       
        
        imageView.frame = CGRect(x: 0, y: 0, width: robotSize, height: robotSize)
        
       
        setCoordinates(x: coordinates.x, y: coordinates.y)
       
        
        // Tap Gesture code from https://agrawalsuneet.medium.com/uiview-clicklistener-swift-88ab5dec64b5
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(clickOnActor(sender:)))
        
       // let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragActor(sender:)))
     
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        //imageView.addGestureRecognizer(dragGesture)

    }
    
    @objc func clickOnActor(sender : UITapGestureRecognizer) {
        print("click on", imagePath)
        freeplayWorkspaceVC!.updateCurrentActor(newActor: self)
        print(imageView.center)
    }
    
    @objc func dragActor(sender: UIPanGestureRecognizer) {
//        if let actorView = sender.view, let freeplayOutputView = freeplayWorkspaceVC?.freeplayOutputView {
//                let point = sender.location(in: freeplayOutputView)
//                
//              
//          
//                    
//                imageView.center = CGPoint(x: point.x, y: point.y)
//                sender.setTranslation(CGPoint.zero, in: freeplayWorkspaceVC!.freeplayOutputView)
//            }
        let dragLocation = sender.translation(in: freeplayWorkspaceVC!.freeplayOutputView)
        print("drag location = ", dragLocation)
        let actorHeight = sender.view!.layer.frame.height
        let actorWidth = sender.view!.layer.frame.width
        
        let backgroundTopY: CGFloat = 0
        let backgroundBottomY = freeplayWorkspaceVC!.freeplayOutputView.frame.height
        let backgroundLeftX: CGFloat = 0
        let backgroundRightX = freeplayWorkspaceVC!.freeplayOutputView.frame.width
        
        // don't drag if out of bounds
        if !(dragLocation.x - actorWidth / 2 <= backgroundLeftX || dragLocation.x + actorWidth / 2 >= backgroundRightX) {
            // within x bounds
            setCoordinates(x: dragLocation.x, y: coordinates.y)
            
        }
        
        if !(dragLocation.y - actorHeight / 2 <= backgroundTopY || dragLocation.y + actorHeight / 2 >= backgroundBottomY ) {
            // within y bounds
            setCoordinates(x: coordinates.x, y: dragLocation.y)
        }
    }
    
    func moveToOrigin(executingProgram: ExecutingProgram) {
        let currentX = coordinates.x
        let currentY = coordinates.y
        
        let backgroundCenterX =  freeplayWorkspaceVC!.freeplayOutputView.frame.width / 2
        let backgroundCenterY =  freeplayWorkspaceVC!.freeplayOutputView.frame.height / 2
        
        let animationDuration = sqrt(pow((backgroundCenterX - currentX),2) + pow( (backgroundCenterY - currentY),2)) / (movementAnimationSpeed * 2)
       
        animatedMoveToCoordinates(x: backgroundCenterX, y: backgroundCenterY, duration: animationDuration)
       
        executingProgram.finishCommand(withDuration: animationDuration)
        
    }
    
    func playMove(distance: Double, xDirection: Int, yDirection: Int, executingProgram: ExecutingProgram) {
        print("move distance = ", distance, "x direction = ", xDirection, " y direction = ", yDirection)
        
        if (!checkWillCollide(distance: distance, xDirection: xDirection, yDirection: yDirection, executingProgram: executingProgram)) {
            let animationDuration = distance / movementAnimationSpeed
            // Code to animate UIImage is from Dharmesh Kheni's answer on:  https://stackoverflow.com/questions/32133056/how-can-i-move-an-image-in-swift
            let newX = coordinates.x + (distance * CGFloat(xDirection))
            let newY = coordinates.y + (distance * CGFloat(yDirection))
            
            animatedMoveToCoordinates(x: newX, y: newY, duration: animationDuration)
            
            executingProgram.finishCommand(withDuration: animationDuration)
            
        }
        
    }
    
    func checkWillCollide(distance: Double, xDirection: Int, yDirection: Int, executingProgram: ExecutingProgram) -> Bool {
        let currentX = coordinates.x
        let currentY = coordinates.y
        let actorHeight = imageView.frame.height
        let actorWidth = imageView.layer.frame.width
        
        let actorTopY = currentY - (actorHeight / 2)
        let actorBottomY = currentY + (actorHeight / 2)
        let actorLeftX = currentX - (actorWidth / 2)
        let actorRightX = currentX + (actorWidth / 2)
        
        
        let backgroundTopY: CGFloat = 0
        let backgroundBottomY = freeplayWorkspaceVC!.freeplayOutputView.frame.height
        let backgroundLeftX: CGFloat = 0
        let backgroundRightX = freeplayWorkspaceVC!.freeplayOutputView.frame.width
        
        
        // Check if it will hit the top or bottom of the screen
        if (yDirection != 0) {
            if (actorTopY + (distance * Double(yDirection)) <= backgroundTopY + 5 // top side
                || actorBottomY + (distance * Double(yDirection)) >= backgroundBottomY - 5 // bottom side
                    ) {
                
                var amountCanMove: CGFloat = 0
                if yDirection < 0 {
                    amountCanMove = actorTopY
                } else if yDirection > 0 {
                    amountCanMove = backgroundBottomY - actorBottomY
                }
                let animationDuration = amountCanMove / movementAnimationSpeed
                
                let newY = coordinates.y + (amountCanMove * CGFloat(yDirection))
                
                animatedMoveToCoordinates(x: coordinates.x, y: newY, duration: animationDuration)
                
                let bounceAmount = 10.0
                let bounceDuration = bounceAmount / movementAnimationSpeed
                
                let newBounceY = coordinates.y + ((bounceAmount + 5) * CGFloat(-yDirection))
                
                animatedMoveToCoordinates(x: coordinates.x, y: newBounceY, duration: bounceDuration, delay: animationDuration)
               
                let bounceBackY = coordinates.y + (bounceAmount * CGFloat(yDirection))
                
                animatedMoveToCoordinates(x: coordinates.x, y: bounceBackY, duration: bounceDuration, delay: animationDuration + bounceDuration)
                
                executingProgram.finishCommand(withDuration: animationDuration + 2 * bounceDuration)
                return true
            }
        }
        
         //Check if it will hit the left or right side of the screen
        if (xDirection != 0) {
            if (actorLeftX + (distance * Double(xDirection)) <= backgroundLeftX + 5 // left side
                || actorRightX + (distance * Double(xDirection)) >= backgroundRightX - 5 // right side
                    ) {
                
                var amountCanMove: CGFloat = 0
                if xDirection < 0 {
                    amountCanMove = actorLeftX
                } else if xDirection > 0 {
                    amountCanMove = backgroundRightX - actorRightX
                }
                let animationDuration = amountCanMove / movementAnimationSpeed
                
                let newX = coordinates.x + (amountCanMove * CGFloat(xDirection))
                animatedMoveToCoordinates(x: newX, y: coordinates.y, duration: animationDuration)
                
                let bounceAmount = 10.0
                let bounceDuration = bounceAmount / movementAnimationSpeed
                
                let newBounceX = coordinates.x + ((bounceAmount + 5) * CGFloat(-xDirection))
                animatedMoveToCoordinates(x: newBounceX, y: coordinates.y, duration: bounceDuration, delay: animationDuration)
                
                let bounceBackX = coordinates.x + (bounceAmount * CGFloat(xDirection))
                animatedMoveToCoordinates(x: bounceBackX, y: coordinates.y, duration: bounceDuration, delay: animationDuration + bounceDuration)
               
        
                executingProgram.finishCommand(withDuration: animationDuration + 2 * bounceDuration)
                print(" X HIt")
                return true
            }
        }
        return false
    }
    
    func setToSavedCoordinates() {
        setCoordinates(x: coordinates.x, y: coordinates.y)
    }
    
    
    func setCoordinates(x: CGFloat, y: CGFloat) {
        //print("setting coords to x = ", x, " y = ", y)
        if x == -10 && y == -10 {
            let outputWidth = freeplayWorkspaceVC!.freeplayOutputView.frame.width
            let outputHeight = freeplayWorkspaceVC!.freeplayOutputView.frame.height
            let imageWidth = imageView.frame.width
            let imageHeight = imageView.frame.height
            coordinates = (CGFloat.random(in: imageWidth..<outputWidth - imageWidth), CGFloat.random(in: imageHeight..<outputHeight - imageHeight))
        } else {
            coordinates = (x,y)
        }
        imageView.center.x = coordinates.x
        imageView.center.y =  coordinates.y
        
        freeplayWorkspaceVC!.freeplayOutputView.bringSubviewToFront(imageView)
        
    }
    
    func animatedMoveToCoordinates(x: CGFloat, y: CGFloat, duration: TimeInterval, delay: TimeInterval = 0) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveLinear, animations: {
            self.imageView.center.x = x
            self.imageView.center.y = y
           }, completion: nil)
        
        coordinates = (x,y)
    }
    
    func getCurrentX() -> CGFloat {
        return coordinates.x
    }
    
    func getCurrentY() -> CGFloat {
        return coordinates.y
    }
    
   
}


