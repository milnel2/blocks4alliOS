//  edit 6/18/19
//  SelectedBlockViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 6/1/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class SelectedBlockViewController: UIViewController {
    /*View controller that displays the currently selected block (selected either from workspace or
     toolbox, which you are moving */
    
    var blocks: [Block]?
    var blockSize = 200
    let blockSpacing = 1
    var delegate: BlockSelectionDelegate?
    
    //MARK: - viewDidLoad function
    override func viewDidLoad() {
        print("\n")
        print("entered viewDidLoad")
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.accessibilityLabel = "Back"
        
        //Puts top of selected block view at the top of the screen
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        let myFrame = CGRect(x: 0, y: Int(self.view.bounds.height/2), width: 0, height: 0)
        
        let myBlockView = BlockView.init(frame: myFrame, block: blocks!, myBlockSize: blockSize)
        
        self.view.addSubview(myBlockView)
                
        if blocks![0].isModifiable ?? false {
            let modifierButton = createModifierButton()
            modifierButton.addTarget(self, action: #selector(modifierPressed(sender:)), for: .touchUpInside)
            myBlockView.addSubview(modifierButton)
        }
       
        // Do any additional setup after loading the view.
        let label = (blocks?[0].name)! + " selected. Select location in workspace to place it"
        
        if #available (iOS 13.0, *){
            self.view.accessibilityUserInputLabels = [""]
        }
        
        self.view.isAccessibilityElement = true
        self.view.accessibilityLabel = label
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: self.view)
        
        delegate?.beginMovingBlocks(blocks!)
        delegate?.setParentViewController(self.parent!)
    }
    @objc func modifierPressed(sender: UIButton!) {
        print("Modifier button in toolbox pressed")
    }
    
    func createModifierButton() -> CustomButton {
        let modifierButton = CustomButton(frame: CGRect(x: (blockSize / 7), y:(-blockSize * 8) / 9, width: (blockSize / 4) * 3, height: (blockSize / 4) * 3))
        
        let dict = getModifierDictionary() // holds properties of all modifier blocks
        let name = blocks![0].name
        let (defaultValue, attributeName, imagePath, displaysText, secondAttributeName, secondDefault, showTextImage) = getModifierData(name: name, dict: dict!) // constants taken from dict based on name
        var placeHolderBlock = blocks![0]
        if blocks?[0].addedBlocks.count ?? 0 > 0 {
            // renamed block.addedBlocks[0] for simplicity
            placeHolderBlock = blocks![0].addedBlocks[0]
        }
        // the current state of the block modifier - used for voiceOver
        //TODO: should this be added back in?
//        var modifierInformation = placeHolderBlock.attributes[attributeName] ?? nil
        
        // choose image path
        var image: UIImage?
        if imagePath != nil { // blocks have an imagePath in the dictionary if their image is not based on the attribute (ex. controlModifierBackground)
            image = UIImage(named: imagePath!)

            if image != nil { // make sure that the image actually exists
                modifierButton.setBackgroundImage(image, for: .normal)
            } else { // print error
                print("Image file not found: \(imagePath!)")
                modifierButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        } else {
            // blocks that don't have an imagePath in the dictionary have an image based on their attribute (ex. cat and bragging sounds)
            image = UIImage(named: "\(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
            if secondAttributeName != nil && secondDefault != nil{
                image = UIImage(named: "\(placeHolderBlock.attributes[secondAttributeName!] ?? secondDefault!)")
            }
            // handle show icon or show text for modifiers that change depending on the settings
            if defaults.integer(forKey: "showText") == 1 && showTextImage != nil{
                // show text image
                image = UIImage(named: showTextImage!)
            }
            if image != nil { // make sure that the image actually exists
                modifierButton.setBackgroundImage(image, for: .normal)
            } else {
                print("Image file not found: \(placeHolderBlock.attributes[attributeName] ?? defaultValue)")
                modifierButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            }
        }
        
        if displaysText == "true" { // modifier blocks that display text on them (ex. turn left)
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
                    text = "\(placeHolderBlock.attributes["distance"] ?? defaultValue) cm \n"
                    //modifierInformation = text + ", \(placeHolderBlock.attributes["speed"] ?? secondDefault)"
                } else {
                    // show text mode
                    text = "\(placeHolderBlock.attributes["distance"] ?? defaultValue) cm, \(placeHolderBlock.attributes["speed"] ?? secondDefault ?? "N/A")"
                    //modifierInformation = text
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
            } else if attributeName == "variableSelected" {
                // variable blocks
                text = "\(text) = \(placeHolderBlock.attributes["variableValue"] ?? secondDefault ?? "N/A")"
                //modifierInformation = text
            }
            modifierButton.setTitle(text, for: .normal)
            
            // TODO: allow for font to be either .title1 or .title2 depending on what fits best
            modifierButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
            modifierButton.setTitleColor(.black, for: .normal)
            modifierButton.titleLabel?.numberOfLines = 0
        }
        return modifierButton
    }
    
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
    
    private func getModifierDictionary () -> NSDictionary?{
        /* converts ModifierProperties plost to a NSDictionary*/
        // this code to access a plist as a dictionary is from https://stackoverflow.com/questions/24045570/how-do-i-get-a-plist-as-a-dictionary-in-swift
        let dict: NSDictionary?
         if let path = Bundle.main.path(forResource: "ModifierProperties", ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
         } else {
             print("could not access ModifierProperties plist")
             return nil
         }
        return dict!
    }
    
    /// gets values for modifier blocks from a dictionary and returns them as a tuple. Prints errors if properties cannot be found
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
