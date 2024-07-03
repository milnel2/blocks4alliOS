//
//  CustomizeActorViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 7/1/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class CustomizeActorViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var actorImageDisplayView: UIImageView!
    
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    @IBOutlet var colorButtons: [UIButton]!
    
    
    var currentActor: VirtualRobot? = nil
    var currentProject: Project? = nil
    var freeplayWorkspace: FreePlayWorkspaceViewController? = nil
    
    var selectedColor = ""
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        freeplayWorkspace!.deleteActor(actor: currentActor!)
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass back data to freeplay workspace
        if let destination = segue.destination as? FreePlayWorkspaceViewController {
            destination.currentProject = currentProject
            currentActor!.imagePath = VirtualRobot.calculateImagePath(baseImagePath: currentActor!.baseImagePath, color: selectedColor)
            currentActor!.color = selectedColor
            currentActor!.updateImageView()
        }
    }
    
    override func viewDidLoad() {
        actorImageDisplayView.image = UIImage(named: currentActor!.imagePath)
        
        selectedColor = currentActor!.color
        // show previous selection
        resetColorHighlights()
        switch currentActor!.color {
        case "Default":
            highlightButton(button: defaultButton)
        case "Red":
            highlightButton(button: redButton)
        case "Yellow":
            highlightButton(button: yellowButton)
        case "Blue":
            highlightButton(button: blueButton)
        default:
            highlightButton(button: defaultButton)
        }
        
        setUpAccessibility()
        
    }
    
    func setUpAccessibility() {
        accessibilityElements = [actorImageDisplayView!, defaultButton!, redButton!, yellowButton!, blueButton!, backButton!, deleteButton!]
        actorImageDisplayView.accessibilityLabel = "\(currentActor!.name) \(currentActor!.color) Color."
        // TODO: for some reason focus is being set on the back button first
        for button in colorButtons {
            button.accessibilityHint = "Double tap to set color"
        }
    }
    
    func setActorDisplayColor(color: String) {
        let imagePath = VirtualRobot.calculateImagePath(baseImagePath: currentActor!.baseImagePath, color: color)
        actorImageDisplayView.image = UIImage(named: imagePath)
    }
    
    func resetColorHighlights() {
        for button in colorButtons {
            removeHighlightFromButton(button: button)
        }
    }
    
    func highlightButton(button: UIButton) {
        button.layer.borderWidth = 10
        button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        button.isSelected = true
    }
    
    func removeHighlightFromButton(button: UIButton) {
        button.layer.borderWidth = 0
        button.isSelected = false
    }
    
    @IBAction func defaultPressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: defaultButton)
        selectedColor = "Default"
        setActorDisplayColor(color: "Default")
    }
    @IBAction func redPressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: redButton)
        selectedColor = "Red"
        setActorDisplayColor(color: "Red")
    }
    @IBAction func yellowPressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: yellowButton)
        selectedColor = "Yellow"
        setActorDisplayColor(color: "Yellow")
    }
    @IBAction func bluePressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: blueButton)
        selectedColor = "Blue"
        setActorDisplayColor(color: "Blue")
    }
    
}
