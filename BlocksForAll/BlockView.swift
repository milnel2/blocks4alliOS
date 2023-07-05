//
//  BlockView.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 6/1/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AudioToolbox

/// Given a block, creates the view that should be shown.
class BlockView: UIView, UITextFieldDelegate {
    
    var blocks: [Block]  // The block in the view. May be multiple blocks if the block includes start/end blocks (repeat block, etc.)
    var blockSize = 150  // Creates the width and height of the block view.
    let blockSpacing = 1  // TODO: Find out what this does. If anything.
    
    //MARK: - Initialization
    init (frame : CGRect, block : [Block], myBlockSize: Int) {
        
        self.blocks = block
        super.init(frame : frame)
        blockSize = myBlockSize
        self.addSubview(simpleView(FromBlock: block))
    }
    
    //MARK: - Accessible Element Focus
    override func accessibilityElementDidBecomeFocused()
    {
        print(blocks[0].name + " is focused")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Creation
    func simpleView(FromBlock block: [Block]) -> UIView {
        
        let block = block[0]
        
        let isModifierBlock = block.isModifiable ?? false
        
        var myViewHeight: Int
        let myFrame: CGRect
        let myViewWidth: Int
        
        // Makes the blocks wider if they are in the toolbox.
        if block.isInToolBox ?? false {
            //TODO: test this on different size screens
            myViewWidth = (blockSize * 3) / 2
        } else {
            myViewWidth = blockSize
        }
        
        // Sets the view and frame size based on whether the block has a modifier or not.
        if isModifierBlock {
            myViewHeight = blockSize * 2  // Modifier blocks are twice the height of normal blocks
            myFrame = CGRect(x: 0, y: -myViewHeight/2, width: myViewWidth, height: myViewHeight)
        } else {
            myViewHeight = blockSize
            myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        }
        
        // Sets the view properties (e.g. background color & image).
        let myView = UIView(frame: myFrame)
        myView.backgroundColor = block.color.uiColor
        if(block.imageName != nil && defaults.integer(forKey: "showText") == 0) {
            let imageName = block.imageName!
            var image = UIImage(named: imageName)
            let imv: UIImageView
            if isModifierBlock {
                image = imageWithImage(image: image!, scaledToSize: CGSize(width: blockSize, height: myViewHeight / 2))
                imv = UIImageView.init(image: image)
                imv.layer.position.y = CGFloat((blockSize * 6) / 4)
                if block.isInToolBox ?? false {  // center the image if the block is in the toolbox
                    imv.layer.position.x = CGFloat((myViewWidth) - ((blockSize * 4) / 5))
                }
            } else {
                image = imageWithImage(image: image!, scaledToSize: CGSize(width: blockSize, height: myViewHeight))
                imv = UIImageView.init(image: image)
                imv.layer.position.y = CGFloat((blockSize / 2))
                if block.isInToolBox ?? false {  // center the image if the block is in the toolbox
                    imv.layer.position.x = CGFloat((myViewWidth) - ((blockSize * 4) / 5))
                }
            }
            myView.addSubview(imv)
        }else {
            // Sets the block label if it doesn't have an image or if the app is in show text mode.
            let myLabel = UILabel.init(frame: myFrame)
            myLabel.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
            myLabel.numberOfLines = 0
            myLabel.adjustsFontForContentSizeCategory = true
            let currentFontSize = myLabel.font.pointSize
            
            var name = block.name
            if currentFontSize > 31.0 { // If dynamic text is being used, some of the labels need to be shortened.
                name = removePhrase(phraseToRemove: " Noise", originalString: name)
                name = removePhrase(phraseToRemove: "Drive ", originalString: name)
                name = removePhrase(phraseToRemove: "Set ", originalString: name)
                name = removePhrase(phraseToRemove: " Color", originalString: name)
                name = removePhrase(phraseToRemove: " for Time", originalString: name)
                name = removePhrase(phraseToRemove: " or ", originalString: name, replaceWith: "/")
                name = removePhrase(phraseToRemove: "Repeat ", originalString: name)
                name = removePhrase(phraseToRemove: "Ear ", originalString: name)
                name = removePhrase(phraseToRemove: "Toward", originalString: name, replaceWith: "at")
                name = removePhrase(phraseToRemove: " Functions", originalString: name)
                name = removePhrase(phraseToRemove: "Backward", originalString: name, replaceWith: "Back")
            }
            
            // Sets text properties (e.g alignment & color)
            myLabel.text = name
            myLabel.textAlignment = .center
            myLabel.layer.zPosition = 1
            
            if #available(iOS 13.0, *) {
                myLabel.textColor = UIColor.label
            } else {
                myLabel.textColor = UIColor.black
            }
            
            if isModifierBlock {
                myLabel.layer.position.y = CGFloat((blockSize * 6) / 4)
            } else {
                myLabel.layer.position.y = CGFloat(blockSize / 2)
            }
            
            myView.addSubview(myLabel)
        }
        
        return myView
    }
    
    //MARK: - Supporting Functions
    /// Scales given image to the given size, and returns the new scaled image.
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Given a string and a phrase, removes the phrase from the string and replaces it if possible. Returns the new string.
    private func removePhrase (phraseToRemove: String, originalString: String, replaceWith: String = "") -> String {
        
        var newString = originalString
        
        if phraseToRemove == "Set " { // the Set Variable block should not be edited, only the Set Light blocks
            if newString.range(of: "Set Variable") != nil {
                return originalString
            }
        }
        if let range = newString.range(of: phraseToRemove){
            newString.replaceSubrange(range, with: replaceWith)
        }
        
        return newString
    }
}
