//
//  ViewController.swift
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
    private let blockDoubleHeight = 25
    private let trashcanWidth = 100
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    public var indexOfCurrentBlock = -1
    public var fromWorkspace = false

    var blocksBeingMoved = [Block]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.dropZoneHandler = self
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
            let twoBlocks = blocks[0].double
            
            //don't need to do anything if trashed, already removed from workspace
            if(!trashed){
                //change for beginning
                var announcement = ""
                if(index != 0){
                    let myBlock = blocksStack[index-1]
                    announcement = blocks[0].name + " placed after " + myBlock.name
                }else{
                    announcement = blocks[0].name + " placed at beginning"
                }
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
                
                //add block to stack
                if twoBlocks {
                    if(fromWorkspace){
                        blocksStack.insert(contentsOf: blocks, at: index)
                        
                        var indexPathArray = [IndexPath]()
                        for i in 0..<blocks.count{
                            indexPathArray += [IndexPath.init(row: index+i, section: 0)]
                        }
                        
                        blocksProgram.performBatchUpdates({
                            self.blocksProgram.insertItems(at: indexPathArray)
                        }, completion: nil)
                        
                    }else{
                        let block = blocks[0]
                        blocksStack.insert(block, at: index)
                        let endBlockName = "End " + block.name
                        let endBlock = Block(name: endBlockName, color: block.color, double: true, editable: block.editable)
                        endBlock?.counterpart = block
                        block.counterpart = endBlock
                        blocksStack.insert(endBlock!, at: index+1)
                        blocksProgram.performBatchUpdates({
                            self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0), IndexPath.init(row: index+1, section: 0)])
                        }, completion: nil)
                    }
                }else{
                    blocksStack.insert(blocks[0], at: index)
                    blocksProgram.performBatchUpdates({
                        self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0)])
                    }, completion: nil)
                }
            }
            fromWorkspace = false
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
        
        let index = min((Int(location.x) - totalSize/2)/totalSize, blocksStack.count)
        if(index != previousIndex || trashed != (Int(location.x) >= Int(view.frame.width) - trashcanWidth)){
            var announcement = ""
            if(Int(location.x) >= Int(view.frame.width) - trashcanWidth){
                announcement = "Trash"
                trashed = true
            }
            else if(previousIndex == -1 || index <= 0){
                announcement = "Place at beginning"
                trashed = false
            }else{
                announcement = "Place after " + blocksStack[index-1].name
                trashed = false
            }
            print(announcement)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
            previousIndex = index
        }
        
        return OBDropAction.move
    }

    //MARK: - OBOvmSource
    func createOvum(from sourceView: UIView!) -> OBOvum! {
        let ovum = OBOvum.init()
        if let sView = sourceView as? UICollectionViewCell{
            fromWorkspace = true
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

