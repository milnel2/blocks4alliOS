//
//  I3BlocksCollectionViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/12/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

//var blocksStack3 = [Block]()
var indexToAdd3 = 0


class I3BlocksCollectionViewController: UICollectionViewController {
    var blocksStack3 = [Block]()
    //private let reuseIdentifier = "Cell"
    //update these as collection view changes
    private let blockWidth = 90
    private let blockHeight = 100
    private let blockSpacing = 1
    private let blockDoubleHeight = 25
    private let trashcanWidth = 100
    
    private var count = 0
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    //public var indexOfCurrentBlock = -1
    
    private let collectionReuseIdentifier = "BlockCell"
    
    //var blocksBeingMoved = [Block]()
    
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
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blocksStack3.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath) as! I3BlockCollectionViewCell
        
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        
        let block = blocksStack3[indexPath.row]

        var blocksToAdd = [Block]()
        
        //check if block is nested (or nested multiple times)
        for i in 0...indexPath.row {
            if blocksStack3[i].double {
                if(blocksStack3[i].ID! < blocksStack3[i].counterpartID!){
                    if(i != indexPath.row){
                        blocksToAdd.append(blocksStack3[i])
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
        
        return cell
    }
    
    
    
    
    func addBlock(_sender: UIButton){
        if let blockView = _sender.superview as? I3BlockCollectionViewCell{
            indexToAdd3 = (collectionView?.indexPath(for: blockView)?.row)! + 1
            if let parentViewController = self.parent as? PlaceholderViewController{
                parentViewController.performSegue(withIdentifier: "addNewBlockSegue", sender: parentViewController)
            }
        }
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
