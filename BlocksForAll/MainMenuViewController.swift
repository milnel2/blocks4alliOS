//
//  MainMenuViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 8/30/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    var blockSize = 150 /* this controls the size of the blocks you put down in the Building Screen */
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 11.0, *) {
            if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
                print("accessibility enabled")
                blockSize = 200
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBOutlet weak var blockSizeSlider: UISlider!
    @IBOutlet weak var sampleBlock: UIView!
    
	//MARK: - viewDidLoad function
	override func viewDidLoad() {
        super.viewDidLoad()
        blockSize = Int(blockSizeSlider.value)
        sampleBlock.frame = CGRect(x: Int(sampleBlock.frame.midX) - blockSize/2, y: Int(sampleBlock.frame.maxY) - blockSize, width: blockSize, height: blockSize)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        blockSize = Int(sender.value)
        sampleBlock.frame = CGRect(x: Int(sampleBlock.frame.midX) - blockSize/2, y: Int(sampleBlock.frame.maxY)-blockSize, width: blockSize, height: blockSize)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let myDestination = segue.destination as? BlocksViewController{
            myDestination.blockHeight = blockSize
            myDestination.blockWidth = blockSize
            print("block size " , blockSize)
        }
        if let destinationViewController = segue.destination as? UINavigationController{
            if let myTopViewController = destinationViewController.topViewController as? BlocksViewController{
                print("block size 2 " , blockSize)
            }
        }
        
    }
    

}
