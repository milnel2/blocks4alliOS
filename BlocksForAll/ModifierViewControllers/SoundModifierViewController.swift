//
//  SoundModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/20/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import Foundation
import UIKit


class SoundModifierViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    /* Custom view controller for the sound modifier scenes (ex. Animal Noise, Emotion Noise, etc.)*/
    
    public var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    
    private let cellReuseIdentifier = "Cell" // used for UICollectionView
    
    private var soundSelected = 0 // index of the sound choice in the soundDictionary array
    
    private var soundType = "Animal Noise" // Name of sounds that gets used for accessing data and displaying information
    
    // from Paul Hegarty, lectures 13 and 14
    private let defaults = UserDefaults.standard // used to know if in show text mode or show icon mode
    
    @IBOutlet weak var back: UIButton! // back arrow button
    
    @IBOutlet var soundModView: UIView! // view within the view controller
    
    @IBOutlet var soundModTitle: UILabel! // label at top of screen
    
    //TODO: get this sounddictionary from asset folders?
    // holds the different options for sounds
    // the keys are the same as what gets put in the soundModTitle and are accessed by using soundType
    // the values are arrays of strings which are the same as the image names for those sounds. In text mode, a capitalized version of these strings are shown instead of the images.
    // the first string in each array is the default value
    let soundDictionary: [String:[String]] =
        ["Animal Noise" :  ["cat", "crocodile", "dinosaur", "goat", "buzz", "elephant", "dog", "horse", "lion", "turkey", "random animal"],
         "Emotion Noise" : ["bragging", "confused", "giggle", "grunt", "sigh", "snore", "surprised", "yawn" ,"random emotion"],
         "Object Noise": ["laser", "squeak", "trumpet", "random object"],
         "Vehicle Noise": ["airplane", "beep", "boat", "helicopter", "siren", "speed boost", "start engine", "tire squeal", "train" ,"random vehicle"],
         "Speak" : ["hi", "bye", "cool", "haha", "hi", "huh", "let's go", "oh", "tah dah!", "uh huh", "uh oh", "wah", "wee hee!", "wee", "wow", "yippe!" ,"random word"]]
    
    var items: [String] = [] // holds the specific array of sound strings accessed from the soundDictionary
    
    private var attributeName = "" // a reformatted version of soundType. Used for accessing and saving data (ex. if soundType = "Animal Noise", attributeName is "animalNoise"
    
    // TODO: should buttonSize be the same value as blockSize?
    private let buttonSize = 150 // the size of each button that is showed in the collection view
    
    // from https://stackoverflow.com/questions/24110762/swift-determine-ios-screen-size
    let screenSize: CGRect = UIScreen.main.bounds // size of the screen that the app is being run on. Used to build button layout
    
    override func viewDidLoad() {
        let soundType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name // get the soundType from the button that caused this screen to open

        items = soundDictionary[soundType] ?? [] // get the array of sounds for the soundType

        // Derive attrtibuteName from soundType
        attributeName = ""
        let soundTypeWordArray = soundType.split(separator: " ")

        var i = 0
        for str in soundTypeWordArray {
            let wordToAppend: String
            if i == 0 {
                wordToAppend = str.lowercased()
            } else {
                wordToAppend = str.capitalized
            }
            attributeName.append(wordToAppend)
            i += 1
        }
        
        //Calculate where the collectionView should be put on the screen
        let screenWidth = Int(screenSize.width)
        let screenHeight = Int(screenSize.height)

        let soundModTitleY = Int(soundModTitle.layer.position.y)
        let collectionViewPadding = screenWidth / 5
        
        let collectionViewHeight = screenHeight - collectionViewPadding - soundModTitleY // take into account padding and the soundModTitle for how tall the collection view should be
        let collectionViewWidth = screenWidth - collectionViewPadding // take into account padding for how wide the collection view should be
        
        let middleOfScreenY = Int(screenHeight / 2) - Int(collectionViewHeight / 2)
        let middleOfScreenX = Int(screenWidth / 2) - Int(collectionViewWidth / 2)
      
        let startingY = Int(middleOfScreenY + (soundModTitleY))
        let startingX = Int(middleOfScreenX)
        
        // Configure the layout of the collectionView
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: buttonSize, height: buttonSize) // size of each cell
        
        // Create and set up the collectionView
        let vc = UICollectionView(frame: CGRect(x: startingX, y: startingY, width: collectionViewWidth, height: collectionViewHeight), collectionViewLayout: layout)
        vc.register(SoundButtonCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        vc.delegate = self
        vc.dataSource = self
        vc.isAccessibilityElement = true
        
        soundModView.addSubview(vc)

        soundModTitle.text = soundType // Set title of the screen
        
        // Default sound or preserve last selection
        let previousSound = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? items[0]

        soundSelected = items.firstIndex(of: previousSound) ?? 0 // get the index of the previousSound
        
        //TODO: switch control and VO not accessing the sound buttons
        //reroute VO Order to be more intuitive
        soundModView.accessibilityElements = [back!, soundModTitle!, vc]
    }
    
    /// Takes an image and returns a resized version of it
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    ///  Number of items in the section of the collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    /// Called when the collectionView is being populated with cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! SoundButtonCell
        let index = indexPath.item // numerical index of cell
        
        // Create an image for the cell
        let image = UIImage(named: items[index])
        if image != nil && defaults.value(forKey: "showText") as! Int == 0 {
            // Show Icons is on and the image was found
            let resizedImage = imageWithImage(image: image!, scaledToSize: CGSize(width: buttonSize, height: buttonSize)) // resize the image to fit the button
            let imv = UIImageView(image: resizedImage)
            cell.addSubview(imv)
        } else {
            // No image was found and/or show Text is on
            let textView = UILabel(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
            textView.text = items[index].capitalized
            
            // Text Style
            textView.textColor = .black
            textView.backgroundColor = .clear
            textView.textAlignment = .center
            textView.font = UIFont.accessibleFont(withStyle: .title2, size: 34.0)
            textView.adjustsFontForContentSizeCategory = true
            textView.adjustsFontSizeToFitWidth = true
            textView.numberOfLines = 2
            
            //TODO: have the background color match the type of block
            cell.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            
            cell.addSubview(textView)
        }
        
        // Put a border around the cell if it is currently selected
        if String(soundSelected) == cell.accessibilityIdentifier {
            cell.layer.borderWidth = 10
            cell.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        
        // Accessibility
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "cell \(index) of \(items.count) cells"
        cell.accessibilityIdentifier = String(index)
        
        //TODO: fix this
        //collectionView.accessibilityElements?.append(cell)
       
        return cell
    }
    
    /// Called when a sound button is pressed
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Deselect all buttons except for the currently selected one (only one can be selected at a time)
        for cell in collectionView.visibleCells{
            cell.isSelected = false
            cell.layer.borderWidth = 0
        }
        
        let selectedCell = collectionView.cellForItem(at: indexPath)
        selectedCell?.layer.borderWidth = 10
        selectedCell?.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        selectedCell?.isSelected = true
        soundSelected = indexPath.item
    }
    
    //TODO: test and finish the method
    func createVoiceControlLabels(button: UIButton) {
        var voiceControlLabel = button.accessibilityLabel!
        let wordToRemove = " Noise"
        if let range = voiceControlLabel.range(of: wordToRemove){
            voiceControlLabel.removeSubrange(range)
        }
        
        if #available(iOS 13.0, *) {
            button.accessibilityUserInputLabels = ["\(voiceControlLabel)", "\(button.accessibilityLabel!)"]
        }
    }
    
    /// Called when
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            // TODO: update so that just an array is used for images, so that soundSelected can be passed instead
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = items[soundSelected] // Tell BlocksViewController which sound was selected
        }
    }
}


class SoundButtonCell  : UICollectionViewCell {
    /* Custom cell class for the sound buttons*/
    // I got this class from https://stackoverflow.com/questions/39438803/how-to-create-uicollectionviewcell-programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init? (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

