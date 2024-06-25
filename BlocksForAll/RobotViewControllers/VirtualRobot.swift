//
//  VirtualRobot.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/11/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import AVFAudio

let movementAnimationSpeed: CGFloat = 50 // The bigger the number, the faster the animation

class VirtualRobot: Equatable {
    static func == (lhs: VirtualRobot, rhs: VirtualRobot) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    

    
    var imagePath: String
    var imageView: UIImageView
    var freeplayWorkspaceVC: FreePlayWorkspaceViewController?
    let robotSize: CGFloat = 120
    var functionDict: [String : [Block]]
    var name: String
    var coordinates: (x: CGFloat, y: CGFloat) = (-10, -10) // center coordinates of robot image
    var project: Project?
    var executingProgram: ExecutingProgram? = nil
    var isRunning: Bool = false
    
    let UUID: String // Universally Unique Identifier used to compare Virtual Robots
    
    var audioPlayer: AVAudioPlayer?  // Used to play sound blocks
    var soundEffectAudioPlayer: AVAudioPlayer?  // Used to play sound effects like hitting walls
    
   
    
    init(imagePath: String, freeplayWorkspaceVC: FreePlayWorkspaceViewController, name: String = "Dash", coordinates: (x: CGFloat, y: CGFloat) = (-10, -10), project: Project?) {
        
        
        self.imagePath = imagePath
        self.freeplayWorkspaceVC = freeplayWorkspaceVC
    
        self.project = project
        self.name = name
        self.coordinates = coordinates
        self.functionDict = [:]
        self.UUID = Foundation.UUID().uuidString
        
        
        
        let image = UIImage(named: imagePath)
        if (image == nil) {
            print("Error: Couldn't create image in VirtualRobot class from image path: ", imagePath)
        }
        imageView = UIImageView(image: UIImage(named: imagePath))
        
        
        imageView.frame = CGRect(x: 0, y: 0, width: robotSize, height: robotSize)
        
        setCoordinates(x: self.coordinates.x, y: self.coordinates.y)
        
        functionDict = createFunctionDict()
        
    }
    
    init(imagePath: String, name: String, coordinates: (x: CGFloat, y: CGFloat) = (-10, -10), project: Project?) {
        
        self.imagePath = imagePath
        self.freeplayWorkspaceVC = nil
        self.project = project
        self.name = name
        self.coordinates = coordinates
        
        self.UUID = Foundation.UUID().uuidString
        
        self.functionDict = [:]
        
        let image = UIImage(named: imagePath)
        if (image == nil) {
            print("Error: Couldn't create image in VirtualRobot class from image path: ", imagePath)
        }
        imageView = UIImageView(image: UIImage(named: imagePath))
        functionDict = createFunctionDict()
    }
    
    func createFunctionDict() -> [String: [Block]] {
        if project?.projectType == ProjectType.Freeplay {
            return [ON_RUN_STRING : [], ON_BUMP_STRING: [], ON_TAP_STRING: []]
        } else {
            return ["Main Workspace": []]
        }
    }
    
    func setProject(project: Project) {
        self.project = project
        if functionDict.isEmpty {
            functionDict = createFunctionDict()
        }
        
    }
    
    func addFreeplayWorkspaceVC(freeplayWorkspaceVC: FreePlayWorkspaceViewController) {
        self.freeplayWorkspaceVC = freeplayWorkspaceVC
       
        
        imageView.frame = CGRect(x: 0, y: 0, width: robotSize, height: robotSize)
        
       
        setCoordinates(x: coordinates.x, y: coordinates.y)
       
      

    }
   
    
    func moveToOrigin(executingProgram: ExecutingProgram) {
        let currentX = coordinates.x
        let currentY = coordinates.y
        
        let backgroundCenterX =  freeplayWorkspaceVC!.freeplayOutputView.frame.width / 2
        let backgroundCenterY =  freeplayWorkspaceVC!.freeplayOutputView.frame.height / 2
        
        let animationDuration = sqrt(pow((backgroundCenterX - currentX),2) + pow( (backgroundCenterY - currentY),2)) / (movementAnimationSpeed * 2)
       
        animatedMoveToCoordinates(x: backgroundCenterX, y: backgroundCenterY, duration: animationDuration)
       
        executingProgram.finishCommand(withDuration: animationDuration) //TODO: block highlight is going away before movement is finished
        
    }
    
    func playMove(distance: Double, xDirection: Int, yDirection: Int, executingProgram: ExecutingProgram) {
        
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
                
                // play hit sound when getting to wall
                Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { timer in
                    self.playHitWallSound()
                }
                
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
                
                // play hit sound when getting to wall
                Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { timer in
                    self.playHitWallSound()
                }
                
                let bounceAmount = 10.0
                let bounceDuration = bounceAmount / movementAnimationSpeed
                
                let newBounceX = coordinates.x + ((bounceAmount + 5) * CGFloat(-xDirection))
                animatedMoveToCoordinates(x: newBounceX, y: coordinates.y, duration: bounceDuration, delay: animationDuration)
                
                let bounceBackX = coordinates.x + (bounceAmount * CGFloat(xDirection))
                animatedMoveToCoordinates(x: bounceBackX, y: coordinates.y, duration: bounceDuration, delay: animationDuration + bounceDuration)
               
        
                executingProgram.finishCommand(withDuration: animationDuration + 2 * bounceDuration)
                return true
            }
        }
        return false
    }
    
    func playHitWallSound() {
        // Code to play audio is from https://www.tutorialspoint.com/how-to-play-a-sound-using-swift
        guard let path = Bundle.main.path(forResource: "bounceOffWall", ofType:"mp3") else {
            print("Couldn't find sound file for ", "bounceOffWall")
                 return }
        let url = URL(fileURLWithPath: path)
        do {
            
            soundEffectAudioPlayer = try AVAudioPlayer(contentsOf: url)
            
           
            soundEffectAudioPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
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
    
    // left turn is a negative angle and right turn is a positive angle
    func playTurn(angle: Double, executingProgram: ExecutingProgram) {
        let angleInRadians = angle * .pi / 180
       
        let animationDuration = abs(angleInRadians) / (movementAnimationSpeed / 10)
        if abs(angleInRadians) <= .pi {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians)
               }, completion: nil)
        } else {
            // if the angle is greater than 180 degrees, the turn has to be split up into two turns
            UIView.animate(withDuration: animationDuration / 2, delay: 0, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians / 2)
               }, completion: nil)
            UIView.animate(withDuration: animationDuration / 2, delay: animationDuration / 2, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians / 2)
               }, completion: nil)
        }
        
        // TODO: retain rotation amounts between sessions
        executingProgram.finishCommand(withDuration: animationDuration)
        
       
    }
    
    func playSound(soundName: String, executingProgram: ExecutingProgram) {
        // Play sound
        // Code to play audio is from https://www.tutorialspoint.com/how-to-play-a-sound-using-swift
        guard let path = Bundle.main.path(forResource: soundName, ofType:"mp3") else {
            print("Couldn't find sound file for ", soundName)
                 return }
        let url = URL(fileURLWithPath: path)
        do {
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
           
            audioPlayer?.play()
            print("PLAYING AUDIO from", audioPlayer)
        } catch let error {
            print(error.localizedDescription)
        }
        
        executingProgram.finishCommand(withDuration: 1.5)
    }
   
}


