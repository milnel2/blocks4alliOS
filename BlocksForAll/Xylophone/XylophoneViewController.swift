//
//  XylophoneViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 12/26/25.
//  Copyright © 2025 Blocks4All. All rights reserved.
//
import UIKit
import Foundation

class XylophoneViewController: UIViewController {
    // View Controller Elements
    
//    @IBOutlet weak var startListeningToInputButton: UIButton!
    @IBOutlet weak var calibrateButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var turquoiseButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    
    private var noteCoordinates: [String : (x: Int, y: Int)] = ["Red" : (0,0), "Orange": (0,0), "Yellow": (0,0), "Green": (0,0), "Turquoise": (0,0), "Blue": (0,0), "Purple": (0,0), "Pink": (0,0)]
    
    private var isCalibrated: Bool = false
    
    public func setIsCalibrated(isCalibrated: Bool) {
        print("is calibrated = \(isCalibrated)")
        self.isCalibrated = isCalibrated
    }
    
    @IBAction func backToMainMenuButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "xylophoneToMainMenu", sender: self)
    }
    
    @IBAction func calibrateButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "calibrateXylophone", sender: self)
    }
    
    @IBAction func redPressed(_ sender: Any) {
        print("red pressed")
        if (!isCalibrated) { return }
        playNote(color: "Red")
    }
    
    @IBAction func orangePressed(_ sender: Any) {
        if (!isCalibrated) { return }
        playNote(color: "Orange")
    }
    
    @IBAction func yellowPressed(_ sender: Any) {
        if (!isCalibrated) { return }
        playNote(color: "Yellow")

    }
    @IBAction func greenPressed(_ sender: Any) {
        if (!isCalibrated) { return }
        playNote(color: "Green")
    }

    @IBAction func turquoisePressed(_ sender: Any) {
        if (!isCalibrated) { return }
        playNote(color: "Turquoise")

    }
    @IBAction func bluePressed(_ sender: Any) {
        if (!isCalibrated) { return }
        playNote(color: "Blue")
    }
    
    @IBAction func purplePressed(_ sender: Any) {
        if (!isCalibrated) { return }
        playNote(color: "Purple")
    }
    @IBAction func pinkPressed(_ sender: Any) {
        if (!isCalibrated) { return }
        playNote(color: "Pink")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? CalibrateXylophoneViewController {
            destinationViewController.setNoteCoordinates(coords: noteCoordinates)
        }
    }
    
    public func setNoteCoordinates(coords: [String : (x: Int, y: Int)]) {
        noteCoordinates = coords
    }
    
    override func viewDidLoad() {
               
        if RobotControlViewController.areRobotsConnected() {
            // Start searching for data
            for robot in connectedRobots {
                robot.peripheral.setNotifyValue(true, for: robot.dashSensorCharacteristic2!)
                robot.peripheral.setNotifyValue(true, for: robot.dashSensorCharacteristic1!)
                robot.peripheral.setNotifyValue(true, for: robot.dashInfoCharacteristic!)
            }
        }
        
        if isCalibrated {
            redButton.isEnabled = true
            orangeButton.isEnabled = true
            yellowButton.isEnabled = true
            greenButton.isEnabled = true
            turquoiseButton.isEnabled = true
            blueButton.isEnabled = true
            purpleButton.isEnabled = true
            pinkButton.isEnabled = true
        } else {
            redButton.isEnabled = false
            orangeButton.isEnabled = false
            yellowButton.isEnabled = false
            greenButton.isEnabled = false
            turquoiseButton.isEnabled = false
            blueButton.isEnabled = false
            purpleButton.isEnabled = false
            pinkButton.isEnabled = false
        }
    }
    
    func moveHeadX(x: Int) {
        if !RobotControlViewController.areRobotsConnected() { return }
        
        var newHeadX = x
        // convert to sending values
        if (newHeadX >= 255) {
            // looking somewhere to the right
            newHeadX = Int(Double(newHeadX - 511) / -4.46)
        } else {
            // looking somewhere to the left
            newHeadX = Int((Double(newHeadX) - 1118.75) / -4.375)
        }
        
        if newHeadX >= 60 && newHeadX <= 100 {
            // looking all the way to the right, keep it in place instead of wrapping it around
            newHeadX = 60
        }
        
        if newHeadX > 260 {
            newHeadX -= 260
            // move past the center line to the right.
        }
        
        if newHeadX < 0 {
            newHeadX = 260 + newHeadX
            // move past the center line to the left
        }
       
        print("New X = \(newHeadX)")
        let data = ExecutingProgram.setHeadXPosition(x: newHeadX)
        
        print("Data = \(data)")
        
        print("Sending to Dash...")
        sendDataToDash(data: Data(data))
    }
    
    func moveHeadY(y: Int) {
        if !RobotControlViewController.areRobotsConnected() { return }
        
        let newHeadY = ExecutingProgram.setHeadYPosition(y: y)
        sendDataToDash(data: Data(newHeadY))
        
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { timer in
            let backUp = ExecutingProgram.setHeadYPosition(y: 22)
            self.sendDataToDash(data: Data(backUp))
        }
    }
    
    func playNote(color: String) {
        if (noteCoordinates.keys.contains(color)) {
            let x = noteCoordinates[color]!.x
            let y = noteCoordinates[color]!.y
            moveHeadX(x: x)
            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { timer in
                self.moveHeadY(y: y)
            }
        } else {
            print("\(color) not present in noteCoordinates dictionary")
        }
    }
    
    /// Send data to dash to execute
    func sendDataToDash(data: Data) {
        if (connectedRobots.isEmpty ) {
            print("no robots connected")
            return // TODO: handle if there is no connected robot or no characteristic to send to
        }
        
        for robot in connectedRobots {
            robot.peripheral.writeValue(data, for: robot.dashCharacteristic!, type: .withoutResponse)
        }
    }
}
    

