//
//  SoundModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/20/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import Foundation
import UIKit

class SoundModifierViewController: UIViewController{
    /* Custom view controller for the sound modifier scenes (ex. Animal Noise, Emotion Noise, etc.*/
    
    var modifierBlockIndexSender: Int?
    var soundSelected: String = "cat"
    var soundType = "animalNoise"
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet var soundModView: UIView!
    
    @IBOutlet var soundModTitle: UILabel!
    
    
    var buttons: [UIButton] = []
    
    // from https://stackoverflow.com/questions/24110762/swift-determine-ios-screen-size
    let screenSize: CGRect = UIScreen.main.bounds // used to build button layout
    
    override func viewDidLoad() {
        
        //reroute VO Order to be more intuitive
        //animalModView.accessibilityElements = [animalTitle!,buttons!, back!]
        let animals = ["cat", "crocodile", "dinosaur", "goat", "buzz", "elephant", "dog", "horse", "lion", "turkey", "random animal"]
        let soundType = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].name
        var numButtons = 11
        var rows = 2
        var cols: Int = numButtons / 3 //swift rounds it down
        var addingToRowArray = [0,0,0]
        var numButtonsIsNiceAndEven = true
        if numButtons > 10 {
            rows = 3
            if numButtons % 3 == 1 {
                // third row will have 1 more than the others
                addingToRowArray = [0,0,1]
                numButtonsIsNiceAndEven = false
            } else if numButtons % 3 == 2{
                // second and third row will have 1 more than the other
                addingToRowArray = [0,1,1]
                numButtonsIsNiceAndEven = false
            }
        } else {
            // 2 rows
            if numButtons % 2 == 0 {
                // even number
                cols = numButtons / 2
            } else {
                // 2nd row will have 1 more than 1st
                addingToRowArray = [0,1]
                numButtonsIsNiceAndEven = false
            }
        }
        
        
        let screenWidth = Int(screenSize.width)
        let screenHeight = Int(screenSize.height)
        
        let buttonSize = 150
        let buttonSpacing = screenWidth / 40
        let soundModTitleY = Int(soundModTitle.layer.position.y)

        let heightOfButtons = (rows * buttonSize) + ((rows - 1) * buttonSpacing) // todo: what if this is going to go off og the screen? need to make buttons smaller
        let middleOfScreenY = Int((screenHeight - heightOfButtons) / 2)
        let startingY = Int(middleOfScreenY + (soundModTitleY))
        
        let widthOfButtons: Int
        if numButtonsIsNiceAndEven {
            widthOfButtons = (cols * buttonSize) + ((cols - 1) * buttonSpacing)// for even columns
        } else {
            widthOfButtons = ((cols + 1) * buttonSize) + ((cols + 1 - 1) * buttonSpacing)// for uneven columns
        }
        
        let startingX = Int((screenWidth - widthOfButtons) / 2)
        var x = startingX
        var y = startingY
        
        var index = 0
        
        for row in 1...rows {
            x = startingX
            for col in 1...cols {
                let button = UIButton(frame: CGRect(x: x, y: y, width: buttonSize, height: buttonSize))
                soundModView.addSubview(button)
                
                buttons.append(button)
                if index < animals.count {//index is in range of array
                    button.accessibilityLabel = animals[index]
                    let image = UIImage(named: animals[index])
                    if image != nil {
                        button.setBackgroundImage(image, for: .normal)
                    } else {
                        button.setTitle(animals[index], for: .normal)
                    }
                    
                    
                    button.accessibilityIdentifier = animals[index]
                    
                    
                    button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
                    
                    if col == cols && rows == 3{
                        if addingToRowArray[row - 1] == 1 {
                            index += 1
                            x += buttonSize + buttonSpacing
                            let extraButton = UIButton(frame: CGRect(x: x, y: y, width: buttonSize, height: buttonSize))
                            soundModView.addSubview(extraButton)
                            
                            buttons.append(extraButton)
                            if index < animals.count {//index is in range of array
                                extraButton.accessibilityLabel = animals[index]
                                let image = UIImage(named: animals[index])
                                if image != nil {
                                    extraButton.setBackgroundImage(image, for: .normal)
                                } else {
                                    extraButton.setTitle(animals[index], for: .normal)
                                }
                                
                                
                                extraButton.accessibilityIdentifier = animals[index]
                                
                                
                                extraButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
                            }
                        }
                    }
                } else { // there aren't any more values in the array
                    button.backgroundColor = .gray
                    button.accessibilityLabel = "N/A"
                    button.accessibilityIdentifier = "N/A"

                }
             
                    
                x += buttonSize + buttonSpacing
                index += 1
            }
            y += buttonSize + buttonSpacing
        
        }
        
        soundModTitle.text = soundType
        
        var attributeName = ""
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
        let previousSound: String = functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[attributeName] ?? "cat"
        
        soundSelected = previousSound
        
        for button in buttons {
            //Highlights current animal when mod view is entered
            if soundSelected == button.accessibilityIdentifier {
                button.layer.borderWidth = 10
                button.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
                button.isSelected = true
            }else{
                button.isSelected = false
            }
            createVoiceControlLabels(button: button)
        }
        back.titleLabel?.adjustsFontForContentSizeCategory = true
    }
    @objc func buttonPressed(sender : UIButton) {
        //Deselects all buttons but currently selected one (only one can be selected at a time)
        self.buttons.forEach { (button) in
            button.layer.borderWidth = 0
            button.isSelected = false
                }
        //Selects pressed button
        sender.layer.borderWidth = 10
        sender.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        if let buttonID = sender.accessibilityIdentifier {
            soundSelected = buttonID
            sender.isSelected = true
        }
        
        
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
            functionsDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes[soundType] = soundSelected
        }
    }
}

