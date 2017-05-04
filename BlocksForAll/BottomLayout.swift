//
//  bottomFlowLayout.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 4/26/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BottomLayout: UICollectionViewLayout {
    
    //cache attributes so they do not need to be recalculated
    private var cache = [UICollectionViewLayoutAttributes]()
    var blockWidth: CGFloat = 100
    var blockHeight: CGFloat = 100
    var blockSpacing: CGFloat = 1
    
  
    /*override func prepare(){
        if cache.isEmpty {
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                        print("preparing to layout")
                let indexPath = IndexPath(item: item, section: 0)
                let myFloat = CGFloat(item)
                let frame = CGRect(x: myFloat * (blockWidth+blockSpacing), y: (collectionView?.bounds.height)!-blockHeight, width: blockWidth, height: blockHeight)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
            }
        }
    }*/
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            print("preparing to layout")
            let indexPath = IndexPath(item: item, section: 0)
            let myFloat = CGFloat(item)
            let frame = CGRect(x: myFloat * (blockWidth+blockSpacing), y: (collectionView?.bounds.height)!-blockHeight, width: blockWidth, height: blockHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
        }
        
        return cache
        /*var layoutAttributes = [UICollectionViewLayoutAttributes]()
        //check if their frames intersect with rect
        //TODO: do I need this?
        for attributes in cache{
            if attributes.frame.intersects(rect) {
                        print("layout")
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes*/
    }
    
    
    
    /*override func collectionViewContentSize() -> CGSize {
        return CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
    }*/
    /*
     let cellSpacing:CGFloat = 0
     
     override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
     if let attributes = super.layoutAttributesForElements(in: rect) {
     for (index, attribute) in attributes.enumerated() {
     if index == 0 { continue }
     let prevLayoutAttributes = attributes[index - 1]
     let origin = prevLayoutAttributes.frame.maxX
     if(origin + cellSpacing + attribute.frame.size.width < self.collectionViewContentSize.width){
     attribute.frame.origin.x = origin + cellSpacing
     }//self.collectionViewContentSize().width) {
     }
     return attributes
     }
     return nil
     }
     */

}
