//
//  FreePlayWorkspaceViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/7/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class FreePlayWorkspaceViewController:  BlocksViewController {
    
    
    @IBOutlet weak var currentActorImageView: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        currentActorImageView.alpha = 0.3
    }
}
