//
//  BorderedUIView.swift
// Arc
//
//  Created by Spencer King on 10/24/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

@IBDesignable
open class BorderedUIView: UIView {
    @IBInspectable var borderWidth: CGFloat = 0.0{
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
