//
//  ViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AVFoundation


class DragAndDropViewController: RobotControlViewController, OBDropZone, OBOvumSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //@IBOutlet weak var playButton: UIButton!
    
    private let collectionReuseIdentifier = "BlockCell"
    private var spatialLayout = false
    
    //update these as collection view changes
    private let blockWidth = 100
    private let blockHeight = 100
    private let blockSpacing = 1
    private let blockDoubleHeight = 25
    private let trashcanWidth = 100
    
    private var count = 0
    
    //Set to -1 to distinguish blocks that are pulled in from toolbox vs moving in workspace
    public var indexOfCurrentBlock = -1
    public var fromWorkspace = false
    
    //@IBOutlet weak var blocksProgram: UIStackView!
    @IBOutlet weak var blocksProgram: UICollectionView!
    
    //collection of blocks that are part of your program

    var blocksStack = [Block]()
    var blocksBeingMoved = [Block]()

    //toggle between spatial and audio layouts when button pressed
    @IBAction func switchLayouts(_ sender: Any) {
        spatialLayout = !spatialLayout
        blocksProgram.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        blocksProgram.delegate = self
        blocksProgram.dataSource = self
        self.view.dropZoneHandler = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // run code
    @IBAction func playButtonClicked(_ sender: Any) {
        var cmdToSend = WWCommandSetSequence()
        var repeatCommands = [WWCommandSet]()
        var repeat2times = false
        var repeat3times = false
        for block in blocksStack{
            print(block.name)
            //TODO add repeat blocks
            
            let distance: Double = 10
            let myAction = WWCommandSet()
            if block.name == "Drive Forward" {
                let bodyPose = WWCommandBodyPose.init(relativeMeasuredX: distance, y: 0, radians: 0, time: 2)
                myAction.setBodyPose(bodyPose)
            }
            if block.name == "Say Hi" {
                let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_HI)
                myAction.setSound(speaker)
            }
            
            if block.name == "Make Horse Noise" {
                let speaker = WWCommandSpeaker.init(defaultSound: WW_SOUNDFILE_HORSE)
                myAction.setSound(speaker)
            }
            //TODO: FIX FOR NESTED LOOPS
            if block.name == "Repeat 3 Times" {
                repeat3times = true
            }else if block.name == "End Repeat 3 Times" {
                repeat3times = false
                for index in 1...3{
                    for action in repeatCommands {
                        cmdToSend.add(action, withDuration: 2.0)
                    }
                }
            }else if repeat3times {
                repeatCommands.append(myAction)
            }else {
                cmdToSend.add(myAction, withDuration: 2.0)
            }
            
            //TODO WRONG
            /*if block.name == "Drive Backward" {
                var backward = WWCommandBodyLinearAngular(linear: -10, angular: 0)
                myAction.setBodyLinearAngular(backward)
                cmdToSend.add(myAction, withDuration: 2.0)
                var stop = WWCommandBodyLinearAngular(linear: 0, angular: 0)
                myAction.setBodyLinearAngular(stop)
                //let bodyPose = WWCommandBodyPose.init(relativeMeasuredX: -10.0, y: 0, radians: 0, time: 2)
                //myAction.setBodyPose(bodyPose)
            }
            //TODO WRONG
            if block.name == "Turn Left" {
                myAction.setBodyWheels(WWCommandBodyWheels.init(leftWheel: -20.0, rightWheel: 20.0))
            }*/
        }
        sendCommandSequenceToRobots(cmdSeq: cmdToSend)
        //sendCommandSetToRobots(cmd: cmdToSend)
    }
    
    // MARK: - Drag and Drop Methods
    
    func ovumEntered(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("Entered View", comment: ""))
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
                //change for beginning
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
                        
                        blocksProgram.performBatchUpdates({
                            self.blocksProgram.insertItems(at: indexPathArray)
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
                        blocksProgram.performBatchUpdates({
                            self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0), IndexPath.init(row: index+1, section: 0)])
                        }, completion: nil)
                    }
                }else{
                    blocksStack.insert(blocks[0], at: index)
                    blocksProgram.performBatchUpdates({
                        self.blocksProgram.insertItems(at: [IndexPath.init(row: index, section: 0)])
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

    //MARK: - OBOvmSource
    func createOvum(from sourceView: UIView!) -> OBOvum! {
        let ovum = OBOvum.init()
        if let sView = sourceView as? BlockCollectionViewCell{
            fromWorkspace = true
            indexOfCurrentBlock = (blocksProgram.indexPath(for: sView)?.row)!
            //TODO: UPDATE THIS TO DROP TWO BLOCKS AND EVERYTHING IN BETWEEN
            let myBlock = blocksStack[indexOfCurrentBlock]
            if myBlock.double == true{
                var indexOfCounterpart = -1
                for i in 0..<blocksStack.count {
                    if blocksStack[i].ID == myBlock.counterpartID {
                        indexOfCounterpart = i
                    }
                }
                var indexPathArray = [IndexPath]()
                var tempBlockStack = [Block]()
                for i in min(indexOfCounterpart, indexOfCurrentBlock)...max(indexOfCounterpart, indexOfCurrentBlock){
                    indexPathArray += [IndexPath.init(row: i, section: 0)]
                    tempBlockStack += [blocksStack[i]]
                }
                ovum.dataObject = tempBlockStack
                
                blocksStack.removeSubrange(min(indexOfCounterpart, indexOfCurrentBlock)...max(indexOfCounterpart, indexOfCurrentBlock))
                blocksProgram.performBatchUpdates({
                    self.blocksProgram.deleteItems(at: indexPathArray)
                }, completion: nil)
            }else{ //only a single block to be removed
                ovum.dataObject = [blocksStack[indexOfCurrentBlock]]
                blocksStack.remove(at: indexOfCurrentBlock)
                blocksProgram.performBatchUpdates({
                    self.blocksProgram.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
                }, completion: nil)
            }
            blocksBeingMoved = ovum.dataObject as! [Block]
        }else{ //probably should throw an error
            ovum.dataObject = sourceView.backgroundColor
        }
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        if let sView = sourceView as? BlockCollectionViewCell{
            let dragView = createViewRepresentation(FromBlocks: blocksBeingMoved)
            dragView.frame.origin.x = sView.frame.origin.x
            dragView.frame.origin.y = sView.frame.origin.y
            return dragView
            /*
            let frame = sView.convert(sView.bounds, to: sView.window)
            //TODO: UPDATE THIS TO DROP TWO BLOCKS AND EVERYTHING IN BETWEEN
            let dragView = UIView(frame: frame)
            dragView.backgroundColor = sView.backgroundColor
            let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth))
            myLabel.text = sView.labelView.text
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            dragView.self.addSubview(myLabel)
            dragView.alpha = 0.75
            return dragView*/
        }
        
        return sourceView
    }

    
    func ovumDragEnded(_ ovum: OBOvum!) {
        return
    }
    
    func createViewRepresentation(FromBlocks blocksRep: [Block]) -> UIView {
        let myViewWidth = (blockWidth + blockSpacing)*blocksRep.count
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        count = 0
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseIdentifier, for: indexPath) as! BlockCollectionViewCell
        
        if !spatialLayout {
            // Configure the cell
            for myView in cell.subviews{
                myView.removeFromSuperview()
            }
            
            
            //THIS SHOULD WORK FOR SECOND VERSION OF PROGRAM STRUCTURE
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
            blocksToAdd.reverse()
            
            let block = blocksStack[indexPath.row]
            
            var accessibilityLabel = block.name
            var spearCon = ""
            for b in blocksToAdd{
                spearCon += " r "
                accessibilityLabel += " inside " + b.name
            }
            accessibilityLabel = spearCon + accessibilityLabel
            
            let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth))
            myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            myLabel.numberOfLines = 0
            myLabel.accessibilityLabel = accessibilityLabel
            cell.addSubview(myLabel)
            
            cell.backgroundColor = block.color

            
            if (cell.gestureRecognizers == nil || cell.gestureRecognizers?.count == 0) {
                let manager = OBDragDropManager.shared()
                let recognizer = manager?.createDragDropGestureRecognizer(with: UIPanGestureRecognizer.classForCoder(), source: self)
                //let recognizer = manager?.createLongPressDragDropGestureRecognizer(with: self)
                cell.addGestureRecognizer(recognizer!)
                
                //ADDED TO FAKE VOICEOVER
                /*
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_sender:)))
                //tap.delegate = self
                cell.addGestureRecognizer(tap)
                
                //let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_sender:)))
                //cell.addGestureRecognizer(pan)
                //cell.accessibilityTraits = accessibility
                cell.isUserInteractionEnabled = true
     */
            }
        }else {
            // Configure the cell
            for myView in cell.subviews{
                myView.removeFromSuperview()
            }
            
            let block = blocksStack[indexPath.row]
            
            
            //THIS SHOULD WORK FOR SECOND VERSION OF PROGRAM STRUCTURE
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
            
            if (cell.gestureRecognizers == nil || cell.gestureRecognizers?.count == 0) {
                let manager = OBDragDropManager.shared()
                let recognizer = manager?.createDragDropGestureRecognizer(with: UIPanGestureRecognizer.classForCoder(), source: self)
                //let recognizer = manager?.createLongPressDragDropGestureRecognizer(with: self)
                cell.addGestureRecognizer(recognizer!)
            }
        
        }
        
        return cell
    }
    
    func playSound(){
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1104
        
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    func handleSingleTap(_sender: UITapGestureRecognizer){
        if let myView = _sender.view as? BlockCollectionViewCell{
            // create a sound ID, in this case its the tweet sound.
            playSound()
            
            //print(myView.labelView.text ?? "nope")
        }
    }

}

