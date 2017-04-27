//
//  Interface3ViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/7/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class PlaceholderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var blocksProgram: UICollectionView!
    var blockToAdd: Block?
    //var indexToAdd: Int?
    var count = 0
    
    private let blockWidth = 90
    private let blockHeight = 100
    private let blockSpacing = 1
    private let blockDoubleHeight = 25
    
    private var spatialLayout = false
    private let collectionReuseIdentifier = "BlockCell"
    
    @IBAction func switchLayout(_ sender: Any) {
        spatialLayout = !spatialLayout
        blocksProgram.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        blocksProgram.delegate = self
        blocksProgram.dataSource = self

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
                    blocksStack.insert(blockToAdd!, at: indexToAdd3)
                    blockToAdd!.ID = count
                    count += 1
                    let endBlockName = "End " + blockToAdd!.name
                    guard let block1 = Block(name: endBlockName, color: blockToAdd!.color, double: true) else {
                        fatalError("Unable to instantiate block1")
                    }
                    blocksStack.insert(block1, at: indexToAdd3+1)
                    block1.ID = indexToAdd3+1
                    block1.counterpartID = indexToAdd3
                    block1.counterpart = blockToAdd
                    blockToAdd?.counterpart = block1
                    blockToAdd?.counterpartID = indexToAdd3+1
                }else{
                    blocksStack.insert(blockToAdd!, at: indexToAdd3)
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
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocksStack.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath) as! I3BlockCollectionViewCell
        
        if !spatialLayout {
            // Configure the cell
            for myView in cell.subviews{
                myView.removeFromSuperview()
            }
            
            let block = blocksStack[indexPath.row]
            
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
            
            let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockHeight))
            //let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: blockHeight))
            myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            myLabel.numberOfLines = 0
            myLabel.backgroundColor = block.color
            
            cell.addSubview(myLabel)
            
            let placeholderBlock = UIButton.init(frame: CGRect(x: blockWidth, y: 0, width: blockWidth/2, height: blockHeight ))
            placeholderBlock.backgroundColor = UIColor.gray
            placeholderBlock.titleLabel?.text = "+"
            placeholderBlock.titleLabel?.textColor = UIColor.white
            placeholderBlock.accessibilityLabel = "Add Block after " + block.name
            
            placeholderBlock.addTarget(self, action: #selector(self.addBlock(_sender:)), for: .touchUpInside)
            
            cell.addSubview(placeholderBlock)
        }else{
            // Configure the cell
            for myView in cell.subviews{
                myView.removeFromSuperview()
            }
            
            let block = blocksStack[indexPath.row]
            
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
            
            let placeholderBlock = UIButton.init(frame: CGRect(x: blockWidth, y: -count*(blockHeight/2+blockSpacing), width: blockWidth/2, height: blockHeight + count*(blockHeight/2+blockSpacing)))
            placeholderBlock.backgroundColor = UIColor.gray
            placeholderBlock.titleLabel?.text = "+"
            placeholderBlock.titleLabel?.textColor = UIColor.white
            placeholderBlock.accessibilityLabel = "Add Block after " + block.name
            //placeholderBlock.
            //placeholderBlock.addTarget(self, action: #selector(self.addBlock(atIndex:)), for: .touchUpInside)
            /*if let parentViewController = self.parent as? Interface3ViewController{
             placeholderBlock.addTarget(self, action: #selector(parentViewController.addBlock(_sender:)), for: .touchUpInside)
             print("hello world")
             //I3BlocksCollectionViewController.addBlock(atIndex:(indexPath.row + 1))), for: .touchUpInside)
             }*/
            placeholderBlock.addTarget(self, action: #selector(self.addBlock(_sender:)), for: .touchUpInside)
            
            //I3BlocksCollectionViewController.addBlock(atIndex:(indexPath.row + 1))), for: .touchUpInside)
            cell.addSubview(placeholderBlock)
        }
        return cell
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
        if let myDestination = segue.destination as? I3BlocksTypeTableViewController{
            myDestination.sendingInterface = 3
        }
        // you can set this name in 'segue.embed' in storyboard
        if segue.identifier == "I3StackedCollectionViewControllerIdentifier" {
            if let connectContainerViewController = segue.destination as? UICollectionViewController{
                containerViewController = connectContainerViewController
                blocksProgram = connectContainerViewController.collectionView
            }
        }
    }

}
