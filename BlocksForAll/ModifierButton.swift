//
//  ModifierButton.swift
//  BlocksForAll
//
//  Created by Lucy Rubin on 6/27/24.
//  Copyright © 2024 Blocks4All. All rights reserved.
//

import Foundation

class ModifierButton: UIButton {
    var block: Block?
    var currentProject: Project?
    
    var outputWidth = 0.0
    var outputHeight = 0.0
    
    var rectHeight = 0.0
    var rectWidth = 0.0
    override func draw(_ rect: CGRect) {
        if block != nil && currentProject != nil {
            if block!.name == "Move to Location" {
                // TODO: text description of button
                
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
                

                
                var coordinateString = block!.attributes["moveToLocation"]
                
                if coordinateString == nil || coordinateString == "-1,-1"{ // if the string is -1,-1 that means that there isn't a value, set it to the center
                    coordinateString = "\(Int(outputWidth / 2)),\(Int(outputHeight / 2))"
                    
                    block!.attributes["moveToLocation"] = coordinateString
                }
                let originalCoords = VirtualRobot.parseCoordinateString(coordinateString: coordinateString!)
                
                
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
                
                let row = block!.attributes["row"] ?? "Not available"
                let col = block!.attributes["column"] ?? "Not available"
                accessibilityLabel = "Row \(row) Column \(col)"
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
