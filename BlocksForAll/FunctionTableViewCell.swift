//
//  FunctionTableViewCell.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/19/19.
//  Copyright © 2019 Mariella Page. All rights reserved.
//

import UIKit

//help from Brian Voong
//this class creates the actual cells in the function table view controller.
class FunctionTableViewCell: UITableViewCell {

    var functionTableViewController: FunctionTableViewController?
    var function: String?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var functionView: FunctionView!
    
    //button to delete functions
    let deleteButton: CustomButton = {
        let button = CustomButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.sizeToFit()    //makes button wider with larger text
        
        button.backgroundColor = UIColor(red: 1.0, green: CGFloat(60.0/255.0), blue: 0.0, alpha: 1.0)    //red
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    //button to rename functions
    let renameButton: CustomButton = {
        let button = CustomButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle("Rename", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        button.sizeToFit()   //makes button wider with larger text
        
        button.backgroundColor = UIColor(red: 0.0, green: CGFloat(166.0/255.0), blue: 1.0, alpha: 1.0)   //blue
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    //button for initial naming of function
    let nameButton: CustomButton = {
        let button = CustomButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle("Sample Function", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        
        button.backgroundColor = UIColor(red: 1.0, green: CGFloat(147.0/255.0), blue: 0.0, alpha: 1.0)    //Same color as function blocks
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    func setUpViews(){
        contentView.addSubview(nameButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(renameButton)
        
        deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        nameButton.addTarget(self, action: #selector(nameFunction(sender:)), for: .touchUpInside)
        renameButton.addTarget(self, action: #selector(renameFunction(sender:)), for: .touchUpInside)
        
        //organizes function name to be in center of row, rename and delete at end.
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1]-8-[v2]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameButton, "v1": renameButton, "v2": deleteButton]))

        //Center buttons vertically in tableView cell (with padding)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameButton]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": deleteButton]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": renameButton]))
    }

    @objc func deleteAction(sender: UIButton){
        // Declare Alert message
//        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
//
//        // Create Yes button with action handler
//        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
//             print("yes button tapped")
//             self.delete(<#T##sender: Any?##Any?#>)
//        })
//
//        // Create Cancel button with action handlder
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
//            print("Cancel button tapped")
//        }
//        //Add OK and Cancel button to dialog message
//        dialogMessage.addAction(yes)
//        dialogMessage.addAction(cancel)
//
//        // Present dialog message to user
//        self.present(dialogMessage, animated: true, completion: nil)
        
        print("tapped")
        functionTableViewController?.deleteCell(cell: self)
        
    }

    @objc func nameFunction(sender: UIButton){
        print("tapped")
        functionTableViewController?.blockModifier(cell: self, sender: nil)
    }

    @objc func renameFunction(sender: UIButton){
        print("tapped")
        functionTableViewController?.renameCell(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}



