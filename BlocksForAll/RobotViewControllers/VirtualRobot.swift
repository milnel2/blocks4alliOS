//
//  VirtualRobot.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/11/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import AVFAudio



class VirtualRobot: Equatable {
    static func == (lhs: VirtualRobot, rhs: VirtualRobot) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    

    
    var imagePath: String
    var imageView: UIImageView
    var freeplayOutputView: FreeplayOutputView?
    var robotSize: CGFloat = 120
    let defaultRobotSize: CGFloat = 120
    var functionDict: [String : [Block]]
    var name: String
    var coordinates: (x: CGFloat, y: CGFloat) = (-10, -10) // center coordinates of robot image
    var project: Project?
    var executingProgram: ExecutingProgram? = nil
    var isRunning: Bool = false
    
    let UUID: String // Universally Unique Identifier used to compare Virtual Robots
    
    var audioPlayer: AVAudioPlayer?  // Used to play sound blocks
    var soundEffectAudioPlayer: AVAudioPlayer?  // Used to play sound effects like hitting walls
    
    // used during full screen
    var verticalDistanceMultiplier = 1.0
    var horizontalDistanceMultiplier = 1.0
    
    let reallySlowAnimSpeed: CGFloat = 15
    let slowAnimSpeed: CGFloat = 30
    let normalAnimationSpeed: CGFloat = 60
    let fastAnimSpeed: CGFloat = 100
    let reallyFastAnimSpeed: CGFloat = 170
    var movementAnimationSpeed: CGFloat = 50 // The bigger the number, the faster the animation
    
    
    init(imagePath: String, freeplayOutputView: FreeplayOutputView, name: String = "Dash", coordinates: (x: CGFloat, y: CGFloat) = (-10, -10), project: Project?, uuid: String? = nil, robotSize: CGFloat = 120) {
        
        
        self.imagePath = imagePath
        self.freeplayOutputView = freeplayOutputView
    
        self.project = project
        self.name = name
        self.coordinates = coordinates
        self.functionDict = [:]
        self.UUID = uuid ?? Foundation.UUID().uuidString
        self.robotSize = robotSize
        
        
        let image = UIImage(named: imagePath)
        if (image == nil) {
            print("Error: Couldn't create image in VirtualRobot class from image path: ", imagePath)
        }
        imageView = UIImageView(image: UIImage(named: imagePath))
        
        
        imageView.frame = CGRect(x: 0, y: 0, width: robotSize, height: robotSize)
        
        setCoordinates(x: self.coordinates.x, y: self.coordinates.y)
        
        functionDict = createFunctionDict()
        
    }
    
    init(imagePath: String, name: String, coordinates: (x: CGFloat, y: CGFloat) = (-10, -10), project: Project?, uuid: String? = nil, robotSize: CGFloat = 120) {
        
        self.imagePath = imagePath
        self.freeplayOutputView = nil
        self.project = project
        self.name = name
        self.coordinates = coordinates
        
        self.UUID = uuid ?? Foundation.UUID().uuidString
        self.robotSize = robotSize
        
        self.functionDict = [:]
        
        let image = UIImage(named: imagePath)
        if (image == nil) {
            print("Error: Couldn't create image in VirtualRobot class from image path: ", imagePath)
        }
        imageView = UIImageView(image: UIImage(named: imagePath))
        
        
        functionDict = createFunctionDict()
    }
    
    public func setActorSpeedByName(speedName: String) {
        print("setting \(name) speed to \(speedName)")
        switch speedName {
        case "Really Slow":
            movementAnimationSpeed = reallySlowAnimSpeed
        case "Slow":
            movementAnimationSpeed = slowAnimSpeed
        case "Normal":
            movementAnimationSpeed = normalAnimationSpeed
        case "Fast":
            movementAnimationSpeed = fastAnimSpeed
        case "Really Fast":
            movementAnimationSpeed = reallyFastAnimSpeed
        default:
            movementAnimationSpeed = normalAnimationSpeed
        }
    }
    
    public func setActorSize(size: CGFloat) {
        robotSize = size
        let x = imageView.frame.minX
        let y = imageView.frame.minY
        imageView.frame = CGRect(x: x, y: y, width: size, height: size)
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
    
    func addFreeplayOutputView(freeplayOutputView: FreeplayOutputView) {
        self.freeplayOutputView = freeplayOutputView
       
        
        imageView.frame = CGRect(x: 0, y: 0, width: robotSize, height: robotSize)
        
       
        setCoordinates(x: coordinates.x, y: coordinates.y)
       
      

    }
   
    
    func moveToOrigin(executingProgram: ExecutingProgram) {
        let currentX = coordinates.x
        let currentY = coordinates.y
        
        let backgroundCenterX =  freeplayOutputView!.frame.width / 2
        let backgroundCenterY =  freeplayOutputView!.frame.height / 2
        
        let animationDuration = VirtualRobot.calculateMovementDistance(startX: currentX, startY: currentY, endX: backgroundCenterX, endY: backgroundCenterY) / (movementAnimationSpeed * 2)
       
        animatedMoveToCoordinates(x: backgroundCenterX, y: backgroundCenterY, duration: animationDuration)
       
        executingProgram.finishCommand(withDuration: animationDuration) //TODO: block highlight is going away before movement is finished
        
    }
    
    public static func calculateMovementDistance(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) -> Double {
        return sqrt(pow((endX - startX),2) + pow( (endY - startY),2))
    }
    
    func moveToActor(actorUUID: String, executingProgram: ExecutingProgram) {
        if actorUUID == "" {
            fatalError("Error: move to actor failed. actorUUID was empty")
        }
        let actor = VirtualRobot.getActorFromUUID(actorUUID: actorUUID, inProject: project!)
        if actor != nil {
            let currentCoords = self.coordinates
            let newCoords = actor!.coordinates
            let distanceToMove = VirtualRobot.calculateMovementDistance(startX: currentCoords.x, startY: currentCoords.y, endX: newCoords.x, endY: newCoords.y)
            let animationDuration = distanceToMove / movementAnimationSpeed
            animatedMoveToCoordinates(x: newCoords.x, y: newCoords.y, duration: animationDuration)
            
            executingProgram.finishCommand(withDuration: animationDuration)
        }
       
    }
    
    func moveToLocation(coordinateString: String, executingProgram: ExecutingProgram) {
        let (x, y) = VirtualRobot.parseCoordinateString(coordinateString: coordinateString)
        
        // adjust coordinates for full screen if needed
        let adjustedX = x * horizontalDistanceMultiplier
        let adjustedY = y * verticalDistanceMultiplier

        let horizontalDistance = coordinates.x - adjustedX
        let verticalDistance = coordinates.y - adjustedY
        
        let distance = sqrt(pow(horizontalDistance, 2) + pow(verticalDistance, 2)) // pythagorean theorem
        
        let animationDuration = distance / movementAnimationSpeed
         
        animatedMoveToCoordinates(x: adjustedX, y: adjustedY, duration: animationDuration)
            
        executingProgram.finishCommand(withDuration: animationDuration)
        
        
    }
    
    public static func parseCoordinateString(coordinateString: String) -> (x: CGFloat, y: CGFloat) {
        let values = coordinateString.split(separator: ",")
        let x = Int(values[0]) ?? 0
        let y = Int(values[1]) ?? 0
        return (x: CGFloat(x), y: CGFloat(y))
    }


    public static func getActorFromUUID(actorUUID: String, inProject: Project) -> VirtualRobot?{
        for actor in inProject.actors {
            if actor.UUID == actorUUID {
                return actor
            }
        }
        return nil
    }
    
    /// if actorUUID string is empty, return either the second actor or the current actor
    public static func getActorFromUUIDOrDefault(actorUUID: String, inProject: Project) -> VirtualRobot?{
        if actorUUID == "" {
            for actor in inProject.actors {
                if actor != inProject.currentActor {
                    return actor // return any other actor than the current one
                }
            }
            return inProject.currentActor // if there are no other actors, just return the current one
        } else {
            return getActorFromUUID(actorUUID: actorUUID, inProject: inProject)
        }
       
    }
    
    func changeActorSize(amount: Int, growOrShrink: Int, executingProgram: ExecutingProgram) {
        
        
        let sizeInterval: CGFloat = 10
        let amountToChange = CGFloat(amount) * sizeInterval * CGFloat(growOrShrink)
        
        if robotSize + amountToChange > 0 && robotSize + amountToChange < (freeplayOutputView!.frame.height * 0.75) { //TODO: get as much bigger as possible, and do an indication that you can't go any bigger
            robotSize += amountToChange
            
            let animationDuration = CGFloat(amount) / movementAnimationSpeed * 10.0
            animatedSetSize(size: robotSize, duration: TimeInterval(animationDuration) )
            
            executingProgram.finishCommand(withDuration: animationDuration)
        } else {
            executingProgram.finishCommand() // don't shrink or grow if it will get too big or too small
        }
        
        
        
        
    }
    
    func animatedSetSize(size: CGFloat, duration: TimeInterval, delay: TimeInterval = 0) {
        // Animating while still being able to recognize being tapped is from Matt's answer on https://stackoverflow.com/questions/57032194/tapping-a-uiimage-while-its-being-animated
        let anim = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: .linear))
           anim.addAnimations {
               self.setActorSize(size: size)
               self.setToSavedCoordinates()
           }
        
        anim.startAnimation()
        
        
    }
    
    
    func playMove(distance: Double, xDirection: Int, yDirection: Int, executingProgram: ExecutingProgram) {
        var adjustedDistance = 0.0
        if xDirection != 0 {
            adjustedDistance = distance  * horizontalDistanceMultiplier
        }
        if yDirection != 0 {
            adjustedDistance = distance * verticalDistanceMultiplier
        }
        if (!checkWillCollide(distance: adjustedDistance, xDirection: xDirection, yDirection: yDirection, executingProgram: executingProgram)) {
            let animationDuration = adjustedDistance / movementAnimationSpeed
            // Code to animate UIImage is from Dharmesh Kheni's answer on:  https://stackoverflow.com/questions/32133056/how-can-i-move-an-image-in-swift
            let newX = coordinates.x + (adjustedDistance * CGFloat(xDirection))
            let newY = coordinates.y + (adjustedDistance * CGFloat(yDirection))
            
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
        let backgroundBottomY = freeplayOutputView!.frame.height
        let backgroundLeftX: CGFloat = 0
        let backgroundRightX = freeplayOutputView!.frame.width
        
        
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
    
    
    
    
    public func setCoordinates(x: CGFloat, y: CGFloat) {
        //print("setting coords to x = ", x, " y = ", y)
        if x == -10 && y == -10 {
            let outputWidth = freeplayOutputView!.frame.width
            let outputHeight = freeplayOutputView!.frame.height
            let imageWidth = imageView.frame.width
            let imageHeight = imageView.frame.height
            coordinates = (CGFloat.random(in: imageWidth..<outputWidth - imageWidth), CGFloat.random(in: imageHeight..<outputHeight - imageHeight))
        } else {
            coordinates = (x,y)
        }
        imageView.center.x = coordinates.x
        imageView.center.y =  coordinates.y
        
        freeplayOutputView!.bringSubviewToFront(imageView)
        
    }
    
    func animatedMoveToCoordinates(x: CGFloat, y: CGFloat, duration: TimeInterval, delay: TimeInterval = 0) {
        // Animating while still being able to recognize being tapped is from Matt's answer on https://stackoverflow.com/questions/57032194/tapping-a-uiimage-while-its-being-animated
        let anim = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: .linear))
           anim.addAnimations {
               self.imageView.center.x = x
               self.imageView.center.y = y
           }
       
        anim.startAnimation()

        
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
        } catch let error {
            print(error.localizedDescription)
        }
        
        executingProgram.finishCommand(withDuration: 1.5)
    }
   
}


