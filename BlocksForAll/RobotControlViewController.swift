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
    
    func robot(_ robot: WWRobot!, didStopExecutingCommand sequence: WWCommandSetSequence!, withResults results: [AnyHashable : Any]!) {
        let connectedRobots = robotManager?.allConnectedRobots
        for _ in connectedRobots!{
            robot.resetState()
        }
    }
    
    func play(_ blocks2Play: [Block]){
        let connectedRobots = robotManager?.allConnectedRobots
        if connectedRobots != nil{
            let cmdToSend = WWCommandSetSequence()
            var repeatCommands = [WWCommandSet]()
            var repeat2times = false
            var repeat3times = false
            for block in blocks2Play{
                var duration = 1.0
                print(block.name)
                //TODO add repeat blocks
                let distance: Double = 50
                var myAction = WWCommandSet()
                if block.name == "Drive Forward" {
                    //let bodyPose = WWCommandBodyPose.init(relativeMeasuredX: distance, y: 0, radians: 0, time: 1.0)
                    //myAction.setBodyPose(bodyPose)
                    let setAngular = WWCommandBodyLinearAngular(linear: 30, angular: 0)
                    let driveBackward = WWCommandSet()
                    driveBackward.setBodyLinearAngular(setAngular)
                    cmdToSend.add(driveBackward, withDuration: 2.0)
                    myAction = WWCommandToolbelt.moveStop()
                }
                //TODO WRONG
                if block.name == "Drive Backward" {
                    let setAngular = WWCommandBodyLinearAngular(linear: -30, angular: 0)
                    let driveBackward = WWCommandSet()
                    driveBackward.setBodyLinearAngular(setAngular)
                    cmdToSend.add(driveBackward, withDuration: 2.0)
                    myAction = WWCommandToolbelt.moveStop()
                    //let bodyPose = WWCommandBodyPose.init(relativeMeasuredX: -distance, y: 0, radians: 0, time: 1.0)
                    //myAction.setBodyPose(bodyPose)
                }
                if block.name == "Wiggle" {
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
                //TODO WRONG
                if block.name == "Turn Left" {
                    duration = 0.55
                    let rotateLeft = WWCommandSet()
                    rotateLeft.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -20.0, rightWheel: 20.0))
                    cmdToSend.add(rotateLeft, withDuration: duration)
                    myAction = WWCommandToolbelt.moveStop()
                }
                //TODO WRONG
                if block.name == "Turn Right" {
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
                if block.name == "Say Hi" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_HI)
                    myAction.setSound(speaker)
                }
                if block.name == "Make Horse Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_HORSE)
                    myAction.setSound(speaker)
                }
                if block.name == "Make Dog Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_DOG)
                    myAction.setSound(speaker)
                }
                if block.name == "Make Cat Noise" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_CAT)
                    myAction.setSound(speaker)
                }
                if block.name == "Start Engine" {
                    let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_ENGINE_REV)
                    myAction.setSound(speaker)
                }
                //TODO: FIX FOR NESTED LOOPS
                if block.name == "Repeat 3 Times" {
                    repeat3times = true
                }else if block.name == "End Repeat 3 Times" {
                    repeat3times = false
                    for _ in 1...3{
                        for action in repeatCommands {
                            cmdToSend.add(action, withDuration: duration)
                        }
                    }
                }else if repeat3times {
                    repeatCommands.append(myAction)
                }else {
                    cmdToSend.add(myAction, withDuration: duration)
                }
                
                //TODO WRONG
                /*if block.name == "Drive Backward" {
                 var backward = WWCommandBodyLinearAngular(linear: -10, angular: 0)
                 myAction.setBodyLinearAngular(backward)
                 cmdToSend.add(myAction, withDuration: 2.0)
                 var stop = WWCommandBodyLinearAngular(linear: 0, angular: 0)
                 myAction.setBodyLinearAngular(stop)
                 //let bodyPose = WWCommandBodyPose.init(relativeMeasuredX: -10.0, y: 0, radians: 0, time: 2)
                 //myAction.setBodyPose(bodyPose)
                 }
                 //TODO WRONG
                 if block.name == "Turn Left" {
                 myAction.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -20.0, rightWheel: 20.0))
                 }*/
            }
            sendCommandSequenceToRobots(cmdSeq: cmdToSend)
            //sendCommandSetToRobots(cmd: cmdToSend)
        }else{
            print("no connected robots")
        }
    }

}
