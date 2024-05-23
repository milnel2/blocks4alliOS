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
    var soundLevel: Int // value from 0 to 255 of how much sound is heard
    var soundDirection: Int //TODO: description
    
    
    // Sensors not in use
    var button0: Bool // Middle white button on top of head
    var button1: Bool // Bottom left orange button on top of head
    var button2: Bool // Bottom right orange button on top of head
    var button3: Bool // Top orange button on top of head
    var tilt: Int // I'm unsure of the difference between tilt and lean
    var lean: Int
    var clap: Bool // True if a clap is heard
    var zAcceleration: Int
    var leftSensorSeesDot: Bool
    var rightSensorSeesDot: Bool
    var dotWasSeen: Bool
    
    
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
    }
    
    func updateSensorData2(data: String) {
        let dataArray = Array(data)
        var dataList: [Int] = []
        
        // Parse data string
        for i in stride(from: 0, to: dataArray.count, by: 2) {
            // substring code is from Mahima Srivastava on https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift
            let dataHexCode = String(dataArray[i..<i+2]) // every two hex characters is one sensor value
            let dataInt = Int(dataHexCode, radix: 16) ?? 0
            dataList.append(dataInt)
        }
        
        // parse through data and update values
        // Code to interpret sensor data is from https://github.com/vdwel/RobotControl/tree/master
        
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
    

//    def updateSensorData2(self, data):
//           dataString = data.encode('hex')
//           dataList = [int(dataString[i:i + 2], 16) for i in range(0, len(dataString), 2)]
//           self.debug15List = dataList

//
//           if dataList[0x13] == 0x05:
//               self.leftSensorSeesDot = True if dataList[0x11] == 0xAA else False
//               self.rightSensorSeesDot = True if dataList[0x12] == 0xAA else False
//               self.dotWasSeen = True
//           if dataList[0x13] == 0x01:
//               if self.dotWasSeen == False:
//                   self.leftSensorSeesDot = False
//                   self.rightSensorSeesDot = False
//               self.dotWasSeen = False
}
