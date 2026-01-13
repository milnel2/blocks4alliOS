//
//  CalibrateXylophoneViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 1/12/26.
//  Copyright © 2026 Blocks4All. All rights reserved.
//
import UIKit
import Foundation

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
    // 4: Green key
    // 5: Turquoise key
    // 6: Pink key
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
            noteCoordinates["Red"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on green (fourth) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_GreenKey")
        case 5:
            noteCoordinates["Green"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on turquoise (fifth) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_TurquoiseKey")
        case 6:
            noteCoordinates["Turquoise"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Place mallet on pink (eighth) key."
            instructionsImage.image = HelperFunctions.getUIImage(named: "Calibrate_PinkKey")
        case 7:
            noteCoordinates["Pink"] = (connectedRobots[0].headX,connectedRobots[0].headY)
            
            instructionsLabel.text = "Calibration complete!"
            // Calculate other key positions
            let greenToRedDist = noteCoordinates["Green"]!.x - noteCoordinates["Red"]!.x
            let orangeX = noteCoordinates["Red"]!.x + (greenToRedDist / 3)
            let orangeY = (noteCoordinates["Green"]!.y + noteCoordinates["Red"]!.y) / 2
            noteCoordinates["Orange"] = (x: orangeX, y: orangeY)

            let yellowX = noteCoordinates["Red"]!.x + (2 * greenToRedDist / 3)
            let yellowY = (noteCoordinates["Green"]!.y + noteCoordinates["Red"]!.y) / 2
            noteCoordinates["Yellow"] = (x: yellowX, y: yellowY)

            let turqToPinkDist = noteCoordinates["Turquoise"]!.x - noteCoordinates["Pink"]!.x

            let blueX = noteCoordinates["Turquoise"]!.x - (turqToPinkDist / 3)
            let blueY = (noteCoordinates["Turquoise"]!.y + noteCoordinates["Pink"]!.y) / 2
            noteCoordinates["Blue"] = (x: blueX, y: blueY)

            let purpleX = noteCoordinates["Turquoise"]!.x - (2 * turqToPinkDist / 3)
            let purpleY = (noteCoordinates["Turquoise"]!.y + noteCoordinates["Pink"]!.y) / 2
            noteCoordinates["Purple"] = (x: purpleX, y: purpleY)
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
