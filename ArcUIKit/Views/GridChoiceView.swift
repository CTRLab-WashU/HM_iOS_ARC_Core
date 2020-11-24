//
//  GridChoiceView.swift
//  ArcUIKit
//
//  Created by Andrew Pearson on 9/1/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class GridChoiceView : IndicatorView {
    /**
            
     
     */
    public enum PopupAction {
            case set(responseData:Int, index:IndexPath, confirmTime:Date)
            case unset(index:IndexPath)
       }
    public var phoneButton:UIButton{
        get {
            return gridTestSelection.phoneButton
        }
    }
    public var keyButton:UIButton{
        get {
            return gridTestSelection.keyButton
        }
    }
    public var penButton:UIButton{
        get {
            return gridTestSelection.penButton
        }
    }
    public var removeButton:UIButton{
        get {
            return gridTestSelection.removeItem
        }
    }
    
    private let gridTestSelection:GridTestSelectionView
    
    
    
    override public init(frame: CGRect) {
        gridTestSelection = .get()
        
        super.init(frame: frame)
    }
    /**
    - parameters:
       - parent: needed to add GridChoice as subview
       - indexPath: index path of cell selected
       - targetView: view of cell to be targeted
       - choice: Index of image symbol selected
       - action:
            * called after user makes a selection;
            * send set if symbol is tapped;
            * send back unset if remove is tapped;
            * removes itself from parent view after action is called;
     */
    public init(in parent:UIView, indexPath:IndexPath, targetView: UIView, choice: Int?, action:@escaping(PopupAction) -> ()) {
        
        gridTestSelection = .get()
        super.init(frame: .zero)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: removeButton.titleLabel?.text ?? "", attributes: underlineAttribute)
        removeButton.titleLabel?.attributedText = underlineAttributedString
        var arrowPosition:Bool = false
        if indexPath.row > 19 {
            arrowPosition = false
        } else {
            arrowPosition = true
        }
        self.targetView = targetView
        
        self.configure(with: IndicatorView.Config(primaryColor: .white, secondaryColor: .white, textColor: .black, cornerRadius: 16, arrowEnabled: true, arrowAbove: arrowPosition))
        self.container?.axis = .horizontal
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowColor = UIColor.black.cgColor
        self.container?.addArrangedSubview(gridTestSelection)
        parent.addSubview(self)
        self.layout {
            $0.centerX == targetView.centerXAnchor ~ 500
            $0.top >= parent.safeAreaLayoutGuide.topAnchor ~ 999
            $0.bottom <= parent.safeAreaLayoutGuide.bottomAnchor ~ 999
            $0.trailing <= parent.safeAreaLayoutGuide.trailingAnchor - 28 ~ 999
            $0.leading >= parent.safeAreaLayoutGuide.leadingAnchor + 28 ~ 999
            if indexPath.row > 19{
                $0.bottom == targetView.topAnchor - 8 ~ 500
            } else{
                $0.top == targetView.bottomAnchor + 8 ~ 500
            }
        }
       
        
        if choice == 0 {
            gridTestSelection.keyButton.isEnabled = false
            gridTestSelection.keyImage.alpha = 0.5
        }
        styleImageButton(imageButton: gridTestSelection.keyImage)
        gridTestSelection.keyButton.accessibilityIdentifier = "key_button"
        gridTestSelection.keyButton.addAction { [weak self] in
            action(.set(responseData: 0, index: indexPath, confirmTime:Date()))
            self?.removeFromSuperview()
        }
        
        if choice == 1 {
            gridTestSelection.phoneButton.isEnabled = false
            gridTestSelection.phoneImage.alpha = 0.5
        }
        styleImageButton(imageButton: gridTestSelection.phoneImage)
        gridTestSelection.phoneButton.accessibilityIdentifier = "phone_button"
        gridTestSelection.phoneButton.addAction { [weak self] in
            action(.set(responseData: 1, index: indexPath, confirmTime:Date()))
            self?.removeFromSuperview()
        }
        
        if choice == 2 {
            gridTestSelection.penButton.isEnabled = false
            gridTestSelection.penImage.alpha = 0.5
        }
        styleImageButton(imageButton: gridTestSelection.penImage)
        gridTestSelection.penButton.accessibilityIdentifier = "pen_button"
        gridTestSelection.penButton.addAction { [weak self] in
            action(.set(responseData: 2, index: indexPath, confirmTime:Date()))
            self?.removeFromSuperview()
        }
        if choice != nil {
            gridTestSelection.removeItem.accessibilityIdentifier = "remove_button"
            gridTestSelection.removeItem.addAction { [weak self] in
                action(.unset(index: indexPath))
                self?.removeFromSuperview()
                
            }
        } else {
            gridTestSelection.hideRemoveItemButton()
        }
        
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func styleImageButton(imageButton:UIImageView)
    {
        imageButton.layer.cornerRadius = 6
        imageButton.layer.borderColor = UIColor.lightGray.cgColor
        imageButton.layer.borderWidth = 1
        imageButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageButton.layer.shadowColor = UIColor.black.cgColor
        imageButton.layer.shadowRadius = 1
        imageButton.layer.shadowOpacity = 0.5
        imageButton.layer.masksToBounds = false
    }
    
}
