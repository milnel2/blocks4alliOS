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
class SelectLocationModifierViewController: UIViewController  {
    
    let cellReuseIdentifier = "selectLocationCell"
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var modifierTitleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentProject: Project? = nil
    
    var outputView: FreeplayOutputView? = nil
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "backToFreeplay", sender: nil)
    }
    
    var outputWidth = 0.0
    var outputHeight = 0.0
    
    var cellWidth = 0.0
    var cellHeight = 0.0
    
   
    let numRows = LocationConstants.numRows
    let numCols = LocationConstants.numCols
    
    var optionSelectedIndex = 0
    public var modifierBlockIndexSender: Int? // used to know which modifier block was clicked to enter this screen. It is public because it is used by BlocksViewController as well
    
    
    var visual = CGRect()
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if outputView == nil {
            fatalError("Output view is nil")
        }
        
        let outputViewSize = outputView!.frame.size
        outputWidth = outputViewSize.width
        outputHeight = outputViewSize.height
        
       // collectionView.frame.size = outputViewSize
        
        collectionView.addConstraint(NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: outputWidth))
        collectionView.addConstraint(NSLayoutConstraint(item: collectionView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: outputHeight))
        
        calculateCellSize()
        
        
        
        let centerCellIndex = SelectLocationModifierViewController.calculateCenterCellIndex()
        // Default option or preserve last selection
        var previousOption = currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["cellIndex"] ?? String(centerCellIndex)
        
        if previousOption == "-1" { // if value is -1, that means that it is doing the default, so set it to center cell index
            optionSelectedIndex = centerCellIndex
        } else {
            optionSelectedIndex = Int(previousOption) ?? centerCellIndex
        }
               
    }
    
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
    
    func calculateCellSize() {
        cellWidth = floor(collectionView.layer.frame.width / numCols)
        cellHeight = floor(collectionView.layer.frame.height / numRows) * 0.925
    }
    
    func getCoordinatesFromCellIndex(index: Int) -> String{
        let row = index / Int(numCols)
        let col = index % Int(numCols)
        
        let x = col * Int(cellWidth) + (Int(cellWidth) / 2)
        let y = row * Int(cellWidth) + (Int(cellHeight) / 2)
        
        return String("\(x),\(y)")
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // Going back to freeplay workspace
        if let destination = segue.destination as? FreePlayWorkspaceViewController {
            destination.currentProject = currentProject
            
            let coords = getCoordinatesFromCellIndex(index: optionSelectedIndex)
            print("setting coords: ", coords)
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["moveToLocation"] = coords
            currentProject!.currentActor!.functionDict[currentWorkspace]![modifierBlockIndexSender!].addedBlocks[0].attributes["cellIndex"] = String(optionSelectedIndex)
        }
    }
    
   
}

extension SelectLocationModifierViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(numCols * numRows)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! LocationCollectionViewCell
        let index = indexPath.item  // numerical index of cell
        
        if index % 2 == 0 { // make a checkered pattern of cells
            cell.backgroundColor = .white
           
        } else {
            cell.backgroundColor = .lightGray
        }
        
        cell.backgroundColor = cell.backgroundColor!.withAlphaComponent(0.7) // make cell slightly transparent so you can see the background behind it
        if indexPath.item == optionSelectedIndex {
            setCellHighlight(cell: cell, value: true)
        } else {
            setCellHighlight(cell: cell, value: false)
        }
        
        
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
    
}

class LocationCollectionViewCell  : UICollectionViewCell {
    /* Custom cell class for the location choice buttons*/
    
    func updateAccessibilityTools() {
        fatalError("updateAccessibilityTools not implemented")
    }
}

