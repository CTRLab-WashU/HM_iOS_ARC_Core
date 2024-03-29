//
//  ACLabel.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 2/12/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
import UIKit
import HMMarkup
@IBDesignable open class ACLabel : HMMarkupLabel {
    
    public var style:ACTextStyle = .none {
        didSet {
            setup(isSelected: false)
        }
    }
    
    @IBInspectable var styleId:Int = 0 {
        didSet {
            style = ACTextStyle(rawValue: styleId) ?? .none
            
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        //setup(isSelected: false)
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //setup(isSelected: false)

    }
    
    func setup(isSelected:Bool) {
        self.font = style.font
        markupText()
    }
}
