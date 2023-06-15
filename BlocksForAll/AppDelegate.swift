//
//  AppDelegate.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //From Drag and Drop
        //let manager = OBDragDropManager.shared()
        //manager?.prepareOverlayWindow(usingMainWindow: self.window)

        
        //OBDragDropManager *manager = [OBDragDropManager sharedManager];
        //[manager prepareOverlayWindowUsingMainWindow:self.window];
        currentWorkspace = "Main Workspace"
        load()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        save()
        
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        save()
    }
    
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
            let jsonString = try String(contentsOf: getDocumentsDirectory().appendingPathComponent("Blocks4AllSave2.json"))
            //print(jsonString)
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
                let jsonObjs = function.components(separatedBy: "\n Next Object \n")

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
            if functionsDictFromSave["Main Workspace"] == nil{
                functionsDictFromSave["Main Workspace"] = []
            }
            functionsDict = functionsDictFromSave
            // sets global functionsDict to the functionsDictFrom Save


            print("load completed")
        }catch{
            print("load failed")
            functionsDict["Main Workspace"] = []
        }
        // sets current workspace to main workspace so you don't load and wind up on a random function screen
        currentWorkspace = "Main Workspace"
    }


    func ifAndRepeatCounterparts(functionBlocksDictCounter: [String : [Block]]){
        var forOpen: [Block] = []
        //array of all of the "Repeat" blocks but not the "End Repeat" blocks
        var ifOpen: [Block] = []
        //array of all of the "If" blocks but not the "End If" blocks
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
                case "End If":
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
                default: break
                }
        }

        }
    }
    
    /// Saves each block as a json object cast as a String to a file. Uses fileManager to add and remove blocks from previous saves to stay up to date.
    func save(){
        let fileManager = FileManager.default

        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave2.json")
        do{
            //Deletes previous save in order to rewrite for each save action
            try fileManager.removeItem(at: filename)
        }catch{
            print("couldn't delete previous Blocks4AllSave2")
        }

        // string that json text is appended too
        var writeText = String()
        /** block represents each block belonging to the global array of blocks in the workspace. blocksStack holds all blocks on the screen. **/
        let funcNames = functionsDict.keys
        //gets all the function names in functionsDict as an array of strings

        for name in funcNames{
        // for all functions
            writeText.append("New Function \n")
            writeText.append(name)
            //adds name of function immediately after the new function and prior to the next object so that it can be parsed same way as blocks
            writeText.append("\n Next Object \n")
            // allows name to be handled in load at the same time as blocks
            for block in functionsDict[name]!{
                // for block in the current fuctionsDict function's array of blocks
                if let jsonText = block.jsonVar{
                    // sets jsonText to block.jsonVar which removes counterparts so it doesn't wind up with an infite amount of counterparts
                    writeText.append(String(data: jsonText, encoding: .utf8)!)
                    //adds the jsonText as .utf8 as a string to the writeText string
                    writeText.append("\n Next Object \n")
                    //marks next object
                }
                do{
                    try writeText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                    // writes the accumlated string of json objects to a single file
                }catch{
                    print("couldn't create json for", block)
                }
            }
        }
    }
}

