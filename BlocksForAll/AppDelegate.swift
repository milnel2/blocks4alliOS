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
        var galleryTypePart = true
        
        var projectNamePart = true
        var projectImageNamePart = true
        
        var actorNamePart = true
        var actorImageNamePart = true
        
        var functionNamePart = true
        
       
        // used to see if the section being parsed/decoded is the name of a function
        var functionsDictFromSave: [String : [Block] ] = [:]
        // used to store the loaded stuff and later normal functionsDict is set to the from save version
        do{
            let jsonString = try String(contentsOf: getDocumentsDirectory().appendingPathComponent("Blocks4AllSave2.json"))
           //  creates a string type of the entire json file
            
            let galleryTypeStrings = jsonString.components(separatedBy: "New Gallery Type \n")
            for galleryTypeString in galleryTypeStrings {
                if galleryTypeString == "" {
                    continue
                }
                galleryTypePart = true
                var galleryType = String()
                
                let projectStrings = galleryTypeString.components(separatedBy: "New Project \n")
                
                for line in projectStrings[0].components(separatedBy: "\n") {
                    if galleryTypePart {
                        galleryTypePart = false
                        galleryType = line
                    }
                }
                for projectString in projectStrings[1...] {
                    if projectString == "" {
                        continue
                    }
                    
                    //for every new project set these to true again so that the new project will be named and an image name will be saved
                    projectNamePart = true
                    projectImageNamePart = true
                    
                    var projectName = String()
                    var projectImageName = String()
                  //  var projectFunctionDict: [String : [Block] ] = [:]
                    
                    let actorStrings = projectString.components(separatedBy: "New Actor \n")
                    
                    // the first element of actorStrings will have the project image and name data
                    for line in actorStrings[0].components(separatedBy: "\n") {
                        if !projectNamePart && projectImageNamePart {
                            projectImageNamePart = false
                            projectImageName = line
                        } else if projectNamePart && projectImageNamePart {
                            projectNamePart = false
                            projectName = line
                        } else {
                            continue
                        }
                    }
                    
                    var actorsFromSave: [VirtualRobot] = []
                    for actorString in actorStrings[1...] {
                        if actorString == "" {
                            continue
                        }
                        
                        //for every new actor set these to true again so that the new actor will be named
                        actorNamePart = true
                        actorImageNamePart = true
                        
                        var actorName = String()
                        var actorImageName = String()
                        
                       
                        
                        let functionStrings = actorString.components(separatedBy: "New Function \n")
                        
                        // the first element of functionStrings will have the project image and name data
                        for line in functionStrings[0].components(separatedBy: "\n") {
                            if !actorNamePart && actorImageNamePart {
                                actorImageNamePart = false
                                actorImageName = line
                                print("actor image name = ", actorImageName)
                            } else if actorNamePart && actorImageNamePart {
                                actorNamePart = false
                                actorName = line
                                print("actor name = ", actorName)
                            } else {
                                continue
                            }
                        }
                        
                        let robot = VirtualRobot(imagePath: actorImageName, name: actorName)
                        
                        for functionString in functionStrings[1...] {
                            if functionString == "" {
                                continue
                            }
                            
                            //for every new function set this to true again so that the new function will be named
                            functionNamePart = true
                            
                            var functionBlockStack = [Block]() // temporary function blockStack
                            var functionName = String()
                            let jsonObjs = functionString.components(separatedBy: "\n Next Object \n")
                            for object in jsonObjs{
                               
                                if object == "" {
                                   // this covers empty strings at beginings and ends
                                   continue
                                   // same as i++
                               }
                                
                                if functionNamePart {
                                    // if the current object is supposed to be the name then
                                    functionName = object
                                    // set the function name to the current object
                                    functionNamePart = false
                                    // set function name to false until next function is being decoded/parsed
                                } else {
                                    let jsonObject = object.data(using: .utf8)  // this takes the object as a string and turns it into a data object named jsonPart
                                    let blockBeingCreated = try? JSONDecoder().decode(Block.self, from: jsonObject!)  // this is the block being made
                                    
                                    if blockBeingCreated != nil {
                                        // adds the created block to the array of blocks that will later be set to the array of blocks for the current function
                                        functionBlockStack.append(blockBeingCreated!)
                                    }
                                }
                                
                                // TODO: update this comment
                                //adds current function to the functionsDict from save includes name and [Block]
                               
                                
                                functionsDictFromSave[functionName] = functionBlockStack
                                
                                 
                            }
                            robot.functionDict[functionName] = functionBlockStack
                            
                        }
                        
                        
                        actorsFromSave.append(robot)
                    }
                    
                    //adds proper counterparts
                    ifAndRepeatCounterparts(functionBlocksDictCounter: functionsDictFromSave)
                    
                    //TODO: update this?
                    if functionsDictFromSave["Main Workspace"] == nil{
                        functionsDictFromSave["Main Workspace"] = []
                    }
                    
                    let project = Project(name: projectName, imageName: projectImageName, actors: actorsFromSave)
                    
                    // saves a project to the global var allProjects
                    allProjects[galleryType]!.append(project)
//                    allProjects[galleryType]!.append(Project(name: projectName, imageName: projectImageName, functionDict: functionsDictFromSave))
                }
            }
            
            print("load completed")
        }catch{
            print("load failed")
            /*allProjects["Robot Projects"] = [Project(name: "Empty Project", imageName: "", functionDict:["Main Workspace": []])]*/ // TODO: handle if there are no projects
            allProjects["Robot Projects"] = [Project(name: "Empty Project", imageName: "")]
        }
        // sets current workspace to main workspace so you don't load and wind up on a random function screen
        currentWorkspace = "Main Workspace"
    }


    // TODO: check that this method still works
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
            print("couldn't delete previous Blocks4AllSave2. Error = ", error)
        }
        
        
        // string that json text is appended to
        var writeText = String()
      
        for galleryType in allProjects.keys {
            writeText.append("New Gallery Type \n")
            writeText.append(galleryType)
            writeText.append("\n")
            for project in allProjects[galleryType]! {
                writeText.append("New Project \n")
                writeText.append(project.name)
                writeText.append("\n")
                writeText.append(project.imageName)
                writeText.append("\n")
               
                //TODO: fix this to work with physical robot and custom functions
                for actor in project.actors {
                    writeText.append("New Actor \n")
                    writeText.append(actor.name)
                    writeText.append("\n")
                    writeText.append(actor.imagePath)
                    writeText.append("\n")
                    
                    let funcNames = actor.functionDict.keys
                    //gets all the function names in functionsDict as an array of strings
                    for name in funcNames{
                    // for all functions
                        writeText.append("New Function \n")
                        writeText.append(name)
                        //adds name of function immediately after the new function and prior to the next object so that it can be parsed same way as blocks
                        writeText.append("\n Next Object \n")
                        // allows name to be handled in load at the same time as blocks
                        for block in actor.functionDict[name]!{
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
                
            
                do{
                    // do a final write to the file. Needs to happen one last time just in case the workspace was empty
                    try writeText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                    // writes the accumlated string of json objects to a single file
                }catch{
                    print("couldn't write save to file. Error = ", error)
                }
            }
        }
        print(writeText)
    }
}

