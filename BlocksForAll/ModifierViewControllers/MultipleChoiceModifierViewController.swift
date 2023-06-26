//
//  MultipleChoiceModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/20/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class MultipleChoiceModifierViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    /* Custom view controller for the multiple choice modifier scenes (ex. Animal Noise, Emotion Noise, Set Light Color, etc.)*/
      
      public var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
      
      private let cellReuseIdentifier = "Cell" // used for UICollectionView
      
      private var optionSelectedIndex = 0 // index of the option in the optionDictionary array
      
      private var optionType = "" // Name of options that gets used for accessing data and displaying information
      
      // from Paul Hegarty, lectures 13 and 14
      private let defaults = UserDefaults.standard // used to know if in show text mode or show icon mode
      
      @IBOutlet weak var back: UIButton! // back arrow button
      
      @IBOutlet var optionModView: UIView! // view within the view controller
      
      @IBOutlet var optionModTitle: UILabel! // label at top of screen
      
      //TODO: get this dictionary from asset folders?
      // holds the different options for each multiple choice modifier type
      // the keys are the same as what gets put in the optionModTitle and are accessed by using optionType
      // the values are arrays of strings which are the same as the image names for those options. In text mode, a capitalized version of these strings are shown instead of the images.
      // the first string in each array is the default value
      let optionDictionary: [String:[String]] =
          ["Animal Noise" :  ["cat", "crocodile", "dinosaur", "goat", "bee", "elephant", "dog", "horse", "lion", "turkey", "random animal"],
           "Emotion Noise" : ["bragging", "confused", "giggle", "grunt", "sigh", "snore", "surprised", "yawn" ,"random emotion"],
           "Object Noise": ["laser", "squeak", "trumpet", "random object"],
           "Vehicle Noise": ["airplane", "beep", "boat", "helicopter", "siren", "speed boost", "start engine", "tire squeal", "train" ,"random vehicle"],
           "Speak" : ["hi", "bye", "cool", "haha", "hi", "huh", "let's go", "oh", "tah dah!", "uh huh", "uh oh", "wah", "wee hee!", "wee", "wow", "yippe!" ,"random word"],
           "Set Right Ear Light Color" : ["red", "orange", "yellow", "green", "blue", "purple", "white", "black"],
           "Set Left Ear Light Color" : ["red", "orange", "yellow", "green", "blue", "purple", "white", "black"],
           "Set Chest Light Color" : ["red", "orange", "yellow", "green", "blue", "purple", "white", "black"],
           "Set All Lights Color": ["red", "orange", "yellow", "green", "blue", "purple", "white", "black"]]
      
      var items: [String] = [] // holds the specific array of modifier type strings accessed from the optionDictionary
      
      private var attributeName = "" // a reformatted version of optionType. Used for accessing and saving data (ex. if soundType = "Animal Noise", attributeName is "animalNoise"
      
      // TODO: should buttonSize be the same value as blockSize?
      private let buttonSize = 150 // the size of each button that is showed in the collection view
      
      // from https://stackoverflow.com/questions/24110762/swift-determine-ios-screen-size
      let screenSize: CGRect = UIScreen.main.bounds // size of the screen that the app is being run on. Used to build button layout
      
      override func viewDidLoad() {
          
          optionType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name // get the optionType from the button that caused this screen to open
          
          items = optionDictionary[optionType] ?? [] // get the array of options for the optionType

          attributeName = getAttributeName()
          
          let collectionView = configureCollectionView()
          
          collectionView.isAccessibilityElement = false
          
          collectionView.shouldGroupAccessibilityChildren = true // this and more good voiceOver tips are from https://medium.com/bpxl-craft/how-to-make-voiceover-more-friendly-in-your-ios-app-8fac34ab8c51
          

          optionModTitle.text = optionType // Set title of the screen
          
          // Default option or preserve last selection
          let previousOption = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? items[0]

          optionSelectedIndex = items.firstIndex(of: previousOption) ?? 0 // get the index of the previousOption
          
          //reroute VO Order to be more intuitive
          optionModView.accessibilityElements = [back!, optionModTitle!, collectionView]
          
          optionModTitle.accessibilityLabel = optionType
      }
      
      ///  Number of items in the section of the collectionView
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return self.items.count
      }
      
      /// Called when the collectionView is being populated with cells
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! MultipleChoiceButtonCell
          let index = indexPath.item // numerical index of cell
          
          // Create an image for the cell
          let image = UIImage(named: items[index])
          if image != nil && defaults.value(forKey: "showText") as! Int == 0 {
              // Show Icons is on and the image was found
              let resizedImage = reiszeImage(image: image!, scaledToSize: CGSize(width: buttonSize, height: buttonSize)) // resize the image to fit the button
              let imv = UIImageView(image: resizedImage)
              cell.addSubview(imv)
          } else {
              // No image was found and/or Show Text is on
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
              
              // Naming convention for color assets is (attributeName)Color
              // ex. animalNoiseColor, emotionNoiseColor
              let colorPath = "\(attributeName)Color"
              let myUIColor = UIColor(named: colorPath)
              cell.backgroundColor = myUIColor ?? #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
              
              cell.addSubview(textView)
          }
          
          // Accessibility
          cell.isAccessibilityElement = true
          
          if attributeName == "lightColor" {
              cell.accessibilityLabel = "\(items[index]) color. Option \(index + 1) of \(items.count)"
          } else {
              cell.accessibilityLabel = "\(items[index]) sound. Option \(index + 1) of \(items.count)"
          }
          
          cell.accessibilityHint = "Double tap to select"
          cell.accessibilityIdentifier = String(index)
          
          // Put a border around the cell if it is currently selected
          if String(optionSelectedIndex) == cell.accessibilityIdentifier {
              cell.layer.borderWidth = 10
              cell.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
              cell.isSelected = true
              cell.accessibilityHint = "Selected"
          } else {
              cell.isSelected = false
          }
         
          return cell
      }
      
      /// Called when an option button is pressed
      /// Deselect all buttons except for the currently selected one (only one can be selected at a time)
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          for cell in collectionView.visibleCells{ // deselect all buttons
              cell.isSelected = false
              cell.layer.borderWidth = 0
          }
          
          let selectedCell = collectionView.cellForItem(at: indexPath) // highlight the one selected button
          selectedCell?.layer.borderWidth = 10
          selectedCell?.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
          selectedCell?.isSelected = true
          optionSelectedIndex = indexPath.item
      }
      
      //TODO: test and finish this method
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
      
      /// Derive attrtibuteName from optionType
      /// Turns a phrase into camelcase (ex. Animal Noise -> animalNoise)
      private func getAttributeName () -> String {
         
          var tempAttributeName = ""
          let soundTypeWordArray = optionType.split(separator: " ") // remove spaces

          var i = 0
          for str in soundTypeWordArray {
              let wordToAppend: String
              if i == 0 {
                  wordToAppend = str.lowercased() // first word is lowercased
              } else {
                  wordToAppend = str.capitalized // all other words are capitalized
              }
              tempAttributeName.append(wordToAppend)
              i += 1
          }
          
          //TODO: fix this code so that this if statement isnt needed
          if optionType.contains("Light Color") || optionType.contains("Lights Color"){ // sets the attribute name for light color blocks
              tempAttributeName = "lightColor"
          }
         
          return tempAttributeName
      }
      
      /// Builds and returns a UICollectionView to hold the modifier buttons
      func configureCollectionView() -> UICollectionView{
          //Calculate where the collectionView should be put on the screen
          //TODO: center cells in collectionView?
          let screenWidth = Int(screenSize.width)
          let screenHeight = Int(screenSize.height)

          let soundModTitleY = Int(optionModTitle.layer.position.y)
          let collectionViewPadding = screenWidth / 5
          
          let collectionViewHeight = screenHeight - collectionViewPadding - soundModTitleY // take into account padding and the optionModTitle for how tall the collection view should be
          let collectionViewWidth = screenWidth - collectionViewPadding // take into account padding for how wide the collection view should be
          
          let middleOfScreenY = Int(screenHeight / 2) - Int(collectionViewHeight / 2)
          let middleOfScreenX = Int(screenWidth / 2) - Int(collectionViewWidth / 2)
        
          let startingY = Int(middleOfScreenY + (soundModTitleY))
          let startingX = Int(middleOfScreenX)
          
          // Configure the layout of the collectionView
          let layout = UICollectionViewFlowLayout()
          layout.itemSize = CGSize(width: buttonSize, height: buttonSize) // size of each cell
          
          // Create and set up the collectionView
          let myCollectionView = UICollectionView(frame: CGRect(x: startingX, y: startingY, width: collectionViewWidth, height: collectionViewHeight), collectionViewLayout: layout)
          myCollectionView.register(MultipleChoiceButtonCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
          myCollectionView.delegate = self
          myCollectionView.dataSource = self
          myCollectionView.isAccessibilityElement = true
          myCollectionView.backgroundColor = .clear
          
          optionModView.addSubview(myCollectionView)
          
          return myCollectionView
      }
      
      /// Takes an image and returns a resized version of it
      func reiszeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
          UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
          image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
          let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
          UIGraphicsEndImageContext()
          return newImage
      }
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?){
          if segue.destination is BlocksViewController{
              // TODO: update so that just an array is used for images, so that soundSelected can be passed instead
              functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = items[optionSelectedIndex] // Tell BlocksViewController which sound was selected
              
              //TODO: make this come from the modifierProperties dictionary
              if attributeName == "lightColor" {
                  functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["modifierBlockColor"] = items[optionSelectedIndex]
              }
          }
      }
  }

  class MultipleChoiceButtonCell  : UICollectionViewCell {
      /* Custom cell class for the multiple choice buttons buttons*/
      // I got this class from https://stackoverflow.com/questions/39438803/how-to-create-uicollectionviewcell-programmatically
      override init(frame: CGRect) {
          super.init(frame: frame)
      }
      
      required init? (coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
  }
