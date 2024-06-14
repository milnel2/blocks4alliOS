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
   
    @IBOutlet weak var renameButton: UIButton!
    
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
       
           
       }
       
   
    @IBAction func renameButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Enter project name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "New Project Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            if self.validateFunctionName(name: textField.text!, currentAlert: alert) {
                // name is valid, rename the project
                for proj in allProjects[self.cellGalleryType]! {
                    if proj.name == self.project.name {
                        proj.name = textField.text!
                        continue
                    }
                }
                self.project.name = textField.text!
                self.updateUI()
            }
            
        }))

        parentViewController!.present(alert, animated: true)
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
    
    func validateFunctionName(name: String, currentAlert: UIAlertController) -> Bool{
        let dictionary = self.getModifierDictionary()!
        if (dictionary[name] != nil) {
            // Name is protected, show an alert do not rename the function
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: "Name is protected", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.parentViewController!.present(invalidNameAlert, animated: true)
            }
            return false
        } else if (name == "") {
            // Name is empty string
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: "Name cannot be empty", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.parentViewController!.present(invalidNameAlert, animated: true)
            }
            return false
        } else if (self.project.functionDict.keys.contains(name))  {
            // Duplicate custom function name
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: "Name already exists", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.parentViewController!.present(invalidNameAlert, animated: true)
            }
            return false
        } else {
            for proj in allProjects[cellGalleryType]! {
                if proj.name == name {
                    currentAlert.dismiss(animated: true) {
                        let invalidNameAlert = UIAlertController(title: "Name already exists", message: "Choose a different name", preferredStyle: .alert)
                        invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.parentViewController!.present(invalidNameAlert, animated: true)
                    }
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
