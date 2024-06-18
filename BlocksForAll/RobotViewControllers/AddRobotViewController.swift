//
//  AddRobotViewController.swift
//  BlocksForAll
//
//  Created by lmilne on 7/11/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//

import UIKit

class AddRobotViewController: UIViewController {
    var sentFromWorkspace = true
    
    var currentProject: Project?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if sentFromWorkspace{
            performSegue(withIdentifier: "robotMenuToWorkspace", sender: self)
        }else{
            performSegue(withIdentifier: "robotMenuToSettings", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BlocksViewController {
            destination.currentProject = currentProject
            destination.currentProject = currentProject
        }
    }
}
