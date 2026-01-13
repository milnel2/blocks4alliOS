//
//  CalibrateXylophoneViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 1/12/26.
//  Copyright © 2026 Blocks4All. All rights reserved.
//
import UIKit
import Foundation
// TODO: translate this VC to Spanish
class CalibrateXylophoneViewController: UIViewController {
    
    @IBOutlet weak var calibrateLabel: UILabel!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var instructionsImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func cancelPressed(_ sender: Any) {
        doneCalibrating = false
        performSegue(withIdentifier: "calibrateToXylophone", sender: self)
    }
    
    private var doneCalibrating: Bool = false
    public var noteCoordinates: [String : (x: Int, y: Int)] = ["Red" : (0,0), "Orange": (0,0), "Yellow": (0,0), "Green": (0,0), "Turquoise": (0,0), "Blue": (0,0), "Purple": (0,0), "Pink": (0,0)]
    
    // Current index of calibration steps:
    // 0: Connect robot
    // 1: Attach xylophone
    // 2: Attach mallet
    // 3: Red key
    // 4: Orange key
    // 5: Yellow key
    // 6: Green key
    // 7: Turquoise key
    // 8: Blue key
    // 9: Purple key
    // 10: Pink key
    // 11: Complete
    private var calibrationStep: Int = 1
    private var xylophoneViewController: XylophoneViewController?
    
    
    public func setNoteCoordinates(coords: [String : (x: Int, y: Int)]) {
        noteCoordinates = coords
    }
    
    override func viewDidLoad() {
        doneCalibrating = false
        
        if (RobotControlViewController.areRobotsConnected()) {
            // A robot is already connected, ready to calibrate
            
            // Start searching for data
            for robot in connectedRobots {
                robot.peripheral.setNotifyValue(true, for: robot.dashSensorCharacteristic1!)
            }
            calibrationStep = 1
        } else {
            // Prompt to connect a robot
            performSegue(withIdentifier: "calibrateToAddRobot", sender: self)
            calibrationStep = 0
        }
        updateStep()
    }
    
  
    func updateStep() {
        switch calibrationStep {
        case 0:
            instructionsLabel.text = "Connect a Dash robot."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_ConnectRobot")
            nextButton.setTitle("Search for Robots", for: .normal)
        case 1:
            instructionsLabel.text = "Attach xylophone to Dash."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_Xylophone")
            nextButton.setTitle("Next", for: .normal)

        case 2:
            instructionsLabel.text = "Attach mallet to Dash's left ear."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_AttachMallet")
        case 3:
            instructionsLabel.text = "Place mallet on red (first/largest) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_RedKey")
        case 4:
            // Save coordinates
            noteCoordinates["Red"] = (connectedRobots[0].headX, connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on orange (second) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_OrangeKey")
        case 5:
            // Save coordinates
            noteCoordinates["Orange"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on yellow (third) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_YellowKey")
        case 6:
            // Save coordinates
            noteCoordinates["Yellow"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on green (fourth) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_GreenKey")
        case 7:
            noteCoordinates["Green"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on turquoise (fifth) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_TurquoiseKey")
        case 8:
            // Save coordinates
            noteCoordinates["Turquoise"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on blue (sixth) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_BlueKey")
        case 9:
            // Save coordinates
            noteCoordinates["Blue"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on purple (seventh) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_PurpleKey")
        case 10:
            noteCoordinates["Purple"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on pink (eighth) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_PinkKey")
        case 11:
            noteCoordinates["Pink"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Calibration complete!"
            
            doneCalibrating = true
            performSegue(withIdentifier: "calibrateToXylophone", sender: self)
        default:
            instructionsLabel.text = "Calibration error. Please cancel and try again."
        }
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if calibrationStep == 0 {
            // Open add robot screen
            performSegue(withIdentifier: "calibrateToAddRobot", sender: self)
        } else {
            calibrationStep += 1
            updateStep()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? XylophoneViewController {
            destinationViewController.setIsCalibrated(isCalibrated: doneCalibrating)
            if doneCalibrating {
                destinationViewController.setNoteCoordinates(coords: noteCoordinates)
            }
        }
        
        if let destinationViewController = segue.destination as? AddRobotViewController {
            destinationViewController.sentFrom = .Xylophone
        }
    }
}
