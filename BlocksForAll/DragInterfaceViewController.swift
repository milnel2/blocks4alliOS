//
//  DragInterfaceViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/7/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

var blocksStack = [Block]()
var fromWorkspace = false

class DragInterfaceViewController: UIViewController, OBDropZone {

    
    //update these as collection view changes
    private let blockWidth = 100
    private let blockHeight = 100
    private let blockSpacing = 1
    private let blockDoubleHeight = 25
    private let trashcanWidth = 100
    
    private var count = 0
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    public var indexOfCurrentBlock = -1
    //public var fromWorkspace = false
    
    //@IBOutlet weak var blocksProgram: UIStackView!
    //@IBOutlet weak var blocksProgram: UICollectionView!
    var blocksProgram: UICollectionView?
    
    var blocksBeingMoved = [Block]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.dropZoneHandler = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Accessing the UICollectionView in container
    var containerViewController: UICollectionViewController?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // you can set this name in 'segue.embed' in storyboard
        if segue.identifier == "stackedCollectionViewControllerIdentifier" {
            if let connectContainerViewController = segue.destination as? UICollectionViewController{
                containerViewController = connectContainerViewController
                blocksProgram = connectContainerViewController.collectionView
                /*if let myView = containerViewController?.view as? UICollectionView{
                    blocksProgram = myView
                }*/
            }
        }
    }
    
    /*
     var containerViewController: StackedBlocksCollectionViewController?
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // you can set this name in 'segue.embed' in storyboard
     if segue.identifier == "stackedCollectionViewControllerIdentifier" {
     if let connectContainerViewController = segue.destination as? StackedBlocksCollectionViewController{
     containerViewController = connectContainerViewController
     blocksProgram = connectContainerViewController.collectionView
     /*if let myView = containerViewController?.view as? UICollectionView{
     blocksProgram = myView
     }*/
     }
     }
     }
     */
    
    // MARK: - Drag and Drop Methods
    
    func ovumEntered(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
        //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("Entered View", comment: ""))
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
                var announcement = ""
                if(index != 0){
                    let myBlock = blocksStack[index-1]
                    announcement = blocks[0].name + " placed after " + myBlock.name
                }else{
                    announcement = blocks[0].name + " placed at beginning"
                }
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
                
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
                        
                        blocksProgram?.performBatchUpdates({
                            self.blocksProgram?.insertItems(at: indexPathArray)
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
                        blocksProgram?.performBatchUpdates({
                            self.blocksProgram?.insertItems(at: [IndexPath.init(row: index, section: 0), IndexPath.init(row: index+1, section: 0)])
                        }, completion: nil)
                    }
                }else{
                    blocksStack.insert(blocks[0], at: index)
                    blocksProgram?.performBatchUpdates({
                        self.blocksProgram?.insertItems(at: [IndexPath.init(row: index, section: 0)])
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
}

