//
//  Common.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 2/13/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
import UIKit
@objc public enum Style : Int{
    static let fonts = UIFont.fontNames(forFamilyName: "Roboto")
    
    case none, body, heading, title, selectedBody
    
    var size:CGFloat {
        switch self {
        case .body, .selectedBody:
            return 18.0
        case .heading:
            return 26.0
        case .title:
            return 33.0
        default:
            return 18.0
        }
    }
    var font:UIFont? {
        var f:UIFont?
        switch self {
        
        case .body:
            f = UIFont(name: Style.fonts[0], size: self.size)
   
        case .heading:
            f = UIFont(name: Style.fonts[0], size: self.size)
       
        case .title:
            f = UIFont(name: Style.fonts[0], size: self.size)
            
        case .selectedBody:
            f = UIFont(name: Style.fonts[1], size: self.size)
        
        default:
            break
        }
        
        return f
    }
    
}
