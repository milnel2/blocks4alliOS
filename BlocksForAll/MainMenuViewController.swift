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
    @IBOutlet weak var getStarted: UIButton!
    @IBOutlet weak var instructions: UIButton!
    @IBOutlet weak var addRobots: UIButton!
    @IBOutlet weak var robotImageView: UIImageView!
    
    var blockSize = 150 // this controls the size of the blocks you put down in the Building Screen
    
    var audioPlayer: AVAudioPlayer?  // Used to play the sound effect the plays when you tap the robot image
    
    override func viewDidLoad() {
        // Accessibility
        getStarted.titleLabel?.adjustsFontForContentSizeCategory = true
        instructions.titleLabel?.adjustsFontForContentSizeCategory = true
        addRobots.titleLabel?.adjustsFontForContentSizeCategory = true
        
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
    }
    
    @objc private func robotImageTapped(_ recognizer: UITapGestureRecognizer) {
        // Play sound
        guard let path = Bundle.main.path(forResource: "DashMainMenuSound", ofType:"mp3") else {
            print("couldnt find sound")
                 return }
        let url = URL(fileURLWithPath: path)
        print("playing \(path)")
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
            print("block size " , blockSize)
        }
        if let destinationViewController = segue.destination as? UINavigationController{
            if destinationViewController.topViewController is BlocksViewController{
                print("block size 2 " , blockSize)
            }
        }
    }
}
