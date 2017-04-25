//
//  Interface3ViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/7/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class I3ViewController: UIViewController {
    
    var blocksProgram: UICollectionView?
    var blockToAdd: Block?
    //var indexToAdd: Int?
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if blockToAdd != nil {
            if blockToAdd?.name == "Choose Block from Workspace"{
                //pick a block from workspace
                print("Choosing Block From Workspace")
            }else if blockToAdd?.name == "Cancel"{
                //pick a block from workspace
                print("Do nothing")
            }else{
                //add block
                if(blockToAdd!.double){
                    blocksStack3.insert(blockToAdd!, at: indexToAdd3)
                    blockToAdd!.ID = count
                    count += 1
                    let endBlockName = "End " + blockToAdd!.name
                    guard let block1 = Block(name: endBlockName, color: blockToAdd!.color, double: true) else {
                        fatalError("Unable to instantiate block1")
                    }
                    blocksStack3.insert(block1, at: indexToAdd3+1)
                    block1.ID = indexToAdd3+1
                    block1.counterpartID = indexToAdd3
                    block1.counterpart = blockToAdd
                    blockToAdd?.counterpart = block1
                    blockToAdd?.counterpartID = indexToAdd3+1
                }else{
                    blocksStack3.insert(blockToAdd!, at: indexToAdd3)
                    blockToAdd!.ID = count
                    count += 1
                }
            }
        }
        indexToAdd3 = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBlock(_sender: UIButton){
        if let blockView = _sender.superview as? I3BlockCollectionViewCell{
            indexToAdd3 = (blocksProgram?.indexPath(for: blockView)?.row)! + 1
        }
        performSegue(withIdentifier: "addNewBlockSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    // Accessing the UICollectionView in container
    var containerViewController: UICollectionViewController?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // you can set this name in 'segue.embed' in storyboard
        if segue.identifier == "I3StackedCollectionViewControllerIdentifier" {
            if let connectContainerViewController = segue.destination as? UICollectionViewController{
                containerViewController = connectContainerViewController
                blocksProgram = connectContainerViewController.collectionView
            }
        }
    }

}
