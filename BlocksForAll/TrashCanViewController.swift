//
//  TrashCanViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/3/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class TrashCanViewController: UIViewController, OBDropZone {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.dropZoneHandler = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Drag and Drop Methods
    
    func ovumEntered(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) -> OBDropAction {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString("Trashcan", comment: ""))
        return OBDropAction.copy//OBDragActionCopy
    }
    
    func ovumDropped(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
        print("Trashed")
        //probably a better way of doing this: refactor
        let subviews = view.superview?.subviews
        for item in subviews!{
            if item.isKind(of: UICollectionView.classForCoder()){
                print("Yeehaw")
            }
        }
        
        if let block = ovum.dataObject as? Block{
            
            //check if you are moving block from workspace, remove from blocksStack, push everything back
           /* if(indexOfCurrentBlock >= 0){
                blocksStack.remove(at: indexOfCurrentBlock)
                blocksProgram.performBatchUpdates({
                    //TODO: Do i need to delete anything from subviews?
                    self.blocksProgram.deleteItems(at: [IndexPath.init(row: self.indexOfCurrentBlock, section: 0)])
                }, completion: nil)
                
            }
            indexOfCurrentBlock = -1*/
            
        }
        
    }
    
    func ovumExited(_ ovum: OBOvum!, in view: UIView!, atLocation location: CGPoint) {
        self.view.backgroundColor = UIColor.white
    }
    

}
