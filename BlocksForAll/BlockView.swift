//
//  BlockView.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 6/1/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BlockView: UIView {

    var blocks: [Block]?
    var blockWidth = 100
    let blockHeight = 100
    let blockSpacing = 1
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
    }
    
    func addBlocks(_ blocks: [Block]){
        self.blocks = blocks
    
        self.addSubview(simpleView(FromBlocks: blocks))
        //self.addSubview(createViewRepresentation(FromBlocks: blocks))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func simpleView(FromBlocks blocksRep: [Block]) -> UIView {
        
        let block = blocksRep[0]
        let myViewWidth = blockWidth
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        myView.backgroundColor = block.color
        if(block.imageName != nil){
            let imageName = block.imageName!
            let image = UIImage(named: imageName)
            let imv = UIImageView.init(image: image)
            myView.addSubview(imv)
        }
        return myView
    }

    
    func createViewRepresentation(FromBlocks blocksRep: [Block]) -> UIView {
        let myViewWidth = (blockWidth + blockSpacing)*blocksRep.count
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        var count = 0
        for block in blocksRep{
            let xCoord = count*(blockWidth + blockSpacing)
            let blockView = UIView(frame:CGRect(x: xCoord, y: 0, width: blockWidth, height: blockHeight))
            count += 1
            blockView.backgroundColor = block.color
            myView.addSubview(blockView)
            
            if(block.imageName != nil){
                let imageName = block.imageName!
                let image = UIImage(named: imageName)
                let imv = UIImageView.init(image: image)
                myView.addSubview(imv)
            }
        }
        return myView
    }
    
}
