//
//  UILabel+Extensions.swift
// Arc
//
//  Created by Philip Hayes on 10/8/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
extension UIFont {
    func boldFont() -> UIFont? {
        return addingSymbolicTraits(.traitBold)
    }
    
    func italicFont() -> UIFont? {
        return addingSymbolicTraits(.traitItalic)
    }
    
    func addingSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        let newTraits = fontDescriptor.symbolicTraits.union(traits)
        guard let descriptor = fontDescriptor.withSymbolicTraits(newTraits) else {
            return nil
        }
        
        return UIFont(descriptor: descriptor, size: 0)
    }
}

public extension UILabel
{
	
    // Resizes font size so that single words won't wrap characters if they're too long to fit
    
    public func resizeFontForSingleWords()
    {
        guard let currentFont = self.font else { return; }
        guard let currentText = self.text else { return; }
        
        var minFont = currentFont;
        let words = currentText.components(separatedBy: " ");
        let currentRect = self.frame;
        
        for w in words
        {
            var wRect = (w as NSString).boundingRect(with: currentRect.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: minFont], context: nil);
            
            while wRect.width > currentRect.size.width
            {
                minFont = minFont.withSize(minFont.pointSize - 0.5);
                wRect = (w as NSString).boundingRect(with: currentRect.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: minFont], context: nil);
            }
        }
        
        self.font = minFont;
    }
}
