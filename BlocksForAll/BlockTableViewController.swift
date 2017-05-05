//
//  BlockTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BlockTableViewController: UITableViewController, OBOvumSource {
    
    //MARK: Properties
    var blocks = [Block]()
    var blockTypes = NSArray()
    var typeIndex: Int! = 0
    
    //update these as collection view changes
    private let blockWidth = 100
    private let blockSpacing = 10
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Toolbox"
        
        blockTypes = NSArray(contentsOfFile: Bundle.main.path(forResource: "BlocksMenu", ofType: "plist")!)!
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            self.title = blockType.object(forKey: "type") as? String
        }
        self.accessibilityHint = "Double tap from menu to add block to workspace"
        
        createBlocksArray()
        // Load the sample data
        //loadSampleBlocks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blocks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "BlockTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BlockTableViewCell else {
            fatalError("The dequeued cell is not an instance of BlockTableViewCell.")
        }
        
        let block = blocks[indexPath.row]
        cell.block = block
        
        cell.nameLabel.text = block.name
        cell.blockView.backgroundColor = block.color
        cell.accessibilityHint = "Double tap and hold and drag to the right"
        //cell.blockView.
        //cell.blockView.backgroundColor = UIColor.brown
        // Configure the cell...
        // Drag drop with long press gesture
        //
        // Be careful with attaching gesture recognizers inside tableView:cellForRowAtIndexPath: as cells
        // get reused. Add a check to prevent multiple gesture recognizers from being added to the same cell.
        // The below check is crude but works; you may need something more specific or elegant.
        if (cell.gestureRecognizers == nil || cell.gestureRecognizers?.count == 0) {
            let manager = OBDragDropManager.shared()
            let recognizer = manager?.createDragDropGestureRecognizer(with: UIPanGestureRecognizer.classForCoder(), source: self)
            //let recognizer = manager?.createLongPressDragDropGestureRecognizer(with: self)
            cell.addGestureRecognizer(recognizer!)
            /*OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
            UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
            [cell addGestureRecognizer:recognizer];*/
        }
        

        return cell
    }
    

    
    //MARK: - OBOvmSource
    func createOvum(from sourceView: UIView!) -> OBOvum! {
        let ovum = OBOvum.init()
        if let sView = sourceView as? BlockTableViewCell{
            var twoBlocks = false
            if(sView.nameLabel.text!.contains("Repeat")){
                twoBlocks = true
            }
            ovum.dataObject = [Block(name: sView.nameLabel.text!, color: sView.blockView.backgroundColor!, double: twoBlocks, editable:sView.block!.editable)]
        }else{
            ovum.dataObject = sourceView.backgroundColor
        }
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        if let sView = sourceView as? BlockTableViewCell{
            let frame = sView.convert(sView.blockView.bounds, to: sView.window)

            let dragView = UIView(frame: frame)
            dragView.backgroundColor = sView.blockView.backgroundColor
            let myLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth))
            myLabel.text = sView.nameLabel.text
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            dragView.self.addSubview(myLabel)
            dragView.alpha = 0.75
            return dragView
        }
        
        return sourceView
    }

    
    func ovumDragEnded(_ ovum: OBOvum!) {
        return
    }
    
    
    //MARK: Private Methods
    
    //TODO: this is really convoluted, probably a better way of doing this
    private func createBlocksArray(){
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            if let blockArray = blockType.object(forKey: "Blocks") as? NSArray{
                for item in blockArray{
                    if let dictItem = item as? NSDictionary{
                        let name = dictItem.object(forKey: "name")
                        if let colorString = dictItem.object(forKey: "color") as? String{
                            let color = UIColor.colorFrom(hexString: colorString)
                            if let double = dictItem.object(forKey: "double") as? Bool{
                                if let editable = dictItem.object(forKey: "editable") as? Bool{
                                    guard let block = Block(name: name as! String, color: color, double: double, editable: editable) else {
                                        fatalError("Unable to instantiate block")
                                    }
                                    blocks += [block]
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadSampleBlocks(){
        guard let block1 = Block(name: "Drive Forward", color: UIColor.blue, double: false, editable: false) else {
            fatalError("Unable to instantiate block1")
        }
        
        guard let block2 = Block(name: "Drive Backwards", color: UIColor.blue, double: false, editable: false) else {
            fatalError("Unable to instantiate block2")
        }
        
        guard let block3 = Block(name: "Turn Left", color: UIColor.red, double: false, editable: false) else {
            fatalError("Unable to instantiate block3")
        }
        
        guard let block4 = Block(name: "Turn Right", color: UIColor.red, double: false, editable: false) else {
            fatalError("Unable to instantiate block4")
        }
        
        blocks += [block1, block2, block3, block4]
    
    }

}
