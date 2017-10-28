//
//  BlockView.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 6/1/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit
import AudioToolbox

class BlockView: UIView, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    var blocks: [Block]
    var blockWidth = 150
    var blockHeight = 150
    let blockSpacing = 1
    var picker: UIPickerView?
    var pickerData: [String] = []
    var pickerDataAccessibilityLabels: [String] = []
    var pickedItem: UITextField?
    
    init (frame : CGRect, block : [Block], myBlockWidth: Int, myBlockHeight: Int) {
        self.blocks = block
        super.init(frame : frame)
        blockWidth = myBlockWidth
        blockHeight = myBlockHeight
        self.addSubview(simpleView(FromBlock: block))
    }
    
    override func accessibilityElementDidBecomeFocused() {
        print(blocks[0].name + " is focused")
        //AudioServicesPlaySystemSound(1024)
        if blocks[0].type ==  "Number" || (!blocks[0].acceptedTypes.isEmpty && blocks[0].acceptedTypes[0] == "Number"){
            print("1")
            AudioServicesPlaySystemSound(1257)
        }else if blocks[0].type ==  "Boolean" || (!blocks[0].acceptedTypes.isEmpty && blocks[0].acceptedTypes[0] == "Boolean"){
            print("2")
            AudioServicesPlaySystemSound(1255)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    func simpleView(FromBlock block: [Block]) -> UIView {
        
        let block = block[0]
        let myViewWidth = blockWidth
        let myViewHeight = blockHeight
        let myFrame = CGRect(x: 0, y: 0, width: myViewWidth, height: myViewHeight)
        let myView = UIView(frame: myFrame)
        myView.backgroundColor = block.color
        if(block.imageName != nil){
            let imageName = block.imageName!
            var image = UIImage(named: imageName)
            image = imageWithImage(image: image!, scaledToSize: CGSize(width: myViewWidth, height: myViewHeight))
            let imv = UIImageView.init(image: image)
            myView.addSubview(imv)
        }else if !block.double{ //so end repeat blocks don't have names
            let myLabel = UILabel.init(frame: myFrame)
            myLabel.text = block.name
            myLabel.textAlignment = .center
            myLabel.textColor = UIColor.white
            myLabel.font = UIFont.preferredFont(forTextStyle: .title2)
            myLabel.numberOfLines = 0
            myView.addSubview(myLabel)
        }
        if block.editable {
            //self.pickerData = ["2x","3x", "4x"]
            //self.pickerDataAccessibilityLabels = ["2 times", "3 times", "4 times"]
            self.pickerData = block.options
            self.pickerDataAccessibilityLabels = block.optionsLabels
            /*
            let myTextFrame = CGRect(x: 60, y: 0, width: 50, height: 100)
            pickedItem = UITextField(frame: myTextFrame)
            pickedItem?.text = pickerData[0]
            pickedItem?.textColor = UIColor.white
            pickedItem?.font = UIFont.boldSystemFont(ofSize: 25)
            //pickedItem?.font = UIFont.systemFont(ofSize: 25)
            pickedItem?.delegate = self
            myView.addSubview(pickedItem!)
            */
            let myFrame = CGRect(x: blockWidth/2, y: 0, width: blockWidth/2, height: blockHeight/2)
            //let myFrame = CGRect(x: blockWidth/2, y: 0, width: 40, height: 40)
            self.picker = UIPickerView.init(frame: myFrame)
            self.picker?.isAccessibilityElement = true
            //self.picker?.
            self.picker?.delegate = self
            self.picker?.dataSource = self
            //self.picker?.backgroundColor = block.color
            //self.picker?.isHidden = true
            self.picker?.selectRow(block.pickedOption, inComponent: 0, animated: false)
            
            myView.addSubview(picker!)
            
            //self.pickerData = block.options
        }
        return myView
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view
        let myFrame = CGRect(x: CGFloat(blockWidth/2), y: 0, width: pickerView.rowSize(forComponent: component).width, height: pickerView.rowSize(forComponent: component).height)
        if !(label != nil){
            label = UILabel.init(frame: myFrame)
            if let myLabel = label as? UILabel{
                myLabel.textAlignment = NSTextAlignment.right
                myLabel.textColor = UIColor.white
                myLabel.backgroundColor = blocks[0].color
                myLabel.text = pickerData[row]
                myLabel.font = UIFont.boldSystemFont(ofSize: 35)
                myLabel.accessibilityLabel = pickerDataAccessibilityLabels[row]
                return myLabel
            }
        }
        return label!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        blocks[0].pickedOption = row
        
        /*if let selectedLabel = pickerView.view(forRow: row, forComponent: component) as? UILabel{
            selectedLabel.backgroundColor = UIColor.white
        }*/

        //pickedItem?.text = pickerData[row]
        //self.picker?.isHidden = true
    }
    /*
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.picker?.isHidden = false
        return false
    }
    */
    
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
}
