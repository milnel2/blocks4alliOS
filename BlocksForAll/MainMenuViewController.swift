//
//  MainMenuViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 8/30/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBAction func load(_ sender: Any) {
        print("load save called")
        
        var blockStackFromSave: [Block] = []
        //array of blocks loaded from the save
        
        do{
            let jsonString = try String(contentsOf: filename)
            // creates a string type of the entire json file
            let jsonStrings = jsonString.components(separatedBy: "\n Next Object \n")
            // the string of the json file parsed out into each object in the file
            
            for part in jsonStrings {
                // for each json object in the array of json objects as strings
                if part == "" {
                    break
                }
                // this covers the last string parsed out that's just a new line
                let jsonPart = part.data(using: .utf8)
                // this takes the json object as a string and turns it into a data object named jsonPart
                let blockBeingCreated = Block(json: jsonPart!)
                // this is the block being made, it's created using the block initializer that takes a data format json
                blockStackFromSave.append(blockBeingCreated!)
                // adds the created block to the array of blocks that will later be set to the blocksStack
            }
            
            ifAndRepeatCounterparts(blockStackFromSave)
            blocksStack = blockStackFromSave
            // blockStackFrom save is array of blocks created from save file in this function, sets it to the global array of blocks used
            print("load completed")
        }catch{
            print("load failed")
        }
    }
        
        func ifAndRepeatCounterparts(_ aBlockStack: [Block]){
            var forOpen: [Block] = []
            //array of all of the "Repeat" blocks but not the "End Repeat" blocks
            var ifOpen: [Block] = []
            //array of all of the "If" blocks but not the "End Repeat" blocks
            for block in aBlockStack{
                // iterates through the blocks in the array created from the save, goal is to assign counterparts to all of the For and If statements
                if block.name == "Repeat"{
                    forOpen.append(block)
                    //adds "For" statements to an array
                }else if block.name == "End Repeat"{
                    forOpen.last?.counterpart = block
                    block.counterpart = forOpen.last
                    // matches the repeat start to the counter part repeat end
                    forOpen.removeLast()
                    // removes the open block that was matched to a close block
                }else if block.name == "If"{
                    //mirrors for loop stuff
                    ifOpen.append(block)
                }else if block.name == "End If"{
                    ifOpen.last?.counterpart = block
                    block.counterpart = ifOpen.last
                    ifOpen.removeLast()
                }
            }
        }
        
        // from Paul Hegarty, lectures 13 and 14
    func getDocumentsDirectory() -> URL{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
    }
        // gets the path for the sandbox we're in
        
    lazy var filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
        // global var for the location of the save file

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
