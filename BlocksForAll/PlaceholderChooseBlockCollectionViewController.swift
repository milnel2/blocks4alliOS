//
//  I3ChooseBlockCollectionViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 4/25/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit


class PlaceholderChooseBlockCollectionViewController: UICollectionViewController {
    private let blockWidth = 90
    private let blockHeight = 100
    private let blockSpacing = 1
    private let reuseIdentifier = "BlockCell"
    private let spatialLayout = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return blocksStack.count 
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! I3BlockCollectionViewCell
        
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
        
        if !spatialLayout {
            let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockHeight))
            
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
            placeholderBlock.addTarget(self, action: #selector(self.addBlock(_sender:)), for: .touchUpInside)
            cell.addSubview(placeholderBlock)
        }
        
        return cell
    }
    
    func addBlock(_sender: UIButton){

        //performSegue(withIdentifier: "addNewBlockSegue", sender: self)
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
