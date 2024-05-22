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
    static func == (lhs: Robot, rhs: Robot) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
    
    var peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
}
