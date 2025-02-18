//
//  SelectLocationModifierViewController.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/26/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

public struct LocationConstants {
    static let numRows = 4.0
    static let numCols = 7.0
}

/// View Controller for selecting a location for freeplay Move to Location Blocks. Show a grid of locations to select from
class SelectLocationModifierViewController: UIViewController  {
    
    let cellReuseIdentifier = "selectLocationCell"
    
    @IBOutlet weak var backButton: UIButton! // button to go back to the freeplay workspace
    
    @IBOutlet weak var modifierTitleLabel: UILabel! // label for top of screen
    
    @IBOutlet weak var collectionView: UICollectionView! // collection view to hold the grid of locations
    
    var currentProject: Project? {
        get {
            return UserData.data.getCurrentProject()
        }
    }
    
    var outputView: FreeplayOutputView? = nil // output view of the project currently editing. Its size is used to determine the size of the grid
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    var outputWidth = 0.0 // width of the output view associated with this project
    var outputHeight = 0.0 // height of the output view associated with this project
    
    var cellWidth = 0.0 // width of each grid cell
    var cellHeight = 0.0 // height of each grid cell
    
   
    let numRows = LocationConstants.numRows // number of rows the grid will have
    let numCols = LocationConstants.numCols // number of columns the grid will have
    
    var optionSelectedIndex = 0 // index of the cell currently selected
    
    public var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if outputView == nil {
            fatalError("Output view is nil")
        }
        
        // get the size of the output view
        let outputViewSize = outputView!.frame.size
        outputWidth = outputViewSize.width
        outputHeight = outputViewSize.height
        
        // set the collection view to be the same size as the output view from the workspace
        collectionView.addConstraint(NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: outputWidth))
        collectionView.addConstraint(NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: outputHeight))
        
        
        calculateCellSize()
        
        
        let centerCellIndex = SelectLocationModifierViewController.calculateCenterCellIndex()
        // Default option or preserve last selection
        let previousOption = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["cellIndex"] ?? String(centerCellIndex)
        
        if previousOption == "-1" { // if value is -1, that means that it is doing the default, so set it to center cell index
            optionSelectedIndex = centerCellIndex
        } else {
            optionSelectedIndex = Int(previousOption) ?? centerCellIndex
        }
       
        accessibilityElements = [backButton!, modifierTitleLabel!, collectionView!]
        
        collectionView.backgroundColor = #colorLiteral(red: 0.8588235294, green: 0.9490196078, blue: 1, alpha: 1)
    }
    /// Find the index of the center cell based on the number of rows and number of columns in the grid
    public static func calculateCenterCellIndex() -> Int{
        let centerCellIndex: Int
        let numRows = LocationConstants.numRows
        let numCols = LocationConstants.numCols
        if numRows.truncatingRemainder(dividingBy: 2) != 0 {
            centerCellIndex = Int((numRows * numCols - 1) / 2) // if there are an odd number of rows, just put it in the center
        } else {
            let rowToGoIn = Int(numRows / 2) - 1// go in the upper middle row
            let colToGoIn = Int(ceil(numCols / 2)) - 1 // go in the middle column
            centerCellIndex = (rowToGoIn * Int(numCols)) + colToGoIn
        }
        return centerCellIndex
    }
    
    /// calculate cell size based on the size of the grid and the number of rows and columns
    func calculateCellSize() {
        cellWidth = floor(outputWidth / numCols)
        cellHeight = floor(outputHeight / numRows)
    }
    
    // Given an index of a cell, returns a string of the coordinates associated with it on the output view
    func getCoordinatesFromCellIndex(index: Int) -> String{
        let row = SelectLocationModifierViewController.getRowFromCellIndex(index: index)
        let col = SelectLocationModifierViewController.getColumnFromCellIndex(index: index)
        
        let x = col * Int(cellWidth) + (Int(cellWidth) / 2)
        let y = row * Int(cellWidth) + (Int(cellHeight) / 2)
        
        return String("\(x),\(y)")
    }
    
    public static func getRowFromCellIndex(index: Int) -> Int {
        return index / Int(LocationConstants.numCols)
    }
    
    public static func getColumnFromCellIndex(index: Int) -> Int {
        return index % Int(LocationConstants.numCols)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Going back to freeplay workspace
        if let destination = segue.destination as? FreePlayWorkspaceViewController {
            
            let coords = getCoordinatesFromCellIndex(index: optionSelectedIndex)
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["moveToLocation"] = coords
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["cellIndex"] = String(optionSelectedIndex)
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["row"] = String(SelectLocationModifierViewController.getRowFromCellIndex(index: optionSelectedIndex) + 1)
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["column"] = String(SelectLocationModifierViewController.getColumnFromCellIndex(index: optionSelectedIndex) + 1)
        }
    }
    
   
}

extension SelectLocationModifierViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(numCols * numRows)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth , height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! LocationCollectionViewCell
        let index = indexPath.item  // numerical index of cell
        
        if index % 2 == 0 { // make a checkered pattern of cells
            cell.backgroundColor = .white
           
        } else {
            cell.backgroundColor = .lightGray
        }
        
        cell.backgroundColor = cell.backgroundColor!.withAlphaComponent(0.7) // make cell slightly transparent so you can see the background behind it // TODO: change so that the collectionView has a background image instead of just background color
        
        let cellRow = SelectLocationModifierViewController.getRowFromCellIndex(index: indexPath.item) + 1
        let cellColumn = SelectLocationModifierViewController.getColumnFromCellIndex(index: indexPath.item) + 1
        if indexPath.item == optionSelectedIndex {
            setCellHighlight(cell: cell, value: true)
           
            cell.accessibilityLabel = NSLocalizedString("Selected. Row \(cellRow) of \(numRows), Column \(cellColumn) of \(numCols).", comment: "Accessiblity Label for a selected cell in Select Location View Controller")
        } else {
            setCellHighlight(cell: cell, value: false)
            cell.accessibilityLabel = NSLocalizedString("Row \(cellRow) of \(numRows), Column \(cellColumn) of \(numCols).", comment: "Accessiblity Label for an unselected cell in Select Location View Controller")
        }
        
        cell.isAccessibilityElement = true
        
        cell.layer.frame.size = CGSize(width: cellWidth, height: cellHeight)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells{ // deselect all visible buttons
            setCellHighlight(cell: cell, value: false)
        }
        
        let selectedCell = collectionView.cellForItem(at: indexPath) // highlight the one selected button
        setCellHighlight(cell: selectedCell!, value: true)
        
        optionSelectedIndex = indexPath.item
        
    }
    
    func setCellHighlight(cell: UICollectionViewCell, value: Bool) {
        if value == true{
            cell.layer.borderWidth = 10
            cell.layer.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            cell.isSelected = true
            // TODO: add red X in the middle of the cell
        } else {
            cell.isSelected = false
            cell.layer.borderWidth = 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat { 0.0 } // change value to zero if you want to remove spacing.
    
   func collectionView(
       _ collectionView: UICollectionView,
       layout collectionViewLayout: UICollectionViewLayout,
       minimumInteritemSpacingForSectionAt section: Int
   ) -> CGFloat { 0.0 } // change value to zero if you want to remove spacing.
  
}

class LocationCollectionViewCell  : UICollectionViewCell {
    /* Custom cell class for the location choice buttons*/
    
    func updateAccessibilityTools() {
        fatalError("updateAccessibilityTools not implemented")
    }
}
