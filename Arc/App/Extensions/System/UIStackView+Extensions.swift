//
//  UIStackView.swift
// Arc
//
//  Created by Philip Hayes on 9/28/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
public extension UIStackView {
    func removeSubviews() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
            removeArrangedSubview(view)
            
        }
        layoutSubviews()
    }
}
