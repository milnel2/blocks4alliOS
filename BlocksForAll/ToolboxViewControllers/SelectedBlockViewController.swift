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
        let formattedString = NSLocalizedString("block_selected_access_label", comment: "Accessibility label for when a block is selected to move")
        let label = String.localizedStringWithFormat(formattedString, (blocks?[0].name.localized)!)
        
        
        
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
        let dict = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties") // holds properties of all modifier blocks
        let name = blocks![0].name
        let (defaultValue, attributeName, imagePath, displaysText, secondAttributeName, secondDefault, showTextImage) = getModifierData(name: name, dict: dict!) // constants taken from dict based on name
        var placeHolderBlock = blocks![0]
        
        let modifierData = ModifierButtonData(modifierButton: nil, blockName: name, selector: nil, defaultValue: defaultValue, attributeName: attributeName, accessibilityHint: "", imagePath: imagePath, displaysText: displaysText, secondAttributeName: secondAttributeName, secondDefault: secondDefault, showTextImage: showTextImage)
        let buttonFrame = CGRect(
            x: (blockSize / 7),
            y:(-blockSize * 8) / 9,
            width: (blockSize / 4) * 3,
            height: (blockSize / 4) * 3)
       
        
        
        if blocks?[0].addedBlocks.count ?? 0 > 0 {
            // renamed block.addedBlocks[0] for simplicity
            placeHolderBlock = blocks![0].addedBlocks[0]
        }
        
        let modifierButton = ModifierButton(frame: buttonFrame, block: placeHolderBlock, modifierData: modifierData)
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
        let formattedString = NSLocalizedString("nested_block_selected_access_label", comment: "Accessibility label for when a nested block is selected to move. Says name of block and how many blocks (int) are nested within it") // TODO: don't forget to test this one
        let blockName = blocks![0].name.localized
        var label = "\(blockName) \(String.localizedStringWithFormat(formattedString, numNestedBlocks))"
        
        let formattedString2 = NSLocalizedString("num_nested_blocks", comment: "Label for how many blocks are nested within a block. '<num> Nested Block(s)'")
        nestedBlockLabel.text = String.localizedStringWithFormat(formattedString2, numNestedBlocks)
        
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
    private func getModifierData (name : String, dict : NSDictionary) -> (String, String, String?, Bool, String?, String?, String?) {
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
        let displaysText = (subDictionary.value(forKey: "displaysText") ?? "false") as! String == "true"
        let secondAttributeName = subDictionary.value(forKey: "secondAttributeName") ?? nil
        let secondDefault = subDictionary.value(forKey: "secondDefault") ?? nil
        let showTextImage = subDictionary.value(forKey: "showTextImage") ?? nil
        
        return (defaultValue! as! String, attributeName! as! String, imagePath as? String, displaysText, secondAttributeName as? String, secondDefault as? String, showTextImage as? String)
    }
    
    // TODO: is a prepare() function needed?
}
