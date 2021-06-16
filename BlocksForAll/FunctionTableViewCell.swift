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
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor(red: 1.0, green: CGFloat(60.0/255.0), blue: 0.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //button to rename functions
    let renameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rename", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor(red: 0.0, green: CGFloat(166.0/255.0), blue: 1.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //button for initial naming of function
    let nameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sample Function", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        //Same color as function blocks
        button.backgroundColor = UIColor(red: 1.0, green: CGFloat(147.0/255.0), blue: 0.0, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //organizes function name to be in center of row, rename and delete at end.
    func setUpViews(){
        addSubview(nameButton)
        addSubview(deleteButton)
        addSubview(renameButton)
        
        deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        nameButton.addTarget(self, action: #selector(nameFunction(sender:)), for: .touchUpInside)
        renameButton.addTarget(self, action: #selector(renameFunction(sender:)), for: .touchUpInside)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(80)]-8-[v2(80)]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameButton, "v1": renameButton, "v2": deleteButton]))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameButton]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": deleteButton]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": renameButton]))
    }

    @objc func deleteAction(sender: UIButton){
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



