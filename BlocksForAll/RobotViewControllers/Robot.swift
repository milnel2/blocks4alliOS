//
//  Robot.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 5/22/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import UIKit
import CoreBluetooth

class Robot: Equatable {
    
    var peripheral: CBPeripheral // peripheral object used for Core Bluetooth
    
    
    // Sensors currently in use by Blocks4All
        // Sound
    var soundLevel: Int // value from 0 to 255 of how much sound is heard
    var soundDirection: Int //TODO: description
    
        // Object detection
    var leftDistanceSensor: Int // value from 0 to 255 of how close an object is (255 is closest, 0 is farthest)
    var rightDistanceSensor: Int // value from 0 to 255 of how close an object is (255 is closest, 0 is farthest)
    
    
    
    // Sensors not in use // TODO: organise these by category
        // Buttons
    var button0: Bool // Middle white button on top of head
    var button1: Bool // Bottom left orange button on top of head
    var button2: Bool // Bottom right orange button on top of head
    var button3: Bool // Top orange button on top of head
        // Spatial
    var tilt: Int // I'm unsure of the difference between tilt and lean
    var lean: Int
    var headX: Int // x coordinate of the head
    var headY: Int // y coordinate of the head
    var leftWheel: Int
    var rightWheel: Int
    var wheelDistance: Int
        // Sound
    var clap: Bool // True if a clap is heard
        //Object detection
    var leftSensorSeesDot: Bool
    var rightSensorSeesDot: Bool
    var dotWasSeen: Bool
    var rearDistanceSensor: Int // value from 0 to 255 of how close an object is (255 is closest, 0 is farthest)
        // Acceleration
    var zAcceleration: Int
    var deltaXRotationAcceleration: Int
    var deltaYRotationAcceleration: Int
    var deltaZRotationAcceleration: Int
    var zRotationAcceleration: Int
    
    
    
    static func == (lhs: Robot, rhs: Robot) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
    
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        // Sensors currently being used by Blocks4All
        self.soundLevel = 0
        self.soundDirection = 0
        
        // Sensors not currently being used
        self.button0 = false
        self.button1 = false
        self.button2 = false
        self.button3 = false
        self.tilt = 0
        self.lean = 0
        self.clap = false
        self.zAcceleration = 0
        self.leftSensorSeesDot = false
        self.rightSensorSeesDot = false
        self.dotWasSeen = false
        self.leftDistanceSensor = 0
        self.rightDistanceSensor = 0
        self.rearDistanceSensor = 0
        self.headX = 0
        self.headY = 0
        self.leftWheel = 0
        self.rightWheel = 0
        self.deltaXRotationAcceleration = 0
        self.deltaYRotationAcceleration = 0
        self.deltaZRotationAcceleration = 0
        self.zRotationAcceleration = 0
        self.wheelDistance = 0
    }
    //TODO: documentation
    
    func updateSensorData1(data: String) { 
        // parse through data and update values
        // Code to interpret sensor data is from https://github.com/vdwel/RobotControl/tree/master
        
        let dataList = parseDataString(data: data)
        
        // Sensors currently being used by Blocks4All
        leftDistanceSensor = dataList[7]
        rightDistanceSensor = dataList[6]
        
        
        // Sensors not currently in use
        rearDistanceSensor = dataList[8]
        
        let head = (dataList[0x12] << 8) + dataList[0x13]
        headX = head & 0b0000000111111111  // select last 9 bits
        headY = (head & 0b1111111000000000) >> 9  // select first 7 bits
        if (headX > 255) {
            // signed integer conversion
            headX -= 512
        }
        
        if (headY > 63) {
            headY -= 128
        }
        
        headX = headX * 135 / 244 // convert to degrees
        headY = headY * 22 / 49 // convert to degrees
        
        leftWheel = (dataList[0x11] << 8) + dataList[0x10]
        rightWheel = (dataList[0x0F] << 8) + dataList[0x0E]
        
        // Rotation Acceleration calculations
        var z = (dataList[0x0D] << 8) + dataList[0x0C]
        var deltaZ = z - zRotationAcceleration
        
        if abs(deltaZ) > 0x7FFF {
            if deltaZ < 0 {
                deltaZ += 0x10000
            } else {
                deltaZ = -1 * (0x10000 - deltaZ)
            }
        }
        deltaZRotationAcceleration = deltaZ
        zRotationAcceleration = z
        
        deltaXRotationAcceleration = ((dataList[0x04] & 0b1111) << 8) + dataList[0x05]
        if (deltaXRotationAcceleration > 0x7FF) {
            deltaXRotationAcceleration -= 0x1000
        }
        
        deltaYRotationAcceleration = ((dataList[0x04] & 0b11110000) << 4) + dataList[0x03]
        if (deltaYRotationAcceleration > 0x7FF) {
            deltaYRotationAcceleration -= 0x1000
        }
        
        wheelDistance = (dataList[0x09] & 0b1111 << 12) + (dataList[0x0B] << 8) + dataList[0x0A]
        if (wheelDistance > 0x7FFF) {
            wheelDistance -= 0x10000
        }
    }


    
    func updateSensorData2(data: String) {
        // parse through data and update values
        // Code to interpret sensor data is from https://github.com/vdwel/RobotControl/tree/master
        
        let dataList = parseDataString(data: data)
        
        
        // Sensors currently being used by Blocks4All
        soundLevel =  dataList[0x07]
        
        if (dataList[0x0F] == 0x04) {
            soundDirection = (dataList[0x0D] << 8) + dataList[0x0C]
            if (soundDirection > 180) {
                soundDirection -= 360
            }
        }
        
        
        // Sensors not currently in use
        button0 = dataList[8] & 0b00010000 > 0
        button1 = dataList[8] & 0b00100000 > 0
        button2 = dataList[8] & 0b01000000 > 0
        button3 = dataList[8] & 0b10000000 > 0
        
        tilt = ((dataList[0x04] & 0b11110000) << 4) + dataList[0x02] // TODO: remove tilt? I don't think we will ever really need it
        if (tilt > 0x7FF) {
            tilt -= 0x1000
        }
        
        lean = ((dataList[0x4] & 0b1111) << 8) + dataList[0x03]
        if (lean > 0x7FF) {
            lean -= 0x1000
        }
        
        clap = (dataList[0x0B] & 0b00000001) == 1
 
        zAcceleration = (dataList[0x05] << 4) + dataList[0x06]
        if (zAcceleration > 0x7FF) {
            zAcceleration -= 0x1000
        }
        
        if dataList[0x13] == 0x05 {
            leftSensorSeesDot = dataList[0x11] == 0xAA
            rightSensorSeesDot = dataList[0x12] == 0xAA
            dotWasSeen = true
        }
        if dataList[0x13] == 0x01 {
            if !dotWasSeen {
                leftSensorSeesDot = false
                rightSensorSeesDot = false
            }
            dotWasSeen = false
        }
    }
    

    
    func canHearSound() -> Bool {
        return soundLevel > 50 // TODO: test value for accuracy
    }
    
    func isObstacleDetected() -> Bool {
        if leftDistanceSensor == 255 || rightDistanceSensor == 255 {
            return true
        }
        
        let averageSensorValue = Int((leftDistanceSensor + rightDistanceSensor) / 2)
        return averageSensorValue > 200
    }
    
    func parseDataString(data: String) -> [Int] {
        // code to parse data string is from https://github.com/vdwel/RobotControl/tree/master
        let dataArray = Array(data)
        var dataList: [Int] = []
        
        // Parse data string
        for i in stride(from: 0, to: dataArray.count, by: 2) {
            // substring code is from Mahima Srivastava on https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift
            let dataHexCode = String(dataArray[i..<i+2]) // every two hex characters is one sensor value
            let dataInt = Int(dataHexCode, radix: 16) ?? 0
            dataList.append(dataInt)
        }
        
        return dataList
    }
    


}

