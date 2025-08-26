//
//  ChooseActorViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/18/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

// View Controller to choose an actor to add to the freeplay project
class ChooseActorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    @IBOutlet weak var chooseActorTitleLabel: UILabel! // title label at top of screen
    
    @IBOutlet weak var backButton: UIButton! // button to go back to the freeplay workspace and cancel adding an actor
    
    @IBOutlet weak var actorsCollectionView: UICollectionView! // collection view that holds all of the possible actors that can be added
    
    @IBOutlet weak var addActorButton: UIButton! // button to add the actor to the project
    
    private let buttonSize = (((defaults.value(forKey: "blockSize") as! Int) * 10) / 9) // the size of each button that is showed in the collection view
    
    private var optionSelectedIndex = 0 // index of the option in the ActorsMenu array
    
    var actorOptions: NSArray = [] // List of actors from the ActorsMenu plist
    
    var selectedActor = (name: "", baseImagePath: "", color: "") // Actor that is currently selected
    
    var freeplayOutputView: FreeplayOutputView? // used during segues
    
    var currentActorImageView: UIImageView? // used during segues
    
    override func viewDidLoad() {
        // Styling
        addActorButton.backgroundColor = #colorLiteral(red: 1, green: 0.6078431373, blue: 0.2980392157, alpha: 1)
        addActorButton.titleLabel?.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
        addActorButton.titleLabel?.adjustsFontForContentSizeCategory = true
        addActorButton.titleLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        addActorButton.layer.borderWidth = 5
        addActorButton.layer.borderColor = #colorLiteral(red: 0.5231451956, green: 0.3179902169, blue: 0.1559177838, alpha: 1)
       
        addActorButton.layer.cornerRadius = 10
        
        setFontStyle()
        
        // get data for possible actors
         if let path = Bundle.main.path(forResource: "ActorsMenu", ofType: "plist") {
            actorOptions = NSArray(contentsOfFile: path)!
         } else {
             print("could not access ActorsMenu plist")
         }
       
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self
        actorsCollectionView.register(ActorCell.self, forCellWithReuseIdentifier: "ActorCell")
         
        // Voice Over
        accessibilityElements = [backButton!, chooseActorTitleLabel!, actorsCollectionView!, addActorButton!]
        
        // Text
        chooseActorTitleLabel.text = NSLocalizedString("Choose New Actor", comment: "Title for choose new actor view controller").localizedCapitalized
        addActorButton.setTitle(NSLocalizedString("Add", comment: "Button text to add new actor to project"), for: .normal)
    }
    
    /// Set all labels to custom font
    private func setFontStyle() {
        chooseActorTitleLabel.adjustsFontForContentSizeCategory = true
        chooseActorTitleLabel.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)        
    }
    
    // MARK: Actions
    @IBAction func backButtonPressed(_ sender: Any) { // Return to freeplay without adding a new actor
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    @IBAction func addActorPressed(_ sender: Any) { // Return to freeplay and add a new actor
        performSegue(withIdentifier: "backToFreeplayWithNewActor", sender: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "backToFreeplay") {
          let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
           
           freeplayWorkspaceVC.currentActorImageView = currentActorImageView
          
           freeplayWorkspaceVC.newActorToAdd = nil // don't add a new actor
        
       }
        if segue.identifier == "backToFreeplayWithNewActor" {
            let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
       
             freeplayWorkspaceVC.currentActorImageView = currentActorImageView
            
             freeplayWorkspaceVC.newActorToAdd = (name: selectedActor.name, baseImagePath: selectedActor.baseImagePath, color: "Default") // add a new actor
        }
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actorOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: CGFloat(buttonSize), height: CGFloat(buttonSize))
        return size
    }
      
    /// Called when the collectionView is being populated with cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActorCell", for: indexPath) as! ActorCell
        let index = indexPath.item  // numerical index of cell
        
        // Reset labels and images in cells
        // ----- Below code is from https://stackoverflow.com/questions/23647833/uicollectionviewcell-is-overlapped-when-scrolling
        for view in cell.subviews {
          view.removeFromSuperview()
        }
        // ----- End of code citation
        
        // Some cell styling
        cell.contentView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        
        // Create an image for the cell
        var baseImagePath = ""
        var name = ""
        
        if let actorType = actorOptions[index] as? NSDictionary{
            // Get the image for this actor
            baseImagePath = actorType.value(forKey: "imagePath") as! String
            let imagePath = VirtualRobot.calculateImagePath(baseImagePath: baseImagePath, color: "Default")
            name = actorType.value(forKey: "name") as! String
            let image = UIImage(named: imagePath)
            
            if image != nil  {
                let resizedImage = HelperFunctions.resizeImage(image: image!, scaledToSize: CGSize(width: Int(Double(buttonSize) * 0.9), height: Int(Double(buttonSize) * 0.9)))  // resize the image to fit the button. We make the image a little smaller so that it fits nicely within the button background.
                let imv = UIImageView(image: resizedImage)
                cell.addSubview(imv)
                
                // Center image view within the cell
                imv.translatesAutoresizingMaskIntoConstraints = false
                imv.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
                imv.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            }
        }
          
        // Accessibility
        cell.isAccessibilityElement = true
        
        let formattedString = NSLocalizedString("actor_cell_access_label", comment: "Accessibility label for actor cell. '<actor_name>. <actor_color> color.'")
        let resultString = String.localizedStringWithFormat(formattedString, name.localized, "Default".localized)
        cell.accessibilityLabel = resultString
        
        cell.accessibilityHint = NSLocalizedString("Double tap to select.", comment: "Accessibility hint for actor cell")
        
        cell.accessibilityIdentifier = String(index)
    
        // Put a border around the cell if it is currently selected
        if String(optionSelectedIndex) == cell.accessibilityIdentifier {
            cell.layer.borderWidth = 10
            cell.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            cell.isSelected = true
            
            cell.accessibilityHint = "\("Selected".localized)."
            
            let formattedString = NSLocalizedString("actor_cell_access_label", comment: "Accessibility label for actor cell. Should say the actor's name and color.")
            let resultString = String.localizedStringWithFormat(formattedString, name, "Default".localized)
            cell.accessibilityLabel = resultString
           
            selectedActor = (name: name, baseImagePath: baseImagePath, color: "Default".localized)
        } else {
            cell.isSelected = false
            cell.layer.borderWidth = 0
        }
        return cell
    }
      
    /// Called when an option button is pressed
    /// Deselect all buttons except for the currently selected one (only one can be selected at a time)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells{ // deselect all visible buttons
            cell.isSelected = false
            cell.layer.borderWidth = 0
        }
        let selectedCell = collectionView.cellForItem(at: indexPath) // highlight the one selected button
        selectedCell?.layer.borderWidth = 10
        selectedCell?.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        selectedCell?.isSelected = true
        optionSelectedIndex = indexPath.item
        
        var imagePath = ""
        var name = ""
        
        // Select this new actor
        if let actorType = actorOptions[optionSelectedIndex] as? NSDictionary{
            imagePath = actorType.value(forKey: "imagePath") as! String
            name = actorType.value(forKey: "name") as! String
            selectedActor = (name: name, baseImagePath: imagePath, color: "Default".localized)
        }
    }
}

import Foundation

class ActorCell: UICollectionViewCell {
    
}
