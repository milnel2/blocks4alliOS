//
//  WorkspaceCollectionView.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class ProjectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var projectNameLabel: UITextField!
    
    
    var parentViewController: ProjectGalleryViewController?
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var cellGalleryType: String = "Robot Projects"
    
    
    var project : Project! {
       didSet {
           self.updateUI()
       }
   }
    func updateUI() {
            
        if let project = project {
           imageView.image = UIImage(named:project.imageName)
           projectNameLabel.text = project.name
           //details.text = course.details
           //colorView.backgroundColor = course.color
        } else {
           imageView.image = nil
           projectNameLabel.text = nil
           //details.text = nil
           //colorView.backgroundColor = nil
        }
      
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
        

        
        projectNameLabel.adjustsFontForContentSizeCategory = true
        projectNameLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        projectNameLabel.borderStyle = .none
           
        updateAccessibilityTools()
       }
    // TODO: automatically name projects
    func updateAccessibilityTools() {
        isAccessibilityElement = false
        
        contentView.isAccessibilityElement = true
        accessibilityTraits = .allowsDirectInteraction
        
        
        
        projectNameLabel.isAccessibilityElement = true
       
        
        deleteButton.isAccessibilityElement = true
        
        
        contentView.accessibilityHint = "Open " + project.name + " Project" // TODO: add image description
        projectNameLabel.accessibilityHint = "Double tap to rename " + project.name + " Project"
        deleteButton.accessibilityHint = "Delete " + project.name + " Project"
        
        accessibilityElements = [contentView, projectNameLabel!, deleteButton!]
        
        
    }
    
   // TODO: text field gets covered by keyboard
    @IBAction func projectNameEdited(_ sender: Any) {
        let newName = projectNameLabel.text
        if validateFunctionName(name: newName ?? "") {
            // name is valid, rename the project
            for proj in allProjects[cellGalleryType]! {
                if proj.name == project.name {
                    proj.name = newName!
                    continue
                }
            }
            project.name = newName!
            
        }
        // if the name isn't valid, the textfield will go back to whatever the name previously was
        updateUI()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you sure you want to delete this project?", message: "This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {action in
            // delete project
            let index = allProjects[self.cellGalleryType]!.firstIndex(of: self.project)!
            allProjects[self.cellGalleryType]!.remove(at: index)
            // reload gallery
            self.parentViewController!.reloadGallery()
            print("deleted")
        }))
        parentViewController!.present(alert, animated: true)
        
    }
    
    func validateFunctionName(name: String) -> Bool{
        let dictionary = self.getModifierDictionary()!
        if (dictionary[name] != nil) {
            // Name is protected, show an alert do not rename the function
            
                let invalidNameAlert = UIAlertController(title: "Name is protected", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
               parentViewController!.present(invalidNameAlert, animated: true)
            
            return false
        } else if (name == "") {
            // Name is empty string
           
                let invalidNameAlert = UIAlertController(title: "Name cannot be empty", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                parentViewController!.present(invalidNameAlert, animated: true)
            
            return false
        } else if (self.project.currentActor!.functionDict.keys.contains(name))  {
            // Duplicate custom function name
           
                let invalidNameAlert = UIAlertController(title: "Name already exists", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
               parentViewController!.present(invalidNameAlert, animated: true)
            
            return false
        } else {
            for proj in allProjects[cellGalleryType]! {
                if proj.name == name {
                    
                        let invalidNameAlert = UIAlertController(title: "Name already exists", message: "Choose a different name", preferredStyle: .alert)
                        invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        parentViewController!.present(invalidNameAlert, animated: true)
                    
                    return false
                }
            }
        }
           
        return true
        
    }
    
    //TODO: make this a public static helper function
    /// Converts ModifierProperties plost to a NSDictionary
    private func getModifierDictionary () -> NSDictionary?{
        // this code to access a plist as a dictionary is from https://stackoverflow.com/questions/24045570/how-do-i-get-a-plist-as-a-dictionary-in-swift
        let dict: NSDictionary?
         if let path = Bundle.main.path(forResource: "ModifierProperties", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
         } else {
             print("could not access ModifierProperties plist")
             return nil
         }
        return dict!
    }
    
    
}
