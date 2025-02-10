//
//  FunctionTableViewCell.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/19/19.
//  Copyright © 2019 Mariella Page. All rights reserved.
//

import UIKit

// help from Brian Voong

class FunctionTableViewCell: UITableViewCell {
    /* This class creates the actual cells in the function table view controller. */

    var functionTableViewController: FunctionTableViewController?
    var function: String?
    
    // Buttons
    // Button to delete functions
    let deleteButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle("Delete".localized, for: .normal)
        button.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.sizeToFit()  // makes button wider with larger text
        
        button.backgroundColor = UIColor(red: 1.0, green: CGFloat(60.0/255.0), blue: 0.0, alpha: 1.0)  // Red
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // Button to rename functions
    let renameButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle(NSLocalizedString("Rename", comment: "Title for a rename function button"), for: .normal)
        button.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 26.0)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.sizeToFit()  // Makes button wider with larger text
        
        button.backgroundColor = UIColor(red: 0.0, green: CGFloat(166.0/255.0), blue: 1.0, alpha: 1.0)  // Blue
        button.setTitleColor(.white, for: .normal)
        
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // Button for initial naming of function
    let nameButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle(NSLocalizedString("Sample Function", comment: "Title for a button for a new function"), for: .normal)
        button.titleLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 28.0)
        button.backgroundColor = UIColor(named: "light_purple_block")
        // Allow for changing color based on dark/light mode
        if #available(iOS 13.0, *) {
            button.setTitleColor(.label, for: .normal)
        } else {
            button.setTitleColor(.black, for: .normal)
        }
        
        // Same color as function blocks
        button.layer.borderWidth = 2
        
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpViews(){
        // Add buttons to cell
        contentView.addSubview(nameButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(renameButton)
        
        // Add targets to the buttons
        deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
        nameButton.addTarget(self, action: #selector(nameFunction(sender:)), for: .touchUpInside)
        renameButton.addTarget(self, action: #selector(renameFunction(sender:)), for: .touchUpInside)
        
        // Organizes function name to be in center of row, rename and delete at end.
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1]-8-[v2]-8-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameButton, "v1": renameButton, "v2": deleteButton]))

        // Center buttons vertically in tableView cell (with padding)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": nameButton]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": deleteButton]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[v0]-5-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": renameButton]))
    }
    
    /// Called when delete button pressed
    @objc func deleteAction(sender: UIButton){
        functionTableViewController?.deleteCell(cell: self)
    }
    
    /// Called when name function button pressed
    @objc func nameFunction(sender: UIButton){
        functionTableViewController?.blockModifier(cell: self, sender: nil)
    }

    /// Called when rename function button pressed
    @objc func renameFunction(sender: UIButton){
        functionTableViewController?.renameCell(cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Configure the view for the selected state
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}



