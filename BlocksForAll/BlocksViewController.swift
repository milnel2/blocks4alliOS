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
    private let blockHeight = 100
    private let blockSpacing = 1
    private let blockDoubleHeight = 25
    private let trashcanWidth = 100
    
    private var count = 0
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    public var indexOfCurrentBlock = -1
    public var fromWorkspace = false
    
    //@IBOutlet weak var blocksProgram: UIStackView!
    @IBOutlet weak var blocksProgram: UICollectionView!

    @IBOutlet weak var trashcanView: UIView!
    
    var blocksStack = [Block]()
    var blocksBeingMoved = [Block]()

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

        //TODO: update this to make [Block]
        if let blocks = ovum.dataObject as? [Block]{
            //figure out where it should go
            let totalSize = blockWidth+blockSpacing
            
            let index = min((Int(location.x) - totalSize/2)/totalSize, blocksStack.count)
            print(index)
            
            //check if in trashcan
            let trashed = (Int(location.x) >= Int(view.frame.width) - trashcanWidth)
            let twoBlocks = blocks[0].double
            
            //don't need to do anything if trashed, already removed from workspace
            if(!trashed){
                //add block to stack
                if(blocks[0].ID == nil){
                    blocks[0].ID = count
                    count += 1
                }
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
           }else{ //probably shoudl be error
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
            fromWorkspace = true
            indexOfCurrentBlock = (blocksProgram.indexPath(for: sView)?.row)!
            //TODO: UPDATE THIS TO DROP TWO BLOCKS AND EVERYTHING IN BETWEEN
            let myBlock = blocksStack[indexOfCurrentBlock]
            if myBlock.double == true{
                var indexOfCounterpart = -1
                for i in 0..<blocksStack.count {
                    if blocksStack[i].ID == myBlock.counterpartID {
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
        }else{ //probably should throw an error
            ovum.dataObject = sourceView.backgroundColor
        }
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        if let sView = sourceView as? BlockCollectionViewCell{
            let dragView = createViewRepresentation(FromBlocks: blocksBeingMoved)
            dragView.frame.origin.x = sView.frame.origin.x
            dragView.frame.origin.y = sView.frame.origin.y
            return dragView
            /*
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
            return dragView*/
        }
        
        return sourceView
    }

    
    func ovumDragEnded(_ ovum: OBOvum!) {
        return
    }
    
    func createViewRepresentation(FromBlocks blocksRep: [Block]) -> UIView {
        let myViewWidth = (blockWidth + blockSpacing)*blocksRep.count
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        count = 0
        for block in blocksRep{
            let xCoord = count*(blockWidth + blockSpacing)
            let blockView = UIView(frame:CGRect(x: xCoord, y: 0, width: blockWidth, height: blockHeight))
            count += 1
            blockView.backgroundColor = block.color
            let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth))
            myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            blockView.self.addSubview(myLabel)
            myView.addSubview(blockView)
        }
        myView.alpha = 0.75
        return myView
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
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        
        let block = blocksStack[indexPath.row]
        
        let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth))
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = UIColor.white
        myLabel.numberOfLines = 0
        cell.addSubview(myLabel)
        
        cell.backgroundColor = block.color
        //cell.labelView.text = block.name
        /*
        if(cell.subviews.count >= 2) {
            cell.subviews[1].removeFromSuperview()
            print("removing subview")
        }
         
         
        */
        
        //trying to fix up interface 1
        /*
        var nestingLevel = 0
        var highestNestingLevel = 0
        //check if block is nested (or nested multiple times)
        for i in 0...indexPath.row {
            if blocksStack[i].double {
                if(blocksStack[i].ID! < blocksStack[i].counterpartID!){
                    nestingLevel += 1
                    highestNestingLevel += 1
                }else{
                    nestingLevel -= 1
                    if(nestingLevel == 0){
                        highestNestingLevel = 0
                    }
                }
            }
        }
        var currentNestingLevel = nestingLevel
        
        var i = indexPath.row + 1
        while(nestingLevel > 0){
            if blocksStack[i].double {
                if(blocksStack[i].ID! < blocksStack[i].counterpartID!){
                    nestingLevel += 1
                    highestNestingLevel += 1
                }else {
                    nestingLevel -= 1
                }
            }
            i -= 1
        }
        
        if(block.double && block.ID! > block.counterpartID!){
            currentNestingLevel += 1
            highestNestingLevel = max(highestNestingLevel, 1)
        }
        
        print(block.name, currentNestingLevel, highestNestingLevel)
        
        //think i need to add in for end block
        if currentNestingLevel >= 1{
            for i in 1...highestNestingLevel{
                let myRect = CGRect(x: 0, y: -(blockDoubleHeight+blockSpacing)*i, width: blockWidth+blockSpacing, height: blockDoubleHeight)
                let myView = UIView(frame: myRect)
                myView.backgroundColor = UIColor.colorFrom(hexString: "#FFA500")
                cell.addSubview(myView)
            }
        }
        */
        /*THIS SHOULD WORK FOR SECOND VERSION OF PROGRAM STRUCTURE
        var nestingLevel = 0
        //check if block is nested (or nested multiple times)
        for i in 0...indexPath.row {
            if blocksStack[i].double {
                if(blocksStack[i].ID! < blocksStack[i].counterpartID!){
                    nestingLevel += 1
                }else if(indexPath.row > i){
                    nestingLevel -= 1
                }
            }
        }
        //think i need to add in for end block
        if nestingLevel >= 1{
            for i in 1...nestingLevel{
                let myRect = CGRect(x: 0, y: -(blockDoubleHeight+blockSpacing)*i, width: blockWidth+blockSpacing, height: blockDoubleHeight)
                let myView = UIView(frame: myRect)
                myView.backgroundColor = UIColor.colorFrom(hexString: "#FFA500")
                cell.addSubview(myView)
            }
        }
         */
        
        
        /*
        if(block.double && block.ID! < block.counterpartID!){
            var spacing = 0
            
            //TODO check for repeats within loop
            var indexOfCounterpart = -1
            for i in 0..<blocksStack.count {
                if blocksStack[i].ID == block.counterpartID {
                    indexOfCounterpart = i
                }
            }
            
            for i in 1...(indexOfCounterpart-indexPath.row){
                spacing = blockWidth + i*(blockWidth+blockSpacing)
            }
            
            let myRect = CGRect(x: 0, y: -blockDoubleHeight, width: spacing, height: blockDoubleHeight)
            let myView = UIView(frame: myRect)
            myView.backgroundColor = block.color
            cell.addSubview(myView)
           
            //myView.leftAnchor.constraint(equalTo: cell.leftAnchor)
        }*/
        
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

