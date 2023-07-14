//
//  BlockView.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 6/1/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AudioToolbox

class BlockView: UIView, UITextFieldDelegate {
    /*Given a block, creates the view that should be shown - seems to create everything but the modifier button*/
    
    var blocks: [Block]
    var blockSize = 150
    let blockSpacing = 1
    
    var pickedItem: UITextField?
    
    //MARK: - init Block View
    init (frame : CGRect, block : [Block], myBlockSize: Int) {
        self.blocks = block
        super.init(frame : frame)
        blockSize = myBlockSize
        self.addSubview(simpleView(FromBlock: block))
    }
    
    //MARK: - Element Focus
    override func accessibilityElementDidBecomeFocused() {
        
        print(blocks[0].name + " is focused")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
        
    //MARK: - simpleView
    func simpleView(FromBlock block: [Block]) -> UIView {
        let block = block[0]
        
        //let isModifierBlock = isModifierOrContainerBlock(block: block)
        let isModifierBlock = block.isModifiable ?? false
        
        var myViewHeight: Int
        let myFrame: CGRect

        let myViewWidth: Int
        
        if block.isInToolBox ?? false {  // the blocks should be wider if they are in the toolbox
            //TODO: test this on different size screens
            myViewWidth = (blockSize * 3) / 2
        } else {
            myViewWidth = blockSize
        }
        
        if isModifierBlock {
            myViewHeight = blockSize * 2
            myFrame = CGRect(x: 0, y: -myViewHeight/2, width: myViewWidth, height: myViewHeight)
        } else {
            myViewHeight = blockSize
            myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)

        }
        
        let myView = UIView(frame: myFrame)
        myView.backgroundColor = UIColor(named: "\(block.colorName)")
        if(block.imageName != nil && defaults.integer(forKey: "showText") == 0){
            let imageName = block.imageName!
            var image = UIImage(named: imageName)
            let imv: UIImageView
            if isModifierBlock {
                image = imageWithImage(image: image!, scaledToSize: CGSize(width: blockSize, height: myViewHeight / 2))
                imv = UIImageView.init(image: image)
                imv.image = UIImage(named: imageName)
                imv.layer.position.y = CGFloat((blockSize * 6) / 4)
                if block.isInToolBox ?? false {  // center the image if the block is in the toolbox
                    imv.layer.position.x = CGFloat((myViewWidth) - ((blockSize * 4) / 5))
                }
            } else {
                image = imageWithImage(image: image!, scaledToSize: CGSize(width: blockSize, height: myViewHeight))
                imv = UIImageView.init(image: image)
                imv.image = UIImage(named: imageName)
                imv.layer.position.y = CGFloat((blockSize / 2))
                if block.isInToolBox ?? false {  // center the image if the block is in the toolbox
                    imv.layer.position.x = CGFloat((myViewWidth) - ((blockSize * 4) / 5))
                }
                
            }
            
            //            if #available(iOS 11.0, *) {
            //                imv.adjustsImageSizeForAccessibilityContentSizeCategory = true
            //            } else {
            //                // Fallback on earlier versions
            //            }
            myView.addSubview(imv)
        }else {
            let myLabel = UILabel.init(frame: myFrame)
            myLabel.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
            myLabel.numberOfLines = 0
            myLabel.adjustsFontForContentSizeCategory = true
            let currentFontSize = myLabel.font.pointSize
            
            var name = block.name
            if currentFontSize > 31.0 { // dynamic text is being used, so some of the labels need to be shortened
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
                name = removePhrase(phraseToRemove: "Forward", originalString: name, replaceWith: "Ahead")
                name = removePhrase(phraseToRemove: "Backward", originalString: name, replaceWith: "Back")
            }
            myLabel.text = name
            myLabel.textAlignment = .center
            if #available(iOS 13.0, *) {
                myLabel.textColor = UIColor.label
            } else {
                myLabel.textColor = UIColor.black
            }
            myLabel.layer.zPosition = 1
           
            
            if isModifierBlock {
                myLabel.layer.position.y = CGFloat((blockSize * 6) / 4)
            } else {
                myLabel.layer.position.y = CGFloat(blockSize / 2)
            }
            myView.addSubview(myLabel)
        }
        block.isInToolBox = block.isInToolBox ?? false
        if !block.isInToolBox! && block.isRunning {
            myView.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            myView.layer.borderWidth = 15
        } else {
            myView.layer.borderWidth = 0
        }
        
        
        return myView
    }
    
    ///  Given a string and a phrase, removes the phrase from the string and replaces it if possible. Returns the new string
    private func removePhrase (phraseToRemove: String, originalString: String, replaceWith: String = "") -> String{
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
