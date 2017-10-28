//
//  DragAndDropViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AVFoundation

//collection of blocks that are part of your program

var blocksStack = [Block]()

class DragAndDropViewController: BlocksViewController, OBDropZone, OBOvumSource {
    
    //update these as collection view changes
    private let trashcanWidth = 150
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    public var indexOfCurrentBlock = -1
    //movingBlocks = false //to change play button


    override func viewDidLoad() {
        super.viewDidLoad()
        dragOn = true
        // Do any additional setup after loading the view, typically from a nib.
        self.view.dropZoneHandler = self
        movingBlocks = false
    }
    
    // MARK: - Drag and Drop Methods
    
    func ovumEntered(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
        //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("Entered View", comment: ""))
        movingBlocks = true
        changeButton()
        return OBDropAction.copy
    }
    
    
    func ovumDropped(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {

        //TODO: update this to make [Block]
        if let blocks = ovum.dataObject as? [Block]{
            //figure out where it should go
            let totalSize = blockWidth+blockSpacing
            
            let index = min((Int(location.x) - totalSize/2)/totalSize, blocksStack.count)
            
            //check if in trashcan
            let trashed = (Int(location.x) >= Int(view.frame.width) - trashcanWidth)
            
            //don't need to do anything if trashed, already removed from workspace
            if(!trashed){
                addBlocks(blocks, at: index)
            }else{
                let announcement = blocks[0].name + " placed in trash"
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
                
            }
            blocksBeingMoved.removeAll()
            movingBlocks = false
            changeButton()
           }else{ //probably should be error
            print("Not [Block]")
        }
        
    }
    
    func ovumExited(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
        self.view.backgroundColor = UIColor.white
    }
    
    var previousIndex = -1
    var trashed = false
    func ovumMoved(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
        let totalSize = blockWidth+blockSpacing
        
        let dropIndex = min((Int(location.x) - totalSize/2)/totalSize, blocksStack.count)
        if(dropIndex != previousIndex || trashed != (Int(location.x) >= Int(view.frame.width) - trashcanWidth)){
            var announcement = ""
            if(Int(location.x) >= Int(view.frame.width) - trashcanWidth){
                announcement = "Place in Trash"
                trashed = true
            }
            else if(previousIndex == -1 || dropIndex <= 0){
                announcement = "Place at beginning"
                trashed = false
            }else{
                announcement = "Place after " + blocksStack[dropIndex-1].name
                trashed = false
            }
            print(announcement)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
            previousIndex = dropIndex
        }
        
        return OBDropAction.move
    }

    //MARK: - OBOvmSource
    func createOvum(from sourceView: UIView!) -> OBOvum! {
        let ovum = OBOvum.init()
        if let sView = sourceView as? UICollectionViewCell{
            indexOfCurrentBlock = (blocksProgram.indexPath(for: sView)?.row)!
            //TODO: UPDATE THIS TO DROP TWO BLOCKS AND EVERYTHING IN BETWEEN
            let myBlock = blocksStack[indexOfCurrentBlock]
            if myBlock.double == true{
                var indexOfCounterpart = -1
                for i in 0..<blocksStack.count {
                    if blocksStack[i] === myBlock.counterpart {
                        indexOfCounterpart = i
                    }
                }
                var indexPathArray = [IndexPath]()
                var tempBlockStack = [Block]()
                for i in min(indexOfCounterpart, indexOfCurrentBlock)...max(indexOfCounterpart, indexOfCurrentBlock){
                    indexPathArray += [IndexPath.init(row: i, section: 0)]
                    tempBlockStack += [blocksStack[i]]
                }
                ovum.dataObject = tempBlockStack
                
                blocksStack.removeSubrange(min(indexOfCounterpart, indexOfCurrentBlock)...max(indexOfCounterpart, indexOfCurrentBlock))
                blocksProgram.performBatchUpdates({
                    self.blocksProgram.deleteItems(at: indexPathArray)
                }, completion: nil)
            }else{ //only a single block to be removed
                ovum.dataObject = [blocksStack[indexOfCurrentBlock]]
                blocksStack.remove(at: indexOfCurrentBlock)
                blocksProgram.performBatchUpdates({
                    self.blocksProgram.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
                }, completion: nil)
            }
            blocksBeingMoved = ovum.dataObject as! [Block]
            movingBlocks = true
            changeButton()
        }else{ //probably should throw an error
            ovum.dataObject = sourceView.backgroundColor
        }
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        if let sView = sourceView as? UICollectionViewCell{
            
            /*let dragView = BlockView.init(frame: CGRect.init(x: 0, y: 0, width: blockWidth, height: blockWidth), block: [sView.block!])
            return dragView*/
            
            let dragView = createViewRepresentation(FromBlocks: blocksBeingMoved)
            dragView.frame.origin.x = sView.frame.origin.x
            dragView.frame.origin.y = sView.frame.origin.y
            return dragView
        }
        
        return sourceView
    }


    func ovumDragEnded(_ ovum: OBOvum!) {
        return
    }
    
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocksStack.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        
        let startingHeight = Int(cell.frame.height)-blockHeight
        
        let block = blocksStack[indexPath.row]
        var blocksToAdd = [Block]()
        
        //check if block is nested (or nested multiple times)
        for i in 0...indexPath.row {
            if blocksStack[i].double {
                if(!blocksStack[i].name.contains("End")){
                    if(i != indexPath.row){
                        blocksToAdd.append(blocksStack[i])
                    }
                }else{
                    blocksToAdd.removeLast()
                }
            }
        }
        if !spatialLayout {
            blocksToAdd.reverse()
            
            let block = blocksStack[indexPath.row]
            
            //let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: Int(cell.frame.height)-blockHeight, width: blockWidth, height: blockWidth))
            
            let myView = BlockView.init(frame: CGRect.init(x: 0, y: Int(cell.frame.height)-blockHeight, width: blockWidth, height: blockWidth),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
            myView.isAccessibilityElement = true
            addAccessibilityLabel(myLabel: myView, block: block, number: indexPath.row + 1, blocksToAdd: blocksToAdd, spatial: false, interface: 1)
            //myView.isAccessibilityElement = true
            cell.addSubview(myView)

            if block.name == "If" || block.name == "Repeat" {
                if block.addedBlocks.isEmpty{
                    //draw false block
                    var placeholderBlock = Block(name: "False", color: UIColor.red, double: false, editable: false, imageName: "false.png", type: "Boolean")
                    if block.name == "Repeat"{
                        placeholderBlock = Block(name: "two times", color: UIColor.red, double: false, editable: false, imageName: "2.png", type: "Number")
                    }
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight, width: blockWidth, height: blockHeight),  block: [placeholderBlock!], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = "False"
                    if block.name == "Repeat"{
                        myConditionLabel.accessibilityLabel = "two times"
                    }
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }else{
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight, width: blockWidth, height: blockHeight),  block: [block.addedBlocks[0]], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = block.addedBlocks[0].name
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }
            }
            
            
        }else {
            var count = 0
            for b in blocksToAdd{
                let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))
                
                myView.accessibilityLabel = "Inside " + b.name
                myView.text = "Inside " + b.name
                
                cell.addSubview(myView)
                count += 1
            }
            //let blockPlacementInfo = ". Workspace block " + String(indexPath.row + 1) + " of " + String(blocksStack.count)
            
            //var movementInfo = "Tap and hold to move block."
            
            //add main label
            let myLabel = BlockView.init(frame: CGRect.init(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockWidth), block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
            addAccessibilityLabel(myLabel: myLabel, block: block, number: indexPath.row + 1, blocksToAdd: blocksToAdd, spatial: true, interface: 1)
            
            //let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
            //myLabel.isAccessibilityElement = true
            //myLabel.accessibilityLabel = block.name + blockPlacementInfo + movementInfo
            //myLabel.picker?.isAccessibilityElement = true
            cell.addSubview(myLabel)
            /*if(block.imageName != nil){
                let imageName = block.imageName!
                let image = UIImage(named: imageName)
                let imv = UIImageView.init(image: image)
                myLabel.addSubview(imv)
            }*/
            if block.name == "If" || block.name ==  "Repeat" {
                if block.addedBlocks.isEmpty{
                    //draw false block
                    var placeholderBlock = Block(name: "False", color: UIColor.red, double: false, editable: false, imageName: "false.png", type: "Boolean")
                    if block.name == "Repeat"{
                        placeholderBlock = Block(name: "two times", color: UIColor.red, double: false, editable: false, imageName: "2.png", type: "Number")
                    }
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [placeholderBlock!], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = "False"
                    if block.name == "Repeat"{
                        myConditionLabel.accessibilityLabel = "two times"
                    }
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }else{
                    let myConditionLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-blockHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block.addedBlocks[0]], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                    myConditionLabel.accessibilityLabel = block.addedBlocks[0].name
                    myConditionLabel.isAccessibilityElement = true
                    cell.addSubview(myConditionLabel)
                }
            }
        }
        addGestureRecognizer(cell)
        
        return cell
    }
    
    
    override func addGestureRecognizer(_ cell:UICollectionViewCell){
        if (cell.gestureRecognizers == nil || cell.gestureRecognizers?.count == 0) {
            let manager = OBDragDropManager.shared()
            let recognizer = manager?.createDragDropGestureRecognizer(with: UIPanGestureRecognizer.classForCoder(), source: self)
            //let recognizer = manager?.createLongPressDragDropGestureRecognizer(with: self)
            cell.addGestureRecognizer(recognizer!)
            
            //ADDED TO FAKE VOICEOVER
            /*
             let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_sender:)))
             //tap.delegate = self
             cell.addGestureRecognizer(tap)
             
             //let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_sender:)))
             //cell.addGestureRecognizer(pan)
             //cell.accessibilityTraits = accessibility
             cell.isUserInteractionEnabled = true
             */
        }
    }
    
    func playSound(){
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1104
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    func handleSingleTap(_sender: UITapGestureRecognizer){
        if (_sender.view as? UICollectionViewCell) != nil{
            // create a sound ID, in this case its the tweet sound.
            playSound()
            
        }
    }

}

