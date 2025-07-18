//
//  SelectBackgroundModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 9/22/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

import UIKit

/// View Controller for the Select Background modifier blocks in Freeplay mode. Can view default backgrounds, saved custom backgrounds, and add new backgrounds
class SelectBackgroundModifierViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    /* View controller for the Select Background modifier scene */
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var SelectBackgroundTitleLabel: UILabel!
    @IBOutlet weak var FocusedBackgroundImageView: UIImageView! // Large image view that is an enlarged version of the selected background image
    @IBOutlet weak var FocusedBackgroundContentView: UIView! // View that holds the focused background
    @IBOutlet weak var DeleteBackgroundButton: UIButton! // Button to delete a custom background
    @IBOutlet weak var BackgroundsCollectionView: UICollectionView! // Holds row of background image options
    @IBOutlet weak var AddNewBackgroundButton: UIButton!
    @IBOutlet weak var HorizontalStackView: UIStackView! // Holds AddNewBackgroundButton and collection view
    
    
    var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    var currentProject: Project? {
        get {
            return UserData.data.getCurrentProject()
        }
    } // Project user is currently working in
    var backgrounds: [BackgroundImage] = [] // List of all available backgrounds
    var focusedBackground: BackgroundImage? = nil // Background image currently in middle of the screen and large
    var focusedBackgroundIndex = 0 // Index of the focused background in backgrounds list
    
    private var cellWidth: CGFloat = 100 // width of each cell
    private var cellHeight: CGFloat = 100 // height of each cell
    
    //TODO: update buttonSize
    private let buttonSize = (((defaults.value(forKey: "blockSize") as! Int) * 10) / 9) // the size of each button that is showed in the collection view
    
    
    override func viewDidLoad() {
        loadBackgrounds()
        preserveLastSelection()
        doStyling()
        
        // Dynamic Text
        back.titleLabel?.adjustsFontForContentSizeCategory = true
        setFontStyle()
        
        let cellScale = 0.1
        let screenSize = UIScreen.main.bounds.size
        cellWidth = floor(screenSize.width * cellScale)
        cellHeight = floor(screenSize.height * cellScale)
        
        
        BackgroundsCollectionView.delegate = self
        BackgroundsCollectionView.dataSource = self
        BackgroundsCollectionView.register(BackgroundCell.self, forCellWithReuseIdentifier: "BackgroundCell")
        
        setUpAccessibility()
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
       
    }
    
    @IBAction func addNewBackgroundButtonPressed(_ sender: Any) {
        if checkForPhotoPermission() {
            getImage()
        } else {
            askForPhotoPermission()
        }
    }
    
    /// Focus the background image that was last selected for this block
    func preserveLastSelection() {
        if let previousBackgroundPath: String = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["background"] {
            // Look for an background image that has the same image path
            for i in 0..<backgrounds.count {
                let imagePath = backgrounds[i].getImagePath()
                if imagePath == previousBackgroundPath {
                    // Found a match
                    focusBackground(imageIndex: i)
                    return
                }
            }
        }
        // By default, focus the first image in the list if no match was found
       focusBackground(imageIndex: 0)
   }
    
    // Loads all background image paths into the backgrounds list
    func loadBackgrounds() {
        backgrounds = []
        
        let backgroundPaths = getSavedBackgroundPaths()
        
        // Attempt to find images for all of the file paths
        for path in backgroundPaths {
            backgrounds.append(BackgroundImage(imagePath: path))
        }
    }
    
    
    func getSavedBackgroundPaths() -> [String] {
        let defaultBackgrounds = UserData.data.getDefaultBackgroundPaths()
        
        
        var allBackgrounds = defaultBackgrounds
        for background in UserData.data.getCustomBackgroundPaths() {
            allBackgrounds.append(background)
        }
        return allBackgrounds
    }
    
    // Make the image found at backgrounds[imageIndex] be focused, large, and in the middle of the screen
    func focusBackground(imageIndex: Int) {
        let bgImage = backgrounds[imageIndex]
        focusedBackgroundIndex = imageIndex
        
        focusedBackground = bgImage
        FocusedBackgroundImageView.image = bgImage.getImage()
        // If the background path is a built-in background (plain color), scale to fill. Otherwise (custom image), just aspect fit it.
        if (UserData.data.hasDefaultBackgroundPath(path: bgImage.getImagePath())) {
            FocusedBackgroundImageView.contentMode = .scaleToFill
        } else {
            FocusedBackgroundImageView?.contentMode = .scaleAspectFit
        }
        
        // Remove highlight on all cells
        for cell in BackgroundsCollectionView.visibleCells {
            if let backgroundCell = cell as? BackgroundCell {
                backgroundCell.removeHighlight()
            }
        }
        
        let savedCustomPaths = UserData.data.getCustomBackgroundPaths()
        if savedCustomPaths.contains(backgrounds[imageIndex].getImagePath()) { // Curent image is a custom background, show the delete button
            DeleteBackgroundButton.isHidden = false
            DeleteBackgroundButton.isEnabled = true
            DeleteBackgroundButton.tag = imageIndex // pass the index of the cell
            FocusedBackgroundContentView.accessibilityElements = [FocusedBackgroundImageView!, DeleteBackgroundButton!]
        } else { // This is a built-in background, hide the delete button
            DeleteBackgroundButton.isHidden = true
            DeleteBackgroundButton.isEnabled = false
            FocusedBackgroundContentView.accessibilityElements = [FocusedBackgroundImageView!]
        }
        
        BackgroundsCollectionView.reloadData()
    }
    
    /// Add given background image to list and highlights/focuses it
    func addNewBackgroundImage(backgroundImage: BackgroundImage) {
        backgrounds.append(backgroundImage)
        focusBackground(imageIndex: backgrounds.count - 1)

        // Remove highlight on all cells
        for cell in BackgroundsCollectionView.visibleCells {
            if let backgroundCell = cell as? BackgroundCell {
                backgroundCell.removeHighlight()
            }
        }
        BackgroundsCollectionView.reloadData()
    }
    
    /// Delete the given background image from the backgrounds list and from user data
    func deleteCustomBackground(cellIndex: Int) {
        let removedBackground = backgrounds.remove(at: cellIndex)
        if UserData.data.removeBackgroundPath(path: removedBackground.getImagePath()) == false {
            print("Error: Could not remove background path \(removedBackground.getImagePath()) from user data")
        }
        
        focusBackground(imageIndex: 0)
        loadBackgrounds()
        BackgroundsCollectionView.reloadData()
        
        HelperFunctions.deleteImageFromDocumentDirectory(name: removedBackground.getImagePath())
    }
    
    
    // MARK: Image Picker
    /// Open the camera roll image picker
    private func getImage() {
        // Accessing the Image Picker code is from https://stackoverflow.com/questions/52399079/accessing-the-camera-and-photo-library-in-swift-4
        
        let sourceType = UIImagePickerController.SourceType.photoLibrary // TODO: also use PHPicker for newer iOS versions, this will be deprecated
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.modalPresentationStyle = .fullScreen
            self.present(imagePickerController, animated: true, completion: nil)
            
        } else {
            print("\(sourceType) not available on device.")
        }
    }
    
    /// Called after an image has been selected from the camera roll. Saves image to document directory and adds it to the list
    func imageSelectedFromPhotos(image: UIImage) {
        let imageName = generateBackgroundImageName()
        let imageURL = HelperFunctions.getDocumentsDirectory().appendingPathComponent(imageName)
        // Save image to directory
        if let data = image.pngData() {
            do {
                    try data.write(to: imageURL)
                } catch {
                    print("Unable to Write Image Data to Disk")
                }
        }
        
        UserData.data.addBackgroundPath(path: imageName)
        addNewBackgroundImage(backgroundImage: BackgroundImage(imagePath: imageName))
    }
    
    
   /// Generate a unique file name for an image from the camera rolll
    func generateBackgroundImageName() -> String {
        let numCustomImages = backgrounds.count
        var nameAlreadyTaken = true
        
        var tempImageName = "custom_\(numCustomImages).png"
        var counter = 0
        while (nameAlreadyTaken) {
            tempImageName = "custom_\(numCustomImages + counter).png"
            let image = HelperFunctions.getUIImage(named: tempImageName)
            if (image == UIImage(named: "EmptyImage")) {
                nameAlreadyTaken = false
            }
            counter += 1
        }
        let newImageName = tempImageName
        return newImageName
    }
    
    /// Return true if user has previously given permission to access camera roll
    func checkForPhotoPermission() -> Bool{
        print("Need to implement: checkForPhotoPermission()")
        let permissionGranted = true
        
        return permissionGranted
    }
    
    /// Ask user for permission to access camera rolll
    func askForPhotoPermission() {
        print("Need to implement: askForPhotoPermission")
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    // Accessing the Image Picker code is from  https://stackoverflow.com/questions/52399079/accessing-the-camera-and-photo-library-in-swift-4
    /// After an image is picked from the camera roll, save it as a UIImage and go on to save it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) { [weak self] in
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else {
                print("error getting image")
                return
            }
            // Save image
            print("image saved")
            
            self?.imageSelectedFromPhotos(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgrounds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCell", for: indexPath) as! BackgroundCell
        
        // Set up image
        let index = indexPath.item // Numerical index of the cell
        let bgImage = backgrounds[index]
        
        let imageView = UIImageView(image: bgImage.getImage())
        
        imageView.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellWidth)
        cell.addSubview(imageView)
        
        // Accessibility
        cell.isAccessibilityElement = true
        let nonZeroIndex = index + 1
        let totalNumCells = backgrounds.count
        
        cell.accessibilityLabel =
            String.localizedStringWithFormat(
                NSLocalizedString("multiple_choice_image_unselected_indexed_access_label", comment: "Accessibility Label for an unselected background image cell in Select Background View Controller"),
                bgImage.getImagePath(),
                nonZeroIndex,
                totalNumCells)
        
        // Highlight the cell if needed
        if index == focusedBackgroundIndex {
            cell.highlight()
            
            cell.accessibilityLabel =
                String.localizedStringWithFormat(
                    NSLocalizedString("multiple_choice_image_selected_indexed_access_label", comment: "Accessibility Label for a selected background image cell in Select Background View Controller"),
                    bgImage.getImagePath(),
                    nonZeroIndex,
                    totalNumCells)
        } else {
            cell.removeHighlight()
            
            // Put a black border around the white background cell so that it is visible
            if (bgImage.getImagePath() == "WhiteBackground") {
                cell.layer.borderWidth = 5
                cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        
        return cell
    }
    
    @IBAction func deleteAction(sender: UIButton){
        // Verify delete action
        let titleString: String
        titleString = NSLocalizedString("Are you sure you want to delete this background image?", comment: "")
        
        let alert = UIAlertController(title: titleString, message: "This action cannot be undone.".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler: {action in
            // delete project
            self.deleteCustomBackground(cellIndex: sender.tag)
        }))
        
        self.present(alert, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    /// When a cell is selected, highlight it and focus it
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        
        // Remove highlight on all cells
        for cell in collectionView.visibleCells {
            if let backgroundCell = cell as? BackgroundCell {
                backgroundCell.removeHighlight()
            }
        }
        // Highlight just the selected cell
        let cell = collectionView.cellForItem(at: indexPath) as! BackgroundCell
        cell.highlight()
        
        focusBackground(imageIndex: index)
    }
    
    /// Add a margin to the collection view so that the cells don't go right up to the edge
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    //MARK: Styling and Accessibility
    /// Set all labels to custom font
    private func setFontStyle() {
    // TODO: implement
    }
    
    /// Visual styling of the view components
    func doStyling() {
        // Style the row of background options at the bottom of the screen
        HorizontalStackView.layer.borderWidth = 5
        HorizontalStackView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // TODO: dark mode
        HorizontalStackView.layer.cornerRadius = 10
      
      //  HorizontalStackView.addConstraint(NSLayoutConstraint(item: HorizontalStackView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cellHeight * 2))
        
        FocusedBackgroundImageView.layer.borderWidth = 5
        FocusedBackgroundImageView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        AddNewBackgroundButton.titleLabel?.text = ""
        
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        let heightContstraint = NSLayoutConstraint(item: FocusedBackgroundContentView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenHeight / 2.5)
        let widthContstraint = NSLayoutConstraint(item: FocusedBackgroundContentView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenWidth / 2.5)
        FocusedBackgroundContentView.addConstraint(heightContstraint)
        FocusedBackgroundContentView.addConstraint(widthContstraint)
        
        let heightContstraint2 = NSLayoutConstraint(item: FocusedBackgroundImageView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenHeight / 2.5)
        let widthContstraint2 = NSLayoutConstraint(item: FocusedBackgroundImageView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: screenWidth / 2.5)
        FocusedBackgroundImageView.addConstraint(heightContstraint2)
        FocusedBackgroundImageView.addConstraint(widthContstraint2)
    }
    
    func setUpAccessibility() {
        SelectBackgroundTitleLabel.isAccessibilityElement = true
        //FocusedBackgroundContentView.isAccessibilityElement = true
        FocusedBackgroundImageView.isAccessibilityElement = true
        DeleteBackgroundButton.isAccessibilityElement = true
        DeleteBackgroundButton.accessibilityTraits = .button
        
        accessibilityElements = [back!, SelectBackgroundTitleLabel!, FocusedBackgroundContentView!, DeleteBackgroundButton!, BackgroundsCollectionView!]
        back.accessibilityLabel = "Back".localized
        DeleteBackgroundButton.accessibilityLabel =  String.localizedStringWithFormat(
            NSLocalizedString("delete_custom_image_button_access_label", comment: "Accessibility Label for a button that will delete a custom image"),
            focusedBackground!.getImagePath())
        FocusedBackgroundImageView.accessibilityLabel =
            String.localizedStringWithFormat(
                NSLocalizedString("multiple_choice_image_selected_access_label", comment: "Accessibility Label for a selected Image View"),
                focusedBackground!.getImagePath())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "backToFreeplay") {
            let focusedBackgroundImage = backgrounds[focusedBackgroundIndex]
            
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["background"] = focusedBackgroundImage.getImagePath() // Tell BlocksViewController which background was selected
        }
    }
}


class BackgroundCell: UICollectionViewCell {
    
    func highlight() {
        layer.borderWidth = 10
        layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        isSelected = true
    }
    func removeHighlight() {
        layer.borderWidth = 0
        isSelected = false
    }
}

