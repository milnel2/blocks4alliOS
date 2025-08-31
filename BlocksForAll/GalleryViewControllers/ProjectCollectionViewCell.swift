//
//  WorkspaceCollectionView.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

// UICollectionViewCell used in gallery to represent a project. Has an image, name, and delete button
class ProjectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! // Displays screenshot of the project
    
    @IBOutlet weak var projectNameLabel: UILabel! // Displays the name of the project. Can be edited
    
    var parentViewController: ProjectGalleryViewController? // View Controller that the cell is a part of
    
    @IBOutlet weak var deleteButton: UIButton! // Button to delete project
    
    var cellGalleryType: String = ROBOT_GALLERY_TYPE // Type of project that the cell is for: either robot or freeplay
    
    var project : Project! { // associated Project object
       didSet {
           self.updateUI()
           self.setUpProjectLabelTap()
       }
    }
    
    func updateUI() {
        if let project = project {
            if project.imageName != "" {
                // Set up and add project image
                let resizedImage = HelperFunctions.resizeImage(image: HelperFunctions.getUIImage(named: project.imageName), scaledToSize: imageView.frame.size)
                imageView.image = resizedImage
                imageView.contentMode = .scaleToFill
            }
            // Project name
           projectNameLabel.text = project.name
        } else {
           imageView.image = nil
           projectNameLabel.text = nil
        }
      
        // Styling
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
        
        projectNameLabel.adjustsFontForContentSizeCategory = true
        projectNameLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 34.0)
        
        // Accessibility
        updateAccessibilityTools()
       }
    
    // When the project name label is tapped, prompt to rename the project
    @objc func projectLabelTapped(_ sender: UITapGestureRecognizer) {
        // Show rename project alert
        let titleString: String
        let placeholderString: String
        
        titleString = NSLocalizedString("Enter project name", comment: "Title for alert to name a new project")
        placeholderString = NSLocalizedString("Your project name", comment: "Placeholder text for textfield to enter project name")
       
        let alert = UIAlertController(title: titleString, message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = placeholderString
        }
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            if self.validateProjectName(name: textField.text ?? "") {
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
            // if the name isn't valid, the label will go back to whatever the name previously was
            updateUI()
        }
    
    /// Adds tap gesture to project name label for renaming project
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
        projectNameLabel.accessibilityTraits = [.button, .allowsDirectInteraction]
        
        deleteButton.isAccessibilityElement = true
        deleteButton.accessibilityTraits = [.button, .allowsDirectInteraction]

        accessibilityElements = [contentView, projectNameLabel!, deleteButton!]
        
        let cellIndex = allProjects[cellGalleryType]?.firstIndex(of: project) ?? 0
        let numProjects = allProjects[cellGalleryType]?.count ?? 0
        
        let formattedString = NSLocalizedString("project_name_label_access_label", comment: "Accessibility label for Project Name Label. Tapping the label will allow user to rename the project")
        let resultString = String.localizedStringWithFormat(formattedString, project.name)
        projectNameLabel.accessibilityLabel = resultString
        
        let formattedString2 = NSLocalizedString("project_cell_access_hint", comment: "Accessibility hint for project cell in the project gallery.")
        let resultString2 = String.localizedStringWithFormat(formattedString2, project.name, (cellIndex + 1), numProjects)
        contentView.accessibilityHint = resultString2
        
        let formattedString3 = NSLocalizedString("delete_project_button_access_label", comment: "Accessibility label for Delete Project Button on project cell in project gallery")
        let resultString3 = String.localizedStringWithFormat(formattedString3, project.name)
        deleteButton.accessibilityLabel = resultString3
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        // Verify delete action
        let titleString: String
        
        titleString = NSLocalizedString("Are you sure you want to delete this project?", comment: "")
        
        let alert = UIAlertController(title: titleString, message: "This action cannot be undone.".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: {action in
            // delete project
            let index = allProjects[self.cellGalleryType]!.firstIndex(of: self.project)!
            allProjects[self.cellGalleryType]!.remove(at: index)
            // reload gallery
            self.parentViewController!.reloadGallery()
        }))
        parentViewController!.present(alert, animated: true)
    }
    
    func validateProjectName(name: String) -> Bool{
        let dictionary = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties")!
        if (dictionary[name] != nil) {
            // Name is protected, show an alert do not rename the function
            let titleString: String
            let messageString: String
            
            titleString = NSLocalizedString("Name is protected", comment: "")
            messageString = NSLocalizedString("Choose a different name", comment: "")
        
            let invalidNameAlert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
            invalidNameAlert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
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
            let titleString: String
            let messageString: String
            
            titleString = NSLocalizedString("Name already exists", comment: "")
            messageString = NSLocalizedString("Choose a different name", comment: "")
        
            let invalidNameAlert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
            invalidNameAlert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
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
