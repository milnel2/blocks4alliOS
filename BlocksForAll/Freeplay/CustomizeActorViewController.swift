//
//  CustomizeActorViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 7/1/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class CustomizeActorViewController: UIViewController {
    
    var currentActor: VirtualRobot? = nil
    var currentProject: Project? = nil
    var freeplayWorkspace: FreePlayWorkspaceViewController? = nil
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        freeplayWorkspace!.deleteActor(actor: currentActor!)
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // pass back data to freeplay workspace
        if let destination = segue.destination as? FreePlayWorkspaceViewController {
            destination.currentProject = currentProject
            
        }
    }
    
}
