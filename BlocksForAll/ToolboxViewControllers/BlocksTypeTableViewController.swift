//
//  BlocksTypeTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/4/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

/// The Toolbox menu that allows you to select the block type (e.g. sounds, drive, etc.).
class BlocksTypeTableViewController: UITableViewController {
    
    //MARK: Properties
    var blockDict = NSArray()  // A dictionary created from the BlocksMenu.
    var blockTypes = [Block]()  // A list of all the block types.
    var indexToAdd = 0  // Tracks which index of block has been added.
    var blockSize = 150  // Used to determine the position of the subviews.
    
    // Used to pass on delegate to selectedBlockViewController
    var delegate: BlockSelectionDelegate?
    
    //MARK: - viewDidLoad Function
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Toolbox"
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        }
        
        self.tableView.bounces = true
        
        self.accessibilityLabel = "Toolbox Menu"
        self.accessibilityHint = "Double tap from menu to select block category"
       
        blockDict = NSArray(contentsOfFile: Bundle.main.path(forResource: "BlocksMenu", ofType: "plist")!)!
        
        createBlocksArray()
        delegate?.setParentViewController(self.parent ?? self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "BlockTypeTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        // Configure the cell...
        let blockType = blockTypes[indexPath.row]
        cell.textLabel?.text = blockType.name
        if #available(iOS 13.0, *) {
            cell.textLabel?.textColor = UIColor.label
        } else {
            cell.textLabel?.textColor = UIColor.black
        }
        // Cell properties.
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 29.0)
        cell.backgroundColor = UIColor(named: "\(blockType.colorName)")
        cell.accessibilityLabel = blockType.name + " category"
        cell.accessibilityHint = "Double tap to explore blocks in this category"
        
        // Option to add an icon to the toollbox blocks.
        // The icon should be roughly 80 x 80 pixels.
        if cell.textLabel != nil {
            // Only adds the icon if dynamic text sizing is not being used.
            //TODO: check that this works on the larger IPad
            if cell.textLabel!.font.pointSize <= 34 {
                let imagePath = "\(blockType.name)Icon.pdf"
                let image = UIImage(named: imagePath)
                let imv: UIImageView

                imv = UIImageView.init(image: image)
                imv.layer.position.y = CGFloat(blockSize / 2)
                imv.layer.position.x = CGFloat((blockSize * 6) / 5)
                cell.addSubview(imv)
            }
        }
        
        // Makes the categories that Dot cannot use deactivate
        if dotRobotIsConnected {
            switch cell.textLabel?.text {
            case "Drive", "Motion":
                cell.backgroundColor = cell.backgroundColor?.withAlphaComponent(0.25)
                if #available(iOS 13.0, *) {
                    cell.accessibilityRespondsToUserInteraction = false
                }
                cell.isUserInteractionEnabled = false
            default:
                break
            }
        } else {
            switch cell.textLabel?.text {
            case "Drive", "Motion":
                cell.backgroundColor = cell.backgroundColor?.withAlphaComponent(1.0)
                if #available(iOS 13.0, *) {
                    cell.accessibilityRespondsToUserInteraction = true
                }
                cell.isUserInteractionEnabled = true
            default:
                break
            }
        }
       
        //Makes label more intuitive for Voice Control
        if #available(iOS 13.0, *) {
            cell.accessibilityUserInputLabels = ["\(blockType.name)"]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(blockSize + 10)
        
    }
    
    //MARK: - Create blocks array
    //TODO: this is really convoluted, probably a better way of doing this
    private func createBlocksArray() {
        for item in blockDict{
            // for item in blockDict which is a NSArray that contains contents of BlocksMenu.plist
            if let blockType = item as? NSDictionary{
                // for every item blockType is a constant set to the item as a NSDictionary
                // initializes the block properities
                let name = blockType.object(forKey: "type") as? String
                let isModifiable = blockType.object(forKey: "isModifiable") as? Bool ?? false
                let double = blockType.object(forKey: "double") as? Bool ?? false
                
                var color = "green_block"
                if let colorString = blockType.object(forKey: "color") as? String{
                    color = colorString
                }
                
                guard let block = Block(name: name!, colorName: color, double: double, isModifiable: isModifiable) else {
                    fatalError("Unable to instantiate block")
                }
                
                blockTypes += [block]
                // adds block to the array of blocks that are the different types used for automatically generating the toolbox UI components
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Letting destination controller know which blocks type was picked
        if let myDestination = segue.destination as? BlockTableViewController{
            myDestination.typeIndex = tableView.indexPathForSelectedRow?.row
            myDestination.delegate = self.delegate
        }
    }
}
