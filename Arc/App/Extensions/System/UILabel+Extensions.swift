//
//  UILabel+Extensions.swift
// Arc
//
//  Created by Philip Hayes on 10/8/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

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
