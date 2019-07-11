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
        if let connectedRobots = robotManager?.allConnectedRobots{
            return !connectedRobots.isEmpty
        }else{
            return false
        }
    }
    
    //this function allows the blocks in the workspace to be sent to the robot
    func play(blocksStackPlay: [Block]){
        print("in play")
        let connectedRobots = robotManager?.allConnectedRobots
        if connectedRobots != nil{
        
            // var repeatCommands = [WWCommandSet]()
            executingProgram = ExecutingProgram(blocksStackExecute: blocksStackPlay)
            executeNextCommand()
            
            } else{
            print("no connected robots")
        }
    }
    
    func executeNextCommand() {
        print("in poll for next commnad")
        guard let executingProgram = executingProgram else {
            return  // not running
        }
        guard !executingProgram.isComplete else {
            print("in if iscomplete")
            self.executingProgram = nil
            programHasCompleted()
            return  // no more commands left
        }
    
        executingProgram.executeNextCommand()
    }

    func robot(_ robot: WWRobot!, didFinishCommand sequence: WWCommandSetSequence!) {
        executeNextCommand()
    }

    var isProgramComplete: Bool {
        print("in program is complete")
        return executingProgram?.isComplete ?? true
    }
    
    func programHasCompleted() {
        // subclasses may override
    }
}

class ExecutingProgram {
    var position: Int = 0
    var blocksToExec: [Block]
    var currentCommandBeingExecuted: WWCommandSetSequence?
    var repeatCountAndIndexArray: [(timesToR: Int, index: Int)] = []
    
    // TODO: store command in this variable so you can check if it's executing later
    //var currentCommand: WWCommandOrSomething

    init(blocksStackExecute: [Block]) {
        self.blocksToExec = blocksStackExecute
    }
    
    var isComplete: Bool {
        return position >= blocksToExec.count
    }
    
//    var isStopped: Bool {
//        return notRunning
//    }
    func executeNextCommand() {
        print("in execute nextcommand")
        guard !isComplete else {
            return
        }

        var blockToExec = blocksToExec[position]
        //for command in myCommands{
        print(blockToExec)
        var duration = 2.0
        //TODO: add repeat blocks
        var myAction = WWCommandSet()
        let cmdToSend = WWCommandSetSequence()
        
        
        switch blockToExec.name{
        //Animals Category
        case "Make Cat Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_CAT)
            
        case "Make Crocodile Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_CROCODILE)
            
        case "Make Dinosaur Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_DINOSAUR)
            
        case "Make Dog Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_DOG)
            
        case "Make Elephant Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_ELEPHANT)
            
        case "Make Goat Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_GOAT)
            
        case "Make Horse Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_HORSE)
            
        case "Make Lion Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_LION)
        case "Make Turkey Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_GOBBLE)
            
        //Control Category - might have to add to
        case "If":
            var condition = false
            var data = getSensorData()
            if blocksToExec[position].addedBlocks[0].name == "Hear Voice"{
                if(!data.isEmpty){
                    //just checks first robot
                    let micData: WWSensorMicrophone = data[0].sensor(for: WWComponentId(WW_SENSOR_MICROPHONE)) as! WWSensorMicrophone
                    print("amp: ", micData.amplitude, "direction: ", micData.triangulationAngle)
                    if(micData.amplitude > 0){
                        print("hear Voice true")
                        condition = true
                    }
                }
            } else if blocksToExec[position].addedBlocks[0].name == "Obstacle in front"{
                if(!data.isEmpty){
                    //just checks first robot
                    let distanceDataFL: WWSensorDistance =  data[0].sensor(for: WWComponentId(WW_SENSOR_DISTANCE_FRONT_LEFT_FACING)) as! WWSensorDistance
                    let distanceDataFR: WWSensorDistance = data[0].sensor(for: WWComponentId(WW_SENSOR_DISTANCE_FRONT_RIGHT_FACING)) as! WWSensorDistance
                    print("distance: ", distanceDataFL.reflectance, distanceDataFR.reflectance)
                    if(distanceDataFL.reflectance > 0.5 || distanceDataFR.reflectance > 0.5){
                        print("obstacle in front true")
                        condition = true
                    }
                }
            }
            if(condition){
                print("TRUE")
                //if it's true, just keep going
            }else{
                //if it's not true, keep going and don't do any of the blocks until you see endif
//                while(blockToExec.name != "End If"){
//                    position += 1
//                    blockToExec = blocksToExec[position]
//                    print("it is an endif")
//                }
                ifFalse()
            }
            
        case "Repeat":
            print("in Repeat")
            repeatCountAndIndexArray.append((timesToR: Int(blocksToExec[position].addedBlocks[0].attributes["timesToRepeat"] ?? "0") ?? 0, index: position))
            print(repeatCountAndIndexArray)
            //position += 1
            //executeNextCommand()
            
        case "End Repeat" :
            print("in End Repeat")
            repeatCountAndIndexArray[repeatCountAndIndexArray.count - 1].timesToR -= 1
            if repeatCountAndIndexArray[repeatCountAndIndexArray.count - 1].timesToR == 0{
                repeatCountAndIndexArray.remove(at: (repeatCountAndIndexArray.count - 1) )
            }else {
                position = repeatCountAndIndexArray[(repeatCountAndIndexArray.count - 1)].index
            }
            print(repeatCountAndIndexArray)
            
            
        case "Wait for Time":
            myAction = playWait(waitBlock: blockToExec, cmdToSend: cmdToSend)
            
        //Drive Category
        case "Drive Forward":
            //drive constant is positive because this is drive forward
            myAction = playDrive(driveBlock: blockToExec, driveConstant: 1.0, cmdToSend: cmdToSend)
            
        case "Drive Backward":
            //drive constant is negative because this is drive backward
            myAction = playDrive(driveBlock: blockToExec, driveConstant: -1.0, cmdToSend: cmdToSend)
            
            /* right now this code allows Dash to pivot from the wheel in the direction he is turning in (e.g. right turn, pivot on right wheel),
             if he needs to pivot from his head/center, then the direction he is turning in would need to be negative */
        case "Turn Left":
            myAction = playTurn(direction: 0, cmdToSend: cmdToSend)
            
        case "Turn Right":
            myAction = playTurn(direction:1, cmdToSend: cmdToSend)
            
            
            
            
        //Emotes Category
        case "Confused":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_CONFUSED)
        case "Bragging":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_BRAGGING)
        case "Giggle":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_GIGGLE)
        case "Grunt":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_GRUNT)
        case "Sigh":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_SIGH)
        case "Surprised":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_SURPRISED)
        case "Yawn":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_YAWN)
            
            
            //Lights Category
        //MARK: change this code and make is smoother once we have user input
        case "Set Eye Light":
            let light = playLight()
            myAction.setEyeLight(light)
            //                    myAction.setChestLight(light)
            
        case "Set Left Ear Light":
            let light = playLight()
            myAction.setLeftEarLight(light)
            
        case "Set Right Ear Light":
            let light = playLight()
            myAction.setRightEarLight(light)
            
        case "Set Chest Light":
            let light = playLight()
            myAction.setChestLight(light)
            
        case "Set All Lights":
            let light = playLight()
            myAction.setEyeLight(light)
            myAction.setRightEarLight(light)
            myAction.setLeftEarLight(light)
            myAction.setChestLight(light)
            
        //Motion Category
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
            
        //Look Category
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
            lookleft.setHeadPositionPan(WWCommandHeadPosition.init(degree: -60))
            duration = 0.3
            cmdToSend.add(lookleft, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
        case "Look Right":
            let lookright = WWCommandSet()
            lookright.setHeadPositionPan(WWCommandHeadPosition.init(degree: 60))
            duration = 0.3
            cmdToSend.add(lookright, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
        case "Look Forward":
            let lookforward = WWCommandSet()
            lookforward.setHeadPositionTilt(WWCommandHeadPosition.init(degree:0), pan: WWCommandHeadPosition.init(degree:0))
            duration = 0.3
            cmdToSend.add(lookforward, withDuration: duration)
            myAction =  WWCommandToolbelt.moveStop()
            
            
        case "Dance":
            duration = 0.5
            let rotateLeft = WWCommandSet()
            rotateLeft.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -30.0, rightWheel: 30.0))
            let rotateRight = WWCommandSet()
            rotateRight.setBodyWheels(WWCommandBodyWheels.init(leftWheel: 30.0, rightWheel: -30.0))
            let setLeft = WWCommandSet()
            let light = playLight()
            setLeft.setLeftEarLight(light)
            let setRight = WWCommandSet()
            setRight.setRightEarLight(light)
            
            var danceIndex = 0
            while danceIndex < 2 {
                cmdToSend.add(rotateLeft, withDuration: duration)
                cmdToSend.add(rotateRight, withDuration: duration)
                cmdToSend.add(setLeft, withDuration: duration)
                cmdToSend.add(setRight, withDuration: duration)
                danceIndex += 1
            }
            let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_WOOHOO)
            myAction.setSound(speaker)
            
            myAction = WWCommandToolbelt.moveStop()
            danceIndex = 0
            
            
        //Sound Category
        case "Make Random Noise":
            playNoise(myAction: myAction, sound: soundFiles[.random(in: soundFiles.indices)])
        case "Buzz":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_BUZZ)
        case "Lasers":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_LASERS)
        case "Snore":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_SNORING)
        case "Trumpet":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_TRUMPET)
        case "Squeak":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_SQUEAK)
            
            
        //Speak Category
        case "Say Hi":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_HI)
        case "Say Bye":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_BYE)
        case "Say Cool":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_COOL)
        case "Say Ha ha":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_HAHA)
        case "Say huhhh":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_HUH)
        case "Say Lets Go":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_LETS_GO)
        case "Say O":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_OOH)
        case "Say Wow":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_WOW)
        case "Say Tahhh Dahhhh":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_TAH_DAH)
        case "Say Uh Huhhh":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_UH_HUH)
        case "Say Uh O":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_UH_OH)
        case "Say Wah":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_WAH)
        case "Say We":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_WEE)
        case "Say We he":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_WEEHEE)
        case "Say Yipp e":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_YIPPE)
            
            
        //vehicle Category - check on
        case "Airplane Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_AIRPLANE)
        case "Beep":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_BEEP)
        case "Boat Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_BOAT)
        case "Helicopter Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_HELICOPTER)
        case "Horn":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_HORN)
        case "Siren Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_SIREN)
        case "Speed Boost":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_SPEED_BOOST)
        case "Start Engine Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_ENGINE_REV)
        case "Tire Squeal":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_TIRE_SQUEAL)
        case "Train Noise":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_TRAIN)
            
            
        //not in a category or plist? add
        case "Say Okay":
            playNoise(myAction: myAction, sound: WW_SOUNDFILE_OKAY)
            
        default:
            print("There is no command")
            
        }
        
        //the code that actually sends and removes the command's action to the sequence of code
        cmdToSend.add(myAction, withDuration: duration)
        print(cmdToSend)
        sendCommandSequenceToRobots(cmdSeq: cmdToSend)
        //cmdToSend.removeAllEvents()
        currentCommandBeingExecuted = cmdToSend
        position += 1
    }

    
    func ifFalse(){
        print("ifFalse Entered")
        var openIfs = 1
        while openIfs > 0{
            position += 1
            if blocksToExec[position].name == "End If"{
                openIfs -= 1
            } else if ((blocksToExec[position].name == "IfObstacle in front") || (blocksToExec[position].name == "IfHear Voice")){
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
//        for block in blocksStack{
//            if block.name.contains("Wait"){
//                wait = Double(block.addedBlocks[0].attributes["wait"] ?? "0") ?? 0
//            }
//        }
// old code prior to passing the block rather than string command
        wait = Double(waitBlock.addedBlocks[0].attributes["wait:"] ?? "0") ?? 0
        let waitingPeriod = WWCommandSet()
        print("waiting", wait)
        cmdToSend.add(waitingPeriod, withDuration: wait)
        return WWCommandToolbelt.moveStop()
    }

    
    //decomposition of drive functions
    func playDrive (driveBlock: Block, driveConstant: Double,  cmdToSend: WWCommandSetSequence) -> WWCommandSet{
        var distance = 0.0
        var robotSpeed = 0.0
        var speed: String
        speed = driveBlock.addedBlocks[0].attributes["speed"] ?? "Normal"
        distance = Double(driveBlock.addedBlocks[0].attributes["distance"] ?? "30") ?? 30
    
        switch speed {
            case "Really Fast":
                robotSpeed = 50.0
            case "Fast":
                robotSpeed = 40.0
            case "Normal":
                robotSpeed = 30.0
            case "Slow":
                robotSpeed = 10.0
            case "Very Slow":
                robotSpeed = 5.0
            default:
                robotSpeed = 30.0
        }
            
        
        
        let setAngular = WWCommandBodyLinearAngular(linear: ((driveConstant) * robotSpeed), angular: 0)
        let drive = WWCommandSet()
        drive.setBodyLinearAngular(setAngular)
        /*by multiplying (distance/robotSpped) by 1.25, the time needed to start and stop Dash is taken into account, and he more or less travels the
         distance he needs to in the right time. However he travels a little too far on the very slow speed. */
        cmdToSend.add(drive, withDuration: (distance/robotSpeed) * 1.25)
        return WWCommandToolbelt.moveStop()
    }
    
    // MARK: decomposition of turn functions
    func playTurn (direction: Int, cmdToSend: WWCommandSetSequence) -> WWCommandSet{
        var angleToTurn: Double = 45
        var turnConstantLW: Double = 0
        var turnConstantRW: Double = 0
        
        // TODO: clean up
        for block in blocksStack{
            if block.name.contains("Turn Left"){
                angleToTurn = Double(block.addedBlocks[0].attributes["angle"] ?? "45") ?? 45
                if direction == 0 { // turn left
                    switch angleToTurn{ // degrees
                    case 45:
                        turnConstantLW = 0
                        turnConstantRW = 16
                    case 90:
                        turnConstantLW = 0
                        turnConstantRW = 25.3
                    case 135:
                        turnConstantLW = 0
                        turnConstantRW = 35
                    case 180:
                        turnConstantLW = 0
                        turnConstantRW = 43
                    case 225:
                        turnConstantLW = 0
                        turnConstantRW = 47
                    case 270:
                        turnConstantLW = 0
                        turnConstantRW = 53
                    case 315:
                        turnConstantLW = 0
                        turnConstantRW = 57
                    case 360:
                        turnConstantLW = 0
                        turnConstantRW = 65
                    default: // 45 degrees
                        turnConstantLW = 0
                        turnConstantRW = 16
                    }
                }
            }
            else if block.name.contains("Turn Right"){
                angleToTurn = Double(block.addedBlocks[0].attributes["angle"] ?? "45") ?? 45
                if direction == 1 { // turn right
                    switch angleToTurn{ // degrees
                    case 45:
                        turnConstantRW = 0
                        turnConstantLW = 16
                    case 90:
                        turnConstantRW = 0
                        turnConstantLW = 25.3
                    case 135:
                        turnConstantRW = 0
                        turnConstantLW = 35
                    case 180:
                        turnConstantRW = 0
                        turnConstantLW = 43
                    case 225:
                        turnConstantRW = 0
                        turnConstantLW = 47
                    case 270:
                        turnConstantRW = 0
                        turnConstantLW = 53
                    case 315:
                        turnConstantRW = 0
                        turnConstantLW = 57
                    case 360:
                        turnConstantRW = 0
                        turnConstantLW = 65
                    default: // 45 degrees
                        turnConstantRW = 0
                        turnConstantLW = 16
                    }
                }
            }
        }
        let rotate = WWCommandSet()
        rotate.setBodyWheels(WWCommandBodyWheels.init(leftWheel: (turnConstantLW * 1), rightWheel: (turnConstantRW * 1)))
        // testing how to make turns better!
        cmdToSend.add(rotate, withDuration: 1)
        return WWCommandToolbelt.moveStop()
    }
    
    func playLight () -> WWCommandLightRGB{
        var color = ""
        for block in blocksStack{
            if block.name.contains("Light"){
                color = String(block.addedBlocks[0].attributes["lightColor"] ?? "white")
            }
        }
        
        var selectedColor = WWCommandLightRGB.init(red: 0.9, green: 0.9, blue: 0.9)
        switch color{
        case "black":
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

    func sendCommandSequenceToRobots(cmdSeq: WWCommandSetSequence){
        let connectedRobots = robotManager?.allConnectedRobots
        for r in connectedRobots!{
            if let robot = r as? WWRobot{
                robot.executeCommand(cmdSeq, withOptions: nil)
            }
        }
    }

    let soundFiles =
        [WW_SOUNDFILE_AIRPLANE,
         WW_SOUNDFILE_BEEP,
         WW_SOUNDFILE_BOAT,
         WW_SOUNDFILE_BRAGGING,
         WW_SOUNDFILE_BUZZ,
         WW_SOUNDFILE_BYE,
         WW_SOUNDFILE_CAT,
         WW_SOUNDFILE_CONFUSED,
         WW_SOUNDFILE_COOL,
         WW_SOUNDFILE_CROCODILE,
         WW_SOUNDFILE_DINOSAUR,
         WW_SOUNDFILE_DOG,
         WW_SOUNDFILE_ELEPHANT,
         WW_SOUNDFILE_ENGINE_REV,
         WW_SOUNDFILE_GIGGLE,
         WW_SOUNDFILE_GOAT,
         WW_SOUNDFILE_GOBBLE,
         WW_SOUNDFILE_GRUNT,
         WW_SOUNDFILE_HAHA,
         WW_SOUNDFILE_HELICOPTER,
         WW_SOUNDFILE_HI,
         WW_SOUNDFILE_HORN,
         WW_SOUNDFILE_HORSE,
         WW_SOUNDFILE_HUH,
         WW_SOUNDFILE_LASERS,
         WW_SOUNDFILE_LETS_GO,
         WW_SOUNDFILE_LION,
         WW_SOUNDFILE_OOH,
         WW_SOUNDFILE_OKAY,
         WW_SOUNDFILE_SIGH,
         WW_SOUNDFILE_SIREN,
         WW_SOUNDFILE_SNORING,
         WW_SOUNDFILE_SPEED_BOOST,
         WW_SOUNDFILE_SQUEAK,
         WW_SOUNDFILE_SURPRISED,
         WW_SOUNDFILE_TAH_DAH,
         WW_SOUNDFILE_TIRE_SQUEAL,
         WW_SOUNDFILE_TRAIN,
         WW_SOUNDFILE_TRUMPET,
         WW_SOUNDFILE_UH_HUH,
         WW_SOUNDFILE_UH_OH,
         WW_SOUNDFILE_WAH,
         WW_SOUNDFILE_WEE,
         WW_SOUNDFILE_WEEHEE,
         WW_SOUNDFILE_WOOHOO,
         WW_SOUNDFILE_WOW,
         WW_SOUNDFILE_YAWN,
         WW_SOUNDFILE_YIPPE]
}
