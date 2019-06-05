//
//  ChoiceView.swift
// Arc
//
//  Created by Philip Hayes on 10/10/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
@IBDesignable open class ChoiceView : ACView {
    public enum State {
        case radio, checkBox
        
        var unselectedImage:UIImage? {
            get {
                switch self {
                case .checkBox:
                    return UIImage(named: "cut-ups/checkbox/unselected")
                default:
                    return UIImage(named: "cut-ups/radio/unselected")
                }
            }
        }
        
        var selectedImage:UIImage? {
            get {
                switch self {
                case .checkBox:
                    return UIImage(named: "cut-ups/checkbox/selected")
                default:
                    //return UIImage(named: "cut-ups/radio/selected")
                    return UIImage(named: "cut-ups/radio/selected alt")
                }
            }
        }
        var cornerRadius:CGFloat {
            get {
                switch self {
                case .checkBox:
                    return 6.0
                default:
                    return 22.0
                }
            }
        }
//        var altSelectedImage:UIImage? {
//            get {
//                switch self {
//                case .checkBox:
//                    return nil
//                default:
//                    return UIImage(named: "cut-ups/radio/selected alt")
//                }
//            }
//        }
        
    }
    public var didFinishSetup: (() -> ())?

    override open func awakeFromNib() {
        self.layer.cornerRadius = 6.0
    }

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
	var isExclusive:Bool = false
    var needsImmediateResponse:Bool = false
    var _isSelected = false {
        didSet {
            button.isSelected = _isSelected
            updateColors()
        }
    }
    var tapped:((ChoiceView)->Void)?
    
    func getMessage() -> String? {
        return label.text
    }
    func getSelected() -> Bool {
        return _isSelected
    }
    func set(message:String?) {
        label.text = message?.localized(message ?? "")
    }
    
    func set(selected:Bool) {
        _isSelected = selected
    }
    func set(state:State) {
        button.setImage(state.unselectedImage, for: .normal)
        button.setImage(state.selectedImage, for: .selected)
        self.cornerRadius = state.cornerRadius
        
    }
    @IBAction func tapped(_ sender: Any) {
        //tapped?(self)
		
    }
    
    func updateColors() {
        self.backgroundColor = (_isSelected) ? UIColor(named: "Primary Selection") : nil
        self.borderColor = ((_isSelected) ? UIColor(named: "Primary") : UIColor(named: "Primary Selected")) ?? .clear
        self.borderThickness = (_isSelected) ? 2.0 : 1.0
        if (_isSelected) {
            label.font = UIFont(name: "Roboto-Black", size: 18)
        } else {
            label.font = UIFont(name: "Roboto-Medium", size: 18)
        }
        self.layoutSubviews()
    }
    
    func updateState() {
        if (_isSelected) {
            self._isSelected = false
        } else {
            self._isSelected = true
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if (needsImmediateResponse == true) {
            tapped?(self)
            updateColors()
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        tapped?(self)
        if (needsImmediateResponse == true) {
            updateColors()
        }
    }
    
}
