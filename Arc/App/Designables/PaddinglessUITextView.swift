//
//  PaddinglessUITextView.swift
// Arc
//
//  Created by Spencer King on 11/5/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

@IBDesignable open class PaddinglessUITextView: UITextView {
    override open func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
