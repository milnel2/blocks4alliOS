//
//  PlaceholderViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/7/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class PlaceholderViewController: BlocksViewController {
    
    //@IBOutlet weak var blocksProgram: UICollectionView!
    var blockToAdd: Block?
    var indexToAdd = 0
    var count = 0
    
    //@IBOutlet weak var playTrashToggleButton: UIButton!

    private let placeholderWidth = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        blockWidth = 90
        // Do any additional setup after loading the view.
        
        if blockToAdd != nil {
            if blockToAdd?.name == "Cancel"{
                //pick a block from workspace
                print("Do nothing")
            }else{
                //add block
                //fromWorkspace = false
                //TODO might need movingBlocks here
                addBlocks([blockToAdd!], at: indexToAdd)
            }
        }
        indexToAdd = 0
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocksStack.count + 1 //for add new block at beginning
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: CGFloat(blockWidth + placeholderWidth), height: collectionView.frame.height)
        
        if indexPath.row == 0 {
            size = CGSize(width: CGFloat(placeholderWidth), height: collectionView.frame.height)
        }
        return size
    }
    
    func createPlaceholderBlock(frame: CGRect) -> UIButton{
        let placeholderBlock = UIButton.init(frame: frame)
        placeholderBlock.backgroundColor = UIColor.gray
        placeholderBlock.titleLabel?.textColor = UIColor.white
        placeholderBlock.accessibilityLabel = "Add Block at beginning"
        placeholderBlock.setTitle("+", for: .normal)
        placeholderBlock.addTarget(self, action: #selector(self.addBlockButton(_sender:)), for: .touchUpInside)
        return placeholderBlock
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        
        let startingHeight = Int(cell.frame.height)-blockHeight
        
        if indexPath.row == 0 {
            let placeholderBlock = createPlaceholderBlock(frame: CGRect(x: 0, y: startingHeight, width: placeholderWidth, height: blockHeight ))
            if !blocksBeingMoved.isEmpty{
                placeholderBlock.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at beginning"
            }
            cell.addSubview(placeholderBlock)
        }else{
            let blockStackIndex = indexPath.row - 1
            let block = blocksStack[blockStackIndex]
            
            var blocksToAdd = [Block]()
            
            //check if block is nested (or nested multiple times)
            for i in 0...blockStackIndex {
                if blocksStack[i].double {
                    //this is a begin repeat
                    if(!blocksStack[i].name.contains("End")){
                        if(i != blockStackIndex){
                            blocksToAdd.append(blocksStack[i])
                        }
                    }else{
                        blocksToAdd.removeLast()
                    }
                }
            }
            let blockPlacementInfo = ". block " + String(blockStackIndex + 1) + " of " + String(blocksStack.count)
            
            if !spatialLayout {
                let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: startingHeight, width: blockWidth, height: blockHeight))
                addSpatialAccessibilityLabel(myLabel: myLabel, block: block, number: indexPath.row, blocksToAdd: blocksToAdd)
                cell.addSubview(myLabel)

                myLabel.accessibilityHint = "Double tap to move block"
                
                cell.addSubview(myLabel)
                
                
                let placeholderBlock = createPlaceholderBlock(frame: CGRect(x: blockWidth, y: startingHeight, width: placeholderWidth, height: blockHeight ))
                placeholderBlock.accessibilityLabel = "Add Block after " + block.name + blockPlacementInfo
                cell.addSubview(placeholderBlock)
                
            }else{
                var count = 0
                for b in blocksToAdd{
                    let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))
                    myView.accessibilityLabel = "Inside " + b.name + blockPlacementInfo
                    myView.text = "Inside " + b.name

                    cell.addSubview(myView)
                    count += 1
                }
                
                let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                myLabel.accessibilityLabel = block.name + blockPlacementInfo
                myLabel.accessibilityHint = "Double tap to move block"
                
                cell.addSubview(myLabel)
                
                let placeholderBlock = createPlaceholderBlock(frame: CGRect(x: blockWidth, y: startingHeight-count*(blockHeight/2+blockSpacing), width: placeholderWidth, height: blockHeight + count*(blockHeight/2+blockSpacing)))
                placeholderBlock.accessibilityLabel = "Add Block after " + block.name + blockPlacementInfo
                cell.addSubview(placeholderBlock)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let blocksStackIndex = indexPath.row - 1
        let blocksProgramIndex = indexPath.row
        
        if !blocksBeingMoved.isEmpty{
            addBlocks(blocksBeingMoved, at: blocksStackIndex + 1 )
            //blocksBeingMoved.removeAll()
        }else{
            //make announcement
            let myBlock = blocksStack[blocksStackIndex]
            //remove block from collection and program
            if myBlock.double == true{
                var indexOfCounterpart = -1
                for i in 0..<blocksStack.count {
                    if blocksStack[i] === myBlock.counterpart! {
                        indexOfCounterpart = i
                    }
                }
                var indexPathArray = [IndexPath]()
                var tempBlockStack = [Block]()
                for i in min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex){
                    indexPathArray += [IndexPath.init(row: i+1, section: 0)]
                    tempBlockStack += [blocksStack[i]]
                }
                blocksBeingMoved = tempBlockStack
                
                blocksStack.removeSubrange(min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex))
                blocksProgram.reloadData()
            }else{ //only a single block to be removed
                blocksBeingMoved = [blocksStack[blocksStackIndex]]
                blocksStack.remove(at: blocksStackIndex)
                /*blocksProgram.performBatchUpdates({
                    self.blocksProgram.deleteItems(at: [IndexPath.init(row: blocksProgramIndex, section: 0)])
                }, completion: nil)*/
                blocksProgram.reloadData()
            }
            let announcement = myBlock.name + " selected, chose where to move it.  "
            print(announcement)
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
            //movingBlocks = true
        }
        changeButton()
        //have giant targets to add it to: at begining, in each block, in trash
    }
    
    func addBlockButton(_sender: UIButton){
        if let blockView = _sender.superview as? UICollectionViewCell{
            indexToAdd = (blocksProgram?.indexPath(for: blockView)?.row)!
        }
        performSegue(withIdentifier: "addNewBlockSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    // Pass on index where the block should be added
    var containerViewController: UICollectionViewController?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let myDestination = segue.destination as? I3BlocksTypeTableViewController{
            myDestination.indexToAdd = indexToAdd
        }
    }

}
