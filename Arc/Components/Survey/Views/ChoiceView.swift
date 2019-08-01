//
//  ChoiceView.swift
// Arc
//
//  Created by Philip Hayes on 10/10/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
@IBDesignable open class ChoiceView : UIView {
    public enum State {
        case radio, checkBox, centeredText
        
        var unselectedImage:UIImage? {
            get {
                switch self {
                case .checkBox:
                    return UIImage(named: "cut-ups/checkbox/unselected")
                case .centeredText:
                    return nil
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
                case .centeredText:
                    return nil
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
        self.wrappedView.layer.cornerRadius = 6.0
        self.button.isUserInteractionEnabled = false
        self.wrappedView.isUserInteractionEnabled = false
    }
    
    @IBOutlet weak var wrappedView: ACView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
	var isExclusive:Bool = false
    var needsImmediateResponse:Bool = false
    private var _isSelected = false
    
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
    
    func set(selected:Bool, shouldUpdateColors:Bool=true) {
        _isSelected = selected
        if shouldUpdateColors {
            updateColors()
        }
    }
    func set(state:State) {
        button.setImage(state.unselectedImage, for: .normal)
        button.setImage(state.selectedImage, for: .selected)
        self.wrappedView.cornerRadius = state.cornerRadius
        if state == .centeredText {
            label.textAlignment = .center
            button.isHidden = true
        }
    }
    @IBAction func tapped(_ sender: Any) {
        //tapped?(self)
		
    }
    
    func updateColors() {
        self.button.isSelected = _isSelected
        self.wrappedView.backgroundColor = (_isSelected) ? UIColor(named: "Primary Selection") : nil
        self.wrappedView.borderColor = ((_isSelected) ? UIColor(named: "Primary") : UIColor(named: "Primary Selected")) ?? .clear
        self.wrappedView.borderThickness = (_isSelected) ? 2.0 : 1.0
        if (_isSelected) {
            label.font = UIFont(name: "Roboto-Black", size: 18)
        } else {
            label.font = UIFont(name: "Roboto-Medium", size: 18)
        }
        self.layoutSubviews()
    }
    
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if (needsImmediateResponse == true) {
            tapped?(self)
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let location = touches.first?.location(in: self) else { return }
        if (location.x < 0)
            || (location.y < 0)
            || (location.x > self.frame.width)
            || (location.y > self.frame.height)
        {
            updateColors()
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if (needsImmediateResponse == true) {
            updateColors()
        } else {
            tapped?(self)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        updateColors()
    }
    
}
