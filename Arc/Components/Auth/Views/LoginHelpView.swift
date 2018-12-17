//
//  LoginHelpView.swift
//  mHealth
//
//  Created by Matt Gannon on 11/12/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

public class LoginHelpView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var helpButton:UIButton!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        let attributes:[NSAttributedString.Key:Any] = [
            .foregroundColor : UIColor(named: "Primary") as Any,
            .font : UIFont(name: "Roboto-Regular", size: 18.0) as Any,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let title = NSAttributedString(string: "Problems logging in?", attributes: attributes)
        helpButton.setAttributedTitle(title, for: .normal)
    }
    
}
