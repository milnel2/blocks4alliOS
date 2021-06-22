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
    var blockWidth = 150
    var blockHeight = 150
    let blockSpacing = 1
    
    var pickedItem: UITextField?
    
    //MARK: - init Block View
    init (frame : CGRect, block : [Block], myBlockWidth: Int, myBlockHeight: Int) {
        self.blocks = block
        super.init(frame : frame)
        blockWidth = myBlockWidth
        blockHeight = myBlockHeight
        self.addSubview(simpleView(FromBlock: block))
    }
    
    
    //MARK: - Element Focus
    override func accessibilityElementDidBecomeFocused() {
        print(blocks[0].name + " is focused")
        //AudioServicesPlaySystemSound(1024)
        if blocks[0].type ==  "Number" || (!blocks[0].acceptedTypes.isEmpty && blocks[0].acceptedTypes[0] == "Number"){
            print("1")
            //AudioServicesPlaySystemSound(1257)
        }else if blocks[0].type ==  "Boolean" || (!blocks[0].acceptedTypes.isEmpty && blocks[0].acceptedTypes[0] == "Boolean"){
            print("2")
            //AudioServicesPlaySystemSound(1255)
        }
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
        let myViewWidth = blockWidth
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        myView.backgroundColor = block.color.uiColor
        if(block.imageName != nil){
            let imageName = block.imageName!
            var image = UIImage(named: imageName)
            image = imageWithImage(image: image!, scaledToSize: CGSize(width: myViewWidth, height: myViewHeight))
            let imv = UIImageView.init(image: image)
            //            if #available(iOS 11.0, *) {
            //                imv.adjustsImageSizeForAccessibilityContentSizeCategory = true
            //            } else {
            //                // Fallback on earlier versions
            //            }
            myView.addSubview(imv)
        }else if !block.double || !block.tripleCounterpart{ //so end repeat blocks don't have names
            let myLabel = UILabel.init(frame: myFrame)
            myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            myLabel.font = UIFont.preferredFont(forTextStyle: .title2)
            myLabel.numberOfLines = 0
            myLabel.adjustsFontForContentSizeCategory = true
            myView.addSubview(myLabel)
        }
        return myView
    }
}
