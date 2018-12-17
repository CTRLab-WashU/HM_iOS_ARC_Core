//
//  BorderedTextField.swift
// Arc
//
//  Created by Spencer King on 10/23/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

@IBDesignable
open class BorderedTextField: UITextField {
    
    @IBInspectable
    var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
