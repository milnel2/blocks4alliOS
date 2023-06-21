//
//  SoundModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/20/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import Foundation
import UIKit
class MyCell  : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init? (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SoundModifierViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    /* Custom view controller for the sound modifier scenes (ex. Animal Noise, Emotion Noise, etc.*/
    
    var modifierBlockIndexSender: Int?
    var soundSelected = 0
    var soundType = "animalNoise"
    private let cellReuseIdentifier = "Cell"
    
    // from Paul Hegarty, lectures 13 and 14
    private let defaults = UserDefaults.standard
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet var soundModView: UIView!
    
    @IBOutlet var soundModTitle: UILabel!
    //TODO: get this sounddictionary from asset folders?
    let soundDictionary: [String:[String]] =
        ["Animal Noise" :  ["cat", "crocodile", "dinosaur", "goat", "buzz", "elephant", "dog", "horse", "lion", "turkey", "random animal"],
         "Emotion Noise" : ["bragging", "confused", "giggle", "grunt", "sigh", "snore", "surprised", "yawn" ,"random emotion"],
         "Object Noise": ["laser", "squeak", "trumpet", "random object"],
         "Vehicle Noise": ["airplane", "beep", "boat", "helicopter", "siren", "speed boost", "start engine", "tire squeal", "train" ,"random vehicle"],
         "Speak" : ["hi", "bye", "cool", "haha", "hi", "huh", "let's go", "oh", "tah dah!", "uh huh", "uh oh", "wah", "wee hee!", "wee", "wow", "yippe!" ,"random word"]]
    var items: [String] = []
    //private var buttons: [UIButton] = []
    
    private var attributeName = ""
    
    private let buttonSize = 150
    
    // from https://stackoverflow.com/questions/24110762/swift-determine-ios-screen-size
    let screenSize: CGRect = UIScreen.main.bounds // used to build button layout
    
    override func viewDidLoad() {
        
      
        
                
        let soundType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name
        
        items = soundDictionary[soundType] ?? []
        var numButtons = 11
    
        
       
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: buttonSize, height: buttonSize)

        
        // center the collectionView
        let screenWidth = Int(screenSize.width)
        let screenHeight = Int(screenSize.height)

        let buttonSpacing = screenWidth / 40
        let soundModTitleY = Int(soundModTitle.layer.position.y)
        let collectionViewPadding = 150
        let collectionViewHeight = screenHeight - collectionViewPadding - soundModTitleY
        let collectionViewWidth = screenWidth - collectionViewPadding
        let middleOfScreenY = Int(screenHeight / 2) - Int(collectionViewHeight / 2)
        let middleOfScreenX = Int(screenWidth / 2) - Int(collectionViewWidth / 2)
        let startingY = Int(middleOfScreenY + (soundModTitleY))
        let startingX = Int(middleOfScreenX)
        
        
        let vc = UICollectionView(frame: CGRect(x: startingX, y: startingY, width: collectionViewWidth, height: collectionViewHeight), collectionViewLayout: layout)
        
        vc.register(MyCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        vc.delegate = self
        vc.dataSource = self
        soundModView.addSubview(vc)

        soundModTitle.text = soundType

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
        // default: Cat or preserve last selection
        let previousSound = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? "cat"

        soundSelected = items.firstIndex(of: previousSound) ?? 0
        
        //TODO: switch control not working
        //reroute VO Order to be more intuitive
        soundModView.accessibilityElements = [back!, soundModTitle!, vc]
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! MyCell
        let index = indexPath.item
        cell.accessibilityLabel = items[index]
        let image = UIImage(named: items[index])
        
        if image != nil && defaults.value(forKey: "showText") as! Int == 0 {
            let resizedImage = imageWithImage(image: image!, scaledToSize: CGSize(width: buttonSize, height: buttonSize))
            let imv = UIImageView(image: resizedImage)
            cell.addSubview(imv)
        } else {
            let textView = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            textView.text = items[index].capitalized
            textView.textColor = .black
            textView.backgroundColor = .clear
            
            //cell.setTitle(items[index], for: .normal)
            cell.addSubview(textView)
        }
        cell.accessibilityIdentifier = String(index)
        if String(soundSelected) == cell.accessibilityIdentifier {
            cell.layer.borderWidth = 10
            cell.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }

        //cell.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Deselect all buttons but currently selected one (only one can be selected at a time)
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is BlocksViewController{
            // TODO: update so that just an array is used for images, so that soundSelected can be passed instead
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] = items[soundSelected]
        }
    }
}

