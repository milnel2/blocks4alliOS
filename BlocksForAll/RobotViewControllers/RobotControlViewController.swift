//
//  RobotControlViewController.swift
//  BlocksForAll
//  Parent Class for any ViewController that should control robot
//
//  Created by Lauren Milne on 4/26/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

// Core Bluetooth functionality based on : https://www.maissan.net/articles/dash-and-dot and https://github.com/vdwel/RobotControl/tree/master

import UIKit
import CoreBluetooth

class RobotControlViewController: UIViewController, CBPeripheralDelegate {
    var executingProgram: ExecutingProgram?
    
    var blocksViewController: BlocksViewController?

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
        // TODO: implement
//        let connectedRobots = robotManager?.allConnectedRobots
//        if connectedRobots != nil {
//            for r in connectedRobots!{
//                if let robot = r as? WWRobot{
//                    robot.add(self)
//                    robot.add(WWEventToolbelt.orientationShake())
//                }
//            }
//        }
    }
    
    
    func areRobotsConnected() -> Bool{
        return !connectedRobots.isEmpty
    }
    
    //this function allows the blocks in the workspace to be sent to the robot
    func play(functionsDictToPlay: [String : [Block]], functionNameToExecute: String? = nil, actor: VirtualRobot? = nil){
        print("in play")
       
        if areRobotsConnected() {
            for robot in connectedRobots {
                robot.peripheral.setNotifyValue(true, for: robot.dashSensorCharacteristic2!)
               robot.peripheral.setNotifyValue(true, for: robot.dashSensorCharacteristic1!)
                robot.peripheral.setNotifyValue(true, for: robot.dashInfoCharacteristic!)
            }
            
            
            executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay, robotControlViewController: self)
            //creates executing program
            executeNextCommandRobotControllVC()
            //makes initial executeNextCommandRobotControllVC call
            } else {
        }
    }
    
    func executeNextCommandRobotControllVC() {
        print("in poll for next commnad")
        guard let executingProgram = executingProgram else {
            print ("Error in executing command: executing program does not exist")
            return  // not running
        }
        guard !executingProgram.funcIsComplete else {
        //if command is running
            programHasCompleted()
            refreshScreen() // This unhighlights the final block in the workspace
            return  // no more commands left
        }
       
        // initial call of executeNextCommand on an executingProgram
        executingProgram.executeNextCommandExecProgram()
        refreshScreen() // refreshes any highlights on the blocks
        
    }
    
    func finishedCommand() {
        // if there was a block that was just run, set its isRunning to false
        if executingProgram?.blockCurrentlyRunning != nil {
            executingProgram?.blockCurrentlyRunning!.isRunning = false
        }
        executeNextCommandRobotControllVC()
    }

    var isProgramComplete: Bool {
        return executingProgram?.funcIsComplete ?? true
    }
    
    func programHasCompleted() {
        // subclasses may override
        var allActorsComplete = true
        for actor in UserData.data.getCurrentProject()!.actors {
            if !(actor.executingProgram?.funcIsComplete ?? true) {
                allActorsComplete = false
            }
        }
        if allActorsComplete {
            print("setting executing program stop was pressed to true because all actors are complete")
            self.executingProgram?.stopWasPressed = true
            //self.executingProgram = nil
            blocksViewController?.programHasCompleted()
    
            for workspace in executingProgram!.functionsDictToExec.keys { // remove highlight from all blocks
                for block in executingProgram!.functionsDictToExec[workspace]! {
                    block.isRunning = false
                }
            }
            
            
            refreshScreen() //TODO: if moving from full screen to regular while program is running, block highlight doesn't go away
            
        } else {
            print("not all actors are done")
        }
       
        
    }
    
    func refreshScreen() {
        // subclasses may override
        
        if blocksViewController != nil {
            blocksViewController!.refreshScreen()
        }
       
    }
}

class ExecutingProgram {
    
    
    var currentActor: VirtualRobot? = nil
    
    var positions: [(funcName: String, position: Int)]
    // position used to find index of block in blocksToExec
    var functionsDictToExec: [String : [Block]]
    //all functions in program
    
    var robotControlViewController: RobotControlViewController
    
    var currentFunction: String
    //currentWorkspace/function being read
    
    var blocksToExec: [Block]{     //array blocks (blocksStack) to be executed by the executing program
        return functionsDictToExec[currentFunction]!
    }
    var blockCurrentlyRunning: Block? = nil // the block from blocksToExec that is currently running
    var blockRunningTimer: Timer = Timer()// Timer used for finishCommand() to time how long a block should run for
    var repeatCountAndIndexArray: [(timesToR: Int, index: Int)] = []
    //an array of tuples, each tuple keeps track of the number of times left to repeat that repeat loop as well as the index of the start of the repeat loop
    var variablesDict: [String : Double] = [:]
    //variablesDict is used to keep track of the variables and their values, string is the name of the variable, double is the value of the variable
    var ifCondition: Bool = false
    
    init(functionsDictToExecute: [String:[Block]], robotControlViewController: RobotControlViewController, functionNameToExecute: String? = nil, actor: VirtualRobot? = nil) {
        self.functionsDictToExec = functionsDictToExecute
        // we can latter change this for functions so it takes a dictionary of names and blocksstacks to execute yada yada
        self.variablesDict["apple"] = 0.0
        self.variablesDict["banana"] = 0.0
        self.variablesDict["cherry"] = 0.0
        self.variablesDict["melon"] = 0.0
        self.variablesDict["orange"] = 0.0
        // initializes the variablesDictionary with the five variables we currently have in place and sets them to 0
        self.currentFunction = functionNameToExecute ?? currentWorkspace
        //Either main workspace or a user-created function
        
        //self.blocksToExec = functionsDictToExec[currentFunction]!
        self.positions = [(currentFunction, 0)]
        
        
        self.robotControlViewController = robotControlViewController
        self.currentActor = actor
        
        self.stopWasPressed = false
    }
    var stopWasPressed: Bool
    
    var funcIsComplete: Bool {
        if positions.count != 0{
            if stopWasPressed { // if stop was pressed, force a stop
                return true
            }
            return positions[positions.count - 1].position >= blocksToExec.count
           
        } else {
            return true
        }
        //checks if position in blocksToExec is at end marks as complete used for preventing crashing out of index
    }
    
   
    
    var programIsComplete: Bool {
        return positions[0].position >= functionsDictToExec["Main Workspace"]!.count
    }
    
    func insertBlock(blockToExec: Block? = nil, blockToExecName: String) {
        if !positions.isEmpty {
            positions[positions.count - 1].position -= 1 // back up the current function position by one so that it doesn't skip over anything
        }
        
        currentFunction = blockToExec?.name ?? blockToExecName
        // changes current function to the function being called
        
        positions.append((funcName: currentFunction, position: 0))
    }
    
    func executeNextCommandExecProgram() {
        guard !funcIsComplete else {
            robotControlViewController.programHasCompleted()
            return
        }
        // stops if completed
        
        
        let blockToExec = functionsDictToExec[positions[positions.count - 1].funcName]![(positions[positions.count - 1].position)]
        //the current block being check for executing it's from the [] of blocks that are being executed at the position value that we increment with this function (and repeat and if functions)
        // set the block that is being run .isRunning to true so that it gets highlighted
        blockToExec.isRunning = true
        blockCurrentlyRunning = blockToExec
        robotControlViewController.refreshScreen() // refresh screen to highlight the button
        // Announce on VoiceOver that a block is being run
        UIAccessibility.post(notification: .announcement, argument: "\(blockToExec.name)")
        if connectedRobots.count == 0 && !isInFreeplay{
            return
        }
        switch blockToExec.name{
        //SOUNDS CATEGORY
        // Resource for sound file names: https://github.com/playi/wwjs-examples/blob/master/sounds.md
            //TODO: test all sounds
        case "Animal Noise":
            let animal = blockToExec.addedBlocks[0].attributes["animalNoise"]
            
            switch animal {
            case "random animal":
                if isInFreeplay {
                    playNoise(sound: freeplayAnimalSoundFiles[.random(in: freeplayAnimalSoundFiles.indices)])
                } else {
                    playNoise(sound: animalSoundFiles[.random(in: animalSoundFiles.indices)])
                }
                
            default:
                playNoise(sound: animal ?? "cat")
            }
            
        case "Vehicle Noise":
            let vehicle = blockToExec.addedBlocks[0].attributes["vehicleNoise"]

            switch vehicle {
            
            case "random vehicle":
                playNoise(sound: vehicleSoundFiles[.random(in: vehicleSoundFiles.indices)])
            default:
                playNoise(sound: vehicle ?? "airplane")
            }
            
        case "Object Noise":
            let object = blockToExec.addedBlocks[0].attributes["objectNoise"]
            
            switch object {
            case "random object":
                if isInFreeplay {
                    playNoise(sound: freeplayObjectSoundFiles[.random(in: freeplayObjectSoundFiles.indices)])
                } else {
                    playNoise(sound: objectSoundFiles[.random(in: objectSoundFiles.indices)])
                }
                
            default:
                playNoise(sound: object ?? "trumpet")
            }
            
        case "Emotion Noise":
            let emotion = blockToExec.addedBlocks[0].attributes["emotionNoise"]
            // TODO: all emotion sounds do not work on Dot
            switch emotion {
             // TODO: giggle sound on dot is: "SYSTGIGGLE"
           
            case "random emotion":
                playNoise(sound: emotionSoundFiles[.random(in: emotionSoundFiles.indices)])
            default:
                playNoise(sound: emotion ?? "bragging")
            }
            
        case "Speak":
            let word = blockToExec.addedBlocks[0].attributes["speak"]
            // TODO: all speak sounds do not work on Dot
            switch word {
            
            case "random word":
                playNoise(sound: speakSoundFiles[.random(in: speakSoundFiles.indices)])
            default:
                playNoise(sound: word ?? "hi")
            }
        case "Custom Noise":
            let noiseFile = blockToExec.addedBlocks[0].attributes["customNoise"]
            playNoise(sound: noiseFile ?? "", customAudio: true)
            
        //CONTROL CATEGORY
        case "If":
            // what the statement evaluates to
            // what info we get from the robot
            if blockToExec.addedBlocks[0].attributes["booleanSelected"] == "Hear voice"{
            // check if the if statement is evaluating for a hear_voice
                
                // TODO: if we allow multiple robots to each evaluate the if condition, will that mess up the sequence of the rest of the blocks? Maybe we should disable the ability to connect to more than one robot
                var numTrue = 0
                for _ in 0..<20 { // Check multiple times if the robot hears a sound in order to reduce error
                    if (connectedRobots[0].canHearSound()) {
                        numTrue += 1
                    }
                }
                
                if (numTrue >= 10) { // if sounds was heard at least half of the time, evaluate the if statement to true
                    print("hear Voice true")
                    ifCondition = true
                } else {
                    ifCondition = false
                }
      
                   
            } else if blockToExec.addedBlocks[0].attributes["booleanSelected"] == "Obstacle sensed"{
            // check if the if statement is evaluating for a obstacle_sensed
                
                // TODO: if we allow multiple robots to each evaluate the if condition, will that mess up the sequence of the rest of the blocks? Maybe we should disable the aility to connect to more than one robot
                var numTrue = 0
                for _ in 0..<20 { // Check multiple times if the robot detectsObject in order to reduce error
                    if (connectedRobots[0].isObstacleDetected()) {
                        numTrue += 1
                    }
                }
                
                if (numTrue >= 10) { // if obstacle was detected at least half of the time, evaluate the if statement to true
                   
                    print("detect obstacle true")
                    ifCondition = true
                } else {
                    ifCondition = false
                }
           }

            if(ifCondition){
                //if it's true, just keep going
                finishCommand(withDuration: 1)
            
            }else{
                // run the ifFalse function, this is to skip over blocks that aren't supposed to be executed
                ifFalse()
                finishCommand(withDuration: 1)
                
            }
            print(ifCondition)
        case "End If":
            finishCommand(withDuration: 0.5)
        case "Repeat":
            print("in Repeat")
            //repeatCountAndIndexArray keeps track of how many times to repeat which loop
            repeatCountAndIndexArray.append((timesToR: Int(blockToExec.addedBlocks[0].attributes["timesToRepeat"] ?? "0") ?? 0, index: (positions[positions.count - 1].position) ))
            // adds to repeatCountAndIndexArray the current blocks index and the value of how many times it has left to repeat
            print(repeatCountAndIndexArray)
            finishCommand(withDuration: 0.5)
            
        case "End Repeat" :
            print("in End Repeat")
            //repeatCountAndIndexArray keeps track of how many times to repeat which loop
            repeatCountAndIndexArray[repeatCountAndIndexArray.count - 1].timesToR -= 1
            // end repeat get the last element in the array and tells it that it has repeated once by removing 1 from the timesToR(times left to repeat)
            if repeatCountAndIndexArray[repeatCountAndIndexArray.count - 1].timesToR == 0{
            // if the last index of the repeatCountAndIndexArray and if we're done repeating it and there are 0 timesToR(times left to repeat)
                repeatCountAndIndexArray.remove(at: (repeatCountAndIndexArray.count - 1) )
                // remove the tuple at the end of the array where the timesToR(times left to repeat) to repeat count is 0
            } else {
            // if the loop needs to be repeated it goes to the last index of repeatCountAndIndexArray so that you get to the innermost repeat loop
                positions[positions.count - 1].position = repeatCountAndIndexArray[(repeatCountAndIndexArray.count - 1)].index
                // change the position to the begining of the repeat loop
            }
            print(repeatCountAndIndexArray)
            finishCommand(withDuration: 0.5)
            
        case "Repeat Forever":
            print("in Repeat")
            //repeatCountAndIndexArray keeps track of how many times to repeat which loop
            repeatCountAndIndexArray.append((timesToR: 1, index: (positions[positions.count - 1].position) ))
            // adds to repeatCountAndIndexArray the current blocks index and the value of howmany times it has left to repeat
            print(repeatCountAndIndexArray)
            finishCommand(withDuration: 0.5)
            
        case "End Repeat Forever" :
            print("in End Repeat")
            positions[positions.count - 1].position = repeatCountAndIndexArray[(repeatCountAndIndexArray.count - 1)].index
            // change the position to the begining of the repeat loop
            print(repeatCountAndIndexArray)
            finishCommand(withDuration: 0.5)
            
            
        case "Wait for Time":
            playWait(waitBlock: blockToExec)
            
            
        //DRIVE CATEGORY
        case "Drive Forward":
            //drive constant is positive because this is drive forward
            playDrive(driveBlock: blockToExec, driveConstant: 1.0)
            
        case "Drive Backward":
            //drive constant is negative because this is drive backward
            playDrive(driveBlock: blockToExec, driveConstant: -1.0)
            
            /* right now this code allows Dash to pivot from the wheel in the direction he is turning in (e.g. right turn, pivot on right wheel),
             if he needs to pivot from his head/center, then the direction he is turning in would need to be negative */
        case "Turn Left":
           playTurn(turnBlock: blockToExec)
           
            
        case "Turn Right":
            playTurn(turnBlock: blockToExec)
            
        //LIGHTS CATEGORY
        //MARK: change this code and make is smoother once we have user input
        case "Set Eye Light":
            let value = blockToExec.addedBlocks[0].attributes["eyeLight"] ?? "Off"
            var data: [UInt8]
            if value == "Off" {
                data = playEyeLight(on: false)
            } else {
                data = playEyeLight(on: true)
            }
            sendDataToDash(data: Data(data), withDuration: 1)
            
        case "Spiral Light":
            // Turn spiral light on
            playEyeLightSpiral()
            
        case "Set Left Ear Light Color":
            playLight(lightBlock: blockToExec, positionBits: 11)
        
        case "Set Right Ear Light Color":
            playLight(lightBlock: blockToExec, positionBits: 12)
            
        case "Set Front Light Color":
            playLight(lightBlock: blockToExec, positionBits: 3)
            
        case "Set All Lights Color":
            playLight(lightBlock: blockToExec, positionBits: 3)
            playLight(lightBlock: blockToExec, positionBits: 11)
            playLight(lightBlock: blockToExec, positionBits: 12)
            
            let value = blockToExec.addedBlocks[0].attributes["lightColor"] ?? "Off"
            var data: [UInt8]
            if value == "Off" {
                data = playEyeLight(on: false)
            } else {
                data = playEyeLight(on: true)
            }
            sendDataToDash(data: Data(data), withDuration: 1)
           
        //MOTION CATEGORY
        case "Wiggle":
            let turnLeft = calculateDriveCommand(linearVelocity: 0, angularVelocity: 650)
            let turnRight = calculateDriveCommand(linearVelocity: 0, angularVelocity: -650)
           
            sendDataToDashNoDuration(data: Data(turnLeft))
            // timer code from https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
            Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { timer in
                self.sendDataToDashNoDuration(data: Data(turnRight))
                Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { timer in
                    self.sendDataToDashNoDuration(data: Data(turnLeft))
                    Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { timer in
                        self.sendDataToDashNoDuration(data: Data(turnRight))
                        Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { timer in
                            self.stopWheels()
                            self.finishCommand(withDuration: 0.1) // Move on to next block
                        }
                    }
                }
            }
            
        case "Nod":
            let lookFoward = setHeadYPosition(y: 0)
            let lookUp = setHeadYPosition(y: 22)
            let lookDown = setHeadYPosition(y: -7)
            
            sendDataToDashNoDuration(data: Data(lookFoward))
            
            // timer code from https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                self.sendDataToDashNoDuration(data: Data(lookUp))
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                    self.sendDataToDashNoDuration(data: Data(lookDown))
                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                        self.sendDataToDashNoDuration(data: Data(lookUp))
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                            self.sendDataToDashNoDuration(data: Data(lookDown))
                            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { timer in
                                self.sendDataToDashNoDuration(data: Data(lookFoward))
                                self.finishCommand(withDuration: 0.1) // Move on to next block
                            }
                        }
                    }
                }
            }
        //LOOK CATEGORY
        case "Look Up":
            let data = setHeadYPosition(y: 22)
            sendDataToDash(data: Data(data), withDuration: 2)
            
        case "Look Down":
            let data = setHeadYPosition(y: -7)
            sendDataToDash(data: Data(data), withDuration: 2)
            
        case "Look Left":
            let data = setHeadXPosition(x: -64)
            sendDataToDash(data: Data(data), withDuration: 2)
            
        case "Look Right":
            let data = setHeadXPosition(x: 64)
            sendDataToDash(data: Data(data), withDuration: 2)
            
        case "Look Forward":
            let data = setHeadXandYPostion(x: 0, y: 0)
            sendDataToDashNoDuration(data: Data(data.xData))  // send first command without a duration so that the second command is the only one that has a time on it (otherwise it acts as if this block is two blocks)
            sendDataToDash(data: Data(data.yData), withDuration: 2)
        
        case "Look Toward Voice": // TODO: improve accuracy
            var soundDirectionSum = 0
            let numSamples = 100
            for _ in 0..<numSamples { // Check the sound direction multiple times in order to reduce error
                soundDirectionSum += connectedRobots[0].soundDirection
            }

            let averageSoundDirection = Int(soundDirectionSum / numSamples)
            let xAngle = -averageSoundDirection // angle signs are swapped from soundDirection data to sending data to robot
            let data = setHeadXandYPostion(x: xAngle, y: 0)
            sendDataToDashNoDuration(data: Data(data.xData))  // send first command without a duration so that the second command is the only one that has a time on it (otherwise it acts as if this block is two blocks)
            sendDataToDash(data: Data(data.yData), withDuration: 2)
            
        //VARIABLES CATEGORY
        case "Set Variable":
            variablesDict[ blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] = Double(blockToExec.addedBlocks[0].attributes["variableValue"] ?? "0.0") ?? 0.0
            //assigns the variable value from current block attributes to the variables dict in executing program
            
            finishCommand(withDuration: 1)
            
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
            playDrive(driveBlock: blockToExec, driveConstant: driveConstant)
            
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
            playTurn(turnBlock: blockToExec)
        
        case "Look Up or Down":
            
            let degree = variablesDict[blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0
            
            // should be .initWithDegree, but for some reason that doesn't work, may need to be in radians
            //Negative command values represent left (horizontal) or up (vertical). Positive command values represents right (horizontally) or down (vertically).
            // ranges from  -20 to 7.5 TODO: update these ranges
            
            // TODO: allow for floats and not just ints
            let data = setHeadXandYPostion(x: 0, y: Int(degree))
            sendDataToDashNoDuration(data: Data(data.xData))  // send first command without a duration so that the second command is the only one that has a time on it (otherwise it acts as if this block is two blocks)
            sendDataToDash(data: Data(data.yData), withDuration: 2)
        
        case "Look Left or Right":
           
            let degree = variablesDict[blockToExec.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0
            //Negative command values represent left (horizontal) or up (vertical). Positive command values represents right (horizontally) or down (vertically).
            //-120.0 to 120.0 //TODO: update range
            // TODO: update slider to not allow floats, since ints are all that can be sent to the robot
            let data = setHeadXandYPostion(x: Int(degree), y: 0)
            sendDataToDashNoDuration(data: Data(data.xData))  // send first command without a duration so that the second command is the only one that has a time on it (otherwise it acts as if this block is two blocks)
            sendDataToDash(data: Data(data.yData), withDuration: 2)
        case "Move Up" :
            print("Move up")
            playMove(moveBlock: blockToExec, xDirection: 0, yDirection: -1)
        case "Move Down":
            print("move down")
            playMove(moveBlock: blockToExec, xDirection: 0, yDirection: 1)
        case "Move Left":
            print("move left")
            playMove(moveBlock: blockToExec, xDirection: -1, yDirection: 0)
        case "Move Right":
            print("move right")
            playMove(moveBlock: blockToExec, xDirection: 1, yDirection: 0)
        case "Move to Center":
            print("Move to center")
            moveToOrigin()
        case "Move to Actor":
            print("Move to Actor")
            moveToActor(moveBlock: blockToExec)
        case "Move to Location":
            print("Move to Location")
            moveToLocation(moveBlock: blockToExec)
        case "Set Location":
            print("Set Location")
            moveToLocation(moveBlock: blockToExec)
        case "Set Speed":
            print("Set speed")
            setSpeed(speedBlock: blockToExec)
        case "Grow Actor": // TODO: switch to just "Grow"
            print("grow actor")
            changeSize(sizeBlock: blockToExec, growOrShrink: 1)
        case "Shrink Actor":
            print("Shrink actor")
            changeSize(sizeBlock: blockToExec, growOrShrink: -1)
        case "Set Background":
            print("Set Background")
            setBackground(backgroundBlock: blockToExec)
        case "\(ON_RUN_STRING) Start":
            print("OnRun Start")
            finishCommand()
        case "\(ON_BUMP_STRING) Start":
            print("ON bump Start")
            finishCommand()
        case "\(ON_TAP_STRING) Start":
            print("On tap line Start")
            
            finishCommand()
            // not best way but using default for Functions
        default:
            if blockToExec.name.contains("Function Start") || blockToExec.name.contains("Function End") {
                finishCommand(withDuration: 0.5)
            }
            if blockToExec.type == "Function" {
                currentFunction = blockToExec.name
                // changes current function to the function being called
                positions.append((funcName: currentFunction, position: -1))
                // adds this call of the function to the positions array of tuples so that executing current function knows where to start, -1 value is because beneth here the position value is increased this lets the next block start at an index of 0
               
                finishCommand(withDuration: 1)
            } else {
                print("There is no command, blockToExec name = ", blockToExec.name)
            }
        }
       
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
    
    /// Generate and return data string array for setting the robot head x position
    func setHeadXPosition(x: Int) -> [UInt8] {
        // Set head position code is based off https://github.com/vdwel/RobotControl/blob/master/robot.py
        var xAngle = x
        
        if (xAngle < -64){
            print("Head cannot move more than 64 degrees.")
            xAngle = -64
        } else if (xAngle > 64){
            print("Head cannot move more than 64 degrees.")
            xAngle = 64
        }
        if (xAngle < 0) {
            xAngle *= -1
            xAngle += 0b10000000  // add negative sign bit
        }
       
        var data = [UInt8](repeating: 0, count: 2)
        data = [UInt8](repeating: 0, count: 3)
        data[0] = 6
        data[1] = UInt8(xAngle)
        
        return data
        
    }
    
    /// Generate and return data string array for setting the robot head y position
    func setHeadYPosition(y: Int) -> [UInt8]{
        // TODO: head keeps going back to center without being told to
        // Set head position code is based off https://github.com/vdwel/RobotControl/blob/master/robot.py
        var yAngle = y
        if (yAngle < -7) {
            print("Head cannot go lower than -7 degrees.")
            yAngle = -7
            
        } else if (yAngle > 22) {
            print("Head cannot go higher than 22 degrees.")
            yAngle = 22
            
        }
        
        if (yAngle < 0) {
            yAngle *= -1
            yAngle += 0b10000000  // add negative sign bit
        }
    
        var data = [UInt8](repeating: 0, count: 2)
        data[0] = 7
        data[1] = UInt8(yAngle)
        
        return data
    }
    
    /// Generate and return tuple of two data string arrays for setting the robot head x and y position
    func setHeadXandYPostion(x: Int, y: Int) -> (xData: [UInt8], yData: [UInt8]) {
        let data1 = setHeadXPosition(x: x)
        let data2 = setHeadYPosition(y: y)
        return (xData: data1, yData: data2)
    }

    /// Plays eye light spiral by creating a repeating timer that fires to change which lights are turned on
    func playEyeLightSpiral() {
        // TODO: freeplay
        let spiralDuration = 0.04
        Timer.scheduledTimer(timeInterval: spiralDuration, target: self, selector: #selector(eyeLightTimerFire(timer:)),  userInfo: spiralDuration as Any , repeats: true)
        finishCommand(withDuration: 2)
    }
    
    var currentSpiralLightIndex = 0 // the current single light that should be turned on
    var numberOfTimesSpun = 0 // number of times the eyeLightTimer has been fired
    @objc func eyeLightTimerFire(timer: Timer!) {
        // These two lines make the spiral consist of two adjacent lights
        let currentLightIndex = (currentSpiralLightIndex % 11) + 1
        let nextLightIndex = (currentLightIndex + 1) % 11
        // Update currentSpiralLightIndex
        currentSpiralLightIndex = currentLightIndex
        
        let data = playEyeLight(on: false)// Turn off all lights
        sendDataToDashNoDuration(data: Data(data))
        
        // Send the command to turn on the two lights
        setEyeLightWithIndices(indices: [currentLightIndex, nextLightIndex])
        
        numberOfTimesSpun += 1
        
        let desiredFullRevolutions = 5
        // End the spinning
        if numberOfTimesSpun >= (12 * desiredFullRevolutions) {
            timer.invalidate()
            // Turn all lights back on
            let data = playEyeLight(on: true)
            sendDataToDashNoDuration(data: Data(data))
     
            currentSpiralLightIndex = 0
            numberOfTimesSpun = 0
        }
    }
    
    /// Given an array of indices, turns on the corresponding eye light leds
    func setEyeLightWithIndices(indices: [Int]) {
        var data = [UInt8](repeating: 0, count: 3)
        data[0] = 9
            
        // each bit represents one of the 12 lights on the eye. Since we are using UInt8 to send data, it has to be sent in chunks
        var bitString: UInt16 = 0b0000000000000000
        
        // add a 1 in each index that should be turned on
        for index in indices {
            var indexBit: UInt16 = 0b0000000000000001
            indexBit = indexBit << index
            bitString += indexBit
        }
        
        // chunk the data into two UInt8 values
        // got help with chunking from Tamas_Papp's answer on https://discourse.julialang.org/t/convert-uint16-to-two-uint8/7115
        data[1] = UInt8(bitString >> 8)
        data[2] = UInt8(bitString & 0b0000000011111111)
        
        sendDataToDashNoDuration(data: Data(data))
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

    /// Play the passed sound file name
    func playNoise (sound: String, customAudio: Bool = false){
        if (isInFreeplay) {
            print("Play noise", sound)
            if customAudio { // Audio is a custom file saved by user
                currentActor!.playCustomSound(soundName: sound, executingProgram: self)
            } else { // Audio is a Blocks4All sound
                currentActor!.playSound(soundName: sound, executingProgram: self)
            }
            
          
            
        } else {
            // access robot sound file name from plist
            let dict: NSDictionary?
             if let path = Bundle.main.path(forResource: "SoundFileDict", ofType: "plist") {
                dict = NSDictionary(contentsOfFile: path)
             } else {
                 print("could not access SoundFileDict plist")
                 return
             }
            if !(dict!.allKeys as! [String]).contains(sound) {
                print("Error:", sound, " audio file name could not be found in SoundFileDict plist")
                return
            }
            let soundFileName = dict![sound] as! String
            
            var data = [UInt8](repeating: 0, count: 1 + soundFileName.count)
            data[0] = 24
            for (i, char) in soundFileName.enumerated() {
                data[i + 1] = UInt8(char.asciiValue!)
            }
            
            sendDataToDash(data: Data(data), withDuration: 2)
        }
        
    }
    
    /// Send data to dash to execute and then sends the finish command message after a duration
    func sendDataToDash(data: Data, withDuration: Double) {
        if (connectedRobots.isEmpty ) {
            return // TODO: handle if there is no connected robot or no characteristic to send to
        }
       
        for robot in connectedRobots {
            robot.peripheral.writeValue(data, for: robot.dashCharacteristic!, type: .withoutResponse)
        }
        
        finishCommand(withDuration: withDuration)
    
    }
    
    /// Send message that the block has finished running with optional parameter to wait before sending the message
    func finishCommand(withDuration: Double = 0) {
        blockRunningTimer = Timer.scheduledTimer(withTimeInterval: withDuration, repeats: false) { timer in
            self.robotControlViewController.finishedCommand()
        }
    }
    
    /// Cancel blockRunningTimer which
    private func cancelBlockTimer() {
        print("invalidate")
        blockRunningTimer.invalidate()
    }
    
    /// Stops execution of currently running block. Does not cancel future blocks
    public func stopCurrentBlock() {
        cancelBlockTimer()
        finishCommand()
    }
    
    /// Send a command to Dash. Does not call finishCommand afterwards.  Only sends the data
    func sendDataToDashNoDuration(data: Data) {
        if (connectedRobots.isEmpty ) {
            return // TODO: handle if there is no connected robot
        }
        for robot in connectedRobots {
            robot.peripheral.writeValue(data, for: robot.dashCharacteristic!, type: .withoutResponse)
        }
    }

    func playWait(waitBlock: Block) {
        // TODO: implement for freeplay
        let wait = Double(waitBlock.addedBlocks[0].attributes["wait"] ?? "0") ?? 0
        finishCommand(withDuration: wait)
    }

    func playMove(moveBlock: Block, xDirection: Int, yDirection: Int) {
        let distance = (Double(moveBlock.addedBlocks[0].attributes["movement"] ?? "1") ?? 1 ) * 10
        currentActor!.playMove(distance: distance, xDirection: xDirection, yDirection: yDirection, executingProgram: self)
       
    }
  
    
    func moveToOrigin() {
        currentActor!.moveToOrigin(executingProgram: self)
    }
    
    func moveToActor(moveBlock: Block) {
        let actorUUID = moveBlock.addedBlocks[0].attributes["moveToActor"] ?? ""
        
        
        currentActor!.moveToActor(actorUUID: actorUUID, executingProgram: self)
    }
    
    func moveToLocation(moveBlock: Block) {
        let coordinateString = moveBlock.addedBlocks[0].attributes["moveToLocation"] ?? ""
        currentActor!.moveToLocation(coordinateString: coordinateString, executingProgram: self)
    }
    
    func setSpeed(speedBlock: Block) {
        let speed = speedBlock.addedBlocks[0].attributes["speed"] ?? "Normal"
        currentActor!.setActorSpeedByName(speedName: speed)
        finishCommand(withDuration: 0.5)
    }
    
    func changeSize(sizeBlock: Block, growOrShrink: Int) {
        let sizeChangeAmount = Int(sizeBlock.addedBlocks[0].attributes["sizeChangeAmount"] ?? "1") ?? 1
        
        currentActor!.changeActorSize(amount: sizeChangeAmount, growOrShrink: growOrShrink, executingProgram: self)
    }
    
    func setBackground(backgroundBlock: Block) {
        let backgroundImagePath = backgroundBlock.addedBlocks[0].attributes["background"] ?? "DefaultBackground"
        
        currentActor!.freeplayOutputView?.setBackgroundImage(newImagePath: backgroundImagePath)
        
        
//        let blocksViewController = robotControlViewController.blocksViewController
//        if blocksViewController is FreePlayWorkspaceViewController {
//            let freeplayWorkspaceVC = blocksViewController as! FreePlayWorkspaceViewController
//            freeplayWorkspaceVC.freeplayOutputView.setBackgroundImage(newImagePath: backgroundImagePath)
//        }
//
        finishCommand(withDuration: 0.5)
    }
    
    //decomposition of drive functions
    func playDrive (driveBlock: Block, driveConstant: Double){
        if isInFreeplay {
            // TODO: implement for freeplay
           
            finishCommand(withDuration: 1.5)
        } else {
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
            let linearVelocity = Int(driveDirection * (robotSpeed * 4))
            let angularVelocity = 0
            //linear velocity is the speed times the direction, aka speed times the positive forward or negative backwards, 0 angular momentum so no turning
            
            
            /*by multiplying (distance/robotSpeed) by 1.25, the time needed to start and stop Dash is taken into account, and he more or less travels the
             distance he needs to in the right time. However he travels a little too far on the really slow speed. */
            // this needs fine tuning, generally works fine, but probably a better way to account for this
            // really need internal API from wonderworkshop to make this work
           
            
            var durationModifier = 2.00
            // fine tune duratoin modifier
            if distance < 20 {
                durationModifier = 2.9
            } else if distance >= 40 {
                durationModifier = 1.8
                if distance >= 60 {
                    durationModifier = 1.7
                }
                if distance >= 70 {
                    durationModifier = 1.65
                }
                if distance >= 80 {
                    durationModifier = 1.57
                }
                if distance >= 100 {
                    durationModifier = 1.53
                }
            }
            
            if robotSpeed <= 10 {
                if (distance < 40) {
                    durationModifier *= 0.75
                } else {
                    durationModifier *= 0.9
                }
                if robotSpeed <= 5 {
                    durationModifier *= 0.9
                }
            }
            
            let driveDuration = (distance/robotSpeed) * durationModifier
           
            let data = calculateDriveCommand(linearVelocity: linearVelocity, angularVelocity: angularVelocity)
            
            sendDataToDash(data: Data(data), withDuration: (driveDuration) + 0.3)  // block duration time has to be slightly longer to allow for time for the wheels to stop before going on to the next block
            
            Timer.scheduledTimer(withTimeInterval: driveDuration, repeats: false) { timer in
                // stop driving after the driveDuration has passed
                self.stopWheels()
            }
        }
        
       
    }
    
    func calculateDriveCommand(linearVelocity: Int, angularVelocity: Int) -> [UInt8] {
        var linearVelocity = linearVelocity
        if (linearVelocity < 0) {
            // Not sure why but it seems like 0b10000000000 (1024) is the maximum backwards speed, so the linear velocity has to be bigger than 1024. The bigger the value is, the slower it will go in the backwards direction
            linearVelocity = 2048 - (-linearVelocity)
        }
        var angularVelocity = angularVelocity
        if (angularVelocity < 0) { // handle negative angles
            angularVelocity = 2048 - (-angularVelocity)
        }
        // Bitwise operators for chunking drive command is from: https://www.maissan.net/articles/dash-and-dot/6
        var data = [UInt8](repeating: 0, count: 4)
        data[0] = 2 // drive command
        data[1] = UInt8(linearVelocity & 0b11111111)
        data[2] = UInt8(angularVelocity & 0b11111111)
        data[3] = UInt8((linearVelocity & 0b1111111100000000) >> 8) | UInt8((angularVelocity & 0b1111111100000000) >> 5)
        
        return data
    }
    
    func stopWheels() {
        print("stopping dash")
        var data = [UInt8](repeating: 0, count: 4)
        data[0] = 2
        data[1] = 0
        data[2] = 0
        data[3] = 0
        self.sendDataToDashNoDuration(data: Data(data))
    }
    
    // MARK: decomposition of turn functions
    func playTurn (turnBlock: Block){
        if isInFreeplay {
           
            var angleToTurn: Double = 90
            
            if turnBlock.name.contains("Turn Left") {
                angleToTurn = Double(turnBlock.addedBlocks[0].attributes["angle"] ?? "90") ?? 90 // go through added block to find the attribute angle
                angleToTurn *= -1 // make angle negative because turning left
                
            } else if turnBlock.name.contains("Turn Right") {
                angleToTurn = Double(turnBlock.addedBlocks[0].attributes["angle"] ?? "90") ?? 90
                
            }
            currentActor!.playTurn(angle: angleToTurn, executingProgram: self)
        } else {
            var angleToTurn: Double = 90
            var angularVelocity = 0
            //matches defualt displayed angle
            if turnBlock.name == "Turn"{
            //name of variable turn block is "Turn"
                angleToTurn = variablesDict[turnBlock.addedBlocks[0].attributes["variableSelected"] ?? "orange"] ?? 0.0
                //get the variable selected value for the turn block, go through added and get the added block attribues, default orange, default 0 degrees
                if angleToTurn > 0{
                    angularVelocity = -250
                } else {
                    angularVelocity = 250
                    angleToTurn *= -1 // make angleToTurn positive
                }
                
            } else if turnBlock.name.contains("Turn Left") {
                angleToTurn = Double(turnBlock.addedBlocks[0].attributes["angle"] ?? "90") ?? 90 // go through added block to find the attribute angle
                angularVelocity = 250
                
            } else if turnBlock.name.contains("Turn Right") {
                angleToTurn = Double(turnBlock.addedBlocks[0].attributes["angle"] ?? "90") ?? 90
                angularVelocity = -250
            }
            let data = calculateDriveCommand(linearVelocity: 0, angularVelocity: angularVelocity)
            var turnDuration = angleToTurn/50
            // Angle fine tuning
            if angleToTurn < 30 {
                turnDuration = angleToTurn / 15
            }
            if angleToTurn >= 30 {
                turnDuration = angleToTurn / 25
            }
            if angleToTurn > 44 {
                turnDuration = angleToTurn / 35
            }
            if angleToTurn > 59 {
                turnDuration = angleToTurn / 42
            }
            if angleToTurn > 74 {
                turnDuration = angleToTurn / 45
            }
            if angleToTurn == 90 {
                turnDuration = angleToTurn / 50
            }
            if angleToTurn > 90 {
                turnDuration = angleToTurn / 60
            }
            if angleToTurn > 120 {
                turnDuration = angleToTurn / 70
            }
            if angleToTurn > 179 {
                turnDuration = angleToTurn / 75
            }
            if angleToTurn > 240 {
                turnDuration = angleToTurn / 80
            }
            if angleToTurn > 300 {
                turnDuration = angleToTurn / 85
            }
            
            
            
            sendDataToDash(data: Data(data), withDuration: turnDuration * 1.25) // block duration time has to be slightly longer to allow for time for the wheels to stop before going on to the next block
            
            Timer.scheduledTimer(withTimeInterval: turnDuration, repeats: false) { timer in
                // stop driving after the turnDuration has passed
                self.stopWheels()
            }
        }
        
    }

    
    //decomposition of light functions
    func playLight (lightBlock: Block, positionBits: Int) {
        // TODO: implement for freeplay
        let color = lightBlock.addedBlocks[0].attributes["lightColor"] ?? "white"
        var selectedColor = (red: 255, green: 255, blue: 255)
        switch color {
        case "Off": // this used to be black, but black lights do not exist, it is just turning the light off
            selectedColor = (red: 0, green: 0, blue: 0)
        case "white":
            selectedColor = (red: 255, green: 255, blue: 255)
        case "red":
            selectedColor = (red: 255, green: 0, blue: 0)
        case "green":
            selectedColor = (red: 0, green: 255, blue: 0)
        case "blue":
            selectedColor = (red: 0, green: 0, blue: 255)
        case "orange":
            selectedColor = (red: 255, green: 50, blue: 0)
        case "yellow":
            selectedColor = (red: 255, green: 255, blue: 0)
        case "purple":
            selectedColor = (red: 75, green: 0, blue: 130)
        default:
            selectedColor = (red: 255, green: 255, blue: 255)
        }
        
        var data = [UInt8](repeating: 0, count: 4)
        data[0] = UInt8(positionBits)
        data[1] = UInt8(selectedColor.red)
        data[2] = UInt8(selectedColor.green)
        data[3] = UInt8(selectedColor.blue)
                        
        sendDataToDash(data: Data(data), withDuration: 1)
    }
    
    func playEyeLight(on: Bool) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: 3)
        data[0] = 9 //
        
        // Turn eye light off
        
        if !on {
            data[1] = 0
            data[2] = 0
        } else {
            // Turn eye light on
            // each bit represents one of the 12 lights on the eye. Since we are using UInt8 to send data, it has to be sent in chunks
            data[1] = 0b00001111
            data[2] = 0b11111111
        }
        
        return data
        
    }

   
    
    
    
    let animalSoundFiles =
        ["bee",
         "cat",
         "crocodile",
         "dinosaur",
         "dog",
         "elephant",
         "goat",
         "horse",
         "lion",
         "turkey"]
       
    
    let freeplayAnimalSoundFiles =
        ["dog",
        "cat",
        "dinosaur",
        "goat",
        "bee",
        "horse",
        "turkey"]
       
    let vehicleSoundFiles =
        ["airplane",
         "beep",
         "boat",
         "helicopter",
         "siren",
         "speed boost",
         "start engine",
         "tire squeal",
         "train"]
       
    
    let objectSoundFiles =
        ["laser",
         "squeak",
         "trumpet"]
    
    let freeplayObjectSoundFiles =
        ["laser",
        "squeak",
        "trumpet"]
    
    let emotionSoundFiles =
        ["bragging",
         "confused",
         "giggle",
         "grunt",
         "sigh",
         "snore",
         "surprised",
         "yawn"]
    
    let speakSoundFiles =
        ["hi",
         "bye",
         "cool",
         "haha",
         "huh",
         "let's go",
         "oh",
         "wow",
         "tah dah!",
         "uh huh",
         "uh oh",
         "wah",
         "wee hee!",
         "yippee!"]
}



