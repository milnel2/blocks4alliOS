//
//  SelectedBlockViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 6/1/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

/// View controller that displays the currently selected block (selected either from workspace or toolbox), which you are moving.
class SelectedBlockViewController: UIViewController {
    
    var blocks: [Block]?
    var blockSize = 200
    let blockSpacing = 1
    var delegate: BlockSelectionDelegate?
    
    var currentProject: Project? = nil
    
    //MARK: - viewDidLoad function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.backBarButtonItem?.accessibilityLabel = "Back"
        
        // Puts top of selected block view at the top of the screen
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        var myFrame = CGRect()
        if self.parent?.parent is FreePlayWorkspaceViewController {
            blockSize = 125
            myFrame = CGRect(x: 0, y: Int(7 * self.view.bounds.height / 26), width: 0, height: 0)
        } else {
            blockSize = 200
            myFrame = CGRect(x: 0, y: Int(15 * self.view.bounds.height / 24), width: 0, height: 0)
        }
        
        
        let myBlockView = BlockView.init(frame: myFrame, block: blocks!, myBlockSize: blockSize)
        
        self.view.addSubview(myBlockView)
                
        if blocks![0].isModifiable ?? false {
            let modifierButton = createModifierButton()
            myBlockView.addSubview(modifierButton)
        }
        
        // Do any additional setup after loading the view.
        let label = (blocks?[0].name)! + " selected. Select location in workspace to place it"
        
        if #available (iOS 13.0, *){
            self.view.accessibilityUserInputLabels = [""]
        }
        
        self.view.isAccessibilityElement = true
        self.view.accessibilityLabel = label
        
        // Add label to blocks if they are able to have other blocks nested inside them
        if (blocks![0].double) {
            let nestedBlockView = createNestedBlockView()
            myBlockView.addSubview(nestedBlockView)
        }
    
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: self.view)
        delegate?.beginMovingBlocks(blocks!)
        delegate?.setParentViewController(self.parent!)
    }
    
    //MARK: - Show modifier in moving block
    func createModifierButton() -> UIButton {
        let modifierButton = ModifierButton(frame: CGRect(x: (blockSize / 7), y:(-blockSize * 8) / 9, width: (blockSize / 4) * 3, height: (blockSize / 4) * 3))
        
        
        let dict = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties") // holds properties of all modifier blocks
        let name = blocks![0].name
        let (defaultValue, attributeName, imagePath, displaysText, secondAttributeName, secondDefault, showTextImage) = getModifierData(name: name, dict: dict!) // constants taken from dict based on name
        var placeHolderBlock = blocks![0]
        if blocks?[0].addedBlocks.count ?? 0 > 0 {
            // renamed block.addedBlocks[0] for simplicity
            placeHolderBlock = blocks![0].addedBlocks[0]
            
            
           
            
        }
        
        modifierButton.block = placeHolderBlock
        modifierButton.currentProject = currentProject
        
        // the current state of the block modifier - used for voiceOver
        //TODO: should this be added back in?
        //        var modifierInformation = placeHolderBlock.attributes[attributeName] ?? nil
        if defaults.value(forKey: "showText") as! Int == 0 || (displaysText == "true" && defaults.value(forKey: "showText") as! Int == 1) { // show icons is on
            // choose image path
            var image: UIImage?
            if imagePath != nil { // blocks have an imagePath in the dictionary if their image is not based on the attribute (ex. controlModifierBackground)
                image = HelperFunctions.getUIImage(named: imagePath!)
                
                if image != nil { // make sure that the image actually exists
                    modifierButton.setBackgroundImage(image, for: .normal)
                } else { // print error
                    print("Image file not found: \(imagePath!)")
                    modifierButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                }
            } else {
                // blocks that don't have an imagePath in the dictionary have an image based on their attribute (ex. cat and bragging sounds)
                if secondAttributeName != "variableValue" {
                    if attributeName == "moveToActor" { // images for moveToActor modifier
                        let uuid = placeHolderBlock.attributes[attributeName] ?? ""
                       
                        let actor = VirtualRobot.getActorFromUUIDOrDefault(actorUUID: uuid, inProject: currentProject!)
                        // TODO: create a default value for moveToActor blocks to move nowhere. right now if you just place the block it doesn't work. blocks![0].addedBlocks[0].attributes["moveToActor"] = actor!.UUID
                        image = UIImage(named: actor!.imagePath)
                    } else {
                        image = UIImage(named: "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                    }
                    if secondAttributeName != nil && secondDefault != nil
                    { image = UIImage(named: "\(placeHolderBlock.attributes[secondAttributeName!] ?? secondDefault!)") }
                    
                    // handle show icon or show text for modifiers that change depending on the settings
                    if defaults.integer(forKey: "showText") == 1 && showTextImage != nil{
                        // show text image
                        image = UIImage(named: showTextImage!)
                    }
                    
                    if attributeName == "background" {
                        image = HelperFunctions.getUIImage(named: placeHolderBlock.attributes[attributeName] ?? defaultValue)
                    }
                    if image != nil {  // make sure that the image actually exists
                        modifierButton.setBackgroundImage(image, for: .normal)
                    } else if secondAttributeName != "cellIndex"{
                        print("Image file not found: \(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                        modifierButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                    }
                } else if defaults.value(forKey: "showText") as! Int == 0 {
                    // set variable modifier blocks are a bit different than other modifier blocks
                    image = UIImage(named: "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)Icon") // these special images are called (fruitName)Icon (ex. AppleIcon)
                    if image != nil {  // make sure that the image actually exists
                        modifierButton.setBackgroundImage(image, for: .normal)
                    } else {
                        print("Image file not found: \(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                        modifierButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                    }
                }
            }
        } else if displaysText != "true"  && name != "Move to Location"{  // show text is on
            // No image was found and/or Show Text is on
            // set up fonts before setting the text
            modifierButton.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
            modifierButton.titleLabel?.adjustsFontForContentSizeCategory = true
            
            if #available(iOS 13.0, *) {
                modifierButton.setTitleColor(.label, for: .normal)
            } else {
                modifierButton.setTitleColor(.black, for: .normal)
            }
            
            var colorPath: String = ""
            if name.contains("Light Color") || name.contains("Lights Color") {
                // light modifiers have a different color for each button, so there is a different naming convention
                colorPath = "yellowOpaqueColor"
            } else {
                let backgroundImagePath = "\(attributeName)Background"
                let backgroundImage = UIImage(named: backgroundImagePath)
                if backgroundImage != nil {
                    modifierButton.setBackgroundImage(backgroundImage, for: .normal)
                } else {
                    modifierButton.backgroundColor =  UIColor(named: "whiteOpaqueColor")
                }
            }
            if colorPath != "" {
                let myUIColor = UIColor(named: colorPath)
                modifierButton.backgroundColor = myUIColor ??  UIColor(named: "whiteOpaqueColor")
            }
            
           
            modifierButton.layer.cornerRadius = 20
            // add button rounded border
            
            if name == "Move to Actor" { // move to actor modifiers are a bit different because their default value is a UUID
                let actor = VirtualRobot.getActorFromUUIDOrDefault(actorUUID: defaultValue, inProject: currentProject!)!
                modifierButton.setTitle(actor.color.capitalized + " " + actor.name.capitalized, for: .normal)
            } else {
                modifierButton.setTitle(defaultValue.capitalized, for: .normal)
            }

           
            modifierButton.titleLabel?.numberOfLines = 2
            modifierButton.titleLabel?.lineBreakMode = .byWordWrapping
        }
                                                               
        if displaysText == "true" {
            // modifier blocks that display text on them (ex. turn left)
            
            // set up fonts before setting the text
            modifierButton.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
            modifierButton.titleLabel?.adjustsFontForContentSizeCategory = true
            if #available(iOS 13.0, *) {
                modifierButton.setTitleColor(.label, for: .normal)
            } else {
                modifierButton.setTitleColor(.black, for: .normal)
            }
            modifierButton.titleLabel?.numberOfLines = 0
            
            var text = "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)"
            // handle text formatting based on type of block
            if attributeName == "angle" {
                //<angle>°
                text = "\(text)\u{00B0}"
                //modifierInformation = text
            } else if attributeName == "distance" {
                //drive forward and backwards blocks
                if defaults.integer(forKey: "showText") == 0 {
                    // show icon mode
                    if modifierButton.titleLabel?.font.pointSize ?? 26 <= 34 {
                        text = "30 cm \n"
                    } else {
                        text = "30\n"
                    }
                } else {
                    // show text mode
                    if modifierButton.titleLabel?.font.pointSize ?? 26 <= 34 {
                        text = "30 cm, \nNormal"
                    } else {
                        text = "30, \nNormal"
                    }
                }
            } else if attributeName == "wait" {
                // wait blocks
                if placeHolderBlock.attributes["wait"] == "1"{
                    text = "\(text) second"
                } else if  placeHolderBlock.attributes["wait"] == nil{
                    text = "1 second"
                } else {
                    text = "\(text) seconds"
                }
                //modifierInformation = text
            } else if attributeName == "variableSelected" {  // variable blocks
                if defaults.value(forKey: "showText") as! Int == 0 {
                    text = "\n\n= \(placeHolderBlock.attributes["variableValue"] ?? "0.0")"
                } else {
                    text = "\(placeHolderBlock.attributes["variableSelected"] ?? defaultValue) = \(placeHolderBlock.attributes["variableValue"] ?? secondDefault ?? "0.0")"
                }
                
            }
            modifierButton.setTitle(text, for: .normal)
            
            // TODO: allow for font to be either .title1 or .title2 depending on what fits best
            modifierButton.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 30.0)
            if #available(iOS 13.0, *) {
                modifierButton.setTitleColor(.label, for: .normal)
            } else {
                modifierButton.setTitleColor(.black, for: .normal)
            }
            modifierButton.titleLabel?.numberOfLines = 0
        }
        return modifierButton
    }
    
    /// Creates a label to be added to a block when it is selected. The label says how many blocks are nested within that block. (Used for blocks like repeat, if, etc.)
    func createNestedBlockView() -> UIView {
        // Create the view for the label and put it at the top of the block
        var nestedBlockView = UIView(frame: CGRect(x: 0, y:(-blockSize * 5) / 4, width: blockSize, height: (blockSize / 4)))
        
        // Non-modifiable blocks are shorter, so they have to be placed lower on the screen
        if (!blocks![0].isModifiable!){
            nestedBlockView = UIView(frame: CGRect(x: 0, y:(-blockSize/4), width: blockSize, height: (blockSize / 4)))
        }
        
        // Set the background color of the view to be the same as the background color of the block
        nestedBlockView.backgroundColor = UIColor(named: "\(blocks![0].colorName)")
        
        
        let nestedBlockLabel = UILabel()

       
        let numNestedBlocks = blocks!.count - 2 // the number of blocks that are nested inside of this block (don't count the start and end blocks)
        
        var label = (blocks?[0].name)! + "block with " + String(numNestedBlocks) + " nested blocks selected. Select location in workspace to place it" // Accessibility label for voiceOver
        
        // Set text for the label based on the number of nested blocks (singular or plural)
        if (numNestedBlocks == 1) {
            nestedBlockLabel.text = "1 Nested Block"
            label = (blocks?[0].name)! + "block with 1 nested block selected. Select location in workspace to place it" // Accessibility label for voiceOver
        } else {
            nestedBlockLabel.text = String(numNestedBlocks) + " Nested Blocks"
        }
        
        // Text styling
        nestedBlockLabel.textAlignment = .center
        nestedBlockLabel.font = UIFont.accessibleFont(withStyle: .title1, size: 20.0)
        
        // Label styling
        nestedBlockLabel.backgroundColor = .white
        nestedBlockLabel.layer.cornerRadius = 6
        nestedBlockLabel.layer.masksToBounds = true
        
        // Code for centering a UILabel inside a UIView is from StackOverflow user devbot10's answer from 2018: https://stackoverflow.com/questions/34645943/how-to-center-uilabel-in-swift
        
        nestedBlockLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nestedBlockView.addSubview(nestedBlockLabel)
        
        nestedBlockLabel.centerXAnchor.constraint(equalTo: nestedBlockView.centerXAnchor).isActive = true
        nestedBlockLabel.centerYAnchor.constraint(equalTo: nestedBlockView.centerYAnchor).isActive = true

        // End of code citation
        
        // Set the size of the label based on its parent view
        nestedBlockLabel.widthAnchor.constraint(equalTo: nestedBlockView.widthAnchor, multiplier: 0.9).isActive = true
        nestedBlockLabel.heightAnchor.constraint(equalTo: nestedBlockView.heightAnchor, multiplier: 0.6).isActive = true
        
        // Accessibility
        nestedBlockLabel.adjustsFontSizeToFitWidth = true
        nestedBlockView.isAccessibilityElement = true
        self.view.accessibilityLabel = label
        
        return nestedBlockView
    }
    
    //MARK: - Private Functions
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            // view controller is popping
            delegate?.finishMovingBlocks()
        }
    }
    
    
    /// Gets values for modifier blocks from a dictionary and returns them as a tuple. Prints errors if properties cannot be found.
    private func getModifierData (name : String, dict : NSDictionary) -> (String, String, String?, String, String?, String?, String?) {
        if dict[name] == nil {
            print("\(name) could not be found in modifier block dictionary")
        }
        let subDictionary = dict.value(forKey: name) as! NSDictionary // renamed for simplicity
        
        let defaultValue = subDictionary.value(forKey: "default")
        if defaultValue == nil {
            print("default value for \(name) could not be found")
        }
        let attributeName = subDictionary.value(forKey: "attributeName")
        if attributeName == nil {
            print("attributeName for \(name) could not be found")
        }
        let accessibilityHint = subDictionary.value(forKey: "accessibilityHint")
        if accessibilityHint == nil {
            print("accessibilityHint for \(name) could not be found")
        }
        // these properties are all optional, so they don't need an error message
        let imagePath = subDictionary.value(forKey: "imagePath") ?? nil
        let displaysText = subDictionary.value(forKey: "displaysText") ?? "false"
        let secondAttributeName = subDictionary.value(forKey: "secondAttributeName") ?? nil
        let secondDefault = subDictionary.value(forKey: "secondDefault") ?? nil
        let showTextImage = subDictionary.value(forKey: "showTextImage") ?? nil
        
        return (defaultValue! as! String, attributeName! as! String, imagePath as? String, displaysText as! String, secondAttributeName as? String, secondDefault as? String, showTextImage as? String)
    }
    
    // TODO: is a prepare() function needed?
}
