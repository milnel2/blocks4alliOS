//
//  MainMenuViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 8/30/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    var blockSize = 100
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let myDestination = segue.destination as? BlocksViewController{
            print("block size " , blockSize)
            myDestination.blockWidth = blockSize
            myDestination.blockHeight = blockSize
        }
        if let destinationViewController = segue.destination as? UINavigationController{
            if let myTopViewController = destinationViewController.topViewController as? BlocksViewController{
                print("block size 2 " , blockSize)
                myTopViewController.blockWidth = blockSize
                myTopViewController.blockHeight = blockSize
            }
        }
        
    }
    

}
