//
//  CustomFont.swift
//  BlocksForAll
//
//  Created by Miri Leonard on 6/14/23.
//  Copyright © 2023 Blocks4All. All rights reserved.
//
// This extension was created with help from the tutorial by Yusuf Tor on Kodeco.com
// https://www.kodeco.com/26454946-custom-fonts-getting-started
//

import UIKit

extension UIFont {
    // Custom Font names: Family: APHont Font. Names: ["APHont", "APHont-Italic", "APHont-Bold", "APHont-BoldItalic"]
    
    /// Returns the dynamic custom font  (regular style) with the given style and size.
    /// Make sure to set .adjustsFontForContentSizeCategory = true for the font to adjust dynamically.
    static func accessibleFont(withStyle style: UIFont.TextStyle, size fontSize: CGFloat) -> UIFont {
      guard let customFont = UIFont(name: "APHont", size: fontSize)
      else {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        print("Font not accessed")
        return UIFont(descriptor: descriptor, size: descriptor.pointSize)
      }
      return customFont.dynamicallyTyped(withStyle: style)
    }
    
    /// Returns the dynamic custom font  (Bold style) with the given style and size.
    /// Make sure to set .adjustsFontForContentSizeCategory = true for the font to adjust dynamically.
    static func accessibleBoldFont(withStyle style: UIFont.TextStyle, size fontSize: CGFloat) -> UIFont {
      guard let customFont = UIFont(name: "APHont-Bold", size: fontSize)
      else {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        print("Font not accessed")
        return UIFont(descriptor: descriptor, size: descriptor.pointSize)
      }
      return customFont.dynamicallyTyped(withStyle: style)
    }
    
    /// Returns the dynamic custom font  (Italic style) with the given style and size.
    /// Make sure to set .adjustsFontForContentSizeCategory = true for the font to adjust dynamically.
    static func accessibleItalicFont(withStyle style: UIFont.TextStyle, size fontSize: CGFloat) -> UIFont {
      guard let customFont = UIFont(name: "APHont-BoldItalic", size: fontSize)
      else {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        print("Font not accessed")
        return UIFont(descriptor: descriptor, size: descriptor.pointSize)
      }
      return customFont.dynamicallyTyped(withStyle: style)
    }

    /// Returns the dynamic custom font  (Bold-Italic style) with the given style and size.
    /// Make sure to set .adjustsFontForContentSizeCategory = true for the font to adjust dynamically.
    static func accessibleBoldItalicFont(withStyle style: UIFont.TextStyle, size fontSize: CGFloat) -> UIFont {
      guard let customFont = UIFont(name: "APHont-Italic", size: fontSize)
      else {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        print("Font not accessed")
        return UIFont(descriptor: descriptor, size: descriptor.pointSize)
      }
      return customFont.dynamicallyTyped(withStyle: style)
    }
    
    /// Scales the custom font based on the text style (e.g. largeTitle, body, etc.)
    func dynamicallyTyped(withStyle style: UIFont.TextStyle) -> UIFont {
      let metrics = UIFontMetrics(forTextStyle: style)
      return metrics.scaledFont(for: self)
    }


}


