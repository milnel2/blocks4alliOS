//
//  MainMenuViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 8/30/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    // from Paul Hegarty, lectures 13 and 14
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func load() {
        
// THE CODE BELOW IS TO DELTE PREVIOUS SAVE
//        let fileManager = FileManager.default
//        //filename refers to the url found at "Blocks4AllSave.json"
//        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
//        do{
//            //Deletes previous save in order to rewrite for each save action (therefore, no excess blocks)
//            try fileManager.removeItem(at: filename)
//        }catch{
//            print("couldn't delete save")
//        }
// THE CODE ABOVE IS TO DELETE PREVIOUS SAVE
        
        
        print("load save called")
        var functionNamePart = true
        // used to see if the section being parsed/decoded is the name of a function
        var functionsDictFromSave: [String : [Block] ] = [:]
        // used to store the loaded stuff and later normal functionsDict is set to the from save version
        do{
            let jsonString = try String(contentsOf: getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json"))
            // creates a string type of the entire json file
            let functionStrings = jsonString.components(separatedBy: "New Function \n")
            // the string of the json file parsed out into each function in the file
            
            for function in functionStrings {
                // for each function in the array of functions
                if function == "" {
                    continue
                }
                functionNamePart = true
                //for every new function set this to true again so that the new function will be named
                var functionBlockStack = [Block]()
                // temporary function blockStack
                var functionName = String()
                var jsonObjs = function.components(separatedBy: "\n Next Object \n")
                
                for object in jsonObjs{
                    if object == "" {
                        // this covers empty strings at beginings and ends
                        continue
                        // same as i++
                    }
                    if functionNamePart{
                        // if the current object is supposed to be the name then
                        functionName = object
                        // set the function name to the current object
                        functionNamePart = false
                        // set function name to false until next function is being decoded/parsed
                    }else{
                        let jsonObject = object.data(using: .utf8)
                        // this takes the object as a string and turns it into a data object named jsonPart
                        let blockBeingCreated = try? JSONDecoder().decode(Block.self, from: jsonObject!)
                        // this is the block being made
                        functionBlockStack.append(blockBeingCreated!)
                        // adds the created block to the array of blocks that will later be set to the array of blocks for the current function
                    }
                    functionsDictFromSave[functionName] = functionBlockStack
                    //addes current function to the functionsDict from save includes name and [Block]
                }
            }
            ifAndRepeatCounterparts(functionBlocksDictCounter: functionsDictFromSave)
            //adds proper counterparts
            functionsDict = functionsDictFromSave
            // sets global functionsDict to the functionsDictFrom Save
            print("load completed")
        }catch{
            print("load failed")
            functionsDict["Main Workspace"] = []
            currentWorkspace = "Main Workspace"
        }
        // sets current workspace to main workspace so you don't load and wind up on a random function screen
        currentWorkspace = "Main Workspace"
    }
    
    
    func ifAndRepeatCounterparts(functionBlocksDictCounter: [String : [Block]]){
        var forOpen: [Block] = []
        //array of all of the "Repeat" blocks but not the "End Repeat" blocks
        var ifOpen: [Block] = []
        //array of all of the "If" blocks but not the "End Repeat" blocks
        var ifElseOpen: [Block] = []
        //array of all of the If-Else blocks
        let functions = functionBlocksDictCounter.keys
        
        for function in functions{
            for block in functionBlocksDictCounter[function]!{
                // iterates through the blocks in the array created from the save, goal is to assign counterparts to all of the For and If statements
                switch block.name{
                case "If":
                    //mirrors for loop stuff
                    ifOpen.append(block)
                case "End if":
                    ifOpen.last?.counterpart.append(block)
                    block.counterpart.append(ifOpen.last ?? block)
                    ifOpen.removeLast()
                case "Repeat", "Repeat Forever":
                    forOpen.append(block)
                //adds "For" statements to an array
                case "End Repeat", "End Repeat Forever":
                    forOpen.last?.counterpart.append(block)
                    block.counterpart.append(forOpen.last ?? block)
                    // matches the repeat start to the counter part repeat end
                    forOpen.removeLast()
                // removes the open block that was matched to a close block
                case "If Else":
                    ifElseOpen.append(block)
                case "End If Else":
                    ifElseOpen.append(block)
                    ifElseOpen.last?.counterpart.append(block)
                    block.counterpart.append(ifElseOpen.last ?? block)
                    ifElseOpen.removeLast()
                default:
                    print("hello")
                }
        }
        
        
            
//            if block.name == "Repeat" || block.name == "Repeat Forever"{
//                forOpen.append(block)
//                //adds "For" statements to an array
//            }else if block.name == "End Repeat" || block.name == "End Repeat Forever"{
//                forOpen.last?.counterpart.append(block)
//                block.counterpart.append(forOpen.last ?? block)
//                // matches the repeat start to the counter part repeat end
//                forOpen.removeLast()
//                // removes the open block that was matched to a close block
//            }else if block.name == "If"{
//                //mirrors for loop stuff
//                ifOpen.append(block)
//            }else if block.name == "End If"{
//                ifOpen.last?.counterpart.append(block)
//                block.counterpart.append(ifOpen.last ?? block)
//                ifOpen.removeLast()
//            }
        }
    }
    
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
    
    
    @IBAction func loadFromAddRobots(_ sender: Any) {
        load()
    }
    @IBAction func loadFromGetStarted(_ sender: Any) {
        load()
    }
    
    

}
