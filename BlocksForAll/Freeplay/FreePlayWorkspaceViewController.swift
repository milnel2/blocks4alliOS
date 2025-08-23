//
//  FreePlayWorkspaceViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/7/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

var isInFreeplay: Bool = false // global variable for if the freeplay workspace is open

// View Controller for Freeplay Mode.
class FreePlayWorkspaceViewController: BlocksViewController {
    
    @IBOutlet weak var freeplayOutputView: FreeplayOutputView! // View where actors are located
    
    @IBOutlet weak var homeButton: UIButton! // Button to return to main menu
    
    @IBOutlet weak var currentActorImageView: UIImageView! // image view that shows which actor is currently selected and is being edited
    
    @IBOutlet weak var outputBackgroundImageView: UIImageView! // background image for output
    
    @IBOutlet weak var enterFullScreenButton: UIButton! // button to make output be in fullscreen
    @IBOutlet weak var FirstCodeLineButton: UIButton! // button to open the first code line of the blocksProgram
    
    @IBOutlet weak var secondCodeLineButton: UIButton! // button to open the second code line of the blocksProgram
    
    @IBOutlet weak var buttonsView: UIView! // view that has play button, code lines, and customize actor button
    @IBOutlet weak var addActorButton: UIButton! // button to add a new actor to the project
    
    var newActorToAdd: (name:String, baseImagePath: String, color: String)? // to be used when adding to actors
    
    var backgroundImagePath: String? = nil // Image path for the current background image in the output view
    
    var currentFunctionDict: [String : [Block]]{ // Function dictionary for the actor that is currently selected
        get { return UserData.data.getCurrentProject()!.currentActor!.functionDict}
        set {
            UserData.data.getCurrentProject()!.currentActor!.functionDict = newValue
        }
    }
    
    override func viewDidLoad() {
        if (currentProject == nil) {
            print("ERROR: current project is nil")
        }
        
        freeplayOutputView.freeplayWorkspaceVC = self // Attach self to the output view
        freeplayOutputView.resetActorSubviews() // Remove all actors from output view
        
        // Add actors to the scene
        for actor in currentProject!.actors {
            actor.addFreeplayOutputView(freeplayOutputView: freeplayOutputView) // Attach actor to the output view
            addActor(actor: actor)
        }
        
        isInFreeplay = true
        
        currentWorkspace = ON_RUN_STRING
        
        super.viewDidLoad()
        
        // Styling
        currentActorImageView.alpha = 0.5
        workspaceTitle.text = currentProject!.name
        workspaceTitle.layer.cornerRadius = 10.0
        workspaceTitle.layer.masksToBounds = true
        workspaceTitle.textColor = .black
        addActorButton.layer.masksToBounds = true // allows for corner radius to work
        addActorButton.layer.cornerRadius = 10
        freeplayOutputView.backgroundColor = UIColor(named: "whiteLightModeBlackDarkMode")
        
        updateUI()
        
        // If there is a new actor that needs to be added to the project (coming from the add actor screen), add it.
        if newActorToAdd != nil {
            afterNewActorSelected(name: newActorToAdd!.name, baseImagePath: newActorToAdd!.baseImagePath)
        }
        
        // Add tap gesture recognizer to current actor image
        // Tap Gesture code from https://agrawalsuneet.medium.com/uiview-clicklistener-swift-88ab5dec64b5
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(clickOnCurrentActorImageView(sender:)))
        
        currentActorImageView.addGestureRecognizer(tapGesture)
        
        // Set the background image to be the saved background. Also connects the image view to the output view
        backgroundImagePath = currentProject!.currentBackground?.getImagePath()
        freeplayOutputView.setBackgroundImageView(imageView: outputBackgroundImageView)
        freeplayOutputView.setBackgroundImage(newImagePath: backgroundImagePath)
        
        setUpAccessibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpAccessibility()
    }
    
    // MARK: Actions
    
    // When the current actor image is clicked, go to the customize actor screen
    @objc func clickOnCurrentActorImageView(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "toCustomizeActor", sender: nil)
    }
    
    @IBAction func enterFullScreenPressed(_ sender: Any) {
        performSegue(withIdentifier: "enterFullScreen", sender: nil)
    }
    
    @IBAction func addActorClicked(_ sender: Any) {
        performSegue(withIdentifier: "toChooseActor", sender: nil)
    }
    
    @IBAction func firstCodeLinePressed(_ sender: Any) {
        updateCurrentWorkspace(name: ON_RUN_STRING)
        updateUI()
    }

    @IBAction func secondCodeLinePressed(_ sender: Any) {
        updateCurrentWorkspace(name: ON_TAP_STRING)
        updateUI()
    }
    
    // MARK: Blocks Program
    
    //this function allows the blocks in the workspace to be sent to the virtual robot
    override func play(functionsDictToPlay: [String : [Block]], functionNameToExecute: String? = nil, actor: VirtualRobot? = nil){
        let newRobotControlVC = RobotControlViewController()
        executingProgram = ExecutingProgram(functionsDictToExecute: functionsDictToPlay, robotControlViewController: newRobotControlVC, functionNameToExecute: functionNameToExecute, actor: actor)
        newRobotControlVC.executingProgram = executingProgram
        newRobotControlVC.blocksViewController = self
        
        actor?.executingProgram = executingProgram
        
        executingProgram?.robotControlViewController.executeNextCommandRobotControllVC()
    }
    
    // When the play button is clicked, run the On Run code line for all actors
    override func playClicked() {
        stopIsOption = true
        changePlayTrashButton()
        //Calls RobotControllerViewController play function
        for actor in currentProject!.actors {
            play(functionsDictToPlay: actor.functionDict, functionNameToExecute: ON_RUN_STRING, actor: actor)
            actor.isRunning = true
        }
        robotRunning = true
        // disable modifier blocks while the robot is running
        for modifierBlock in allModifierBlocks {
            modifierBlock.isEnabled = false
            modifierBlock.isAccessibilityElement = false
        }
        refreshScreen()
    }
    
    // MARK: Actors
    // Called after returning from the add actor screen. Creates and adds a new actor to the project.
    func afterNewActorSelected(name: String, baseImagePath: String) {
        let newRobot = VirtualRobot(baseImagePath: baseImagePath, freeplayOutputView: freeplayOutputView, name: name, project: currentProject!)
        addActor(actor: newRobot)
        setCurrentActor(newActor: newRobot) // Set this new actor as the current actor
        newActorToAdd = nil
    }
    
    // Attach actor to the freeplay output view
    func addActor(actor: VirtualRobot) {
        freeplayOutputView.addActor(actor: actor)
    }
    
    // Set the actor that is currently being edited
    func setCurrentActor(newActor: VirtualRobot) {
        currentProject!.currentActor = newActor
        
        refreshScreen()
        updateUI()
    }
    
    // Delete actor from the project
    func deleteActor(actor: VirtualRobot) {
        currentProject!.deleteActor(actor: actor)
    }
    
    // MARK: Project
    
    // save snapshot of the output view and link it with the current project
    override func saveProjectSnapshot() {
        
        // rendering view as image is from: https://www.hackingwithswift.com/example-code/media/how-to-render-a-uiview-to-a-uiimage
        let renderer = UIGraphicsImageRenderer(size: freeplayOutputView.bounds.size)
        let image = renderer.image { ctx in
            freeplayOutputView.drawHierarchy(in: freeplayOutputView.bounds, afterScreenUpdates: true)
        }
        currentProject!.imageName = generateImageName()
    
        // Save image to  directory
        let imageURL = HelperFunctions.getDocumentsDirectory().appendingPathComponent(currentProject!.imageName)
        if let data = image.pngData() {
            do {
                try data.write(to: imageURL)
                } catch {
                    print("Unable to Write Image Data to Disk")
                }
        }
    }
    
    // MARK: UI
    func updateUI() {
        // Update current actor image
        let newImage = HelperFunctions.getUIImage(named: (currentProject?.currentActor!.imagePath)!)
     
        self.currentActorImageView.image = newImage.stroked(with: .white, thickness: 5) // Add border to image
        
        
        // Styling
        FirstCodeLineButton.titleLabel?.font =  UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 24.0)
        secondCodeLineButton.titleLabel?.font =  UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 24.0)
        
        // Allow for dark mode if possible
        if #available(iOS 13.0, *) {
            FirstCodeLineButton.setTitleColor(.label, for: .selected)
            FirstCodeLineButton.setTitleColor(.label, for: .normal)
            secondCodeLineButton.setTitleColor(.label, for: .selected)
            secondCodeLineButton.setTitleColor(.label, for: .normal)
        } else {
            // Fallback on earlier versions
            FirstCodeLineButton.setTitleColor(.black, for: .selected)
            FirstCodeLineButton.setTitleColor(.black, for: .normal)
            secondCodeLineButton.setTitleColor(.black, for: .selected)
            secondCodeLineButton.setTitleColor(.black, for: .normal)
        }
        
        // reset button images
        FirstCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Blue"), for: .normal)
        secondCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Orange"), for: .normal)
       
        // highlight the active code line button
        switch currentWorkspace {
        case ON_RUN_STRING:
            FirstCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Blue-Highlighted"), for: .normal)
        case ON_TAP_STRING:
            secondCodeLineButton.setBackgroundImage(UIImage(named: "CodeLineButton_Orange-Highlighted"), for: .normal)
        default:
            break
        }
        
        setUpAccessibility()
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "toChooseActor") {
          let chooseActorVC = segue.destination as! ChooseActorViewController
           chooseActorVC.currentActorImageView = currentActorImageView
           chooseActorVC.freeplayOutputView = freeplayOutputView
       }
        if (segue.identifier == "enterFullScreen") {
            let fullscreenVC = segue.destination as! FullScreenFreeplayViewController
            
            fullscreenVC.freeplayWorkspaceVC = self
            fullscreenVC.smallViewSize = freeplayOutputView.frame.size
            fullscreenVC.freeplayWorkspaceOriginalPlayButton = playTrashToggleButton
            
            for actor in currentProject!.actors {
                actor.executingProgram?.stopWasPressed = true
            }
        }
        
        if (segue.identifier == "toCustomizeActor") {
            let customizeVC = segue.destination as! CustomizeActorViewController
            customizeVC.currentActor = currentProject!.currentActor
            customizeVC.freeplayWorkspace = self
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
    // MARK: Accessibility
    func setUpAccessibility() {
        freeplayOutputView.isAccessibilityElement = false
        
        freeplayOutputView.accessibilityElements = []
        
        for actor in currentProject!.actors {
            actor.setUpAccessibility()
            freeplayOutputView.accessibilityElements!.append(actor.imageView)
        }
        
        freeplayOutputView.accessibilityElements!.append(enterFullScreenButton!)
        
        currentActorImageView.isUserInteractionEnabled = true
        currentActorImageView.isAccessibilityElement = true
        currentActorImageView.accessibilityTraits = .button
        
        mainMenuButton.isAccessibilityElement = true
        mainMenuButton.isUserInteractionEnabled = true
        mainMenuButton.accessibilityTraits = .button
        
        homeButton.accessibilityLabel = "Main Menu".localized
        
        // Set the accessibility elements for the screen
        resetAccessibilityElements()
        
        addActorButton.accessibilityLabel = NSLocalizedString("Add actor to project.", comment: "Accessibility label for Add Actor Button")
        
        let formattedString = NSLocalizedString("current_actor_image_view_access_label", comment: "Accessibility label for Current Actor Image")
        let actorNameLocalized = currentProject!.currentActor!.name.localized
        let resultString = String.localizedStringWithFormat(formattedString, actorNameLocalized)
        currentActorImageView.accessibilityLabel = resultString
        
        FirstCodeLineButton.accessibilityLabel = NSLocalizedString("On Run code line.", comment: "Accessibility label for On Run Code Line Button")
       
        secondCodeLineButton.accessibilityLabel = NSLocalizedString("On Actor Tap code line.", comment: "Accessibility label for On Actor Tap Code Line Button")
        
        let formattedString2 = NSLocalizedString("second_code_line_access_hint", comment: "Accessibility hint for On Actor Tap Code Line Button")
        let resultString2 = String.localizedStringWithFormat(formattedString2, actorNameLocalized)
        secondCodeLineButton.accessibilityHint = resultString2
        
        enterFullScreenButton.accessibilityLabel = NSLocalizedString("Enter full screen.", comment: "Accessibility Label for Enter Full Screen button")
           
        // highlight the active code line button
        switch currentWorkspace {
        case ON_RUN_STRING:
            secondCodeLineButton.isSelected = false
            FirstCodeLineButton.isSelected = true
        case ON_TAP_STRING:
            secondCodeLineButton.isSelected = true
            FirstCodeLineButton.isSelected = false
        default:
            break
        }
    }
    
    // Update accessibility elements to make navigation easier when moving blocks
    override func beginMovingBlocks(_ blocks: [Block]) {
        super.beginMovingBlocks(blocks)
        accessibilityElements = [toolboxView!, playTrashToggleButton!, FirstCodeLineButton!, secondCodeLineButton!, blocksProgram!, mainMenuButton!]
    }
    
    override func finishMovingBlocks() {
        super.finishMovingBlocks()
        resetAccessibilityElements()
    }
    
    /// Reset accessibility elements for accessing the entire screen
    func resetAccessibilityElements() {
        accessibilityElements = [toolboxView!, freeplayOutputView!, mainMenuButton!, addActorButton!, currentActorImageView!, playTrashToggleButton!, FirstCodeLineButton!, secondCodeLineButton!, blocksProgram!] // toolbox, output, home, add actor, customize, play, line 1, line 2, blocks program
    }
}

public extension UIImage {
    // Code for changing the color of a UIImage is from https://sarunw.com/posts/how-to-change-uiimage-color-in-swift/
    /// Returns a new UIImage with the specified color or the original image if something went wrong
    func colorized (with color: UIColor = .white) -> UIImage {
        let newImage = self.withColor(color)
        
        if newImage == nil {
            return self
        }
        return newImage!
    }
    // Code for changing the color of a UIImage is from https://sarunw.com/posts/how-to-change-uiimage-color-in-swift/
    func withColor(_ color: UIColor) -> UIImage? {
           UIGraphicsBeginImageContextWithOptions(size, false, scale)
           let drawRect = CGRect(x: 0,y: 0,width: size.width,height: size.height)
           color.setFill()
           UIRectFill(drawRect)
           draw(in: drawRect, blendMode: .destinationIn, alpha: 1)

           let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return tintedImage!
       }
    
    // Code to add an outline to a UIImage is from Stéphane de Luca's answer on https://stackoverflow.com/questions/47900243/how-to-add-colored-border-to-uiimage-in-swift
    /// Returns a new UIImage with a border in the specified color or the original image if something went wrong
    func stroked(with color: UIColor = .white, thickness: CGFloat = 2, quality: CGFloat = 10) -> UIImage {

           guard let cgImage = cgImage else { return self }

           // Colorize the stroke image to reflect border color
           let strokeImage = colorized(with: color)

           guard let strokeCGImage = strokeImage.cgImage else { return self }

           /// Rendering quality of the stroke
           let step = quality == 0 ? 10 : abs(quality)

           let oldRect = CGRect(x: thickness, y: thickness, width: size.width, height: size.height).integral
           let newSize = CGSize(width: size.width + 2 * thickness, height: size.height + 2 * thickness)
           let translationVector = CGPoint(x: thickness, y: 0)

           UIGraphicsBeginImageContextWithOptions(newSize, false, scale)

           guard let context = UIGraphicsGetCurrentContext() else { return self }

           defer {
               UIGraphicsEndImageContext()
           }
           context.translateBy(x: 0, y: newSize.height)
           context.scaleBy(x: 1.0, y: -1.0)
           context.interpolationQuality = .high

           for angle: CGFloat in stride(from: 0, to: 360, by: step) {
               let vector = translationVector.rotated(around: .zero, byDegrees: angle)
               let transform = CGAffineTransform(translationX: vector.x, y: vector.y)

               context.concatenate(transform)

               context.draw(strokeCGImage, in: oldRect)

               let resetTransform = CGAffineTransform(translationX: -vector.x, y: -vector.y)
               context.concatenate(resetTransform)
           }

           context.draw(cgImage, in: oldRect)

           guard let stroked = UIGraphicsGetImageFromCurrentImageContext() else { return self }

           return stroked
       }
}

// CGPoint extension code is from Stéphane de Luca's answer on https://stackoverflow.com/questions/47900243/how-to-add-colored-border-to-uiimage-in-swift
extension CGPoint {
    /**
    Rotates the point from the center `origin` by `byDegrees` degrees along the Z axis.

    - Parameters:
        - origin: The center of he rotation;
        - byDegrees: Amount of degrees to rotate around the Z axis.

    - Returns: The rotated point.
    */
    func rotated(around origin: CGPoint, byDegrees: CGFloat) -> CGPoint {
        let dx = x - origin.x
        let dy = y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + byDegrees * .pi / 180.0 // to radians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
}
