//
//  BlocksTypeTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/4/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import SwiftUI

// Make stripe pattern for blocks in toolbox that are unavailable for Dot robots
// From https://stackoverflow.com/questions/39182041/how-to-fill-a-uiview-with-an-alternating-stripe-pattern-programmatically-using-s

extension UIColor {
    
    /// make a diagonal striped pattern
    func patternStripes(color2: UIColor = .white, barThickness t: CGFloat = 25.0) -> UIColor {
        let dim: CGFloat = t * 2.0 * sqrt(2.0)

        let img = UIGraphicsImageRenderer(size: .init(width: dim, height: dim)).image { context in

            // rotate the context and shift up
            context.cgContext.rotate(by: CGFloat.pi / 4.0)
            context.cgContext.translateBy(x: 0.0, y: -2.0 * t)

            let bars: [(UIColor,UIBezierPath)] = [
                (self,  UIBezierPath(rect: .init(x: 0.0, y: 0.0, width: dim * 2.0, height: t))),
                (color2,UIBezierPath(rect: .init(x: 0.0, y: t, width: dim * 2.0, height: t)))
            ]

            bars.forEach {  $0.0.setFill(); $0.1.fill() }
            
            // move down and paint again
            context.cgContext.translateBy(x: 0.0, y: 2.0 * t)
            bars.forEach {  $0.0.setFill(); $0.1.fill() }
        }
        
        return UIColor(patternImage: img)
    }
}


/// The Toolbox menu that allows you to select the block type (e.g. sounds, drive, etc.).
class BlocksTypeTableViewController: UITableViewController {
    
    //MARK: Properties
    var blockDict = NSArray()  // A dictionary created from the BlocksMenu.
    var blockTypes = [Block]()  // A list of all the block types.
    var indexToAdd = 0  // Tracks which index of block has been added.
    var blockSize = 150  // Used to determine the position of the subviews.
    
    // Used to pass on delegate to selectedBlockViewController
    var delegate: BlockSelectionDelegate?
    var currentProject: Project? = nil
   
    
    //MARK: - viewDidLoad Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Toolbox"
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
            self.shouldGroupAccessibilityChildren = true
        }
        
        self.tableView.bounces = true
        
        self.accessibilityLabel = "Toolbox Menu"
        self.accessibilityHint = "Double tap from menu to select block category"
       
        
        if isInFreeplay {
            blockDict = NSArray(contentsOfFile: Bundle.main.path(forResource: "FreeplayBlocksMenu", ofType: "plist")!)!
            self.navigationController?.isNavigationBarHidden = true
        } else {
            blockDict = NSArray(contentsOfFile: Bundle.main.path(forResource: "BlocksMenu", ofType: "plist")!)!
            self.navigationController?.isNavigationBarHidden = false
        }
       
        
        createBlocksArray()
        delegate?.setParentViewController(self.parent ?? self)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isInFreeplay {
            self.navigationController?.isNavigationBarHidden = true
        } else {
            self.navigationController?.isNavigationBarHidden = false
        }
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
            if cell.textLabel!.font.pointSize <= 34 && !isInFreeplay{ // TODO: make icons work in freeplay mode
                let imagePath = "\(blockType.name)Icon.pdf"
                let image = UIImage(named: imagePath)
                let imv: UIImageView

                imv = UIImageView.init(image: image)
                imv.layer.position.y = CGFloat(blockSize / 2)
                imv.layer.position.x = CGFloat((blockSize * 6) / 5)
                cell.addSubview(imv)
            }
        }
        
    
       
        //Makes label more intuitive for Voice Control
        if #available(iOS 13.0, *) {
            cell.accessibilityUserInputLabels = ["\(blockType.name)"]
        }
        cell.selectionStyle = .none // TODO: if the selection style is not none, the selected cell stays gray after navigating back to it
        
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
                
                  // Makes the categories that Dot cannot use deactivate
                if numDotsConnected > 0 && numDotsConnected == connectedRobots.count && (block.name == "Drive" || block.name == "Motion") { // all connected robots are Dots
                      // TODO make this a property of the block instead
                    print("Not allowed on Dot: ", block.name)
                     
                    
                    // don't add the category

                  } else {
                      blockTypes += [block]
                      // adds block to the array of blocks that are the different types used for automatically generating the toolbox UI components
                  }
                
                
               
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
            myDestination.currentProject = currentProject
            
        }
    }
}
