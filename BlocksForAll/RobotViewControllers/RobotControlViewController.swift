//
//  RobotControlViewController.swift
//  BlocksForAll
//  Parent Class for any ViewController that should control robot
//
//  Created by Lauren Milne on 4/26/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class RobotControlViewController: UIViewController, WWRobotObserver {
    
    var executingProgram: ExecutingProgram?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshConnectedRobots()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshConnectedRobots(){
        let connectedRobots = robotManager?.allConnectedRobots
        if connectedRobots != nil {
            for r in connectedRobots!{
                if let robot = r as? WWRobot{
                    robot.add(self)
                    robot.add(WWEventToolbelt.orientationShake())
                }
            }
        }
    }
    
    func robot(_ robot: WWRobot!, eventsTriggered events: [Any]!) {
        for event in events{
            if let e = event as? WWEvent{
                if e.isEqual(WWEventToolbelt.orientationShake()){
                    print("Robot is shaking!")
                }
            }
        }
    }
    
    func robot(_ robot: WWRobot!, didStopExecutingCommand sequence: WWCommandSetSequence!, withResults results: [AnyHashable : Any]!) {
        let connectedRobots = robotManager?.allConnectedRobots
        for _ in connectedRobots!{
            robot.resetState()
        }
    }
    
    func connectedRobots() -> Bool{
        if let connectedRobots = robotManager?.allConnectedRobots {
            return !connectedRobots.isEmpty
        } else {
            return false
        }
    }
    
    //this function allows the blocks in the workspace to be sent to the robot
    func play(functionsDictToPlay: [String : [Block]]){
        print("in play")
        let connectedRobots = robotManager?.allConnectedRobots
        if connectedRobots != nil{
            // var repeatCommands = [WWCommandSet]()
            executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay)
            //creates executing program
            executeNextCommandRobotControllVC()
            //makes initial executeNextCommandRobotControllVC call
            
            } else {
            print("no connected robots")
        }
    }
    
    
    
    func executeNextCommandRobotControllVC() {
        print("in poll for next commnad")
        guard let executingProgram = executingProgram else {
            return  // not running
        }
        guard !executingProgram.funcIsComplete else {
        //if command is running
            print("in if iscomplete")
            self.executingProgram = nil
            programHasCompleted()
            refreshScreen() // This unhighlights the final block in the workspace
            return  // no more commands left
        }
       
        // initial call of executeNextCommand on an executingProgram
        executingProgram.executeNextCommandExecProgram()
        refreshScreen() // refreshes any highlights on the blocks
        
    }

    func robot(_ robot: WWRobot!, didFinishCommand sequence: WWCommandSetSequence!) {
        // if there was a block that was just run, set its isRunning to false
        if executingProgram?.blockCurrentlyRunning != nil {
            executingProgram?.blockCurrentlyRunning!.isRunning = false
        }
        executeNextCommandRobotControllVC()
    }

    var isProgramComplete: Bool {
        print("in program is complete")
        return executingProgram?.funcIsComplete ?? true
    }
    
    func programHasCompleted() {
        // subclasses may override
    }
    
    func refreshScreen() {
        // subclasses may override
    }
}

class ExecutingProgram {
    var positions: [(funcName: String, position: Int)]
    // position used to find index of block in blocksToExec
    var functionsDictToExec: [String : [Block]]
    //all functions in program
    
    var currentFunction: String
    //currentWorkspace/function being read
    
    var blocksToExec: [Block]{
        return functionsDictToExec[currentFunction]!
    }
    var blockCurrentlyRunning: Block? = nil // the block from blocksToExec that is currently running
    //array blocks (blocksStack) to be executed by the executing program
    
    var repeatCountAndIndexArray: [(timesToR: Int, index: Int)] = []
    //an array of tuples, each tuple keeps track of the number of times left to repeat that repeat loop as well as the index of the start of the repeat loop
    var variablesDict: [String : Double] = [:]
    //variablesDict is used to keep track of the variables and their values, string is the name of the variable, double is the value of the variable
    var ifCondition: Bool = false
    
    init(functionsDictToExecute: [String:[Block]]) {
        self.functionsDictToExec = functionsDictToExecute
        // we can latter change this for functions so it takes a dictionary of names and blocksstacks to execute yada yada
        self.variablesDict["apple"] = 0.0
        self.variablesDict["banana"] = 0.0
        self.variablesDict["cherry"] = 0.0
        self.variablesDict["melon"] = 0.0
        self.variablesDict["orange"] = 0.0
        // initializes the variablesDictionary with the five variables we currently have in place and sets them to 0
        self.currentFunction = currentWorkspace
        //Either main workspace or a user-created function
        
        //self.blocksToExec = functionsDictToExec[currentFunction]!
        self.positions = [(currentFunction, 0)]
    }
    
    var funcIsComplete: Bool {
        if positions.count != 0{
            return positions[positions.count - 1].position >= blocksToExec.count
           
        } else {
            return true
        }
        //checks if position in blocksToExec is at end marks as complete used for preventing crashing out of index
    }
    
    var programIsComplete: Bool {
        return positions[0].position >= functionsDictToExec["Main Workspace"]!.count
    }
    
    func executeNextCommandExecProgram() {
        print("in execute nextcommand")
        guard !funcIsComplete else {
            return
        }
        // stops if completed
        
        var myAction = WWCommandSet()
        // set of commands to be executed

        let blockToExec = functionsDictToExec[positions[positions.count - 1].funcName]![(positions[positions.count - 1].position)]
        //the current block being check for executing it's from the [] of blocks that are being executed at the position value that we increment with this function (and repeat and if functions)
        
        print(blockToExec)
        // set the block that is being run .isRunning to true so that it gets highlighted
        blockToExec.isRunning = true
        blockCurrentlyRunning = blockToExec
        // Announce on VoiceOver that a block is being run
        UIAccessibility.post(notification: .announcement, argument: "\(blockToExec.name)")
        
        var duration = 2.0
        // default duration of any command
        
        let cmdToSend = WWCommandSetSequence()
        //an array of command sets to be sent, made of myAction type things
        
        switch blockToExec.name{
        //SOUNDS CATEGORY
            
            //TODO: test all sounds
        case "Animal Noise":
            let animal = blockToExec.addedBlocks[0].attributes["animalNoise"]
            
            switch animal {
            case "bee":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_BUZZ)
            case "cat":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_CAT)
            case "crocodile":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_CROCODILE)
            case "dinosaur":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_DINOSAUR)
            case "dog":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_DOG)
            case "elephant":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_ELEPHANT)
            case "goat":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_GOAT)
            case "horse":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_HORSE)
            case "lion":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_LION)
            case "turkey":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_GOBBLE)
            case "random animal":
                playNoise(myAction: myAction, sound: animalSoundFiles[.random(in: animalSoundFiles.indices)])
            default:
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_CAT)
            }
            
        case "Vehicle Noise":
            let vehicle = blockToExec.addedBlocks[0].attributes["vehicleNoise"]

            switch vehicle {
            case "airplane":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_AIRPLANE)
            case "beep":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_BEEP)
            case "boat":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_BOAT)
            case "helicopter":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_HELICOPTER)
            case "siren":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_SIREN)
            case "speed boost":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_SPEED_BOOST)
            case "start engine":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_ENGINE_REV)
            case "tire squeal":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_TIRE_SQUEAL)
            case "train":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_TRAIN)
            case "random vehicle":
                playNoise(myAction: myAction, sound: vehicleSoundFiles[.random(in: vehicleSoundFiles.indices)])
            default:
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_AIRPLANE)
            }
            
        case "Object Noise":
            let object = blockToExec.addedBlocks[0].attributes["objectNoise"]
            
            switch object {
            case "laser":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_LASERS)
            case "trumpet":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_TRUMPET)
            case "squeak":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_SQUEAK)
            case "random object":
                playNoise(myAction: myAction, sound: objectSoundFiles[.random(in: objectSoundFiles.indices)])
            default:
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_LASERS)
            }
            
        case "Emotion Noise":
            let emotion = blockToExec.addedBlocks[0].attributes["emotionNoise"]
            
            switch emotion {
            case "bragging":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_BRAGGING)
            case "confused":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_CONFUSED)
            case "giggle":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_GIGGLE)
            case "grunt":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_GRUNT)
            case "sigh":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_SIGH)
            case "surprised":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_SURPRISED)
            case "yawn":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_YAWN)
            case "random emotion":
                playNoise(myAction: myAction, sound: emotionSoundFiles[.random(in: emotionSoundFiles.indices)])
            case "snore":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_SNORING)
            default:
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_BRAGGING)
            }
            
        case "Speak":
            let word = blockToExec.addedBlocks[0].attributes["speak"]

            switch word {
            case "hi":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_HI)
            case "bye":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_BYE)
            case "cool":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_COOL)
            case "haha":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_HAHA)
            case "let's go":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_LETS_GO)
            case "oh":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_OOH)
            case "wow":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_WOW)
            case "tah dah!":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_TAH_DAH)
            case "uh huh":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_UH_HUH)
            case "uh oh":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_UH_OH)
            case "wah":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_WAH)
            case "wee hee!":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_WEEHEE)
            case "yippe!":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_YIPPE)
            case "wee":
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_WEE)
            case "random word":
                playNoise(myAction: myAction, sound: speakSoundFiles[.random(in: speakSoundFiles.indices)])
            default:
                playNoise(myAction: myAction, sound: WW_SOUNDFILE_HI)
            }
            
        //CONTROL CATEGORY
        case "If":
            // what the statement evaluates to
            let data = getSensorData()
            // what info we get from the robot
            if blockToExec.addedBlocks[0].attributes["booleanSelected"] == "Hear voice"{
            // check if the if statement is evaluating for a hear_voice
                if(!data.isEmpty){
                // if there is some data from the robot
                    if(data.count>5){
                        for n in 0...4 {
                            let micData: WWSensorMicrophone = data[n].sensor(for: WWComponentId(WW_SENSOR_MICROPHONE)) as! WWSensorMicrophone
                            print("amp: ", micData.amplitude, "direction: ", micData.triangulationAngle)
                            if(micData.amplitude > 0){
                                print("hear Voice true")
                                ifCondition = true
                                // if it does hear a voice, evaluate the if statement to true
                            } else {
                                ifCondition = false
                            }
                    }
                    }
                    else{
                            let micData: WWSensorMicrophone = data[0].sensor(for: WWComponentId(WW_SENSOR_MICROPHONE)) as! WWSensorMicrophone
                            print("amp: ", micData.amplitude, "direction: ", micData.triangulationAngle)
                            if(micData.amplitude > 0){
                                print("hear Voice true")
                                ifCondition = true
                            } else {
                                ifCondition = false
                            }
                    }
                }
//                    let micData: WWSensorMicrophone = data[0].sensor(for: WWComponentId(WW_SENSOR_MICROPHONE)) as! WWSensorMicrophone
//                    print("amp: ", micData.amplitude, "direction: ", micData.triangulationAngle)
//                    if(micData.amplitude > 0){
//                        print("hear Voice true")
//                        ifCondition = true
//                        // if it does hear a voice, evaluate the if statement to true
//                    }
                    // check if hearing voice, tbh not quite sure how this one works dash is rarely consistent with these if statements but the code is solid
            } else if blockToExec.addedBlocks[0].attributes["booleanSelected"] == "Obstacle sensed"{
            // check if the if statement is evaluating for a obstacle_sensed
                if(!data.isEmpty){
                // checks if there is data from the robot
                    let distanceDataFL: WWSensorDistance =  data[0].sensor(for: WWComponentId(WW_SENSOR_DISTANCE_FRONT_LEFT_FACING)) as! WWSensorDistance
                    let distanceDataFR: WWSensorDistance = data[0].sensor(for: WWComponentId(WW_SENSOR_DISTANCE_FRONT_RIGHT_FACING)) as! WWSensorDistance
                    print("distance: ", distanceDataFL.reflectance, distanceDataFR.reflectance)
                    print("checking for obstacle")
                    if(distanceDataFL.reflectance > 0.5 || distanceDataFR.reflectance > 0.5){
                        print("obstacle in front true")
                        ifCondition = true
                        // checks to see if there is a obstacle sensed, if so changes the condition, to evaluate true
                    } else {
                        ifCondition = false
                    }
                }
            }

            if(ifCondition){
                print("TRUE")
                //if it's true, just keep going
            
            }else{
                ifFalse()
                // run the ifFalse function, this is to skip over blocks that aren't supposed to be executed
            }
            print(ifCondition)
            
        case "Repeat":
            print("in Repeat")
            //repeatCountAndIndexArray keeps track of how many times to repeat which loop
            repeatCountAndIndexArray.append((timesToR: Int(blockToExec.addedBlocks[0].attributes["timesToRepeat"] ?? "0") ?? 0, index: (positions[positions.count - 1].position) ))
            // adds to repeatCountAndIndexArray the current blocks index and the value of howmany times it has left to repeat
            print(repeatCountAndIndexArray)
            
        case "End Repeat" :
            print("in End Repeat")
            //repeatCountAndIndexArray keeps track of how many times to repeat which loop
            repeatCountAndIndexArray[repeatCountAndIndexArray.count - 1].timesToR -= 1
            // end repeat get the last element in the array and tells it that it has repeated once by removing 1 from the timesToR(times left to repeat)
            if repeatCountAndIndexArray[repeatCountAndIndexArray.count - 1].timesToR == 0{
            // if the last index of the repeatCountAndIndexArray and if we're done repeating it and there are 0 timesToR(times left to repeat)
                repeatCountAndIndexArray.remove(at: (repeatCountAndIndexArray.count - 1) )
                // remove the tuple at the end of the array where the timesToR(times left to repeat) to repeat count is 0
            }else {
            // if the loop needs to be repeated it goes to the last index of repeatCountAndIndexArray so that you get to the innermost repeat loop
                positions[positions.count - 1].position = repeatCountAndIndexArray[(repeatCountAndIndexArray.count - 1)].index
                // change the position to the begining of the repeat loop
            }
            print(repeatCountAndIndexArray)
            
        case "Repeat Forever":
            print("in Repeat")
            //repeatCountAndIndexArray keeps track of how many times to repeat which loop
            repeatCountAndIndexArray.append((timesToR: 1, index: (positions[positions.count - 1].position) ))
            // adds to repeatCountAndIndexArray the current blocks index and the value of howmany times it has left to repeat
            print(repeatCountAndIndexArray)
            
        case "End Repeat Forever" :
            print("in End Repeat")
            positions[positions.count - 1].position = repeatCountAndIndexArray[(repeatCountAndIndexArray.count - 1)].index
            // change the position to the begining of the repeat loop
            print(repeatCountAndIndexArray)
            
            
        case "Wait for Time":
            myAction = playWait(waitBlock: blockToExec, cmdToSend: cmdToSend)
            duration = 0.1
            
        //DRIVE CATEGORY
        case "Drive Forward":
            //drive constant is positive because this is drive forward
            myAction = playDrive(driveBlock: blockToExec, driveConstant: 1.0, cmdToSend: cmdToSend)
            
        case "Drive Backward":
            //drive constant is negative because this is drive backward
            myAction = playDrive(driveBlock: blockToExec, driveConstant: -1.0, cmdToSend: cmdToSend)
            
            /* right now this code allows Dash to pivot from the wheel in the direction he is turning in (e.g. right turn, pivot on right wheel),
             if he needs to pivot from his head/center, then the direction he is turning in would need to be negative */
        case "Turn Left":
            myAction = playTurn(turnBlock: blockToExec, direction: 0, cmdToSend: cmdToSend)
           
            
        case "Turn Right":
            myAction = playTurn(turnBlock: blockToExec, direction:1, cmdToSend: cmdToSend)
            
        //LIGHTS CATEGORY
        //MARK: change this code and make is smoother once we have user input
        case "Set Eye Light":
            // Turn eye light off
            let value = blockToExec.addedBlocks[0].attributes["eyeLight"] ?? "Off"
            if value == "Off" {
                let eyeRing = WWCommandEyeRing()
                eyeRing.setAllBitmap(false)
                myAction.setEyeRing(eyeRing)
            } else {
                // Turn eye light on
                let eyeRing = WWCommandEyeRing()
                eyeRing.setAllBitmap(true)
                myAction.setEyeRing(eyeRing)
            }
        case "Play Spiral Light":
            // Turn spiral light on
            duration = 0.0
            playEyeLightSpiral(myAction: myAction, cmdSet: cmdToSend)
            
        case "Set Left Ear Light Color":
            let light = playLight(lightBlock: blockToExec)
            myAction.setLeftEarLight(light)
        case "Set Right Ear Light Color":
            let light = playLight(lightBlock: blockToExec)
            myAction.setRightEarLight(light)
            
        case "Set Front Light Color":
            let light = playLight(lightBlock: blockToExec)
            myAction.setChestLight(light)
            
        case "Set All Lights Color":
            let light = playLight(lightBlock: blockToExec)
            myAction.setEyeLight(light)
            myAction.setRightEarLight(light)
            myAction.setLeftEarLight(light)
            myAction.setChestLight(light)
            
            // Turn eye light off
            let value = blockToExec.addedBlocks[0].attributes["lightColor"] ?? "Off"
            if value == "Off" {
                let eyeRing = WWCommandEyeRing()
                eyeRing.setAllBitmap(false)
                myAction.setEyeRing(eyeRing)
            } else {
                // Turn eye light on
                let eyeRing = WWCommandEyeRing()
                eyeRing.setAllBitmap(true)
                myAction.setEyeRing(eyeRing)
            }
            
        //MOTION CATEGORY
        case "Wiggle":
            duration = 2.0
            let rotateLeft = WWCommandSet()
            rotateLeft.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -20.0, rightWheel: 20.0))
            let rotateRight = WWCommandSet()
            rotateRight.setBodyWheels(WWCommandBodyWheels.init(leftWheel: 20.0, rightWheel: -20.0))
            
            var wiggleIndex = 0
            while wiggleIndex < 2 {
                cmdToSend.add(rotateLeft, withDuration: duration)
                cmdToSend.add(rotateRight, withDuration: duration)
                wiggleIndex += 1
            }
            myAction = WWCommandToolbelt.moveStop()
            wiggleIndex = 0
            
        case "Nod":
            let lookup = WWCommandSet()
            lookup.setHeadPositionTilt(WWCommandHeadPosition.init(degree: -30))
            let lookdown = WWCommandSet()
            lookdown.setHeadPositionTilt(WWCommandHeadPosition.init(degree:30))
            duration = 1.0
            var nodIndex = 0
            while nodIndex < 1 {
                cmdToSend.add(lookup, withDuration:duration)
                cmdToSend.add(lookdown, withDuration:duration)
                nodIndex += 1
            }
            myAction = WWCommandToolbelt.moveStop()
            nodIndex = 0
            
        //LOOK CATEGORY
        case "Look Up":
            let lookup = WWCommandSet()
            lookup.setHeadPositionTilt(WWCommandHeadPosition.init(degree: -30))
            duration = 0.3
            cmdToSend.add(lookup, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
        case "Look Down":
            let lookdown = WWCommandSet()
            lookdown.setHeadPositionTilt(WWCommandHeadPosition.init(degree:30))
            duration = 0.3
            cmdToSend.add(lookdown, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
        case "Look Left":
            let lookleft = WWCommandSet()
            lookleft.setHeadPositionPan(WWCommandHeadPosition.init(degree: 60))
            duration = 0.3
            cmdToSend.add(lookleft, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
        case "Look Right":
            let lookright = WWCommandSet()
            lookright.setHeadPositionPan(WWCommandHeadPosition.init(degree: -60))
            duration = 0.3
            cmdToSend.add(lookright, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
        case "Look Forward":
            let lookforward = WWCommandSet()
            lookforward.setHeadPositionTilt(WWCommandHeadPosition.init(degree:0), pan: WWCommandHeadPosition.init(degree:0))
            duration = 0.3
            cmdToSend.add(lookforward, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
        //VARIABLES CATEGORY
        case "Set Variable":
            variablesDict[ blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] = Double(blockToExec.addedBlocks[0].attributes["variableValue"] ?? "0.0") ?? 0.0
            //assigns the variable value from current block attributes to the variables dict in executing program
            print("set variable, variablesDict:", variablesDict)
            
            
        case "Drive":
            var driveConstant = variablesDict[blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0.0
            // gets distance by getting the block, getting its added block, getting the block attribute for variable selected then taking that variable and running it through variablesDict to get it's current value and set that to the distance, defualt orange and 0.0
            if driveConstant > 0.0 {
                driveConstant = 1.0
            } else if driveConstant < 0.0 {
                driveConstant = -1.0
            } else {
                driveConstant = 0
            }
            // if the variable value is positive then set the drive constant to go forward, if negative set it to go backwards, the distance value for the drive will be gathered the same way as the driveconstant was initialized and that's handled in the playDrive function
            print("in Drive, driveConstant", driveConstant)
            myAction = playDrive(driveBlock: blockToExec, driveConstant: driveConstant, cmdToSend: cmdToSend)
            
        case "Turn":
            var direction = variablesDict[blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0
            // gets direction by getting the block, getting its added block, getting the block attribute for variable selected then taking that variable and running it through variablesDict to get it's current value and set that to the direction, defualt orange and 0.0
            if direction > 0 {
                direction = 1
            } else {
                direction = 0
            }
            // if postive turn clockwise, else counter clockwise(might have that mixed up)
            print("in Turn, direction", direction)
            myAction = playTurn(turnBlock: blockToExec, direction: Double(direction), cmdToSend: cmdToSend)
        
        case "Look Up or Down":
            let lookUpOrDown = WWCommandSet()
            let degree = variablesDict[blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0
            lookUpOrDown.setHeadPositionTilt(WWCommandHeadPosition.init(degree: degree))
            // should be .initWithDegree, but for some reason that doesn't work, may need to be in radians
            //Negative command values represent left (horizontal) or up (vertical). Positive command values represents right (horizontally) or down (vertically).
            // ranges from  -20 to 7.5
            duration = 0.3
            cmdToSend.add(lookUpOrDown, withDuration: duration)
            myAction = WWCommandToolbelt.moveStop()
            print("lookUpOrDown, degree", degree)
            
            
        case "Look Left or Right":
            let lookLeftOrRight = WWCommandSet()
            let degree = variablesDict[blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0
            lookLeftOrRight.setHeadPositionPan(WWCommandHeadPosition.init(degree: degree))
            // should be .initWithDegree, but for some reason that doesn't work, may need to be in radians
            //Negative command values represent left (horizontal) or up (vertical). Positive command values represents right (horizontally) or down (vertically).
            //-120.0 to 120.0
            duration = 0.3
            cmdToSend.add(lookLeftOrRight, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            print("lookUpOrDown, degree", degree)
            
        // not best way but using default for Functions
        default:
            if blockToExec.type == "Function" {
                currentFunction = blockToExec.name
                // changes current function to the function being called
                positions.append((funcName: currentFunction, position: -1))
                // adds this call of the function to the positions array of tuples so that executing current function knows where to start, -1 value is because beneth here the position value is increased this lets the next block start at an index of 0
                print("in function")
            } else {
                print("There is no command")
            }
        }
        
        cmdToSend.add(myAction, withDuration: duration)
        // and command set myAction set by cases above to cmdToSend which a sequence of command sets
        print(cmdToSend)
        sendCommandSequenceToRobots(cmdSeq: cmdToSend)
        positions[positions.count - 1].position += 1
        // increase the position so that the blockToExec is updated to the next block in the block stack
        
        if positions[positions.count - 1].position == functionsDictToExec[positions[positions.count - 1].funcName]?.count{
            //checks to see if the function is completed
            positions.removeLast()
            // remove the function from position list
            if positions.count != 0{
                // if the main workspace isn't finished then set the current worksapce to the latests one in position
                currentFunction = positions[positions.count - 1].funcName
                positions[positions.count - 1].position += 1
            }
            print("current function:", currentFunction)
        }
    }

    func playEyeLightSpiral(myAction: WWCommandSet, cmdSet: WWCommandSetSequence) {
        let spiralDuration = 0.04
        Timer.scheduledTimer(timeInterval: spiralDuration, target: self, selector: #selector(eyeLightTimerFire(timer:)),  userInfo: [myAction, cmdSet, spiralDuration] as [Any] , repeats: true)
    }
    
    var currentSpiralLightIndex = 0 // the current single light that should be turned on
    var numberOfTimesSpun = 0 // number of times the eyeLightTimer has been fired
    @objc func eyeLightTimerFire(timer: Timer!) {
        // These two lines make the spiral consist of two adjacent lights
        let currentLightIndex = (currentSpiralLightIndex % 11) + 1
        let nextLightIndex = (currentLightIndex + 1) % 11
        // Update currentSpiralLightIndex
        currentSpiralLightIndex = currentLightIndex
        
        let eyeRing = WWCommandEyeRing()
        eyeRing.setAllBitmap(false) // Turn off all lights
        // Turn on two of the lights
        eyeRing.setLEDValue(true, at: UInt(currentLightIndex))
        eyeRing.setLEDValue(true, at: UInt(nextLightIndex))
        
        let userInfo = timer.userInfo as! NSArray
        let myAction = userInfo[0] as! WWCommandSet
        let cmdToSend = userInfo[1] as! WWCommandSetSequence
        let spiralDuration = userInfo[2] as! Double
        myAction.setEyeRing(eyeRing)
        
        // Send the command to turn on the lights
        cmdToSend.add(myAction, withDuration: spiralDuration)
        sendCommandSequenceToRobots(cmdSeq: cmdToSend)
        numberOfTimesSpun += 1
        
        let desiredFullRevolutions = 5
        // End the spinning
        if numberOfTimesSpun == (12 * desiredFullRevolutions) {
            timer.invalidate()
            // Turn all lights back on
            eyeRing.setAllBitmap(true)
            myAction.setEyeRing(eyeRing)
            cmdToSend.add(myAction, withDuration: spiralDuration)
            sendCommandSequenceToRobots(cmdSeq: cmdToSend)
        }
    }
  
    func ifFalse(){
        // used to skip over blocks inside an IF statement if the IF statement returns false
        print("ifFalse Entered")
        var openIfs = 1
        // number of open ifs to skip if the prior if is false
        while openIfs > 0 {
            positions[positions.count - 1].position += 1
            //moves through the block stack by upping the position, if the position results in something related to ifs drop or add the number of open ifs until you wind up with 0 open ifs then the position should be correct to continue executing
            if blocksToExec[(positions[positions.count - 1].position)].name == "End If" {
                openIfs = 0
            }
            else if ((blocksToExec[(positions[positions.count - 1].position)].name == "IfObstacle in front") || (blocksToExec[(positions[positions.count - 1].position)].name == "IfHear Voice")) {
                openIfs += 1
            }
        }
    }

    //decomposition of all actions that have to do with sound/noise
    func playNoise (myAction: WWCommandSet, sound: String){
        let speaker = WWCommandSpeaker.init(defaultSound: sound)
        myAction.setSound(speaker)
    }
    
    func playWait(waitBlock: Block, cmdToSend: WWCommandSetSequence) -> WWCommandSet {
        var wait = 0.0
        wait = Double(waitBlock.addedBlocks[0].attributes["wait"] ?? "0") ?? 0
        let waitingPeriod = WWCommandSet()
        print("waiting", wait)
        cmdToSend.add(waitingPeriod, withDuration: wait)
        return WWCommandToolbelt.moveStop()
    }

    
    //decomposition of drive functions
    func playDrive (driveBlock: Block, driveConstant: Double,  cmdToSend: WWCommandSetSequence) -> WWCommandSet {
        var distance = 0.0
        var robotSpeed = 0.0
        var speed: String
        //used for cases since speed has 6 set speeds
        var driveDirection = driveConstant
        // drive constant choose direction 1.0 for forwards, -1.0 for backwards
        speed = driveBlock.addedBlocks[0].attributes["speed"] ?? "Normal"
        if driveBlock.name == "Drive"{
            // block named Drive rather than Drive Forward or Drive Backward, Drive is for variables
            distance = variablesDict[driveBlock.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0.0
            // gets distance by getting the block, getting its added block, getting the block attribute for variable selected then taking that variable and running it through variablesDict to get it's current value and set that to the distance, defualt orange and 0.0
            if distance > 0{
                driveDirection = 1.0
            } else if distance < 0{
                distance = distance * -1
                driveDirection = -1.0
            }
            // sets up negative distance values to result in a backwards drive constant
            switch speed {
            case "Really Fast":
                robotSpeed = 50.0
            case "Fast":
                robotSpeed = 40.0
            case "Normal":
                robotSpeed = 30.0
            case "Slow":
                robotSpeed = 10.0
            case "Really Slow":
                robotSpeed = 5.0
            default:
                robotSpeed = 30.0
            }
            // speed cases
            print("Drive variable, robot speed, distance", robotSpeed, " , ", distance)
        } else {
            distance = Double(driveBlock.addedBlocks[0].attributes["distance"] ?? "30") ?? 30
            // gets speed an distance from the added block
            switch speed {
            case "Really Fast":
                robotSpeed = 50.0
            case "Fast":
                robotSpeed = 40.0
            case "Normal":
                robotSpeed = 30.0
            case "Slow":
                robotSpeed = 10.0
            case "Really Slow":
                robotSpeed = 5.0
            default:
                robotSpeed = 30.0
            }
            // speed cases
        }
        let setAngular = WWCommandBodyLinearAngular(linear: ((driveDirection) * robotSpeed), angular: 0)
        //linear velocity is the speed times the direction, aka speed times the positive forward or negative backwards, 0 angular momentum so no turning
        let drive = WWCommandSet()
        drive.setBodyLinearAngular(setAngular)
        /*by multiplying (distance/robotSpped) by 1.25, the time needed to start and stop Dash is taken into account, and he more or less travels the
         distance he needs to in the right time. However he travels a little too far on the really slow speed. */
        // this needs fine tuning, generally works fine, but probably a better way to account for this
        // really need internal API from wonderworkshop to make this work
        var durationModifier = 1.25
        if distance > 89{
            durationModifier = 1.05
        } else if distance > 59{
            durationModifier = 1.1
        }
        cmdToSend.add(drive, withDuration: (distance/robotSpeed) * durationModifier)
        return WWCommandToolbelt.moveStop()
    }
    
    // MARK: decomposition of turn functions
    func playTurn (turnBlock: Block, direction: Double, cmdToSend: WWCommandSetSequence)-> WWCommandSet {
        var angleToTurn: Double = 90
        //matches defualt displayed angle
        if turnBlock.name == "Turn"{
        //name of variable turn block is "Turn"
            angleToTurn = variablesDict[turnBlock.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0.0
            //get the variable selected value for the turn block, go through added and get the added block atttribues, default orange, default 0 degrees
            if angleToTurn > 0{
                // if angle to turn is positve turn clockwise
                let setAngular = WWCommandBodyLinearAngular(linear: 0 , angular: -1.570795)
                // 0 linear velocity in cm/s then angular is pi for 1/2, tau for 1 a revolution in one second, that's too fast to be accuturate so doing 1/4 tau for quater turn per second, -value for a clockwise direction
                let turn = WWCommandSet()
                turn.setBodyLinearAngular(setAngular)
                cmdToSend.add(turn, withDuration: (angleToTurn/90))
                //duration is cut to time basesd of of angular momentum right now 90 because the velocity is 1/4 turn(90degrees) a second
            } else {
                // if angle to turn is negative turn counter clockwise
                let setAngular = WWCommandBodyLinearAngular(linear: 0 , angular: 1.570795)
                // 0 linear velocity in cm/s then angular is pi for 1/2, tau for 1 a revolution in one second, that's too fast to be accuturate so doing 1/4 tau for quater turn per second, +value for a counterclockwise direction
                let turn = WWCommandSet()
                turn.setBodyLinearAngular(setAngular)
                cmdToSend.add(turn, withDuration: ((angleToTurn/90) * -1))
                //duration is cut to time basesd of of angular momentum right now 90 because the velocity is 1/4 turn(90degrees) a second angle to turn is a negative value(which this else statement is for) change the angle to turn to a postive value to calculate duration better
            }
        } else if turnBlock.name.contains("Turn Left") {
            angleToTurn = Double(turnBlock.addedBlocks[0].attributes["angle"] ?? "90") ?? 90
            // go through added block to find the attribute angle
            let setAngular = WWCommandBodyLinearAngular(linear: 0 , angular: 1.570795)
            //0 linear velocity in cm/s then angular is pi for 1/2, tau for 1 a revolution in one second, that's too fast to be accuturate so doing 1/4 tau for quater turn per second, +value for a counterclockwise direction
            let turn = WWCommandSet()
            turn.setBodyLinearAngular(setAngular)
            cmdToSend.add(turn, withDuration: (angleToTurn/90))
            //duration is cut to time basesd of of angular momentum right now 90 because the velocity is 1/4 turn(90degrees) a second
        } else if turnBlock.name.contains("Turn Right") {
            angleToTurn = Double(turnBlock.addedBlocks[0].attributes["angle"] ?? "90") ?? 90
            let setAngular = WWCommandBodyLinearAngular(linear: 0 , angular: -1.570795)
            // 0 linear velocity in cm/s then angular is pi for 1/2, tau for 1 a revolution in one second, that's too fast to be accuturate so doing 1/4 tau for quater turn per second, -value for a clockwise direction
            let turn = WWCommandSet()
            turn.setBodyLinearAngular(setAngular)
            cmdToSend.add(turn, withDuration: (angleToTurn/90))
            //duration is cut to time basesd of of angular momentum right now 90 because the velocity is 1/4 turn(90degrees) a second
        }
        var waitAdd = 0.0
        // variable used for fine tuning duration of commands for accurate turning
        if angleToTurn > 314{
            waitAdd = 0.1
        }
        // use this for fine turning
//        if angleToTurn <= 45{
//            waitAdd = -0.01
//        } else if angleToTurn <= 90{
//            waitAdd = 0.0
//        } else if angleToTurn <= 135{
//            waitAdd = 0.01
//        } else if angleToTurn <= 180{
//            waitAdd = 0.02
//        } else if angleToTurn <= 225{
//            waitAdd = 0.03
//        } else if angleToTurn <= 270{
//            waitAdd = 0.04
//        } else if angleToTurn <= 225{
//            waitAdd = 0.05
//        } else if angleToTurn <= 315{
//            waitAdd = 0.06
//        }  else if angleToTurn <= 360{
//            waitAdd = 0.07
//        }
        let wait = (0.75 + waitAdd)
        // need to wait 1.0 seconds then add a value for fine tuneing
        let waitingPeriod = WWCommandSet()
        cmdToSend.add(waitingPeriod, withDuration: wait)
        //send a wait command so that the stop command below doesn't interupt the turn
        // there's got to be a better way but this works for now, sorry goodluck! -Mariella
        return WWCommandToolbelt.moveStop()
    }

    
    //decomposition of light functions
    func playLight (lightBlock: Block) -> WWCommandLightRGB {
        let color = lightBlock.addedBlocks[0].attributes["lightColor"] ?? "white"
        var selectedColor = WWCommandLightRGB.init(red: 0.9, green: 0.9, blue: 0.9)
        switch color {
        case "Off": // this used to be black, but black lights do not exist, it is just turning the light off
            selectedColor = WWCommandLightRGB.init(red: 0, green: 0, blue: 0)
        case "white":
            selectedColor = WWCommandLightRGB.init(red: 0.9, green: 0.9, blue: 0.9)
        case "red":
            selectedColor = WWCommandLightRGB.init(red: 0.9, green: 0, blue: 0)
        case "green":
            selectedColor = WWCommandLightRGB.init(red: 0, green: 0.9, blue: 0)
        case "blue":
            selectedColor = WWCommandLightRGB.init(red: 0, green: 0, blue: 0.9)
        case "orange":
            selectedColor = WWCommandLightRGB.init(red: 0.9, green: 0.2, blue: 0)
        case "yellow":
            selectedColor = WWCommandLightRGB.init(red: 0.9, green: 0.9, blue: 0)
        case "purple":
            selectedColor = WWCommandLightRGB.init(red: 75, green: 0, blue: 130)
        default:
            selectedColor = WWCommandLightRGB.init(red: 0.9, green: 0.9, blue: 0.9)
        }
        return selectedColor!
    }

    func getSensorData() -> [WWSensorSet] {
        var sensorSet: [WWSensorSet] = []
        let connectedRobots = robotManager?.allConnectedRobots
        for r in connectedRobots!{
            if let robot = r as? WWRobot{
                sensorSet.append(robot.history.currentState())
            }
        }
        //return sensorSet as! [WWSensorSet]
        return sensorSet
    }

    func sendCommandSequenceToRobots(cmdSeq: WWCommandSetSequence) {
        let connectedRobots = robotManager?.allConnectedRobots
        for r in connectedRobots!{
            if let robot = r as? WWRobot{
                robot.executeCommand(cmdSeq, withOptions: nil)
            }
        }
    }

    let animalSoundFiles =
        [WW_SOUNDFILE_CAT,
         WW_SOUNDFILE_CROCODILE,
         WW_SOUNDFILE_DINOSAUR,
         WW_SOUNDFILE_DOG,
         WW_SOUNDFILE_ELEPHANT,
         WW_SOUNDFILE_GOAT,
         WW_SOUNDFILE_HORSE,
         WW_SOUNDFILE_LION,
         WW_SOUNDFILE_GOBBLE,
         WW_SOUNDFILE_BUZZ]
    
    let vehicleSoundFiles =
        [WW_SOUNDFILE_AIRPLANE,
         WW_SOUNDFILE_BEEP,
         WW_SOUNDFILE_BOAT,
         WW_SOUNDFILE_HELICOPTER,
         WW_SOUNDFILE_SIREN,
         WW_SOUNDFILE_SPEED_BOOST,
         WW_SOUNDFILE_ENGINE_REV,
         WW_SOUNDFILE_TIRE_SQUEAL,
         WW_SOUNDFILE_TRAIN]
    
    let objectSoundFiles =
        [WW_SOUNDFILE_LASERS,
         WW_SOUNDFILE_TRUMPET,
         WW_SOUNDFILE_SQUEAK]
    
    let emotionSoundFiles =
        [WW_SOUNDFILE_BRAGGING,
         WW_SOUNDFILE_CONFUSED,
         WW_SOUNDFILE_GIGGLE,
         WW_SOUNDFILE_GRUNT,
         WW_SOUNDFILE_SIGH,
         WW_SOUNDFILE_SURPRISED,
         WW_SOUNDFILE_YAWN,
         WW_SOUNDFILE_SNORING]
    
    let speakSoundFiles =
        [WW_SOUNDFILE_HI,
         WW_SOUNDFILE_BYE,
         WW_SOUNDFILE_COOL,
         WW_SOUNDFILE_HAHA,
         WW_SOUNDFILE_LETS_GO,
         WW_SOUNDFILE_OOH,
         WW_SOUNDFILE_WOW,
         WW_SOUNDFILE_TAH_DAH,
         WW_SOUNDFILE_UH_HUH,
         WW_SOUNDFILE_UH_OH,
         WW_SOUNDFILE_WAH,
         WW_SOUNDFILE_WEEHEE,
         WW_SOUNDFILE_YIPPE]
}
