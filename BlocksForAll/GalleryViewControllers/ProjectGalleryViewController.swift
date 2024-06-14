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
    
    @IBOutlet weak var rightScrollButton: UIButton!
    @IBOutlet weak var leftScrollButton: UIButton!
    
    @IBOutlet weak var addProjectButton: UIButton!
    @IBOutlet weak var displayedCellIndexLabel: UILabel!
    
    var projects: [Project] = []
    var cellScale : CGFloat = 0.7
    
    private var cellWidth: CGFloat = 100
    private var cellHeight: CGFloat = 100
    
    let cellSpacing: CGFloat = 50
    var displayedCellIndex = 0
    
    var galleryType: String = "Robot Projects"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projects = Project.FetchProjects()[galleryType]!
        
        projectGalleryCollectionView.dataSource = self
        projectGalleryCollectionView.delegate = self
        
        let screenSize = UIScreen.main.bounds.size
        cellWidth = floor(screenSize.width * cellScale)
        cellHeight = floor(screenSize.height * cellScale)
        
       
        
        projectGalleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
        // Adding constraints code is from Imanou Petit's answer on https://stackoverflow.com/questions/26180822/how-to-add-constraints-programmatically-using-swift
        let widthConstraint = NSLayoutConstraint(item: projectGalleryCollectionView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: cellWidth + cellSpacing) // Width of collection view = cell width + cell spacing
        let heightConstraint = NSLayoutConstraint(item: projectGalleryCollectionView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: cellHeight + cellSpacing) // Height of collection view = cell height + cell spacing
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        
        updateUI()
        
    }
   
    @IBAction func leftScrollPressed(_ sender: Any) {
        print("left pressed")
       let currentIndexPath =  projectGalleryCollectionView.indexPathsForVisibleItems
        if displayedCellIndex > 0 {
            displayedCellIndex -= 1
            let index = IndexPath.init(item: displayedCellIndex, section: 0)
            projectGalleryCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
        
    }
        
    @IBAction func rightScrollPressed(_ sender: Any) {
        if displayedCellIndex < projects.count - 1 {
            displayedCellIndex += 1
            let index = IndexPath.init(item: displayedCellIndex, section: 0)
            projectGalleryCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func addProjectPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Enter project name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "New Project Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            if self.validateFunctionName(name: textField.text!, currentAlert: alert) {
                // name is valid, rename the project
                allProjects[self.galleryType]!.insert(Project(name: textField.text!, imageName: "drive_backward", functionDict: ["Main Workspace" : []]), at: 0)
                self.projects = allProjects[self.galleryType]!
                self.reloadGallery()
            }
            
        }))

        present(alert, animated: true)
    }
    
    func reloadGallery() {
        self.projects = allProjects[self.galleryType]!
        projectGalleryCollectionView.reloadData()
        updateUI()
    }
    
    func updateUI() {
        displayedCellIndexLabel.text = String(displayedCellIndex + 1) + "/" + String(projects.count)
        updateAccessibilityTools()
    }
    func updateAccessibilityTools() {
        
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
        return projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProjectsCell", for: indexPath) as! ProjectCollectionViewCell
        let project = projects[indexPath.item]
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
        
        let heightConstraint = NSLayoutConstraint(item: cell.imageView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: cellHeight * imageSizeScale) // Height of image view = cell height * imageSizeScale
        let widthConstraint = NSLayoutConstraint(item: cell.imageView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: cellWidth * imageSizeScale) // Height of image view = cell width * imageSizeScale
        NSLayoutConstraint.activate([widthConstraint, heightConstraint])
        

        return cell
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
    
        let selectedProject = allProjects[galleryType]![indexPath.item]
        if galleryType == "Freeplay Projects" { // TODO: change the "freeplay projects from a string to an enumerated value like in unity?
            performSegue(withIdentifier: "openFreeplayFromGallery", sender: selectedProject)
        } else if galleryType == "Robot Projects"{
            performSegue(withIdentifier: "openRobotWorkspaceFromGallery", sender: selectedProject)
           
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "openFreeplayFromGallery") {
          let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
           freeplayWorkspaceVC.project = sender as? Project
           freeplayWorkspaceVC.galleryType = galleryType
        
       }
        if (segue.identifier == "openRobotWorkspaceFromGallery") {
            let robotWorkspaceVC = segue.destination as! BlocksViewController
            robotWorkspaceVC.project = sender as? Project
            robotWorkspaceVC.galleryType = galleryType
        }
    }

    
    
}
