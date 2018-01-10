//
//  BlocksTypeTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/4/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BlocksTypeTableViewController: UITableViewController {
    
    var blockDict = NSArray()
    var blockTypes = [Block]()
    var indexToAdd = 0
    var blockWidth = 150
    
    //used to pass on delegate to selectedBlockViewController
    var delegate: BlockSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Toolbox"
        self.accessibilityLabel = "Toolbox Menu"
        self.accessibilityHint = "Double tap from menu to select block category"
        //self.tableView.frame = CGRect(x: self.tableView.frame.minX, y: self.tableView.frame.minY, width: CGFloat(blockWidth), height: CGFloat(blockWidth))
        
        blockDict = NSArray(contentsOfFile: Bundle.main.path(forResource: "BlocksMenu", ofType: "plist")!)!
        
        createBlocksArray()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        cell.backgroundColor = blockType.color
        //cell.bounds.height = 200
        cell.accessibilityLabel = blockType.name + " category"
        cell.accessibilityHint = "Double tap to explore blocks in this category"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(blockWidth + 10)

    }
    
    //TODO: this is really convoluted, probably a better way of doing this
    private func createBlocksArray(){
        for item in blockDict{
            if let blockType = item as? NSDictionary{
                let name = blockType.object(forKey: "type") as? String
                var color = UIColor.green
                if let colorString = blockType.object(forKey: "color") as? String{
                    color = UIColor.colorFrom(hexString: colorString)
                }
                guard let block = Block(name: name!, color: color, double: false, editable: false) else {
                    fatalError("Unable to instantiate block")
                }
                blockTypes += [block]
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
