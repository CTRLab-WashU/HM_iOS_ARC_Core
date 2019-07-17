//
//  SurveyInputView.swift
// Arc
//
//  Created by Philip Hayes on 9/28/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
public protocol SurveyInputDelegate : class {
	func nextPressed(input:SurveyInput?, value:QuestionResponse?)
	func templateForQuestion(id:String)-> Dictionary<String, String>
	
	func didFinishSetup()
	func didChangeValue()
	func tryNextPressed()
}
public protocol SurveyInput {
    ///Returns nil if the value returned is invalid
    func getValue() -> QuestionResponse?
    func isInformational() -> Bool
    func setValue(_ value:QuestionResponse?)
	func setError(message:String?)
	func supplementaryViews(for view:UIView)
	var orientation:UIStackView.Alignment {get set}
    var distribution:UIStackView.Distribution {get set}
	var inputDelegate:SurveyInputDelegate? {get set}
    var isBottomAnchored:Bool {get}
    var parentScrollView:UIScrollView? {get set}
    
}

extension SurveyInput {
    public var parentScrollView:UIScrollView? {
        get {
            return nil
        }
        set {
            
        }
    }

    public var isBottomAnchored:Bool {
        return false
    }
    public var distribution:UIStackView.Distribution {
        get {
            return .fill
        }
        set {
            
        }
    }
    public func isInformational() -> Bool {
        return false
    }
	public func setError(message: String?) {
		
	}
	
	public func supplementaryViews(for view:UIView) {
		
	}

    func setValues(_ values:[String]?) {
        
    }
	
	func getInputAccessoryView(selector:Selector) -> UIToolbar{
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:50))
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
		let done: UIBarButtonItem = UIBarButtonItem(title: "Done".localized("button_done"), style: UIBarButtonItem.Style.done, target: self, action: selector)
        done.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Roboto-Bold", size: 18)!,
                                     NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
                                     NSAttributedString.Key.foregroundColor : UIColor(named:"Primary")!], for: .normal)

		
		var items:[UIBarButtonItem] = []
		items.append(flexSpace)
		items.append(done)
		
		doneToolbar.items = items
		doneToolbar.sizeToFit()
		return doneToolbar
	}
    
}

