//
//  StackedBlocksCollectionViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/7/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit


class StackedBlocksCollectionViewController: UICollectionViewController, OBOvumSource {

    //update these as collection view changes
    private let blockWidth = 100
    private let blockHeight = 100
    private let blockSpacing = 1
    private let blockDoubleHeight = 25
    private let trashcanWidth = 100
    
    private var count = 0
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    public var indexOfCurrentBlock = -1
    
    private let collectionReuseIdentifier = "BlockCell"
    
    var blocksBeingMoved = [Block]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


        // Do any additional setup after loading the view.
        //self.view.dropZoneHandler = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: - OBOvmSource
    func createOvum(from sourceView: UIView!) -> OBOvum! {
        let ovum = OBOvum.init()
        if let sView = sourceView as? BlockCollectionViewCell{
            fromWorkspace = true
            indexOfCurrentBlock = (collectionView?.indexPath(for: sView)?.row)!
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
                collectionView?.performBatchUpdates({
                    self.collectionView?.deleteItems(at: indexPathArray)
                }, completion: nil)
            }else{ //only a single block to be removed
                ovum.dataObject = [blocksStack[indexOfCurrentBlock]]
                blocksStack.remove(at: indexOfCurrentBlock)
                collectionView?.performBatchUpdates({
                    self.collectionView?.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocksStack.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath) as! BlockCollectionViewCell
        
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        
        let block = blocksStack[indexPath.row]
        
        
        //THIS SHOULD WORK FOR SECOND VERSION OF PROGRAM STRUCTURE
        var blocksToAdd = [Block]()
        
        //check if block is nested (or nested multiple times)
        for i in 0...indexPath.row {
            if blocksStack[i].double {
                if(blocksStack[i].ID! < blocksStack[i].counterpartID!){
                    if(i != indexPath.row){
                        blocksToAdd.append(blocksStack[i])
                    }
                }else{
                    blocksToAdd.removeLast()
                }
            }
        }
        var count = 0
        for b in blocksToAdd{
            let myView = UILabel.init(frame: CGRect(x: -blockSpacing, y: blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))
            //let myView = UILabel.init(frame: CGRect(x: -blockSpacing, y: -count*(blockHeight), width: blockWidth+2*blockSpacing, height: blockHeight))
            myView.accessibilityLabel = "Inside " + b.name
            myView.text = "Inside " + b.name
            myView.textAlignment = .center
            myView.textColor = UIColor.white
            myView.numberOfLines = 0
            myView.backgroundColor = b.color
            cell.addSubview(myView)
            count += 1
        }
        
        let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
        //let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: blockHeight))
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = UIColor.white
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = block.color
        cell.addSubview(myLabel)
        //cell.frame = CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: count*(blockHeight+blockSpacing) )

        //cell.backgroundColor = block.color
        
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
