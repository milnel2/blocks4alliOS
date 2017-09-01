//
//  DragAndDropBlockTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 5/25/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class DragAndDropBlockTableViewController: BlockTableViewController, OBOvumSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.accessibilityHint = "In Toolbox. Tap and then hold and drag to the right to add block to workspace."

        let myView = BlockView.init(frame: CGRect.init(x: 0, y: 0, width: blockWidth, height: blockWidth),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockWidth)
        
        cell.addSubview(myView)
        
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
            let myBlock = Block(name: sView.nameLabel.text!, color: sView.blockView.backgroundColor!, double: sView.block!.double, editable:sView.block!.editable, options: sView.block!.options, pickedOption: sView.block!.pickedOption, optionsLabels: sView.block!.optionsLabels)
            if(sView.block!.imageName != nil){
                myBlock?.addImage(sView.block!.imageName!)
            }
            if (myBlock?.double)!{
                let endBlockName = "End " + (myBlock?.name)!
                let endBlock = Block(name: endBlockName, color: (myBlock?.color)!, double: true, editable: false)
                endBlock?.counterpart = myBlock
                myBlock?.counterpart = endBlock
                ovum.dataObject = [myBlock, endBlock!]
            }else{
                ovum.dataObject = [myBlock]
            }
        }else{
            ovum.dataObject = sourceView.backgroundColor
        }
        return ovum
    }
    
    func createDragRepresentation(ofSourceView sourceView: UIView!, in window: UIWindow!) -> UIView! {
        if let sView = sourceView as? BlockTableViewCell{
            let frame = sView.convert(sView.blockView.bounds, to: sView.window)
            
            let dragView = UIView(frame: frame)
            let myView = BlockView.init(frame: CGRect.init(x: 0, y: 0, width: blockWidth, height: blockWidth), block: [sView.block!],  myBlockWidth: blockWidth, myBlockHeight: blockWidth)
            
            dragView.addSubview(myView)
            
            dragView.alpha = 0.75
            return dragView
        }
        
        return sourceView
    }
    
    
    func ovumDragEnded(_ ovum: OBOvum!) {
        return
    }

}
