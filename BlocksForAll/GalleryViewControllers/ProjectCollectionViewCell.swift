//
//  WorkspaceCollectionView.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/12/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class ProjectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var projectNameLabel: UILabel!
   
    @IBOutlet weak var renameButton: UIButton!
    
    @IBOutlet weak var openButton: UIButton!
    
    var project : Project! {
       didSet {
           self.updateUI()
       }
   }
    func updateUI() {
            
        if let project = project {
           imageView.image = UIImage(named:project.imageName)
           projectNameLabel.text = project.name
           //details.text = course.details
           //colorView.backgroundColor = course.color
        } else {
           imageView.image = nil
           projectNameLabel.text = nil
           //details.text = nil
           //colorView.backgroundColor = nil
        }
      
        imageView.layer.cornerRadius = 10.0
        imageView.layer.masksToBounds = true
       
           openButton.layer.cornerRadius = 10
       }
       
    @IBAction func openButtonPressed(_ sender: Any) {
        //print("superView", self.superview?.)
    }
    @IBAction func renameButtonPressed(_ sender: Any) {
    }
    
}
