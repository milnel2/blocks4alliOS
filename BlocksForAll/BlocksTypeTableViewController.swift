//
//  BlocksTypeTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/4/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BlocksTypeTableViewController: UITableViewController {
    /*Toolbox menu that allows you to select the block type*/
    
    var blockDict = NSArray()
    var blockTypes = [Block]()
    var indexToAdd = 0
    var blockSize = 150
    
    //used to pass on delegate to selectedBlockViewController
    var delegate: BlockSelectionDelegate?
    
    //MARK: - viewDidLoad function
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
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
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.font = UIFont.accessibleFont(withStyle: .title1, size: 29.0)
        cell.backgroundColor = blockType.color.uiColor
        //cell.bounds.height = 200
        cell.accessibilityLabel = blockType.name + " category"
        cell.accessibilityHint = "Double tap to explore blocks in this category"
        
        // add icon to the toolbox options
        // the icon should be roughly 80 x 80 pixels
        
        if cell.textLabel != nil {
            // only add the icon if dynamic text sizing is not being used
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
       
      
        //Makes label more intuitive for Voice Control
        if #available(iOS 13.0, *) {
            cell.accessibilityUserInputLabels = ["\(blockType.name)"]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(blockSize + 10)
        
    }
    
    //TODO: this is really convoluted, probably a better way of doing this
    private func createBlocksArray(){
        for item in blockDict{
            //for item in blockDict which is a NSArray that contains contents of BlocksMenu.plist
            if let blockType = item as? NSDictionary{
                // for every item blockType is a constant set to the item as a NSDictionary
                //initializes the block properities
                let name = blockType.object(forKey: "type") as? String
                let isModifiable = blockType.object(forKey: "isModifiable") as? Bool ?? false
                let double = blockType.object(forKey: "double") as? Bool ?? false
                var color = Color.init(uiColor:UIColor.green )
                if let colorString = blockType.object(forKey: "color") as? String{
                    color = Color.init(uiColor: UIColor.colorFrom(hexString: colorString))
                }
                guard let block = Block(name: name!, color: color, double: double, isModifiable: isModifiable) else {
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
            //if let blockCell = sender as?
            myDestination.typeIndex = tableView.indexPathForSelectedRow?.row
            myDestination.delegate = self.delegate
        }
    }
}


extension UIColor{
    static func colorFrom(hexString:String, alpha:CGFloat = 1.0)->UIColor{
        var rgbValue:UInt32 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 1 // bypass # character
        scanner.scanHexInt32(&rgbValue)
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8)/255.0
        let blue = CGFloat((rgbValue & 0x0000FF))/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
