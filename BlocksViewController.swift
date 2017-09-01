//
//  BlocksViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 5/9/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

protocol BlockSelectionDelegate{
    func setSelectedBlocks(_ blocks:[Block])
    func unsetBlocks()
    func setParentViewController(_ myVC:UIViewController)
}

class BlocksViewController:  RobotControlViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, BlockSelectionDelegate {
    
    @IBOutlet weak var blocksProgram: UICollectionView!
    @IBOutlet weak var playTrashToggleButton: UIButton!
    
    var spatialLayout = false //use spatial or audio layout for blocks
    var blocksBeingMoved = [Block]() //pretty sure we can
        //TODO: do I need both movingBlocks and blocksBeingMoved
    var movingBlocks = false    //currently moving blocks in the workspace
    let collectionReuseIdentifier = "BlockCell"
    var containerViewController: UINavigationController?
    
    var blockWidth = 200
    var blockHeight = 200
    let blockSpacing = 1
    
    var dragOn = false
    
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var spatialButton: UIButton!
    
    //TODO: probably want to get rid of this
    var dropIndex = 0
    
    
    // MARK: - View Set Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        
        //TOGGLE this off if you want to be able to access menu and spatial buttons with VO on
        /*menuButton.isAccessibilityElement = false
        menuButton.accessibilityElementsHidden = true
        spatialButton.isAccessibilityElement = false
        spatialButton.accessibilityElementsHidden = true*/
        
        //#selector(self.addBlockButton(_sender:))
        //NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishAnnouncement(dict:)), name: NSNotification.Name.UIAccessibilityAnnouncementDidFinish, object: nil)
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Block Selection Delegate
    func unsetBlocks() {
        movingBlocks = false
        blocksBeingMoved.removeAll()
        changeButton()
    }
    
    
    func setSelectedBlocks(_ blocks: [Block]) {
        movingBlocks = true
        blocksBeingMoved = blocks
        blocksProgram.reloadData()
        changeButton()
    }
    
    func setParentViewController(_ myVC: UIViewController) {
        containerViewController = myVC as? UINavigationController
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
            //movingBlocks = false
            let announcement = blocksBeingMoved[0].name + " placed in trash."
            //blocksBeingMoved.removeAll()
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
            //CRAZY TRY
            blocksProgram.reloadData()
            //changeButton()
            
            containerViewController?.popViewController(animated: false)
            unsetBlocks()
        }else{
            //play
            if(blocksStack.isEmpty){
                let announcement = "Your robot has nothing to do!  Add some blocks to your workspace. "
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(announcement, comment: ""))
            }else{
                let commands = createCommandSequence(blocksStack)
                play(commands)
            }
        }
    }
    
    func unrollLoop(times: Int, blocks:[Block])->[String]{
        var commands = [String]()
        for _ in 0..<times{
            var i = 0
            while i < blocks.count{
                if blocks[i].name.contains("Repeat") {
                    var timesToRepeat = 1
                    if blocks[i].name == "Repeat 2 Times"{
                        timesToRepeat = 2
                    }else if blocks[i].name == "Repeat 3 Times"{
                        timesToRepeat = 3
                    }else if blocks[i].name == "Repeat Times"{
                        var timesToRepeatAsString = blocks[i].options[blocks[i].pickedOption]
                        timesToRepeatAsString = timesToRepeatAsString.substring(to: timesToRepeatAsString.index(before: timesToRepeatAsString.endIndex))
                        timesToRepeat = Int(timesToRepeatAsString)!
                    }
                    var ii = i+1
                    var blocksToUnroll = [Block]()
                    while blocks[i].counterpart !== blocks[ii]{
                        blocksToUnroll.append(blocks[ii])
                        ii += 1
                    }
                    i = ii
                    let items = unrollLoop(times: timesToRepeat, blocks: blocksToUnroll)
                    //add items
                    for item in items{
                        commands.append(item)
                    }
                }else{
                    var myCommand = blocks[i].name
                    if blocks[i].name.contains("Distance"){
                        let distance = blocks[i].options[blocks[i].pickedOption]
                        myCommand.append(distance)
                    }
                    commands.append(myCommand)
                }
                i+=1
            }
        }
        return commands
    }
    
    
    func createCommandSequence(_ blocks: [Block])->[String]{
        var commands = unrollLoop(times: 1, blocks: blocks)
        for c in commands{
            print(c)
        }
        return commands
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
            blocksStack.insert(contentsOf: blocks, at: index)
            blocksBeingMoved.removeAll()
            blocksProgram.reloadData()
        }else{
            blocksStack.insert(blocks[0], at: index)
            //NEED TO DO THIS?
            blocksBeingMoved.removeAll()
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
            
            let blockView = BlockView(frame: CGRect(x: xCoord, y: 0, width: blockWidth, height: blockHeight),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
            count += 1

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
        return blocksStack.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: CGFloat(blockWidth), height: collectionView.frame.height)
        
        if indexPath.row == blocksStack.count {
            if blocksStack.count < 8 {
                //fill up the rest of the screen
                let myWidth = collectionView.frame.width - CGFloat(blocksStack.count) * CGFloat(blockWidth)
                size = CGSize(width: myWidth, height: collectionView.frame.height)
            }else{
                //just normal size block at the end
                size = CGSize(width: CGFloat(blockWidth), height: collectionView.frame.height)
            }
        }
        return size
    }
    
    func addAccessibilityLabel(myLabel: UIView, block:Block, number: Int, blocksToAdd: [Block], spatial: Bool, interface: Int){

        myLabel.isAccessibilityElement = true
        var accessibilityLabel = ""
        //is blocksStack.count always correct?
        var blockPlacementInfo = ". Workspace block " + String(number) + " of " + String(blocksStack.count)
        var accessibilityHint = ""
        var spearCon = ""
        var nestingInfo  = ""
        var movementInfo = ". Double tap to move block."
        if(!blocksBeingMoved.isEmpty){
            if(interface == 0){
                accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " before "
            }else{
                accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " after "
            }
            movementInfo = ". Double tap to add " + blocksBeingMoved[0].name + " block here"
        }
        
        if(!spatial){
            for b in blocksToAdd{
                spearCon += " r "
                nestingInfo += " inside " + b.name
            }
        }
        if(interface == 1){
            movementInfo = ". tap and hold to move block."
        }
        
        accessibilityLabel += spearCon + block.name + blockPlacementInfo + nestingInfo
        accessibilityHint += movementInfo
        
        myLabel.accessibilityLabel = accessibilityLabel
        myLabel.accessibilityHint = accessibilityHint
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath)
        // Configure the cell
        for myView in cell.subviews{
            myView.removeFromSuperview()
        }
        cell.isAccessibilityElement = false
        if indexPath.row == blocksStack.count {
            if !blocksBeingMoved.isEmpty{
                cell.isAccessibilityElement = true
                if blocksStack.count == 0 {
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at Beginning"
                }else{
                    cell.accessibilityLabel = "Place " + blocksBeingMoved[0].name + " at End"
                }
            }
        }else{
        
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
                let myLabel = BlockView(frame: CGRect(x: 0, y: Int(cell.frame.height)-blockHeight, width: blockWidth, height: blockWidth), block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                
                //let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: Int(cell.frame.height)-blockHeight, width: blockWidth, height: blockWidth))
                //myLabel.isAccessibilityElement = true
                addAccessibilityLabel(myLabel: myLabel, block: block, number: indexPath.row + 1, blocksToAdd: blocksToAdd, spatial:false, interface: 0)

                cell.addSubview(myLabel)

            }else {
                var count = 0
                for b in blocksToAdd{
                    let myView = createBlock(b, withFrame: CGRect(x: -blockSpacing, y: startingHeight + blockHeight/2-count*(blockHeight/2+blockSpacing), width: blockWidth+2*blockSpacing, height: blockHeight/2))

                    myView.accessibilityLabel = "Inside " + b.name
                    myView.text = "Inside " + b.name

                    cell.addSubview(myView)
                    count += 1
                }
                //let blockPlacementInfo = ". Workspace block " + String(indexPath.row + 1) + " of " + String(blocksStack.count)
                
                //var movementInfo = "Double tap to move block."
                
                
                //add main label
                
                let myLabel = BlockView(frame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockHeight)
                addAccessibilityLabel(myLabel: myLabel, block: block, number: indexPath.row+1, blocksToAdd: blocksToAdd, spatial: true, interface: 0)
                
                /*let myLabel = createBlock(block, withFrame: CGRect(x: 0, y: startingHeight-count*(blockHeight/2+blockSpacing), width: blockWidth, height: blockHeight))
                if(block.imageName != nil){
                    let imageName = block.imageName!
                    let image = UIImage(named: imageName)
                    let imv = UIImageView.init(image: image)
                    myLabel.addSubview(imv)
                }*/
                //myLabel.isAccessibilityElement = true
                /*
                let accessibilityLabel = block.name + blockPlacementInfo + movementInfo
                myLabel.accessibilityLabel = accessibilityLabel
                if(!blocksBeingMoved.isEmpty){
                    myLabel.accessibilityLabel = "Place " + blocksBeingMoved[0].name  + " before " +  accessibilityLabel
                    myLabel.accessibilityHint = blockPlacementInfo + ". Double tap to add " + blocksBeingMoved[0].name + " block here"
                }*/
                
                
                cell.addSubview(myLabel)
            }
        }
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
        return myLabel
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(movingBlocks){
            addBlocks(blocksBeingMoved, at: indexPath.row)
            containerViewController?.popViewController(animated: false)
            unsetBlocks()
        }else{
            if(indexPath.row < blocksStack.count){ //otherwise empty block at end
                movingBlocks = true
                let blocksStackIndex = indexPath.row
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
                        indexPathArray += [IndexPath.init(row: i, section: 0)]
                        tempBlockStack += [blocksStack[i]]
                    }
                    blocksBeingMoved = tempBlockStack
                    
                    blocksStack.removeSubrange(min(indexOfCounterpart, blocksStackIndex)...max(indexOfCounterpart, blocksStackIndex))
                    
                }else{ //only a single block to be removed
                    blocksBeingMoved = [blocksStack[blocksStackIndex]]
                    blocksStack.remove(at: blocksStackIndex)
                }
                blocksProgram.reloadData()
                let mySelectedBlockVC = SelectedBlockViewController()
                mySelectedBlockVC.blocks = blocksBeingMoved
                containerViewController?.pushViewController(mySelectedBlockVC, animated: false)
                changeButton()
            }
        }
    }

    func addGestureRecognizer(_ cell:UICollectionViewCell){
    
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerViewController = segue.destination as? UINavigationController{
            if let myTopViewController = containerViewController.topViewController as? BlocksTypeTableViewController{
                myTopViewController.delegate = self
                myTopViewController.blockWidth = blockWidth
            }
        }
    }
    

}
