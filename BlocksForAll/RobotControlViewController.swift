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
    let soundFiles = [WW_SOUNDFILE_GIGGLE,
        WW_SOUNDFILE_AIRPLANE,
        WW_SOUNDFILE_OKAY,
        WW_SOUNDFILE_BYE,
        WW_SOUNDFILE_SIGH,
        WW_SOUNDFILE_BEEP,
        WW_SOUNDFILE_BRAGGING,
        WW_SOUNDFILE_CONFUSED,
        WW_SOUNDFILE_COOL,
        WW_SOUNDFILE_CROCODILE,
        WW_SOUNDFILE_HUH,
        WW_SOUNDFILE_HI,
        WW_SOUNDFILE_WAH,
        WW_SOUNDFILE_WOW,
        WW_SOUNDFILE_DINOSAUR,
        WW_SOUNDFILE_ELEPHANT,
        WW_SOUNDFILE_ENGINE_REV,
        WW_SOUNDFILE_WEE,
        WW_SOUNDFILE_WOOHOO,
        WW_SOUNDFILE_GOAT,
        WW_SOUNDFILE_CAT,
        WW_SOUNDFILE_DOG,
        WW_SOUNDFILE_LION,
        WW_SOUNDFILE_GOBBLE,
        WW_SOUNDFILE_HAHA,
        WW_SOUNDFILE_OOH,
        WW_SOUNDFILE_GRUNT,
        WW_SOUNDFILE_HELICOPTER,
        WW_SOUNDFILE_HORSE,
        WW_SOUNDFILE_LASERS,
        WW_SOUNDFILE_SQUEAK,
        WW_SOUNDFILE_SNORING,
        WW_SOUNDFILE_SPEED_BOOST,
        WW_SOUNDFILE_SURPRISED,
        WW_SOUNDFILE_TAH_DAH,
        WW_SOUNDFILE_YAWN,
        WW_SOUNDFILE_TIRE_SQUEAL,
        WW_SOUNDFILE_TRAIN,
        WW_SOUNDFILE_HORN,
        WW_SOUNDFILE_TRUMPET,
        WW_SOUNDFILE_BOAT,
        WW_SOUNDFILE_BUZZ,
        WW_SOUNDFILE_WEEHEE,
        WW_SOUNDFILE_UH_OH,
        WW_SOUNDFILE_SIREN,
        WW_SOUNDFILE_UH_HUH,
        WW_SOUNDFILE_YIPPE,
        WW_SOUNDFILE_LETS_GO]
    
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
    
    func sendCommandSetToRobots(cmd: WWCommandSet){
        let connectedRobots = robotManager?.allConnectedRobots
        for r in connectedRobots!{
            if let robot = r as? WWRobot{
                robot.send(cmd)
            }
        }
    }
    
    func sendCommandSequenceToRobots(cmdSeq: WWCommandSetSequence){
        let connectedRobots = robotManager?.allConnectedRobots
        for r in connectedRobots!{
            if let robot = r as? WWRobot{
                robot.executeCommand(cmdSeq, withOptions: nil)
            }
        }
    }
    
    func getSensorData() -> [WWSensorSet] {
        var sensorSet: [WWSensorSet] = []
        let connectedRobots = robotManager?.allConnectedRobots
        for r in connectedRobots!{
            if let robot = r as? WWRobot{
                sensorSet.append(robot.history.currentState())
            }
        }
        return sensorSet as! [WWSensorSet]
    }
    
    func robot(_ robot: WWRobot!, didStopExecutingCommand sequence: WWCommandSetSequence!, withResults results: [AnyHashable : Any]!) {
        let connectedRobots = robotManager?.allConnectedRobots
        for _ in connectedRobots!{
            robot.resetState()
        }
    } 
    var leftLightIndex = 0
    var rightLightIndex = 0
    var eyeLightIndex = 0
    
    func play(_ myCommands: [String]){
        let connectedRobots = robotManager?.allConnectedRobots
        if connectedRobots != nil{
            //set up light dict
            let lightDict = [WWCommandLightRGB.init(red: 0.9, green: 0, blue: 0), WWCommandLightRGB.init(red: 0, green: 0.9, blue: 0), WWCommandLightRGB.init(red: 0, green: 0, blue: 0.9), WWCommandLightRGB.init(red: 0, green: 0, blue: 0), WWCommandLightRGB.init(red: 0.9, green: 0.9, blue: 0.9)]

            
            let cmdToSend = WWCommandSetSequence()
            var repeatCommands = [WWCommandSet]()
            var i = 0
            while i < myCommands.count{
                var command = myCommands[i]
            //for command in myCommands{
                var duration = 2.0
                //print(command)
                //TODO add repeat blocks
                var distance: Double = 30
                var myAction = WWCommandSet()
                if command.contains("If"){
                    //TODO check blocks condition
                    var conditionString = command.substring(from: command.index(command.startIndex, offsetBy: 2))
                    print("conditionString" , conditionString)
                    var condition = false
                    if(conditionString == "Hear Voice"){
                        var data = getSensorData()
                        if(!data.isEmpty){
                            //just checks first robot
                            let micData: WWSensorMicrophone = data[0].sensor(for: WWComponentId(WW_SENSOR_MICROPHONE)) as! WWSensorMicrophone
                            print("amp: ", micData.amplitude, "direction: ", micData.triangulationAngle)
                            if(micData.amplitude > 0){
                                condition = true
                            }
                        }
                    }
                    if(conditionString == "Obstacle in front"){
                        var data = getSensorData()
                        if(!data.isEmpty){
                            //just checks first robot
                            let distanceDataFL: WWSensorDistance =  data[0].sensor(for: WWComponentId(WW_SENSOR_DISTANCE_FRONT_LEFT_FACING)) as! WWSensorDistance
                            let distanceDataFR: WWSensorDistance = data[0].sensor(for: WWComponentId(WW_SENSOR_DISTANCE_FRONT_RIGHT_FACING)) as! WWSensorDistance
                                //WWSensorMicrophone = data[0].sensor(for: WWComponentId(WW_SENSOR_MICROPHONE)) as! WWSensorMicrophone
                            print("distance: ", distanceDataFL.reflectance, distanceDataFR.reflectance)
                            if(distanceDataFL.reflectance > 0.5 || distanceDataFR.reflectance > 0.5){
                                condition = true
                            }
                        }
                    }
                    if(condition){
                        print("TRUE")
                        //if it's true, just keep going
                    }else{
                    //if it's not true, keep going and don't do any of the blocks until you see endif
                        while(command != "End If"){
                            i += 1
                            command = myCommands[i]
                            print("it is an endif")
                        }
                    }
                }
                if command.contains("Drive Forward") {
                    //let bodyPose = WWCommandBodyPose.init(relativeMeasuredX: distance, y: 0, radians: 0, time: 1.0)
                    //myAction.setBodyPose(bodyPose)
                    if(command.contains("0")){
                        var distanceString = command
                        distanceString = distanceString.substring(from:distanceString.index(distanceString.endIndex, offsetBy: -2))
                        distance = Double(distanceString)!
                    }
                    
                    
                    let setAngular = WWCommandBodyLinearAngular(linear: distance, angular: 0)
                    let drive = WWCommandSet()
                    drive.setBodyLinearAngular(setAngular)
                    cmdToSend.add(drive, withDuration: 2.0)
                    myAction = WWCommandToolbelt.moveStop()
                }
                if command.contains("Drive Backward") {
                    if(command.contains("0")){
                        var distanceString = command
                        distanceString = distanceString.substring(from:distanceString.index(distanceString.endIndex, offsetBy: -2))
                        distance = Double(distanceString)!
                    }
                    
                    let setAngular = WWCommandBodyLinearAngular(linear: -distance, angular: 0)
                    let driveBackward = WWCommandSet()
                    driveBackward.setBodyLinearAngular(setAngular)
                    cmdToSend.add(driveBackward, withDuration: 2.0)
                    myAction = WWCommandToolbelt.moveStop()
                    //let bodyPose = WWCommandBodyPose.init(relativeMeasuredX: -distance, y: 0, radians: 0, time: 1.0)
                    //myAction.setBodyPose(bodyPose)
                }
                if command == "Wiggle" {
                    duration = 0.5
                    let rotateLeft = WWCommandSet()
                    rotateLeft.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -20.0, rightWheel: 20.0))
                    let rotateRight = WWCommandSet()
                    rotateRight.setBodyWheels(WWCommandBodyWheels.init(leftWheel: 20.0, rightWheel: -20.0))
                    cmdToSend.add(rotateLeft, withDuration: duration)
                    cmdToSend.add(rotateRight, withDuration: duration)
                    cmdToSend.add(rotateLeft, withDuration: duration)
                    cmdToSend.add(rotateRight, withDuration: duration)
                    myAction = WWCommandToolbelt.moveStop()
                }
                if command == "Nod" {
                    //let nodAnimation = WWCommandSetSequence()
                    let lookup = WWCommandSet()
                    lookup.setHeadPositionTilt(WWCommandHeadPosition.init(degree: -20))
                    let lookdown = WWCommandSet()
                    lookdown.setHeadPositionTilt(WWCommandHeadPosition.init(degree:7.5))
                    duration = 0.4
                    cmdToSend.add(lookup, withDuration:duration)
                    cmdToSend.add(lookdown, withDuration:duration)
                    cmdToSend.add(lookup, withDuration:duration)
                    cmdToSend.add(lookdown, withDuration:duration)
                    cmdToSend.add(lookup, withDuration:duration)
                    cmdToSend.add(lookdown, withDuration:duration)
                    cmdToSend.add(lookup, withDuration:duration)
                    cmdToSend.add(lookdown, withDuration:duration)
                    myAction = WWCommandToolbelt.moveStop()
                }
                if command == "Dance" {
                    duration = 0.5
                    let rotateLeft = WWCommandSet()
                    rotateLeft.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -30.0, rightWheel: 30.0))
                    let rotateRight = WWCommandSet()
                    rotateRight.setBodyWheels(WWCommandBodyWheels.init(leftWheel: 30.0, rightWheel: -30.0))
                    let setLeft = WWCommandSet()
                    let light = lightDict[leftLightIndex%lightDict.count]
                    leftLightIndex += 1
                    setLeft.setLeftEarLight(light)
                    let setRight = WWCommandSet()
                    setRight.setRightEarLight(light)
                    rightLightIndex += 1
                    
                    cmdToSend.add(rotateLeft, withDuration: duration)
                    cmdToSend.add(rotateRight, withDuration: duration)
                    cmdToSend.add(setLeft, withDuration: duration)
                    cmdToSend.add(setRight, withDuration: duration)
                    cmdToSend.add(rotateLeft, withDuration: duration)
                    cmdToSend.add(rotateRight, withDuration: duration)
                    cmdToSend.add(setLeft, withDuration: duration)
                    cmdToSend.add(setRight, withDuration: duration)
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_WOOHOO)
                    myAction.setSound(speaker)
                    
                    myAction = WWCommandToolbelt.moveStop()
                }
                if command == "Turn Left" {
                    duration = 0.55
                    let rotateLeft = WWCommandSet()
                    rotateLeft.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -20.0, rightWheel: 20.0))
                    cmdToSend.add(rotateLeft, withDuration: duration)
                    myAction = WWCommandToolbelt.moveStop()
                }
                if command == "Turn Right" {
                    duration = 0.56
                    let rotateLeft = WWCommandSet()
                    rotateLeft.setBodyWheels(WWCommandBodyWheels.init(leftWheel: 20.0, rightWheel: -20.0))
                    cmdToSend.add(rotateLeft, withDuration: duration)
                    myAction = WWCommandToolbelt.moveStop()
                    /*let setAngular = WWCommandBodyLinearAngular(linear: 0, angular: -3.1415)
                    let drive = WWCommandSet()
                    drive.setBodyLinearAngular(setAngular)
                    cmdToSend.add(drive, withDuration: 1.0)
                    myAction = WWCommandToolbelt.moveStop()*/
                    //myAction.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -20.0, rightWheel: 20.0))
                }
                if command == "Say Hi" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_HI)
                    myAction.setSound(speaker)
                }
                if command == "Make Random Noise"{
                    let randomNumber = arc4random_uniform(UInt32(soundFiles.count))
                    let speaker = WWCommandSpeaker.init(defaultSound: soundFiles[Int(randomNumber)])
                    myAction.setSound(speaker)
                }
                if command == "Make Horse Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_HORSE)
                    myAction.setSound(speaker)
                }
                if command == "Make Dog Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_DOG)
                    myAction.setSound(speaker)
                }
                if command == "Make Cat Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_CAT)
                    myAction.setSound(speaker)
                }
                if command == "Make Dinosaur Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_DINOSAUR)
                    myAction.setSound(speaker)
                }
                if command == "Make Elephant Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_ELEPHANT)
                    myAction.setSound(speaker)
                }
                if command == "Make Lion Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_LION)
                    myAction.setSound(speaker)
                }
                if command == "Make Goat Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_GOAT)
                    myAction.setSound(speaker)
                }
                if command == "Make Crocodile Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_CROCODILE)
                    myAction.setSound(speaker)
                }
                if command == "Say Okay" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_OKAY)
                    myAction.setSound(speaker)
                }
                if command == "Say Bye" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_BYE)
                    myAction.setSound(speaker)
                }
                if command == "Bragging" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_BRAGGING)
                    myAction.setSound(speaker)
                }
                if command == "Confused" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_CONFUSED)
                    myAction.setSound(speaker)
                }
                if command == "Say Cool" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_COOL)
                    myAction.setSound(speaker)
                }
                if command == "Say Wow" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_WOW)
                    myAction.setSound(speaker)
                }
                if command == "Start Engine" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_ENGINE_REV)
                    myAction.setSound(speaker)
                }
                if command == "Set Eye Light" {
                    let light = lightDict[eyeLightIndex%lightDict.count]
                    eyeLightIndex += 1
                    myAction.setEyeLight(light)
                    myAction.setChestLight(light)
                }
                if command == "Set Left Ear Light" {
                    let light = lightDict[leftLightIndex%lightDict.count]
                    leftLightIndex += 1
                    myAction.setLeftEarLight(light)
                }
                if command == "Set Right Ear Light" {
                    let light = lightDict[rightLightIndex%lightDict.count]
                    rightLightIndex += 1
                    myAction.setRightEarLight(light)
                }
                cmdToSend.add(myAction, withDuration: duration)
                print(cmdToSend)
                sendCommandSequenceToRobots(cmdSeq: cmdToSend)
                cmdToSend.removeAllEvents()
                i += 1
            }

            //sendCommandSetToRobots(cmd: cmdToSend)
        }else{
            print("no connected robots")
        }
    }

}
