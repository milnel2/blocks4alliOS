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
    
    @IBOutlet weak var displayedCellIndexLabel: UILabel!
    var projects = Project.FetchProjects()
    var cellScale : CGFloat = 0.7
    
    private var cellWidth: CGFloat = 100
    private var cellHeight: CGFloat = 100
    
    let cellSpacing: CGFloat = 50
    var displayedCellIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectGalleryCollectionView.dataSource = self
        projectGalleryCollectionView.delegate = self
        
        let screenSize = UIScreen.main.bounds.size
        cellWidth = floor(screenSize.width * cellScale)
        cellHeight = floor(screenSize.height * cellScale)
        
       
        
        projectGalleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
        // Adding constraints code is from Imanou Petit's answer on https://stackoverflow.com/questions/26180822/how-to-add-constraints-programmatically-using-swift
        let widthConstraint = NSLayoutConstraint(item: projectGalleryCollectionView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: cellWidth + cellSpacing)
        let heightConstraint = NSLayoutConstraint(item: projectGalleryCollectionView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: cellHeight + cellSpacing)
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
    
    func updateUI() {
        displayedCellIndexLabel.text = String(displayedCellIndex + 1) + "/" + String(projects.count)
        updateAccessibilityTools()
    }
    func updateAccessibilityTools() {
        
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
        //cell.backgroundColor = UIColor.black
        cell.layer.borderWidth = 1
       
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowRadius = 2.0
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        cell.layer.shadowRadius = 2.0
        let screenSize: CGRect = UIScreen.main.bounds
        cell.imageView.frame = CGRect(x: 0, y: 0, width: screenSize.width * cellScale, height: screenSize.height * cellScale)

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
    
        let selectedProject = allProjects[indexPath.item]
        performSegue(withIdentifier: "openFreeplayFromGallery", sender: selectedProject)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "openFreeplayFromGallery") {
          let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
          freeplayWorkspaceVC.project = sender as? Project
        
       }
    }

    
    
}
