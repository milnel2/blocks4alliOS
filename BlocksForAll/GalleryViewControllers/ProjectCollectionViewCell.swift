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
    
    @IBOutlet weak var projectNameLabel: UILabel!
    
    
    var parentViewController: ProjectGalleryViewController?
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var cellGalleryType: String = ROBOT_GALLERY_TYPE
    
    
    var project : Project! {
       didSet {
           self.updateUI()
           self.setUpProjectLabelTap()
       }
   }
    func updateUI() {
            
        if let project = project {
            
           
            
            if project.image != nil {
                let resizedImage = HelperFunctions.resizeImage(image: project.image!, scaledToSize: imageView.frame.size)
                imageView.image = resizedImage
                imageView.contentMode = .scaleToFill
            }
          
        
            
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
        
           
        updateAccessibilityTools()
        
       }
    
    @objc func projectLabelTapped(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Enter project name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Your project name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            if self.validateFunctionName(name: textField.text ?? "") {
                let newName = textField.text!
                // name is valid, rename the project
                for proj in allProjects[self.cellGalleryType]! {
                    if proj.name == self.project.name {
                        proj.name = newName
                        continue
                    }
                }
                self.project.name = newName
                self.updateUI()
            }
            
        }))

            parentViewController!.present(alert, animated: true)
        
            // if the name isn't valid, the textfield will go back to whatever the name previously was
        updateUI()
        }
        
    func setUpProjectLabelTap() {
        // adding tap gesture to UILabel is from https://medium.com/app-makers/how-to-add-a-tap-gesture-to-uilabel-in-xcode-swift-7ada58f1664
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.projectLabelTapped(_:)))
        self.projectNameLabel.isUserInteractionEnabled = true
        self.projectNameLabel.addGestureRecognizer(labelTap)
        }
  
    
    func updateAccessibilityTools() {
        isAccessibilityElement = false
        
        contentView.isAccessibilityElement = true
        contentView.accessibilityTraits = .button
        accessibilityTraits = .allowsDirectInteraction
        
        projectNameLabel.isAccessibilityElement = true
        projectNameLabel.accessibilityTraits = .button
        projectNameLabel.accessibilityLabel = "Rename " + project.name
        
        deleteButton.isAccessibilityElement = true
        
        
        contentView.accessibilityHint = "Open " + project.name  // TODO: add image description
        deleteButton.accessibilityLabel = "Delete " + project.name
        
        
        accessibilityElements = [contentView, projectNameLabel!, deleteButton!]
        
        
    }
    
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
        }))
        parentViewController!.present(alert, animated: true)
        
    }
    
    func validateFunctionName(name: String) -> Bool{
        let dictionary = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties")!
        if (dictionary[name] != nil) {
            // Name is protected, show an alert do not rename the function
            
                let invalidNameAlert = UIAlertController(title: "Name is protected", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
               parentViewController!.present(invalidNameAlert, animated: true)
            
            return false
        } else if (name == "") {
            // Empty name. Do nothing
            return false
        } else if (self.project.currentActor!.functionDict.keys.contains(name))  {
            // Duplicate custom function name
            if (self.project.name == name) {
                // is the same name as before. Do nothing
                return false
            }
                let invalidNameAlert = UIAlertController(title: "Name already exists", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
               parentViewController!.present(invalidNameAlert, animated: true)
            
            return false
        } else {
            for proj in allProjects[cellGalleryType]! {
                if proj.name == name {
                    // is the same name as before. Do nothing
                    return false
                }
            }
        }
           
        return true
        
    }
    
    
    
    
    
}
