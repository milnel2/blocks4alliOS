//
//  I4ViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/12/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class I4ViewController: UIViewController {
    
    var blocksProgram: UICollectionView?
    var blockToAdd: Block?
    var count = 0
    var addingBlockFromWorkspace = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if blockToAdd != nil {
            if blockToAdd?.name == "Choose Block from Workspace"{
                //pick a block from workspace
                print("Choosing Block From Workspace")
                addBlockFromWorkspace(at: indexToAdd4)
                addingBlockFromWorkspace = true
            }else if blockToAdd?.name == "Cancel"{
                //pick a block from workspace
                print("Do nothing")
            }else{
                //add block
                if(blockToAdd!.double){
                    blocksStack4.insert(blockToAdd!, at: indexToAdd4)
                    blockToAdd!.ID = count
                    count += 1
                    let endBlockName = "End " + blockToAdd!.name
                    guard let block1 = Block(name: endBlockName, color: blockToAdd!.color, double: true) else {
                        fatalError("Unable to instantiate block1")
                    }
                    blocksStack4.insert(block1, at: indexToAdd4+1)
                    block1.ID = indexToAdd4+1
                    block1.counterpartID = indexToAdd4
                    block1.counterpart = blockToAdd
                    blockToAdd?.counterpart = block1
                    blockToAdd?.counterpartID = indexToAdd4+1
                }else{
                    blocksStack4.insert(blockToAdd!, at: indexToAdd4)
                    blockToAdd!.ID = count
                    count += 1
                }
            }
        }
        indexToAdd4 = 0
    }
    
    func addBlockFromWorkspace(at indexToAdd: Int){
        //audio to tell you are chosing a block to add there
        let announcement = "Select which block you want to move here"
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
        
        //check to make sure that you are adding a block somewhere new, allow option for block already there
        
        
        
        addingBlockFromWorkspace = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBlock(_sender: UIButton){
        if let blockView = _sender.superview as? I3BlockCollectionViewCell{
            indexToAdd4 = (blocksProgram?.indexPath(for: blockView)?.row)! + 1
        }
        performSegue(withIdentifier: "addNewBlockSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    // Accessing the UICollectionView in container
    var containerViewController: UICollectionViewController?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let myDestination = segue.destination as? I3BlocksTypeTableViewController{
            myDestination.sendingInterface = 4
        }
        
        if segue.identifier == "I3StackedCollectionViewControllerIdentifier" {
            if let connectContainerViewController = segue.destination as? UICollectionViewController{
                containerViewController = connectContainerViewController
                blocksProgram = connectContainerViewController.collectionView
            }
        }
    }
    
}
