//
//  VirtualRobot.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/11/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import AVFAudio

/// Class to represent an actor/virtual robot for freeplay mode
class VirtualRobot: Equatable {
    static func == (lhs: VirtualRobot, rhs: VirtualRobot) -> Bool {
        return lhs.UUID == rhs.UUID // each virtual robot has a unique identifier. This eliminates issues with actors having the same name (ex. there might be a lot of "Red Cat" virtual robots
    }

    let baseImagePath: String // base part of the image path for the virtual robot (ex. "Cat" for "Cat_Default"
    var color: String // color of the virtual robot. Used to calculate the image path
    var imagePath: String // actual image path for the robot
    var imageView: UIImageView // image view for displaying the robot
    var freeplayOutputView: FreeplayOutputView? // output view that the image view is a child of
    var robotSize: CGFloat = 120 // current size of robot
    let defaultRobotSize: CGFloat = 120 // original size of robot
    var functionDict: [String : [Block]] // robot's blocks
    var name: String // name of robot
    var coordinates: (x: CGFloat, y: CGFloat) = (-10, -10) // center coordinates of robot image
    var rotationDegrees: CGFloat = 0 // Rotation of robot image in degrees
    var rotationRadians: CGFloat { // Rotation of robot image in radians. Calculated property
        get { return rotationDegrees * .pi / 180}
    }
    var project: Project? // project the robot is associated with
    var executingProgram: ExecutingProgram? = nil // executing program the robot is associated with
    var isRunning: Bool = false // whether or not this robot's blocks are running
    
    let UUID: String // Universally Unique Identifier used to compare Virtual Robots
    
    var audioPlayer: AVAudioPlayer?  // Used to play sound blocks
    var soundEffectAudioPlayer: AVAudioPlayer?  // Used to play sound effects like hitting walls
    
    // used during full screen
    var verticalDistanceMultiplier = 1.0
    var horizontalDistanceMultiplier = 1.0
    
    // animation speed constants
    let reallySlowAnimSpeed: CGFloat = 15
    let slowAnimSpeed: CGFloat = 30
    let normalAnimationSpeed: CGFloat = 60
    let fastAnimSpeed: CGFloat = 100
    let reallyFastAnimSpeed: CGFloat = 170
    var movementAnimationSpeed: CGFloat = 50 // The bigger the number, the faster the animation
    
    init(baseImagePath: String, color: String = "Default", freeplayOutputView: FreeplayOutputView? = nil, name: String = "Dash", coordinates: (x: CGFloat, y: CGFloat) = (-10, -10), rotationDegrees: CGFloat = 0, project: Project?, uuid: String? = nil, robotSize: CGFloat = 120) {
        
        self.freeplayOutputView = freeplayOutputView
       
        self.baseImagePath = baseImagePath
        self.color = color
        self.imagePath = "\(baseImagePath)_\(color)"
    
        self.project = project
        self.name = name
        self.coordinates = coordinates
        self.rotationDegrees = rotationDegrees
        self.functionDict = [:]
        self.UUID = uuid ?? Foundation.UUID().uuidString
        self.robotSize = robotSize
        
        let image = UIImage(named: imagePath)
        if (image == nil) {
            print("Error: Couldn't create image in VirtualRobot class from image path: ", imagePath)
        }
        imageView = UIImageView(image: UIImage(named: imagePath))
        
        functionDict = createFunctionDict()
        
        // Tap Gesture code from https://agrawalsuneet.medium.com/uiview-clicklistener-swift-88ab5dec64b5
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(clickOnActor(sender:)))
       
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        if freeplayOutputView != nil {
            addFreeplayOutputView(freeplayOutputView: freeplayOutputView!)
        }
    }
    
    // when an actor image view is clicked on, play its on tap code line and set it to be the current actor
    @objc func clickOnActor(sender : UITapGestureRecognizer) {
        freeplayOutputView?.freeplayWorkspaceVC?.updateCurrentActor(newActor: self)
        freeplayOutputView?.runOnTapCode(forActor: self)
    }
    
    // update the imageView to match the current imagePath
    public func updateImageView() {
        imageView = UIImageView(image: UIImage(named: imagePath))
    }
    
    /// Calculate the image path for a Virtual Robot based on the given base image path and color
    public static func calculateImagePath(baseImagePath: String, color: String) -> String{
        return "\(baseImagePath)_\(color)"
    }
    
    // Sets animation speed of robot. Controlled by speed blocks
    public func setActorSpeedByName(speedName: String) {
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
    
    func setUpAccessibility() {
        imageView.isUserInteractionEnabled = true
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "\(name.localized). \(color.localized) \(NSLocalizedString("Color", comment:"used in things like 'Red Color' or 'Default Color'")). \(calculateActorLocationStringForAccessibility())"
        imageView.accessibilityHint = NSLocalizedString("Double tap and hold to drag.", comment: "")
        imageView.accessibilityTraits = .button
    }
    
    /// Calculates a descriptive string of where a robot is within the scene
    func calculateActorLocationStringForAccessibility() -> String {
        if freeplayOutputView != nil {
            let outputWidth = freeplayOutputView!.frame.width
            let outputHeight = freeplayOutputView!.frame.height
            
            let x = coordinates.x
            let y = coordinates.y
            
            var accessibilityString = NSLocalizedString("Location is at", comment: "Beginning of description of where a virtual robot is located on the screen. Ex. Location is at left bottom of screen")
            // horizontal position
            if x <= outputWidth / 3 {
                // left third of screen
                accessibilityString.append(" " + NSLocalizedString("left", comment: "Left side of screen"))
            } else if x <= outputWidth * 2 / 3 {
                // middle third of screen (horizontally)
                accessibilityString.append(" " + NSLocalizedString("middle", comment: "middle of screen"))
            } else {
                // right third of screen
                accessibilityString.append(" " + NSLocalizedString("right", comment: "right side of screen"))
            }
            
            // vertical position
            if y <= outputHeight / 3 {
                // top third of screen
                accessibilityString.append(" " + NSLocalizedString("top", comment: "top of screen"))
            } else if y <= outputHeight * 2 / 3 {
                // middle third of screen (vertically)
                if !accessibilityString.contains("middle") {
                    // don't add middle to the string twice
                    accessibilityString.append(" " + NSLocalizedString("middle", comment: "middle of screen"))
                }
                
            } else {
                // bottom third of screen
                accessibilityString.append(" " + NSLocalizedString("bottom", comment: "bottom of screen"))
            }
            
            accessibilityString.append(" " + NSLocalizedString("of screen.", comment: "End of description of where a virtual robot is located on the screen. Ex. Location is at left bottom of screen"))
            return accessibilityString
        }
        
        return ""
    }
    
    public func setActorSize(size: CGFloat) {
        robotSize = size
        let x = imageView.frame.minX
        let y = imageView.frame.minY
        imageView.frame = CGRect(x: x, y: y, width: size, height: size)
    }
    
    /// Returns an basic function dict
    func createFunctionDict() -> [String: [Block]] {
        if project?.projectType == ProjectType.Freeplay {
            return [ON_RUN_STRING : [], ON_BUMP_STRING: [], ON_TAP_STRING: []]
        } else {
            return ["Main Workspace": []]
        }
    }
    
    // Assigns a project to the robot
    func setProject(project: Project) {
        self.project = project
        if functionDict.isEmpty {
            functionDict = createFunctionDict()
        }
    }
    
    // Assigns a freeplay output view to the robot and sets coordinates
    func addFreeplayOutputView(freeplayOutputView: FreeplayOutputView) {
        
        self.freeplayOutputView = freeplayOutputView
       
        imageView.frame = CGRect(x: 0, y: 0, width: robotSize, height: robotSize)
       
        setCoordinates(x: coordinates.x, y: coordinates.y)
    }
   
    /// Move to the center of the freeplay output view, animated, with sound
    func moveToOrigin(executingProgram: ExecutingProgram) {
        let currentX = coordinates.x
        let currentY = coordinates.y
        
        let backgroundCenterX =  freeplayOutputView!.frame.width / 2
        let backgroundCenterY =  freeplayOutputView!.frame.height / 2
        
        let animationDuration = VirtualRobot.calculateMovementDistance(startX: currentX, startY: currentY, endX: backgroundCenterX, endY: backgroundCenterY) / (movementAnimationSpeed * 2)
       
        animatedMoveToCoordinatesWithSound(x: backgroundCenterX, y: backgroundCenterY, duration: animationDuration)
       
        executingProgram.finishCommand(withDuration: animationDuration) //TODO: block highlight is going away before movement is finished
    }
    
    /// Distance formula
    public static func calculateMovementDistance(startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) -> Double {
        return sqrt(pow((endX - startX),2) + pow( (endY - startY),2))
    }
    
    /// Move this robot to the robot with the given actor UUID. Animated and with sound.
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
            animatedMoveToCoordinatesWithSound(x: newCoords.x, y: newCoords.y, duration: animationDuration)
            
            executingProgram.finishCommand(withDuration: animationDuration)
        }
    }
    
    // Move to given coordinate string, animated, with sound
    func moveToLocation(coordinateString: String, executingProgram: ExecutingProgram) {
        let (x, y) = VirtualRobot.parseCoordinateString(coordinateString: coordinateString)
        
        // adjust coordinates for full screen if needed
        let adjustedX = x * horizontalDistanceMultiplier
        let adjustedY = y * verticalDistanceMultiplier

        let horizontalDistance = coordinates.x - adjustedX
        let verticalDistance = coordinates.y - adjustedY
        
        let distance = sqrt(pow(horizontalDistance, 2) + pow(verticalDistance, 2)) // pythagorean theorem
        
        let animationDuration = distance / movementAnimationSpeed
         
        animatedMoveToCoordinatesWithSound(x: adjustedX, y: adjustedY, duration: animationDuration)
            
        executingProgram.finishCommand(withDuration: animationDuration)
    }
    
    // Takes a coordinate string and returns a tuple of CGFloat x and y coordinates
    public static func parseCoordinateString(coordinateString: String) -> (x: CGFloat, y: CGFloat) {
        let values = coordinateString.split(separator: ",")
        let x = Int(values[0]) ?? 0
        let y = Int(values[1]) ?? 0
        return (x: CGFloat(x), y: CGFloat(y))
    }

    // Given an actorUUID returns an actor from that project that has the same UUID or nil
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
    
    /// Change actor size by given amount. If growOrShrink = 1 the actor will grow. If growOrShrink = -1, the actor will shrink
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
    
    // Change size of robot to new size, animated
    func animatedSetSize(size: CGFloat, duration: TimeInterval, delay: TimeInterval = 0) {
        // Animating while still being able to recognize being tapped is from Matt's answer on https://stackoverflow.com/questions/57032194/tapping-a-uiimage-while-its-being-animated
        let anim = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: .linear))
           anim.addAnimations {
               self.setActorSize(size: size)
               self.setToSavedCoordinates()
           }
        
        anim.startAnimation()
    }
    
    // Play a horizontal or vertical move. Stops if it will collide with a wall
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
            
            animatedMoveToCoordinatesWithSound(x: newX, y: newY, duration: animationDuration)
            
            
            executingProgram.finishCommand(withDuration: animationDuration)
            
        }
        
    }
    // Returns true if a move will collide with a wall. If it is true, it will bump into the wall.
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
                
                animatedMoveToCoordinatesWithSound(x: coordinates.x, y: newY, duration: animationDuration)
                
                
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
                animatedMoveToCoordinatesWithSound(x: newX, y: coordinates.y, duration: animationDuration)
                
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
    
    // Play sound of hitting a wall for movement collisions
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
    
    // Move actor to coordinates that are saved to it
    public func setToSavedCoordinates() {
        setCoordinates(x: coordinates.x, y: coordinates.y)
    }
    
    // move (unanimated) robot to given coordinates and updates robot data. If coordinates are (-10,-10), sets it to a random position
    public func setCoordinates(x: CGFloat = -10, y: CGFloat = -10) {
        self.imageView.contentMode = .scaleAspectFit // Prevents image from being distorted when bounds change
        self.imageView.transform = .identity // Resets rotation to 0
        setActorSize(size: robotSize)
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
   
        self.imageView.transform = self.imageView.transform.rotated(by: rotationRadians) // Set actor rotation to saved rotation amount
    
        freeplayOutputView!.bringSubviewToFront(imageView)
    }
    
    func animatedMoveToCoordinatesWithSound(x: CGFloat, y: CGFloat, duration: TimeInterval, delay: TimeInterval = 0) {
        do {
            try playMovementSound(duration: duration, startX: coordinates.x, startY: coordinates.y, endX: x, endY: y)
        } catch let error {
            print("Error playing movement sound: \(error)")
        }
        // Animating while still being able to recognize being tapped is from Matt's answer on https://stackoverflow.com/questions/57032194/tapping-a-uiimage-while-its-being-animated
        let anim = UIViewPropertyAnimator(duration: duration, timingParameters: UICubicTimingParameters(animationCurve: .linear))
           anim.addAnimations {
               self.imageView.center.x = x
               self.imageView.center.y = y
           }
        anim.startAnimation()
        
        coordinates = (x,y)
    }
    
    // moves to given coordinates, animated. But without sound
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
    
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()
    var movementSoundAudioPlayer = AVAudioPlayerNode()
    
    /// Play movement beeping sound. Moving to the left is quieter, right is louder, up is higher pitch, and down is lower pitch.
    func playMovementSound(duration: TimeInterval, startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat) throws {
       
        
        let fileURL = URL(fileReferenceLiteralResourceName: "Movement1BeatLoop.mp3")
        let file = try AVAudioFile(forReading: fileURL) // load in the audio file
        
        // calculating the length of an audio file is from https://forums.developer.apple.com/forums/thread/722272
        let timeInBetween = (1 / file.processingFormat.sampleRate * Double(file.length)) + 0.05
        //print("time in between = ", timeInBetween)
        let numTimesToPlay = Int(Double(duration) / timeInBetween)
        
        let movementDistance = VirtualRobot.calculateMovementDistance(startX: startX, startY: startY, endX: endX, endY: endY)
       
        //speedControl.rate = 1.1
        if numTimesToPlay >= 1 {
            let currentYPosition = Float(self.imageView.center.y)
            let yDistanceFromCenter = Float(self.freeplayOutputView!.frame.height / 2) - currentYPosition
            let currentXPosition = Float(self.imageView.center.x)
            let xDistanceFromCenter = Float(self.freeplayOutputView!.frame.width / 2) - currentXPosition
            
            
            var timesPlayed = 0
            let amountYChangedEachFrame = CGFloat(Int(endY - startY) / (numTimesToPlay))
            let amountXChangedEachFrame = CGFloat(Int(endX - startX) / (numTimesToPlay))
            
          
            Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInBetween), repeats: true, block: { timer in
                if timesPlayed < numTimesToPlay {
                   
                    let currentYPosition = Float(startY + (amountYChangedEachFrame * CGFloat(timesPlayed)))
                    let yDistanceFromCenter = Float(self.freeplayOutputView!.frame.height / 2) - currentYPosition
                    self.pitchControl.pitch = yDistanceFromCenter * 3
                    
                    let currentXPosition = Float(startX + (amountXChangedEachFrame * CGFloat(timesPlayed)))
                    let xDistanceFromCenter = Float(self.freeplayOutputView!.frame.width / 2) - currentXPosition
                    let volume = (1 - xDistanceFromCenter / Float(self.freeplayOutputView!.frame.width / 2)) * 0.5
                    
                    self.movementSoundAudioPlayer.volume = volume
                    
                    do {
                        try self.playMovementOneBeat(file: file)
                    } catch let error {
                        print("Error playing movement sound:", error)
                    }
                    timesPlayed += 1
                } else {
                    timer.invalidate()
                }
            })
        }
    }
    
    func playMovementOneBeat(file: AVAudioFile) throws {
        // code for adjusting audio speed and pitch is from https://www.hackingwithswift.com/example-code/media/how-to-control-the-pitch-and-speed-of-audio-using-avaudioengine
        engine.stop()
        engine.reset()
      
        
        // connect audio player, pitch control, and speed control to the audio engine
        engine.attach(movementSoundAudioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        
        // arrange so the audio player feeds into speed control, which feeds into pitch control, which feeds into main mixer output, which plays aloud
        engine.connect(movementSoundAudioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        
        // prepare to start reading the file
        movementSoundAudioPlayer.scheduleFile(file, at: nil)
        
        
        // start engine and audio player
        try engine.start()
        movementSoundAudioPlayer.play()
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
        } else if abs(angleInRadians) < 2 * .pi{
            // if the angle is greater than 180 degrees, the turn has to be split up into two turns
            UIView.animate(withDuration: animationDuration / 2, delay: 0, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians / 2)
               }, completion: nil)
            UIView.animate(withDuration: animationDuration / 2, delay: animationDuration / 2, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians / 2)
               }, completion: nil)
        } else {
            // If the angle is 360 degrees, the turn has to be split up into three turns so that it goes the correction direction
            UIView.animate(withDuration: animationDuration / 3, delay: 0, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians / 3)
               }, completion: nil)
            UIView.animate(withDuration: animationDuration / 3, delay: animationDuration / 3, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians / 3)
               }, completion: nil)
          UIView.animate(withDuration: animationDuration / 3, delay: 2 * animationDuration / 3, options: .curveLinear, animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: angleInRadians / 3)
               }, completion: nil)
            
        }
        
        rotationDegrees = (rotationDegrees + angle).truncatingRemainder(dividingBy: 360) // Retain rotation amounts between sessions
        executingProgram.finishCommand(withDuration: animationDuration)
    }
    
    func playSound(soundName: String, executingProgram: ExecutingProgram) {
        // Play sound
        // Code to play audio is from https://www.tutorialspoint.com/how-to-play-a-sound-using-swift
        guard let path = Bundle.main.path(forResource: soundName, ofType:"mp3") else {
            print("Couldn't find sound file for", soundName)
            executingProgram.finishCommand(withDuration: 1.5)
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
    
    func playCustomSound(soundName: String, executingProgram: ExecutingProgram) {
       
        let url = project!.getAudioFileURL(forFileName: soundName)
        do {
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
           
            audioPlayer?.play()
            
        } catch let error {
            print(error.localizedDescription)
            
        }
        
        executingProgram.finishCommand(withDuration: audioPlayer?.duration ?? 1.5)
    }
   
}


