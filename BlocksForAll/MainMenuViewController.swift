//
//  MainMenuViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 8/30/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AVFoundation
 
let defaults = UserDefaults.standard  // Used to know block size and if in showIcons or in showText mode. Global so that all files can access it. From Paul Hegarty, lectures 13 and 14

class MainMenuViewController: UIViewController {
    
    // View Controller Elements
    @IBOutlet weak var playWithRobotButton: UIButton!
    @IBOutlet weak var instructions: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var robotImageView: UIImageView!
    @IBOutlet weak var playWithVirtualRobotButton: UIButton!
    @IBOutlet weak var playWithXylophoneButton: UIButton!
    @IBOutlet weak var welcomeLabelImage: UIImageView!
    
    var blockSize = 150 // this controls the size of the blocks you put down in the Building Screen
    
    var audioPlayer: AVAudioPlayer?  // Used to play the sound effect the plays when you tap the robot image
    
    override func viewDidLoad() {
        
        // Button styling
        playWithRobotButton.layer.cornerRadius = 30
        playWithRobotButton.layer.borderWidth = 10
        playWithRobotButton.layer.borderColor = #colorLiteral(red: 0, green: 0.2363941169, blue: 0.2894879827, alpha: 1)
        playWithRobotButton.backgroundColor = #colorLiteral(red: 0, green: 0.7333333333, blue: 0.8980392157, alpha: 1)
        playWithRobotButton.titleLabel?.font =  UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 30.0)
        playWithRobotButton.titleLabel?.adjustsFontSizeToFitWidth = true
        playWithRobotButton.titleLabel?.lineBreakMode = .byWordWrapping
        playWithRobotButton.titleLabel?.textAlignment = .center
        playWithRobotButton.titleLabel?.numberOfLines = 2
        
        playWithVirtualRobotButton.layer.cornerRadius = 30
        playWithVirtualRobotButton.layer.borderWidth = 10
        playWithVirtualRobotButton.layer.borderColor = #colorLiteral(red: 0.5231451956, green: 0.3179902169, blue: 0.1559177838, alpha: 1)
        playWithVirtualRobotButton.backgroundColor = #colorLiteral(red: 1, green: 0.6078431373, blue: 0.2980392157, alpha: 1)
        playWithVirtualRobotButton.titleLabel?.font =  UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 30.0)
        playWithVirtualRobotButton.titleLabel?.adjustsFontSizeToFitWidth = true
        playWithVirtualRobotButton.titleLabel?.lineBreakMode = .byWordWrapping
        playWithVirtualRobotButton.titleLabel?.textAlignment = .center
        playWithRobotButton.titleLabel?.numberOfLines = 2
        
        playWithXylophoneButton.layer.cornerRadius = 30
        playWithXylophoneButton.layer.borderWidth = 10
        playWithXylophoneButton.layer.borderColor = #colorLiteral(red: 0.3607843137, green: 0, blue: 0.7215686275, alpha: 1)
        playWithXylophoneButton.backgroundColor = #colorLiteral(red: 0.6745098039, green: 0.5215686275, blue: 0.9568627451, alpha: 1)
        playWithXylophoneButton.titleLabel?.font =  UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 30.0)
        playWithXylophoneButton.titleLabel?.adjustsFontSizeToFitWidth = true
        playWithXylophoneButton.titleLabel?.lineBreakMode = .byWordWrapping
        playWithXylophoneButton.titleLabel?.textAlignment = .center
        playWithXylophoneButton.titleLabel?.numberOfLines = 2
        
       
        // Accessibility
        playWithRobotButton.titleLabel?.adjustsFontForContentSizeCategory = true
        playWithVirtualRobotButton.titleLabel?.adjustsFontForContentSizeCategory = true
        instructions.titleLabel?.adjustsFontForContentSizeCategory = true
        settingsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        welcomeLabelImage.accessibilityLabel = NSLocalizedString("Welcome to Blocks4All!", comment: "Label for main menu screen")
        settingsButton.accessibilityLabel = NSLocalizedString("Settings", comment: "Accessibility Label for settings button on main menu screen")
        instructions.accessibilityLabel = NSLocalizedString("Help", comment: "Accessibility Label for help button on main menu screen")
        
        // Text
        playWithRobotButton.setTitle(NSLocalizedString("Play with Robot", comment: "Title for Play with Physical Robot button on main menu screen"), for: .normal)
        playWithVirtualRobotButton.setTitle(NSLocalizedString("Play with Virtual Robot", comment: "Title for Play with Virtual Robot button on main menu screen"), for: .normal)
        
        // Default settings
        // if show icons/show text hasn't been set yet, set showText to showIcons by default
        if  defaults.value(forKey: "showText") == nil {
            defaults.setValue(0, forKey: "showText")
        }
        // if blockSize hasn't been set yet, set it to be 150 by default
        if defaults.value(forKey: "blockSize") == nil {
            defaults.setValue(150, forKey: "blockSize")
        }
        
        // adding a gesture recognizer for an image view is from https://stackoverflow.com/questions/30990902/detect-uiimageview-touch-in-swift#:~:text=You%20can%20detect%20touches%20on,explicitly%20in%20storyboard%20or%20programmatically.
        robotImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(robotImageTapped)))
        
        accessibilityElements = [welcomeLabelImage!, playWithRobotButton!, playWithVirtualRobotButton!, settingsButton!, instructions!, robotImageView!]
    }
    
    @objc private func robotImageTapped(_ recognizer: UITapGestureRecognizer) {
        // Play sound
        // Code to play audio is from https://www.tutorialspoint.com/how-to-play-a-sound-using-swift
        guard let path = Bundle.main.path(forResource: "DashMainMenuSound", ofType:"mp3") else {
            print("Couldn't find sound file for DashMainMenuSound")
                 return }
        let url = URL(fileURLWithPath: path)
        do {
            if audioPlayer == nil {
               audioPlayer = try AVAudioPlayer(contentsOf: url)
            }
            audioPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
        // Play animation
        let oneActionTime = 0.15  // Make this number bigger to slow down the animation
        let distanceToWiggleDivider = 15.0  // Make this number bigger to make the wiggle larger
        
        // Turn to the right
        UIView.animate(withDuration: oneActionTime, delay: 0, options: .curveEaseInOut, animations:  {
            self.robotImageView.transform = self.robotImageView.transform.rotated(by: .pi / distanceToWiggleDivider)
        })
        
        // Turn all the way to the left
        UIView.animate(withDuration: oneActionTime * 2, delay: oneActionTime, options: .curveEaseInOut, animations:  {
            self.robotImageView.transform = self.robotImageView.transform.rotated(by: -.pi / (distanceToWiggleDivider / 2))
        })
        
        // Turn back to the right
        UIView.animate(withDuration: oneActionTime * 2, delay: oneActionTime * 3, options: .curveEaseInOut, animations:  {
            self.robotImageView.transform = self.robotImageView.transform.rotated(by: .pi / (distanceToWiggleDivider / 2))
        })
        
        // Turn left and return to the original position
        UIView.animate(withDuration: oneActionTime, delay: oneActionTime * 5, options: .curveEaseInOut, animations:  {
            self.robotImageView.transform = self.robotImageView.transform.rotated(by: -.pi / distanceToWiggleDivider)
        })
        
    }
   
   
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 11.0, *) {
            if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
                print("accessibility enabled")
                blockSize = 200
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let myDestination = segue.destination as? BlocksViewController{
            myDestination.blockSize = blockSize
        }
        if let destinationViewController = segue.destination as? UINavigationController{
            if destinationViewController.topViewController is BlocksViewController{
            }
        }
        
//        if segue.identifier == "mainToFreeplayGallery" {
//            let destinationViewController = segue.destination as? ProjectGalleryViewController
//            destinationViewController?.galleryType = FREEPLAY_GALLERY_TYPE
//        }
//        if segue.identifier == "mainToRobotGallery" {
//            let destinationViewController = segue.destination as? ProjectGalleryViewController
//            destinationViewController?.galleryType = ROBOT_GALLERY_TYPE
//        }
    }
}
