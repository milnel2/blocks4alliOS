//
//  WorkspaceGalleryViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

// Code to create the carousel gallery effect is from https://medium.com/macoclock/create-a-horizontal-collection-view-with-carousel-effect-swift-5-xcode-10-1cd41395c387

import Foundation
import UIKit

class ProjectGalleryViewController: UIViewController {
    
    @IBOutlet weak var projectGalleryCollectionView: UICollectionView!
    
    @IBOutlet weak var homeButton: UIButton!
    
    var projects: [Project] = []
    var cellScale : CGFloat = 0.28
    
    private var cellWidth: CGFloat = 100
    private var cellHeight: CGFloat = 100
    
    let cellSpacing: CGFloat = 50
    var displayedCellIndex = 0
    
    var galleryType: String = "Robot Projects"
    
    override func viewDidLoad() { // TODO: put most recently used project at the front of the list of projects
        super.viewDidLoad()
        
        projects = Project.FetchProjects()[galleryType]!
        
        projectGalleryCollectionView.dataSource = self
        projectGalleryCollectionView.delegate = self
        
        let screenSize = UIScreen.main.bounds.size
        cellWidth = floor(screenSize.width * cellScale)
        cellHeight = floor(screenSize.height * cellScale)
        
       
        
        projectGalleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
        
        updateUI()
        
        
       
    }
   
   
    
    func reloadGallery() {
        self.projects = allProjects[self.galleryType]!
        projectGalleryCollectionView.reloadData()
        updateUI()
    }
    
    func updateUI() {
       
        updateAccessibilityTools()
    }
    func updateAccessibilityTools() {
    
        // TODO: home buttons is being focused instead of the first cell
        accessibilityElements = [homeButton!, projectGalleryCollectionView!]
        
       
    }
    
   
    func validateFunctionName(name: String, currentAlert: UIAlertController) -> Bool{
        let dictionary = self.getModifierDictionary()!
        if (dictionary[name] != nil) {
            // Name is protected, show an alert do not rename the function
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: "Name is protected", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        } else if (name == "") {
            // Name is empty string
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: "Name cannot be empty", message: "Choose a different name", preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        } else {
            for proj in allProjects[galleryType]! {
                if proj.name == name {
                        let invalidNameAlert = UIAlertController(title: "Name already exists", message: "Choose a different name", preferredStyle: .alert)
                        invalidNameAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(invalidNameAlert, animated: true)
                    
                    return false
                }
            }
        }
        return true
        
    }
    
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

extension ProjectGalleryViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects.count + 1 // add one to allow for the add project cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let index = indexPath.item
       
        
        if index == 0 {
            // Add Project Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addProjectCell", for: indexPath) as! AddProjectCollectionViewCell
           
            cell.updateAccessibilityTools()
            cell.layer.borderWidth = 5
            
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 2.0
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
            cell.layer.shadowRadius = 2.0
            return cell
        } else {
            // Project Cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectsCell", for: indexPath) as! ProjectCollectionViewCell
            
            
            
            let project = projects[index - 1] // shift index over 1 because index 0 is the add project cell
            cell.project = project
            cell.parentViewController = self
            cell.cellGalleryType = galleryType
            
            cell.layer.borderWidth = 5
            
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 2.0
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
            cell.layer.shadowRadius = 2.0
            let screenSize: CGRect = UIScreen.main.bounds
            cell.imageView.frame = CGRect(x: 0, y: 0, width: screenSize.width * cellScale, height: screenSize.height * cellScale)
            
            let imageSizeScale = 0.75
            
           
            
            updateAccessibilityTools()
            return cell
        }
    }
    
    // TODO: have cells fill left to right instead of top to bottom
    func calculateAdjustedCellIndex(index: Int) -> Int {
        /*
         [0][2][4]
         [1][3][5]
         
         Turns into:
         
         [0][1][2]
         [3][4][5]
         
         
         0 -> 0
         1 -> 2
         2 -> 4
         3 -> 1
         4 -> 3
         5 -> 5
         
         
         */
        
      return index
//        switch index {
//        case 0:
//            print(0)
//            return 0
//        case 1:
//            print(2)
//            return 2
//        case 2:
//            print(4)
//            return 4
//        case 3:
//            print(1)
//            return 1
//        case 4:
//            print(3)
//            return 3
//        case 5:
//            print(5)
//            return 5
//        default:
//            print("default 0")
//            return 0
//        }
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        displayedCellIndex = indexPath.item
        updateUI()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: cellSpacing / 2, left: cellSpacing / 2, bottom: cellSpacing / 2, right: cellSpacing / 2)
        
        }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        
        
        if index == 0 {
            // Clicked on Add Project Cell
            addProjectPressed()
        } else {
            // Open new project
            openProjectAtIndex(index: index - 1)  // shift index over 1 because index 0 is the add project cell
            
            // Move project to the front of the allProjects array so that it shows up first in the gallery
            let selectedProject = allProjects[galleryType]!.remove(at: index - 1)
            allProjects[galleryType]!.insert(selectedProject, at: 0)
        }
        
       
    }
    
    // Opens project located at given index in the allProjects[galleryType] array
    func openProjectAtIndex(index: Int) {
        let selectedProject = allProjects[galleryType]![index]
        if galleryType == "Freeplay Projects" { // TODO: change the "freeplay projects from a string to an enumerated value like in unity?
            performSegue(withIdentifier: "openFreeplayFromGallery", sender: selectedProject)
        } else if galleryType == "Robot Projects"{
            performSegue(withIdentifier: "openRobotWorkspaceFromGallery", sender: selectedProject)
        }
    }
    
    func addProjectPressed() {
        let projectName = generateNewProjectName()
        // Create new project and insert it at the beginning
        if self.galleryType == "Freeplay Projects" {
            allProjects[self.galleryType]!.insert(Project(name: projectName, imageName: "drive_backward", projectType: ProjectType.Freeplay), at: 0)
        } else {
            allProjects[self.galleryType]!.insert(Project(name: projectName, imageName: "drive_backward", projectType: ProjectType.Robot), at: 0)
        }
        
        // Add project
        self.projects = allProjects[self.galleryType]!
        self.reloadGallery()
        
        // Open Project
        openProjectAtIndex(index: 0)
    }
    
    func generateNewProjectName() -> String {
        
        let newProjectNumber = projects.count + 1
        let defaultProjectName = "Project " + String(newProjectNumber)
        
        if !doesProjectNameAlreadyExist(name: defaultProjectName) {
            return defaultProjectName
        }
        
        // If project name already exists, keep increasing the number until something works
        var projectName = defaultProjectName
        var projectNumber = newProjectNumber
        while doesProjectNameAlreadyExist(name: projectName) {
            projectNumber += 1
            projectName = "Project " + String(projectNumber)
        }
        return projectName
        
    }
    
    func doesProjectNameAlreadyExist(name: String) -> Bool {
        for proj in allProjects[galleryType]! {
            if proj.name == name {
                   return true
            }
        }
        return false
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "openFreeplayFromGallery") {
          let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
           freeplayWorkspaceVC.currentProject = sender as? Project
           freeplayWorkspaceVC.galleryType = galleryType
        
       }
        if (segue.identifier == "openRobotWorkspaceFromGallery") {
            let robotWorkspaceVC = segue.destination as! BlocksViewController
            robotWorkspaceVC.currentProject = sender as? Project
            robotWorkspaceVC.galleryType = galleryType
            
        }
    }

    
    
}
