//
//  SelectedBlockViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 6/1/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class SelectedBlockViewController: UIViewController {
    
    var blocks: [Block]?
    var blockWidth = 100
    let blockHeight = 100
    let blockSpacing = 1
    var delegate: BlockSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.accessibilityLabel = "Cancel"
        
        let myFrame = CGRect(x: 0, y: Int(self.view.bounds.height/2), width: 0, height: 0)
        
        
        let myBlockView = BlockView.init(frame: myFrame, block: blocks!, myBlockWidth: blockWidth, myBlockHeight: blockHeight)
        
        self.view.addSubview(myBlockView)

        // Do any additional setup after loading the view.
        let label = (blocks?[0].name)! + " selected. Select location in workspace to place it"
        
        self.view.isAccessibilityElement = true
        self.view.accessibilityLabel = label
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.view)
        
        delegate?.setSelectedBlocks(blocks!)
        delegate?.setParentViewController(self.parent!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            // view controller is popping
            delegate?.unsetBlocks()
        }
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
