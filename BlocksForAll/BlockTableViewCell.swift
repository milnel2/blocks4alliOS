//
//  BlockTableViewCell.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AudioToolbox

/// The TableViewCell that contains the blocks in the Toolbox.
class BlockTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var blockView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var block: Block?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
