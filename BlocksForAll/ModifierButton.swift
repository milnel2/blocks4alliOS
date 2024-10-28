//
//  ModifierButton.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/27/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class ModifierButton: UIButton {
    var block: Block
    var currentProject: Project?
    var data: ModifierButtonData
    
    var outputWidth = 0.0
    var outputHeight = 0.0
    
    var rectHeight = 0.0
    var rectWidth = 0.0
    
    var attrVal: String = ""
    var secondAttrVal: String = ""
    
    var modifierInformation: String = "" // Used for voiceOver
    
    required init(frame: CGRect, block: Block, currentProject: Project?, modifierData: ModifierButtonData) {
        self.block = block
        self.currentProject = currentProject
        self.data = modifierData
        
        super.init(frame: frame)
        
        self.data.setModifierButton(modifierButton: self)
        
        self.attrVal = self.block.getFirstAttrVal(data: self.data)
        self.secondAttrVal = self.block.getSecondAttrVal(data: self.data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getBlock() -> Block {
        return block
    }
    
    public func setUp() {
        
        modifierInformation = attrVal  // Default value of the current state of the block modifier - used for voiceOver
        
        setUpFonts()
        
        switch data.blockName {
        case "Repeat":
            repeatTimesButton()
        case "Wait for Time":
            waitButton()
        case "Turn Left", "Turn Right":
            turnLeftOrRightButton()
        case "Move Up", "Move Down", "Move Left", "Move Right":
            onlyShowNumberButton()
        case "Set Speed":
            setSpeedButton()
        case "Grow Actor", "Shrink Actor":
            onlyShowNumberButton()
        case "Move to Actor":
            moveToActorButton()
        case "Move to Location":
            // do nothing, draw will handle it // TODO: show text version
            moveToLocationButton()
        case "Set Background":
            setBackgroundButton()
        case "Animal Noise", "Emotion Noise", "Object Noise", "Vehicle Noise", "Speak":
            noiseButton()
        case "Drive Forward", "Drive Backward":
            driveForwardOrBackwardButton()
        case "Set Right Ear Light Color", "Set Left Ear Light Color", "Set Front Light Color", "Set All Lights Color":
            colorButton()
        case "Set Eye Light":
            eyeLightButton()
        case "If":
            ifButton()
        case "Set Variable":
            setVariableButton()
        case "Drive", "Turn", "Look Up or Down", "Look Left or Right":
            moveVariableButton()
        default:
            print("Error: block name \(data.blockName) not recognized in ModifierButton setUp()")
        }
        return
    }
    
    func setUpFonts() {
        // set up fonts before setting the text
        titleLabel?.font = UIFont.accessibleBoldFont(withStyle: .title1, size: 26.0)
        titleLabel?.adjustsFontForContentSizeCategory = true
        if #available(iOS 13.0, *) {
            setTitleColor(.label, for: .normal)
        } else {
            setTitleColor(.black, for: .normal)
        }
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
    
    func oneImageOnlyShowTextIsOn(text: String, backgroundPath: String) {
        setBackgroundImage(named: backgroundPath)
        
        layer.cornerRadius = 20 // add button rounded border
        titleLabel?.numberOfLines = 2
        titleLabel?.lineBreakMode = .byWordWrapping

        setTitle(text.capitalized, for: .normal)
    }
    
    // Variable blocks like Drive, Turn, Look Up or Down, etc.
    func moveVariableButton() {
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: "\(attrVal)")
        } else {
            oneImageOnlyShowTextIsOn(text: "\(attrVal)", backgroundPath: data.imagePath!)
        }
        modifierInformation = "\(attrVal) Variable" //TODO: do something with this
    }
    
    func setBackgroundImage(named imagePath: String) {
        let image = HelperFunctions.getUIImage(named: imagePath)
        setBackgroundImage(image, for: .normal)
    }
    
    func setVariableButton() {
        var text: String
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: "\(attrVal)Icon")  // these special images are called (fruitName)Icon (ex. AppleIcon)
            text = "\n\n= \(secondAttrVal)"
        } else {
            setBackgroundImage(named: data.imagePath!)
            text = "\(attrVal) = \(secondAttrVal)"
        }
        setTitle(text, for: .normal)
        modifierInformation = "\(attrVal) = \(secondAttrVal)"
    }
    
    func ifButton() {
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: attrVal)
        } else {
            let backgroundImagePath = "booleanSelectedBackground"
            oneImageOnlyShowTextIsOn(text: modifierInformation.capitalized, backgroundPath: backgroundImagePath)
        }
        modifierInformation = attrVal
    }
    
    func eyeLightButton() {
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: attrVal)
        } else {
            let backgroundImagePath = "eyeLightBackground"
            oneImageOnlyShowTextIsOn(text: modifierInformation.capitalized, backgroundPath: backgroundImagePath)
        }
        modifierInformation = attrVal
    }
    
    func colorButton() {
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: attrVal)
        } else {
            let color: String = block.attributes[data.attributeName] ?? data.secondDefault!
            let colorPath = "\(color)OpaqueColor"
            
            let myUIColor = UIColor(named: colorPath)
            backgroundColor = myUIColor ?? UIColor(named: "whiteOpaqueColor")
            layer.cornerRadius = 20 // add button rounded border
            titleLabel?.numberOfLines = 2
            titleLabel?.lineBreakMode = .byWordWrapping
            setTitle(color.capitalized, for: .normal)
        }
        
        modifierInformation = attrVal
    }
    
    func driveForwardOrBackwardButton() {
        let defaultValue = data.defaultValue
        let secondAttributeName = data.secondAttributeName
        let secondDefault = data.secondDefault
        let showTextImage = data.showTextImage
        let attributeName = data.attributeName
        
        var image : UIImage
        var text = attrVal
        if HelperFunctions.showIconsIsOn() {
            image = HelperFunctions.getUIImage(named: secondAttrVal)
            if titleLabel?.font.pointSize ?? 26 <= 34 {
                text = "\(attrVal) cm \n"
            } else {
                text = "\(attrVal)\n"
            }
            
        } else {
            image = HelperFunctions.getUIImage(named: showTextImage!)
            if titleLabel?.font.pointSize ?? 26 <= 34 {
                text = "\(attrVal) cm, \(secondAttrVal)"
            } else {
                text = "\(attrVal) \(secondAttrVal)"
            }
           
        }
        setBackgroundImage(image, for: .normal)
        setTitle(text, for: .normal)
        
        modifierInformation = "\(attrVal) cm, at \(secondAttrVal) speed." // TODO: make sure all voice over labels have periods.
    }
    
    func noiseButton() {
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: "\(attrVal)")
        } else {
            let backgroundImagePath = "\(data.attributeName)Background"
            oneImageOnlyShowTextIsOn(text: attrVal, backgroundPath: backgroundImagePath)
        }
        modifierInformation = attrVal
    }
    
    func setBackgroundButton() {
        if HelperFunctions.showIconsIsOn() {
            let defaultValue = "" // TODO: default value
            let imageName = block.attributes["background"] ?? defaultValue
            var image: UIImage
            if UserData.data.hasBackgroundPath(path: imageName) {
                image = HelperFunctions.getUIImage(named: imageName)
            } else {
                // Reset image to default image if the custom path no longer exists in user data (it has been deleted)
                image = HelperFunctions.getUIImage(named: defaultValue)
                block.attributes["background"] = defaultValue
            }
            setBackgroundImage(image, for: .normal)
            
        } else {
            let backgroundImagePath = "driveModifierBackground" // TODO: set the correct yellow background
            oneImageOnlyShowTextIsOn(text: attrVal, backgroundPath: backgroundImagePath)
        }
        
        modifierInformation = attrVal
    }
    
    // Button that only shows a number, both in icons or text mode. Ex. used for grow/shrink and movement blocks
    func onlyShowNumberButton() {
        setBackgroundImage(named: data.imagePath!)
        setTitle(attrVal, for: .normal)
        
        modifierInformation = attrVal
    }
    
    
    func setSpeedButton() {
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: attrVal)
        } else {
            let backgroundImagePath = "driveModifierBackground"
            oneImageOnlyShowTextIsOn(text: modifierInformation, backgroundPath: backgroundImagePath)
        }
        
        modifierInformation = attrVal
    }
    
    func moveToActorButton() {
        let uuid = block.attributes["moveToActor"] ?? ""
        
        let actor = VirtualRobot.getActorFromUUIDOrDefault(actorUUID: uuid, inProject: currentProject!)
        if HelperFunctions.showIconsIsOn() {
            setBackgroundImage(named: actor!.imagePath)
            block.attributes["moveToActor"] = actor!.UUID
        } else {
            let backgroundImagePath = "driveModifierBackground"
            let text = actor!.color.capitalized + " " + actor!.name.capitalized
            oneImageOnlyShowTextIsOn(text: text, backgroundPath: backgroundImagePath)
        }
        
        modifierInformation = actor!.color.capitalized + " " + actor!.name.capitalized
    }
    
    
    func turnLeftOrRightButton() {
        setBackgroundImage(named: data.imagePath!)
        var text = attrVal
        // handle text formatting
        // <angle>°
        text = "\(text)\u{00B0}"
        titleLabel?.font = UIFont.accessibleBoldFont(withStyle: .title1, size: 28.0)
        setTitle(text, for: .normal)
        
        modifierInformation = text
    }

    func repeatTimesButton() {
        setBackgroundImage(named: data.imagePath!)
        
        titleLabel?.font = UIFont.accessibleBoldFont(withStyle: .title1, size: 42.0)
        setTitle(attrVal, for: .normal)
        
        modifierInformation = "\(attrVal) times"
    }
    
    func waitButton() {
        setBackgroundImage(named: data.imagePath!)
        
        var text = attrVal
        
        if block.attributes["wait"] == "1" {
            text = "\(text) second"
        } else {
            text = "\(text) seconds"
        }
        
        setTitle(text, for: .normal)
        
        modifierInformation = text
    }
    
    public func getModifierInformation() -> String{
        return modifierInformation
    }
    
    func moveToLocationButton() {
        var coordinateString = attrVal
        if coordinateString == "-1,-1"{ // if the string is -1,-1 that means that there isn't a value, set it to the center
            let outputView = currentProject!.currentActor!.freeplayOutputView!
            outputWidth = outputView.frame.width
            outputHeight = outputView.frame.height
            coordinateString = "\(Int(outputWidth / 2)),\(Int(outputHeight / 2))"
           
            let cellIndex = Int(SelectLocationModifierViewController.calculateCenterCellIndex())
            print("cell index = \(cellIndex)")
            block.attributes["moveToLocation"] = coordinateString
            block.attributes["cellIndex"] = String(cellIndex)
            block.attributes["row"] =  String(SelectLocationModifierViewController.getRowFromCellIndex(index: cellIndex) + 1)
            block.attributes["column"] = String(SelectLocationModifierViewController.getColumnFromCellIndex(index: cellIndex) + 1)
            attrVal = coordinateString
        }
        
        let row = block.attributes["row"] ?? "Not available"
        let col = block.attributes["column"] ?? "Not available"
       
        modifierInformation = "Row \(row) of \(Int(LocationConstants.numRows)), Column \(col) of \(Int(LocationConstants.numCols))."
    }
    
    override func draw(_ rect: CGRect) {
        if currentProject != nil {
            if block.name == "Move to Actor" {
                // add background
                let buttonHeight = frame.height
                let buttonWidth = frame.width
                
                let outputView = currentProject!.currentActor!.freeplayOutputView!
                outputWidth = outputView.frame.width
                outputHeight = outputView.frame.height
                
                let backgroundRect = CGRect(x: 0,y: 0, width: buttonWidth, height: buttonHeight)
                let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 10)
                
                
                let myUIColor = UIColor(named: "drive_modifier_color") ?? .gray
                myUIColor.setFill()
                backgroundPath.fill()
                
                let actorUUID = block.attributes["moveToActor"] ?? ""
               
                let actor = VirtualRobot.getActorFromUUIDOrDefault(actorUUID: actorUUID, inProject: currentProject!)!
                accessibilityLabel = "\(actor.name), \(actor.color)"
                
                
            } else if block.name == "Move to Location" {
                
                let outputView = currentProject!.currentActor!.freeplayOutputView!
                outputWidth = outputView.frame.width
                outputHeight = outputView.frame.height
                
                let buttonHeight = frame.height
                let buttonWidth = frame.width
                
                let backgroundRect = CGRect(x: 0,y: 0, width: buttonWidth, height: buttonHeight)
                let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 10)
                
                let myUIColor = UIColor(named: "drive_modifier_color") ?? .gray
                myUIColor.setFill()
                backgroundPath.fill()
                
                let heightToWidthRatio: Double = outputHeight / outputWidth
                
                rectWidth = buttonWidth - 10 // adds a tiny bit of padding so that the rectangle doesn't go right up to the edges
                rectHeight = rectWidth * heightToWidthRatio

                let xCoord = (buttonWidth - rectWidth) / 2
                let yCoord = (buttonHeight - rectHeight) / 2
                
                let rect = CGRect(x: xCoord, y: yCoord, width: rectWidth, height: rectHeight)
                let path = UIBezierPath(rect: rect)
                
               
                UIColor.white.setFill()
                path.fill()
                
                // Drawing Bezier Paths is based off of https://www.kodeco.com/8003281-core-graphics-tutorial-getting-started/page/2
                let xWidth = 10.0
                let xHeight = xWidth
                
                let xLineWidth = 4.0
                
                let halfWidth = xWidth / 2
                let halfHeight = xHeight / 2
                
                
                let coordinateString = attrVal
  
                let originalCoords = VirtualRobot.parseCoordinateString(coordinateString: coordinateString)
                
                
                let (centerX, centerY): (x: CGFloat, y: CGFloat) = convertCoordsToSmallSize(oldX: originalCoords.x, oldY: originalCoords.y)
               
                
                let adjustedCenterY = centerY + yCoord// have to push the y value down a bit because the image doesn't take up the entire height of the button
                let adjustedCenterX = centerX + xCoord

                let xPath = UIBezierPath()
                xPath.lineWidth = xLineWidth

                // Draw X
                xPath.move(to: CGPoint(x: adjustedCenterX - halfWidth, y: adjustedCenterY - halfHeight)) // move to upper left
                xPath.addLine(to: CGPoint(x: adjustedCenterX + halfWidth, y: adjustedCenterY + halfHeight)) // draw to bottom right
                
                xPath.move(to: CGPoint(x: adjustedCenterX + halfWidth, y: adjustedCenterY - halfHeight)) // move to top left
                xPath.addLine(to: CGPoint(x: adjustedCenterX - halfWidth, y: adjustedCenterY + halfHeight)) // draw to bottom left

                UIColor.red.setStroke()
                xPath.stroke()
            }
        }
        
        func convertCoordsToSmallSize(oldX: CGFloat, oldY: CGFloat) -> (x: CGFloat, y: CGFloat){
            let widthRatio = rectWidth / outputWidth
            let heightRatio = rectHeight / outputHeight
            
            let newX = oldX * widthRatio
            let newY = oldY * heightRatio
            
            return (x: newX, y: newY)
        }
    }
}

class ModifierButtonData {
    var modifierButton: ModifierButton?
    
    var blockName: String
    var selector: Selector?
    var defaultValue : String
    var attributeName : String
    var accessibilityHint: String
    var imagePath: String?
    var displaysText: Bool
    var secondAttributeName: String?
    var secondDefault: String?
    var showTextImage: String?
    
    init(modifierButton: ModifierButton?, blockName: String, selector: Selector?, defaultValue: String, attributeName: String, accessibilityHint: String, imagePath: String?, displaysText: Bool, secondAttributeName: String?, secondDefault: String?, showTextImage: String?) {
        self.modifierButton = modifierButton
        self.blockName = blockName
        self.selector = selector
        self.defaultValue = defaultValue
        self.attributeName = attributeName
        self.accessibilityHint = accessibilityHint
        self.imagePath = imagePath
        self.displaysText = displaysText
        self.secondAttributeName = secondAttributeName
        self.secondDefault = secondDefault
        self.showTextImage = showTextImage
    }
    
    public func setModifierButton(modifierButton: ModifierButton) {
        self.modifierButton = modifierButton
    }
    
    public func getModifierButton() -> ModifierButton? { return modifierButton }
    
    public func getBlockName() -> String { return blockName }
    
    public func getSelector() -> Selector? { return selector }
    
    public func getDefaultValue() -> String { return defaultValue }
    
    public func getAttributeName() -> String { return attributeName }
    
    public func getAccessibilityHint() -> String { return accessibilityHint }
    
    public func getImagePath() -> String? { return imagePath }
    
    public func getDisplaysText() -> Bool { return displaysText }
    
    public func getSecondAttributeName() -> String? { return secondAttributeName }
    
    public func getSecondDefault() -> String? { return secondDefault }
    
    public func getShowTextImage() -> String? { return showTextImage }
    
    public func getDataTuple() -> (String, Selector?, String, String, String, String?, Bool, String?, String?, String?){
        return (getBlockName(), getSelector(), getDefaultValue(), getAttributeName(), getAccessibilityHint(), getImagePath(), getDisplaysText(), getSecondAttributeName(), getSecondDefault(), getShowTextImage())
    }
}
