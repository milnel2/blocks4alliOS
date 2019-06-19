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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //From Drag and Drop
        //let manager = OBDragDropManager.shared()
        //manager?.prepareOverlayWindow(usingMainWindow: self.window)

        
        //OBDragDropManager *manager = [OBDragDropManager sharedManager];
        //[manager prepareOverlayWindowUsingMainWindow:self.window];
        
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
    
    /** This function saves each block in the superview as a json object cast as a String to a growing file. The function uses fileManager to be able to add and remove blocks from previous saves to stay up to date. **/
    
    func save(){
        let fileManager = FileManager.default
        //filename refers to the url found at "Blocks4AllSave.json"
        let filename = getDocumentsDirectory().appendingPathComponent("Blocks4AllSave.json")
        do{
            //Deletes previous save in order to rewrite for each save action (therefore, no excess blocks)
            try fileManager.removeItem(at: filename)
        }catch{
            print("couldn't delete")
        }
        
        // string that json text is appended too
        var writeText = String()
        /** block represents each block belonging to the global array of blocks in the workspace. blocksStack holds all blocks on the screen. **/
        for block in blocksStack{
            // sets jsonText to the var type json in block that takes a Data object
            if let jsonText = block.json {
                /** appends the data from jsonText in string form to the string writeText. writeText is then saved as a json save file **/
                writeText.append(String(data: jsonText, encoding: .utf8)!)
                
                /** Appending "\n Next Object \n" is meant to separate each encoded block's data in order to make it easier to fetch at a later time **/
                writeText.append("\n Next Object \n")
            }
            do{
                // writes the accumlated string of json objects to a single file
                try writeText.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            }catch {
                print("couldn't print json")
            }
        }
    }
    
    func load() {
        
    }
    
}

