//
//  StartScreenGallery.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 1/11/26.
//  Copyright © 2026 Blocks4All. All rights reserved.
//
// TODO: translate this VC to Spanish
class StartScreenGallery: UIViewController {
    
    @IBOutlet weak var tabsView: UIView! // view that holds the two tabs. Referenced so we can change sorting order
    @IBOutlet weak var freeplayTab: UIImageView!
    @IBOutlet weak var robotTab: UIImageView!
    @IBOutlet weak var buttonsView: UIView! // view that holds the help and settings buttons
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var xylophoneButton: UIButton!
    @IBOutlet weak var galleryTitleLabel: UILabel!
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
    
    var blockSize = 150 // this controls the size of the blocks you put down in the Building Screen
    
    override func viewDidLoad() {
        // Default settings
        // if show icons/show text hasn't been set yet, set showText to showIcons by default
        if  defaults.value(forKey: "showText") == nil {
            defaults.setValue(0, forKey: "showText")
        }
        // if blockSize hasn't been set yet, set it to be 150 by default
        if defaults.value(forKey: "blockSize") == nil {
            defaults.setValue(150, forKey: "blockSize")
        }
        
        
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
        
        setUpAccessibility()
    }
    
    @objc func robotTabClicked(sender : UITapGestureRecognizer) {
        if currentGalleryType != ROBOT_GALLERY_TYPE {
            currentGalleryType = ROBOT_GALLERY_TYPE
            // Move accessibility focus to the gallery
            UIAccessibility.post(notification: .screenChanged, argument: self.galleryCollectionView)
        }
    }
    @objc func freeplayTabClicked(sender : UITapGestureRecognizer) {
        if currentGalleryType != FREEPLAY_GALLERY_TYPE {
            currentGalleryType = FREEPLAY_GALLERY_TYPE
            // Move accessibility focus to the gallery
            UIAccessibility.post(notification: .screenChanged, argument: self.galleryCollectionView)
        }
    }
    
    public func reloadGallery() {
        // Update visuals
        if currentGalleryType == ROBOT_GALLERY_TYPE {
            // dark blue background
            galleryView.backgroundColor = UIColor(named: "dark_blue")
            galleryCollectionView.backgroundColor = UIColor(named: "dark_blue")
            
            // Switch tabs
            tabsView.bringSubviewToFront(robotTab)
            
            // Update title
            galleryTitleLabel.text = "Dash Robot Projects"
            
        } else if currentGalleryType == FREEPLAY_GALLERY_TYPE {
            // orange background
            galleryView.backgroundColor = UIColor(named: "dark_orange")
            galleryCollectionView.backgroundColor = UIColor(named: "dark_orange")
            
            // Switch tabs
            tabsView.bringSubviewToFront(freeplayTab)
            
            // Update title
            galleryTitleLabel.text = "Virtual Robot Projects"
        }
        
        // Update projects
        galleryCollectionView.reloadGallery(galleryType: currentGalleryType)
    }
    
    public func getGalleryType() -> String {
        return currentGalleryType
    }
    
    func setUpAccessibility() {
        // Navigation order
        robotTab.isAccessibilityElement = true
        freeplayTab.isAccessibilityElement = true
        
        accessibilityElements = [tabsView!, buttonsView!, galleryTitleLabel!, galleryCollectionView!]
        tabsView.accessibilityElements = [robotTab!, freeplayTab!]
        buttonsView.accessibilityElements = [xylophoneButton!, settingsButton!, helpButton!]
        
        // VoiceOver labels
        settingsButton.accessibilityLabel = NSLocalizedString("Settings", comment: "Accessibility Label for settings button on main menu screen")
        helpButton.accessibilityLabel = NSLocalizedString("Help", comment: "Accessibility Label for help button on main menu screen")
        xylophoneButton.accessibilityLabel = "Play with Dash's xylophone attachment." // TODO: translate to Spanish
        robotTab.accessibilityLabel = NSLocalizedString("Play with Robot", comment: "Title for Play with Physical Robot button on main menu screen")
        freeplayTab.accessibilityLabel = NSLocalizedString("Play with Virtual Robot", comment: "Title for Play with Virtual Robot button on main menu screen")
        
        // Font
        galleryTitleLabel.font = UIFont.accessibleBoldFont(withStyle: .largeTitle, size: 30)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass blockSize setting
        if let myDestination = segue.destination as? BlocksViewController{
            myDestination.blockSize = blockSize
        }
    
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 11.0, *) {
            if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
                print("accessibility enabled")
                blockSize = 200
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
