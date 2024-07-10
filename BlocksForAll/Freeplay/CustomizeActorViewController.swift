//
//  CustomizeActorViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 7/1/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

// View Controller used to set color of selected freeplay actor
class CustomizeActorViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton! // button to return to the freeplay workspace
    @IBOutlet weak var deleteButton: UIButton! // button the delete the actor
    @IBOutlet weak var actorImageDisplayView: UIImageView! // image showing the actor
    
    @IBOutlet weak var defaultButton: UIButton! // default color button
    @IBOutlet weak var redButton: UIButton! // red color button
    @IBOutlet weak var yellowButton: UIButton! // yellow color button
    @IBOutlet weak var blueButton: UIButton! // blue color button
    
    @IBOutlet var colorButtons: [UIButton]! // array of all color buttons
    
    var currentActor: VirtualRobot? = nil // actor currently customizing
    var currentProject: Project? = nil // project the actor is in
    var freeplayWorkspace: FreePlayWorkspaceViewController? = nil // freeplay workspace that this screen came from
    
    var selectedColor = "" // color name currently selected
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        // Verify choice to delete actor
        let alert = UIAlertController(title: "Are you sure you want to delete this actor?", message: "This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
            // delete actor
            self.freeplayWorkspace!.deleteActor(actor: self.currentActor!)
            self.performSegue(withIdentifier: "backToFreeplay", sender: nil)
        }))
        present(alert, animated: true)
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
        // Styling
        for button in colorButtons {
            button.titleLabel?.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // default color button text should always be black, even in dark mode because its background color is white. This is done in the storyboard by setting the foreground color of the button
            
            button.layer.borderWidth = 5
            button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
           
            button.layer.cornerRadius = 10
            
            // highlight and unhighlight all buttons to get the font sizes to all be the same
            highlightButton(button: button)
            removeHighlightFromButton(button: button)
        }
        
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
        
        if currentProject!.actors.count > 1 { // don't allow deleting when there is only one actor left
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false // can't delete the only actor
        }
    }
    
    func setUpAccessibility() {
        actorImageDisplayView.accessibilityLabel = "\(currentActor!.name) \(selectedColor) Color."
        for button in colorButtons {
            button.accessibilityHint = "Double tap to set color"
        }
        
        view.accessibilityElements = [actorImageDisplayView!, colorButtons!, deleteButton!, backButton!]
        
        deleteButton.accessibilityHint = "Delete \(currentActor!.name) actor."
    }
    
    /// Sets actor image display to the image for the given color name
    func setActorDisplayColor(color: String) {
        let imagePath = VirtualRobot.calculateImagePath(baseImagePath: currentActor!.baseImagePath, color: color)
        actorImageDisplayView.image = UIImage(named: imagePath)
        setUpAccessibility()
    }
    
    /// Remove selction highlight from all color buttons
    func resetColorHighlights() {
        for button in colorButtons {
            removeHighlightFromButton(button: button)
        }
    }
    
    /// Adds selected highlight to given button
    func highlightButton(button: UIButton) {
        button.layer.borderWidth = 10
        button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        button.isSelected = true
    }
    
    /// Removes any selected highlight from given button
    func removeHighlightFromButton(button: UIButton) {
        button.layer.borderWidth = 5
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
       
        button.isSelected = false
    }
    
    /// Set color to default
    @IBAction func defaultPressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: defaultButton)
        selectedColor = "Default"
        setActorDisplayColor(color: "Default")
    }
    
    /// Set color to red
    @IBAction func redPressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: redButton)
        selectedColor = "Red"
        setActorDisplayColor(color: "Red")
    }
    
    /// Set color to yellow
    @IBAction func yellowPressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: yellowButton)
        selectedColor = "Yellow"
        setActorDisplayColor(color: "Yellow")
    }
    
    /// Set color to blue
    @IBAction func bluePressed(_ sender: Any) {
        resetColorHighlights()
        highlightButton(button: blueButton)
        selectedColor = "Blue"
        setActorDisplayColor(color: "Blue")
    }
    
}
