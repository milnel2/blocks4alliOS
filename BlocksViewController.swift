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
    var blocksBeingMoved = [Block]() //pretty sure we can
        //TODO: do I need both movingBlocks and blocksBeingMoved
    var movingBlocks = false    //currently moving blocks in the workspace
    let collectionReuseIdentifier = "BlockCell"
    
    var blockWidth = 100
    let blockHeight = 100
    let blockSpacing = 1
    
    //if drag is set off
    var dragOn = false
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var spatialButton: UIButton!
    
    //TODO: probably want to get rid of this
    var dropIndex = 0
    
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragOn = false
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        
        //TOGGLE this off if you want to be able to access menu and spatial buttons with VO on
        menuButton.isAccessibilityElement = false
        menuButton.accessibilityElementsHidden = true
        spatialButton.isAccessibilityElement = false
        spatialButton.accessibilityElementsHidden = true
        
        //#selector(self.addBlockButton(_sender:))
        //NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishAnnouncement(dict:)), name: NSNotification.Name.UIAccessibilityAnnouncementDidFinish, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func didFinishAnnouncement(dict: NSNotification){
        //if let info = dict.userInfo as? Dictionary
       /* if let spokenString = dict.userInfo?[UIAccessibilityAnnouncementKeyStringValue] as? String {
            //.object(forKey: UIAccessibilityAnnouncementKeyStringValue) as? String{
            print(spokenString)
            if(spokenString.contains("placed")){
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, blocksProgram.cellForItem(at: IndexPath(row: dropIndex, section: 0)))
            }
        }*/
        blocksProgram.reloadData()
        //let spokenString = dict.userInfo.objectForKey(UIAccessibilityAnnouncementKeyStringValue)
        //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, blocksProgram.cellForItem(at: IndexPath(row: index, section: 0)))
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
            playTrashToggleButton.accessibilityLabel = "Place in Trash"
            playTrashToggleButton.accessibilityHint = "Delete selected blocks"
        }else{
            playTrashToggleButton.setBackgroundImage(#imageLiteral(resourceName: "GreenArrow"), for: .normal)
            playTrashToggleButton.accessibilityLabel = "Play"
            playTrashToggleButton.accessibilityHint = "Make your robot go!"
        }
    }
    
    // run code
    @IBAction func playButtonClicked(_ sender: Any) {
        if(movingBlocks){
            //trash
            movingBlocks = false
            let announcement = blocksBeingMoved[0].name + " placed in trash."
            blocksBeingMoved.removeAll()
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
            //CRAZY TRY
            blocksProgram.reloadData()
        }else{
            //play
            if(blocksStack.isEmpty){
                let announcement = "Your robot has nothing to do!  Add some blocks to your workspace. "
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
            }else{
                play(blocksStack)
            }
        }
    }
    
    // MARK: Blocks Methods
    
    func addBlocks(_ blocks:[Block], at index:Int){
        //change for beginning
        var announcement = ""
        dropIndex = index
        if(index != 0){
            let myBlock = blocksStack[index-1]
            announcement = blocks[0].name + " placed after " + myBlock.name
        }else{
            announcement = blocks[0].name + " placed at beginning"
        }
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
        if(blocks[0].double){
            if(!blocksBeingMoved.isEmpty){
                blocksStack.insert(contentsOf: blocks, at: index)
                blocksBeingMoved.removeAll()
                //CRAZY TRY
                blocksProgram.reloadData()
            }else{
                let block = blocks[0]
                blocksStack.insert(block, at: index)
                let endBlockName = "End " + block.name
                let endBlock = Block(name: endBlockName, color: block.color, double: true, editable: block.editable)
                endBlock?.counterpart = block
                block.counterpart = endBlock
                blocksStack.insert(endBlock!, at: index+1)
                //CRAZY TRY
                blocksProgram.reloadData()
            }
        }else{
            blocksStack.insert(blocks[0], at: index)
            //CRAZY TRY
            blocksProgram.reloadData()
        }
    }
    
    func makeAnnouncement(_ announcement: String){
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
    }
    
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
            
            if(block.imageName != nil){
                let imageName = block.imageName!
                let image = UIImage(named: imageName)
                let imv = UIImageView.init(image: image)
                myView.addSubview(imv)
            }
            
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
    
    func addSpatialAccessibilityLabel(myLabel: UILabel, block:Block, number: Int, blocksToAdd: [Block]){
        var accessibilityLabel = block.name
        var spearCon = ""
        for b in blocksToAdd{
            spearCon += " r "
            accessibilityLabel += " inside " + b.name
        }
        let blockPlacementInfo = ". Workspace block " + String(number) + " of " + String(blocksStack.count)
        
        
        var movementInfo = "Double tap to move block."
        
        if(dragOn){
            movementInfo = "tap and hold to move block."
        }
        
        accessibilityLabel = spearCon + accessibilityLabel
        accessibilityHint = blockPlacementInfo + movementInfo
        
        myLabel.accessibilityLabel = accessibilityLabel
        myLabel.accessibilityHint = accessibilityHint
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
            let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: Int(cell.frame.height)-blockHeight, width: blockWidth, height: blockWidth))
            addSpatialAccessibilityLabel(myLabel: myLabel, block: block, number: indexPath.row + 1, blocksToAdd: blocksToAdd)
            cell.addSubview(myLabel)
            if(block.imageName != nil){
                let imageName = block.imageName!
                let image = UIImage(named: imageName)
                let imv = UIImageView.init(image: image)
                myLabel.addSubview(imv)
            }
        }else {
            var count = 0
            for b in blocksToAdd{
                let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))

                myView.accessibilityLabel = "Inside " + b.name
                myView.text = "Inside " + b.name

                cell.addSubview(myView)
                count += 1
            }
            let blockPlacementInfo = ". Workspace block " + String(indexPath.row + 1) + " of " + String(blocksStack.count)
            
            var movementInfo = "Double tap to move block."
            
            if(dragOn){
                movementInfo = "Double tap and hold to move block."
            }
            
            //add main label
            let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
            myLabel.accessibilityLabel = block.name + blockPlacementInfo + movementInfo
            cell.addSubview(myLabel)
            if(block.imageName != nil){
                let imageName = block.imageName!
                let image = UIImage(named: imageName)
                let imv = UIImageView.init(image: image)
                myLabel.addSubview(imv)
            }
        }
        addGestureRecognizer(cell)
        
        return cell
    }

    
    func createBlock(_ block: Block, withFrame frame:CGRect)->UILabel{
        let myLabel = UILabel.init(frame: frame)
        //let myLabel = UILabel.init(frame: CGRect(x: 0, y: -count*(blockHeight+blockSpacing), width: blockWidth, height: blockHeight))
        myLabel.text = block.name
        myLabel.textAlignment = .center
        myLabel.textColor = block.color
        myLabel.numberOfLines = 0
        myLabel.backgroundColor = block.color
        if(block.imageName != nil){
            let imageName = block.imageName!
            let image = UIImage(named: imageName)
            let imv = UIImageView.init(image: image)
            myLabel.addSubview(imv)
        }
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
