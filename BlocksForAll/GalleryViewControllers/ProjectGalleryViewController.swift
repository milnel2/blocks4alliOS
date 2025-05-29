//
//  WorkspaceGalleryViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

/// View Controller for a gallery of projects. Either robot projects or freeplay projects. Can view projects, delete projects, rename projects, or add new projects from this screen.
class ProjectGalleryViewController: UIViewController {
    
    @IBOutlet weak var projectGalleryCollectionView: UICollectionView! // collection view to hold project cells
    @IBOutlet weak var robotButton: UIButton!
    
    @IBOutlet weak var homeButton: UIButton! // button to return to main menu
    
    var projects: [Project] = [] // projects associated with this gallery
    let cellScale : CGFloat = 0.28 // how big cells should be in relation to the screen size
    
    private var cellWidth: CGFloat = 100 // width of all cells
    private var cellHeight: CGFloat = 100 // height of all cells
    
    let cellSpacing: CGFloat = 50 // space between cells
    
    var galleryType: String = ROBOT_GALLERY_TYPE // either freeplay or robot gallery type. Determines the set of projects to display
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projects = Project.FetchProjects()[galleryType]!
        
        projectGalleryCollectionView.dataSource = self
        projectGalleryCollectionView.delegate = self
        
        // calculate cell size
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
        view.accessibilityElements = [projectGalleryCollectionView!, homeButton!]
        
        homeButton.accessibilityLabel = "Main Menu".localized
    }
    
    func validateFunctionName(name: String, currentAlert: UIAlertController) -> Bool{
        let dictionary = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties")!
        if (dictionary[name] != nil) {
            // Name is protected, show an alert do not rename the function
            let titleString: String
            let messageString: String
            
            titleString = NSLocalizedString("Name is protected", comment: "")
            messageString = NSLocalizedString("Choose a different name", comment: "")
           
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        } else if (name == "") {
            // Name is empty string
            let titleString: String
            let messageString: String
            
            titleString = NSLocalizedString("Name cannot be empty", comment: "")
            messageString = NSLocalizedString("Choose a different name", comment: "")
    
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        } else {
            for proj in allProjects[galleryType]! {
                if proj.name == name {
                    let titleString: String
                    let messageString: String
                    
                    titleString = NSLocalizedString("Name already exists", comment: "")
                    messageString = NSLocalizedString( "Choose a different name", comment: "")
                    
                    let invalidNameAlert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
                        invalidNameAlert.addAction(UIAlertAction(title: "Okay".localized, style: .default, handler: nil))
                        self.present(invalidNameAlert, animated: true)
                    
                    return false
                }
            }
        }
        return true
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
            // Styling
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
                
            // Styling
            cell.layer.borderWidth = 5
            cell.layer.shadowColor = UIColor.gray.cgColor
            cell.layer.shadowRadius = 2.0
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
            cell.layer.shadowRadius = 2.0
            
            let screenSize: CGRect = UIScreen.main.bounds
            cell.imageView.frame = CGRect(x: 0, y: 0, width: screenSize.width * cellScale, height: screenSize.height * cellScale)
            
            cell.cellGalleryType = galleryType
            cell.project = project
            cell.parentViewController = self
           
            updateAccessibilityTools()
            return cell
        }
    }
    
    // TODO: have cells fill left to right instead of top to bottom

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
        if galleryType == FREEPLAY_GALLERY_TYPE {
            performSegue(withIdentifier: "openFreeplayFromGallery", sender: selectedProject)
            
        } else if galleryType == ROBOT_GALLERY_TYPE{
            performSegue(withIdentifier: "openRobotWorkspaceFromGallery", sender: selectedProject)
        }
    }
    
    func addProjectPressed() {
        let projectName = generateNewProjectName()
        // Create new project and insert it at the beginning
        if self.galleryType == FREEPLAY_GALLERY_TYPE {
            //TODO: fix image paths
            allProjects[self.galleryType]!.insert(Project(name: projectName, imageName: "drive_backward", projectType: ProjectType.Freeplay), at: 0)
        } else {
            allProjects[self.galleryType]!.insert(Project(name: projectName, imageName: "drive_backward", projectType: ProjectType.Robot), at: 0)
        }
        
        // Add project
        self.projects = allProjects[self.galleryType]!
        
        // Open Project
        openProjectAtIndex(index: 0)
    }
    
    /// Returns a placeholder project name like "Project 1"
    func generateNewProjectName() -> String {
        
        let newProjectNumber = projects.count + 1
        let defaultProjectName: String
       
        let formattedString = NSLocalizedString("new_project_name", comment: "Default name of a project (ex: 'Project 1')")
        let resultString = String.localizedStringWithFormat(formattedString, newProjectNumber)
        defaultProjectName = resultString
        
        if !doesProjectNameAlreadyExist(name: defaultProjectName) {
            return defaultProjectName
        }
        
        // If project name already exists, keep increasing the number until something works
        var projectName = defaultProjectName
        var projectNumber = newProjectNumber
        while doesProjectNameAlreadyExist(name: projectName) {
            projectNumber += 1
            
            let formattedString = NSLocalizedString("new_project_name", comment: "Default name of a project (ex: 'Project 1')")
            let resultString = String.localizedStringWithFormat(formattedString, projectNumber)
            projectName = resultString
        }
        return projectName
        
    }
    
    func doesProjectNameAlreadyExist(name: String) -> Bool {
        for proj in allProjects[FREEPLAY_GALLERY_TYPE]! {
            if proj.name == name {
                   return true
            }
        }
        for proj in allProjects[ROBOT_GALLERY_TYPE]! {
            if proj.name == name {
                   return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "openFreeplayFromGallery") {
          let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
           UserData.data.setCurrentProject(newProject: sender as? Project)
           freeplayWorkspaceVC.galleryType = galleryType
           currentWorkspace = ON_RUN_STRING
        
       }
        if (segue.identifier == "openRobotWorkspaceFromGallery") {
            let robotWorkspaceVC = segue.destination as! BlocksViewController
            UserData.data.setCurrentProject(newProject: sender as? Project)
            robotWorkspaceVC.galleryType = galleryType
            currentWorkspace = "Main Workspace"
        }
    }
}
