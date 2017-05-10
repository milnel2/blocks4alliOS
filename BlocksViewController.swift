//
//  BlocksViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 5/9/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BlocksViewController:  RobotControlViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var blocksProgram: UICollectionView!
    @IBOutlet weak var playTrashToggleButton: UIButton!
    
    var spatialLayout = false //use spatial or audio layout for blocks
    var movingBlocks = false    //currently moving blocks in the workspace
    let collectionReuseIdentifier = "BlockCell"
    
    var blockWidth = 100
    let blockHeight = 100
    let blockSpacing = 1
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blocksProgram.delegate = self
        blocksProgram.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Button Actions
    
    @IBAction func switchLayout(_ sender: Any) {
        spatialLayout = !spatialLayout
        blocksProgram.reloadData()
    }
    
    func changeButton(){
        if movingBlocks{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "Trashcan"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Trash"
            playTrashToggleButton.accessibilityHint = "Delete selected blocks"
        }else{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Play"
            playTrashToggleButton.accessibilityHint = "Make your robot go!"
        }
    }
    
    // run code
    @IBAction func playButtonClicked(_ sender: Any) {
        play(blocksStack)
    }
    
    // MARK: Blocks Methods
    
    func createViewRepresentation(FromBlocks blocksRep: [Block]) -> UIView {
        let myViewWidth = (blockWidth + blockSpacing)*blocksRep.count
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        var count = 0
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        
        let startingHeight = Int(cell.frame.height)-blockHeight
        
        let block = blocksStack[indexPath.row]
        var blocksToAdd = [Block]()
        
        //check if block is nested (or nested multiple times)
        for i in 0...indexPath.row {
            if blocksStack[i].double {
                if(!blocksStack[i].name.contains("End")){
                    if(i != indexPath.row){
                        blocksToAdd.append(blocksStack[i])
                    }
                }else{
                    blocksToAdd.removeLast()
                }
            }
        }
        if !spatialLayout {
            blocksToAdd.reverse()
            
            let block = blocksStack[indexPath.row]
            
            var accessibilityLabel = block.name
            var spearCon = ""
            for b in blocksToAdd{
                spearCon += " r "
                accessibilityLabel += " inside " + b.name
            }
            accessibilityLabel = spearCon + accessibilityLabel
            
            let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: Int(cell.frame.height)-blockHeight, width: blockWidth, height: blockWidth))
            //(frame: CGRect(x: 0, y: Int(cell.frame.height)-blockHeight, width: blockWidth, height: blockWidth))
            /*myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            myLabel.numberOfLines = 0
            myLabel.backgroundColor = block.color*/
            myLabel.accessibilityLabel = accessibilityLabel
            cell.addSubview(myLabel)
            
            //cell.backgroundColor = block.color
            
        }else {
            var count = 0
            for b in blocksToAdd{
                let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))
                
                //let myView = UILabel.init(frame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))
                //let myView = UILabel.init(frame: CGRect(x: -blockSpacing, y: -count*(blockHeight), width: blockWidth+2*blockSpacing, height: blockHeight))
                myView.accessibilityLabel = "Inside " + b.name
                myView.text = "Inside " + b.name
                //myView.textAlignment = .center
               // myView.textColor = UIColor.white
               // myView.numberOfLines = 0
               // myView.backgroundColor = b.color
                cell.addSubview(myView)
                count += 1
            }
            
            //add main label
            let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
            cell.addSubview(myLabel)
            
            /*let myLabel = UILabel.init(frame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
            //let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: blockHeight))
            myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            myLabel.numberOfLines = 0
            myLabel.backgroundColor = block.color
            cell.addSubview(myLabel)*/
            
        }
        addGestureRecognizer(cell)
        
        return cell
    }
    
    func createBlock(_ block: Block, withFrame frame:CGRect)->UILabel{
        let myLabel = UILabel.init(frame: frame)
        //let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: blockHeight))
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = UIColor.white
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = block.color
        return myLabel
    }

    func addGestureRecognizer(_ cell:UICollectionViewCell){
    
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
