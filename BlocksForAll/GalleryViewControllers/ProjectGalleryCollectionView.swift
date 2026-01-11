//
//  WorkspaceGalleryViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

/// Collection Viewrfor a gallery of projects. Either robot projects or freeplay projects. Can view projects, delete projects, rename projects, or add new projects from this gallery.
class ProjectGalleryCollectionView: UICollectionView {
    
    var projects: [Project] = [] // projects associated with this gallery
    let cellScale : CGFloat = 0.28 // how big cells should be in relation to the screen size
    
    private var cellWidth: CGFloat = 100 // width of all cells
    private var cellHeight: CGFloat = 100 // height of all cells
    
    let cellSpacing: CGFloat = 50 // space between cells
    
    var galleryType: String = ROBOT_GALLERY_TYPE // either freeplay or robot gallery type. Determines the set of projects to display
    
    var startScreenGallery: StartScreenGallery? = nil
    
    public func setupGallery(withStartScreenGallery startScreenGallery: StartScreenGallery, galleryType: String) {
        self.startScreenGallery = startScreenGallery
        self.galleryType = galleryType
        
        projects = Project.FetchProjects()[galleryType]!
        
        dataSource = self
        delegate = self
        
        // calculate cell size
        let screenSize = UIScreen.main.bounds.size
        cellWidth = floor(screenSize.width * cellScale)
        cellHeight = floor(screenSize.height * cellScale)
            
        updateUI()
    }
   
    public func reloadGallery(galleryType: String) {
        self.galleryType = galleryType
        self.projects = allProjects[self.galleryType]!
        reloadData()
        updateUI()
    }
    
    func updateUI() {
        updateAccessibilityTools()
    }
    func updateAccessibilityTools() {
//        if #available(iOS 13.0, *) { // Voice Control Labels
//            homeButton.accessibilityUserInputLabels = [
//                NSLocalizedString("Menu", comment: "Voice Control label"),
//                NSLocalizedString("Home", comment: "Voice Control label"),
//                NSLocalizedString("Main Menu", comment: "Voice Control label")
//            ]
//        }
//        homeButton.accessibilityLabel = "Main Menu".localized
    }
    
}

extension ProjectGalleryCollectionView : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            cell.parentViewController = startScreenGallery
           
            updateAccessibilityTools()
            return cell
        }
    }

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
            startScreenGallery!.performSegue(withIdentifier: "openFreeplayFromGallery", sender: selectedProject)
            
        } else if galleryType == ROBOT_GALLERY_TYPE{
            startScreenGallery!.performSegue(withIdentifier: "openRobotWorkspaceFromGallery", sender: selectedProject)
        }
    }
    
    func addProjectPressed() {
        let projectName = generateNewProjectName()
        // Create new project and insert it at the beginning
        if self.galleryType == FREEPLAY_GALLERY_TYPE {
            allProjects[self.galleryType]!.insert(Project(name: projectName, imageName: "WhiteBackground", projectType: ProjectType.Freeplay), at: 0)
        } else {
            allProjects[self.galleryType]!.insert(Project(name: projectName, imageName: "WhiteBackground", projectType: ProjectType.Robot), at: 0)
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
}
