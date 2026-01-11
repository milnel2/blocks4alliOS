//
//  StartScreenGallery.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 1/11/26.
//  Copyright © 2026 Blocks4All. All rights reserved.
//

class StartScreenGallery: UIViewController {
    
    @IBOutlet weak var tabsView: UIView! // view that holds the two tabs. Referenced so we can change sorting order
    @IBOutlet weak var freeplayTab: UIImageView!
    @IBOutlet weak var robotTab: UIImageView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var galleryView: UIView! // Large view that holds the gallery. Referenced so that we can access and change its color
    @IBOutlet weak var galleryCollectionView: ProjectGalleryCollectionView!
        
    @IBAction func helpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "startScreenGalleryToHelp", sender: nil)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "startScreenGalleryToSettings", sender: nil)
    }
    
    private var currentGalleryType: String = ROBOT_GALLERY_TYPE {
        didSet { self.reloadGallery() }
    }
    
    override func viewDidLoad() {
        galleryCollectionView.setupGallery(withStartScreenGallery: self, galleryType: currentGalleryType)
        // Open the Robot project gallery by default
        currentGalleryType = ROBOT_GALLERY_TYPE
        
        // Add tap gesture recognizers to robot and freeplay tabs
        // Tap Gesture code from https://agrawalsuneet.medium.com/uiview-clicklistener-swift-88ab5dec64b5
        let robotTapGesture = UITapGestureRecognizer(target: self, action:  #selector(robotTabClicked(sender:)))
        let freeplayTapGesture = UITapGestureRecognizer(target: self, action:  #selector(freeplayTabClicked(sender:)))
        
        robotTab.isUserInteractionEnabled = true
        freeplayTab.isUserInteractionEnabled = true
        robotTab.addGestureRecognizer(robotTapGesture)
        freeplayTab.addGestureRecognizer(freeplayTapGesture)
    }
    
    @objc func robotTabClicked(sender : UITapGestureRecognizer) {
        if currentGalleryType != ROBOT_GALLERY_TYPE {
            currentGalleryType = ROBOT_GALLERY_TYPE
        }
    }
    @objc func freeplayTabClicked(sender : UITapGestureRecognizer) {
        if currentGalleryType != FREEPLAY_GALLERY_TYPE {
            currentGalleryType = FREEPLAY_GALLERY_TYPE
        }
    }
    
    public func reloadGallery() {
        // Update visuals
        if currentGalleryType == ROBOT_GALLERY_TYPE {
            // dark blue background
            galleryView.backgroundColor = UIColor(named: "navy_text")
            galleryCollectionView.backgroundColor = UIColor(named: "navy_text")
            tabsView.bringSubviewToFront(robotTab)
        } else if currentGalleryType == FREEPLAY_GALLERY_TYPE {
            // orange background
            galleryView.backgroundColor = UIColor(named: "orange_block")
            galleryCollectionView.backgroundColor = UIColor(named: "orange_block")
            tabsView.bringSubviewToFront(freeplayTab)
        }
        
        // Update projects
        galleryCollectionView.reloadGallery(galleryType: currentGalleryType)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "openFreeplayFromGallery") {
          let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
           UserData.data.setCurrentProject(newProject: sender as? Project)
           freeplayWorkspaceVC.galleryType = currentGalleryType
           currentWorkspace = ON_RUN_STRING
        
        }
        if (segue.identifier == "openRobotWorkspaceFromGallery") {
            let robotWorkspaceVC = segue.destination as! BlocksViewController
            UserData.data.setCurrentProject(newProject: sender as? Project)
            robotWorkspaceVC.galleryType = currentGalleryType
            currentWorkspace = "Main Workspace"
        }
    }
}
