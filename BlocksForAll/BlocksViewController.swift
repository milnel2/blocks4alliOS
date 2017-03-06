//
//  ViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit


class BlocksViewController: UIViewController, OBDropZone, OBOvumSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let collectionReuseIdentifier = "BlockCell"
    
    //update these as collection view changes
    private let blockWidth = 100
    private let blockSpacing = 10
    private let trashcanWidth = 100
    
    private var count = 0
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    public var indexOfCurrentBlock = -1
    
    //@IBOutlet weak var blocksProgram: UIStackView!
    @IBOutlet weak var blocksProgram: UICollectionView!

    @IBOutlet weak var trashcanView: UIView!
    
    var blocksStack = [Block]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        self.view.dropZoneHandler = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Drag and Drop Methods
    
    func ovumEntered(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("Entered View", comment: ""))
        return OBDropAction.copy//OBDragActionCopy
    }
    
    func ovumDropped(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
        print("Dropped")
        //TODO: update this to make [Block]
        if let block = ovum.dataObject as? Block{
            //figure out where it should go
            let totalSize = blockWidth+blockSpacing
            
            var index = min((Int(location.x) - totalSize/2)/totalSize, blocksStack.count)
            print(index)
            
            //check if in trashcan
            let trashed = (Int(location.x) >= Int(view.frame.width) - trashcanWidth)
            
            //check if this is part of a double block
            let twoBlocks = block.double
            
            //check if you are moving block within workspace, remove from blocksStack, push everything back
            
            if(indexOfCurrentBlock >= 0){
                //check if dealing with repeat blocks
                
                //TODO: UPDATE THIS TO DROP TWO BLOCKS AND EVERYTHING IN BETWEEN
                if twoBlocks {
                    //find index of counterpart
                    var indexOfCounterpart = -1
                    for i in 0..<blocksStack.count {
                        if blocksStack[i].ID == block.counterpartID {
                            indexOfCounterpart = i
                        }
                    }
                    //End Repeat Block cannot be placed before Begin Repeat Block
                    if(block.name.contains("End")  && index <= indexOfCounterpart) {
                        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("End repeat cannot be placed before begin repeat", comment: ""))
                        print("blocks index " , index, " index of counterpart ", indexOfCounterpart)
                    }
                    else if(!block.name.contains("End")  && index > indexOfCounterpart) {
                        //Begin Repeat Block cannot be placed after End Repeat Block
                        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("Begin repeat cannot be placed after end repeat", comment: ""))
                        print("blocks index " , index, " index of counterpart ", indexOfCounterpart)
                    }else{
                        //move and update placement of counterparts in both
                        blocksStack.remove(at: indexOfCurrentBlock)
                        if(indexOfCurrentBlock < index){
                            index = index-1
                        }
                        if(!trashed){
                            //block.ID = count
                            //count += 1
                            blocksStack.insert(block, at: index)
                            blocksProgram.performBatchUpdates({
                                //TODO: Do i need to delete anything from subviews?
                                self.blocksProgram.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
                                self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0)])
                            }, completion: nil)
                        }else{
                            blocksProgram.performBatchUpdates({
                                //TODO: Do i need to delete anything from subviews?
                                self.blocksProgram.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
                            }, completion: nil)
                        }
                    }
                    
                }else{ //not dealing with two blocks
                    blocksStack.remove(at: indexOfCurrentBlock)
                    if(indexOfCurrentBlock < index){
                        index = index-1
                    }
                    if(!trashed){
                        //block.ID = count
                        //count += 1
                        blocksStack.insert(block, at: index)
                        blocksProgram.performBatchUpdates({
                            //TODO: Do i need to delete anything from subviews?
                            self.blocksProgram.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
                            self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0)])
                        }, completion: nil)
                    }else{
                        blocksProgram.performBatchUpdates({
                            //TODO: Do i need to delete anything from subviews?
                            self.blocksProgram.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
                        }, completion: nil)
                    }
                }
            }else{ //moving from toolbox
                if(!trashed){
                    //add block to stack
                    if twoBlocks {
                        block.ID = count
                        count += 1
                        blocksStack.insert(block, at: index)
                        let endBlockName = "End " + block.name
                        let endBlock = Block(name: endBlockName, color: block.color, double: true)
                        endBlock?.counterpart = block
                        block.counterpart = endBlock
                        endBlock?.ID = count
                        count += 1
                        endBlock?.counterpartID = block.ID
                        block.counterpartID = endBlock?.ID
                        blocksStack.insert(endBlock!, at: index+1)
                        blocksProgram.performBatchUpdates({
                            self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0), IndexPath.init(row: index+1, section: 0)])
                        }, completion: nil)
                    }else{
                        block.ID = count
                        count += 1
                        blocksStack.insert(block, at: index)
                        blocksProgram.performBatchUpdates({
                            self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0)])
                        }, completion: nil)
                    }
                }
            }
            indexOfCurrentBlock = -1
            //print(blocksStack)

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
        //print(location, index)
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
        if let sView = sourceView as? BlockCollectionViewCell{
            indexOfCurrentBlock = (blocksProgram.indexPath(for: sView)?.row)!
            //TODO: UPDATE THIS TO DROP TWO BLOCKS AND EVERYTHING IN BETWEEN
            //Change dataObject to [Block]()
            ovum.dataObject = blocksStack[indexOfCurrentBlock]
        }else{
            ovum.dataObject = sourceView.backgroundColor
        }
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        if let sView = sourceView as? BlockCollectionViewCell{
            let frame = sView.convert(sView.bounds, to: sView.window)
            //TODO: UPDATE THIS TO DROP TWO BLOCKS AND EVERYTHING IN BETWEEN
            let dragView = UIView(frame: frame)
            dragView.backgroundColor = sView.backgroundColor
            let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth))
            myLabel.text = sView.labelView.text
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            dragView.self.addSubview(myLabel)
            dragView.alpha = 0.75
            return dragView
        }
        
        return sourceView
    }

    
    func ovumDragEnded(_ ovum: OBOvum!) {
        return
    }

    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocksStack.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath) as! BlockCollectionViewCell
        
        // Configure the cell
        
        let block = blocksStack[indexPath.row]
        cell.backgroundColor = block.color
        cell.labelView.text = block.name
        if (cell.gestureRecognizers == nil || cell.gestureRecognizers?.count == 0) {
            let manager = OBDragDropManager.shared()
            let recognizer = manager?.createDragDropGestureRecognizer(with: UIPanGestureRecognizer.classForCoder(), source: self)
            //let recognizer = manager?.createLongPressDragDropGestureRecognizer(with: self)
            cell.addGestureRecognizer(recognizer!)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */


}

