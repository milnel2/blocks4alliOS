//
//  ChooseActorViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/18/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class ChooseActorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    @IBOutlet weak var chooseActorTitleLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var actorsCollectionView: UICollectionView!
    
    @IBOutlet weak var addActorButton: UIButton!
    
    private let buttonSize = (((defaults.value(forKey: "blockSize") as! Int) * 10) / 9) // the size of each button that is showed in the collection view
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if (segue.identifier == "backToFreeplay") {
          let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
     
           freeplayWorkspaceVC.currentProject = currentProject // pass the current project back to the workspaceVC
           
           freeplayWorkspaceVC.currentActorImageView = currentActorImageView
          
           freeplayWorkspaceVC.newActorToAdd = nil // don't add a new actor
        
       }
        if segue.identifier == "backToFreeplayWithNewActor" {
            let freeplayWorkspaceVC = segue.destination as! FreePlayWorkspaceViewController
       
             freeplayWorkspaceVC.currentProject = currentProject // pass the current project back to the workspaceVC
             
             freeplayWorkspaceVC.currentActorImageView = currentActorImageView
            
            freeplayWorkspaceVC.newActorToAdd = (name: selectedActor.name, baseImagePath: selectedActor.baseImagePath, color: "Default") // add a new actor
        }
       
    }
    
    
    @IBAction func addActorPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplayWithNewActor", sender: nil)
    }
    
    private var optionSelectedIndex = 0 // index of the option in the ActorsMenu array
    
    var items: NSArray = []
    
    var selectedActor = (name: "", baseImagePath: "", color: "")
    
    var currentProject: Project?
    
    var freeplayOutputView: FreeplayOutputView? // used during segues
    
    var currentActorImageView: UIImageView? // used during segues
   
    override func viewDidLoad() {
        
       
        
         if let path = Bundle.main.path(forResource: "ActorsMenu", ofType: "plist") {
            items = NSArray(contentsOfFile: path)!
         } else {
             print("could not access ActorsMenu plist")
         }
       
        actorsCollectionView.delegate = self
        actorsCollectionView.dataSource = self
        actorsCollectionView.register(ActorCell.self, forCellWithReuseIdentifier: "ActorCell")
         
        //let collectionView = configureCollectionView()
          
//        collectionView.isAccessibilityElement = false
//        collectionView.shouldGroupAccessibilityChildren = true  // this and more good voiceOver tips are from https://medium.com/bpxl-craft/how-to-make-voiceover-more-friendly-in-your-ios-app-8fac34ab8c51
          
       
        
        // Accessibility
        // Voice Over
//        optionModView.accessibilityElements = [back!, optionModTitle!, optionalExtraLabel!, collectionView!]
//        optionModTitle.accessibilityLabel = optionType
//        optionalExtraLabel.accessibilityLabel = optionalExtraLabel.text
//        //Dynamic Text
//        setFontStyle()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
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
        // Below code is from https://stackoverflow.com/questions/23647833/uicollectionviewcell-is-overlapped-when-scrolling
        for view in cell.subviews {
          view.removeFromSuperview()
        }
        // Above code is from https://stackoverflow.com/questions/23647833/uicollectionviewcell-is-overlapped-when-scrolling
       
        // Create an image for the cell
        var baseImagePath = ""
        var name = ""
    
        if let actorType = items[index] as? NSDictionary{
            baseImagePath = actorType.value(forKey: "imagePath") as! String
            var imagePath = VirtualRobot.calculateImagePath(baseImagePath: baseImagePath, color: "Default")
            name = actorType.value(forKey: "name") as! String
            let image = UIImage(named: imagePath)
            
            if image != nil  {
                // Show Icons is on
                let resizedImage = HelperFunctions.resizeImage(image: image!, scaledToSize: CGSize(width: buttonSize, height: buttonSize))  // resize the image to fit the button
                let imv = UIImageView(image: resizedImage)
                cell.addSubview(imv)
            }
        }
          
        // Accessibility
        cell.isAccessibilityElement = true
          
        cell.accessibilityHint = "Double tap to select"
        cell.accessibilityIdentifier = String(index)
          
        // Put a border around the cell if it is currently selected
        if String(optionSelectedIndex) == cell.accessibilityIdentifier {
            cell.layer.borderWidth = 10
            cell.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            cell.isSelected = true
            cell.accessibilityHint = "Selected"
            selectedActor = (name: name, baseImagePath: baseImagePath, color: "Default")
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
    
        if let actorType = items[optionSelectedIndex] as? NSDictionary{
            imagePath = actorType.value(forKey: "imagePath") as! String
            name = actorType.value(forKey: "name") as! String
            selectedActor = (name: name, baseImagePath: imagePath, color: "Default")
        }
        
    }
    
   
}
