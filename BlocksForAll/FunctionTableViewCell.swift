//
//  FunctionTableViewCell.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/19/19.
//  Copyright © 2019 Mariella Page. All rights reserved.
//

import UIKit

//help from Brian Voong
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
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let renameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rename", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let nameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sample Function", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    func setUpViews(){
        addSubview(nameButton)
        addSubview(deleteButton)
        addSubview(renameButton)
        
        deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        nameButton.addTarget(self, action: #selector(nameFunction(sender:)), for: .touchUpInside)
        renameButton.addTarget(self, action: #selector(renameFunction(sender:)), for: .touchUpInside)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(80)]-8-[v2(80)]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameButton, "v1": renameButton, "v2": deleteButton]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameButton]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": deleteButton]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": renameButton]))
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



