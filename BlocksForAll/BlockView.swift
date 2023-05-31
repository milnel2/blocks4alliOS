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
    /*Given a block, creates the view that should be shown*/
    
    var blocks: [Block]
    var blockSize = 150
    let blockSpacing = 1
    
    var pickedItem: UITextField?
    
    // from Paul Hegarty, lectures 13 and 14
    let defaults = UserDefaults.standard
    
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
        //AudioServicesPlaySystemSound(1024)
//        if blocks[0].type ==  "Number" || (!blocks[0].acceptedTypes.isEmpty && blocks[0].acceptedTypes[0] == "Number"){
//            print("1")
//            //AudioServicesPlaySystemSound(1257)
//        }else if blocks[0].type ==  "Boolean" || (!blocks[0].acceptedTypes.isEmpty && blocks[0].acceptedTypes[0] == "Boolean"){
//            print("2")
//            //AudioServicesPlaySystemSound(1255)
//        }
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
    
    //MARK:- simpleView
    func simpleView(FromBlock block: [Block]) -> UIView {
        let block = block[0]
        
        let isModifierBlock = isModifierOrContainerBlock(block: block)
        
        let myViewHeight: Int
        let myFrame: CGRect
        let myViewWidth = blockSize
        if isModifierBlock {
            myViewHeight = blockSize * 2
            myFrame = CGRect(x: 0, y: -myViewHeight/2, width: myViewWidth, height: myViewHeight)
        } else {
            myViewHeight = blockSize
            myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)

           }
        
        
        
        let myView = UIView(frame: myFrame)
        myView.backgroundColor = block.color.uiColor
        if(block.imageName != nil && defaults.integer(forKey: "showText") == 0){
            let imageName = block.imageName!
            var image = UIImage(named: imageName)
            let imv = UIImageView.init(image: image)
            if isModifierBlock {
                image = imageWithImage(image: image!, scaledToSize: CGSize(width: myViewWidth, height: myViewHeight / 2))
                imv.layer.position.y = CGFloat((blockSize * 6) / 4)
            } else {
                image = imageWithImage(image: image!, scaledToSize: CGSize(width: myViewWidth * 2, height: myViewHeight * 2))
                imv.layer.position.y = CGFloat((blockSize / 2))
            }
            
            //            if #available(iOS 11.0, *) {
            //                imv.adjustsImageSizeForAccessibilityContentSizeCategory = true
            //            } else {
            //                // Fallback on earlier versions
            //            }
            myView.addSubview(imv)
        }else {
            let myLabel = UILabel.init(frame: myFrame)
            myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.black
            myLabel.layer.zPosition = 1
            myLabel.font = UIFont.preferredFont(forTextStyle: .title1)
            myLabel.numberOfLines = 0
            myLabel.adjustsFontForContentSizeCategory = true
            
            if isModifierBlock {
                myLabel.layer.position.y = CGFloat((blockSize * 6) / 4)
            } else {
                myLabel.layer.position.y = CGFloat(blockSize / 2)
            }
            myView.addSubview(myLabel)
            
        }
        return myView
    }
    
    // TODO: this needs to be refactored so that it isn't hard coded in. It should be changed so that it accesses the isModifiable property in BlocksMenu
    // returns true for things like if and repeats so that they are tall and still look like they enclose other blocks
    func isModifierOrContainerBlock(block: Block) -> Bool {
        return block.name != "Look Toward Voice"
                && block.name != "Look Forward"
                && block.name != "Look Right"
                && block.name != "Look Left"
                && block.name != "Look Straight"
                && block.name != "Look Down"
                && block.name != "Look Up"
                && block.name != "Wiggle"
                && block.name != "Nod"
                //block.name != "Repeat Forever"
                //&& block.name != "End Repeat Forever"
                //&& block.name != "If"
                //&& block.name != "End If"
    }
}
