//
//  MultilineTextView.swift
// Arc
//
//  Created by Spencer King on 10/25/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
open class MultilineTextView : UIView, SurveyInput, UITextViewDelegate {

    public var orientation: UIStackView.Alignment = .top
    public var didChangeValue: (() -> ())?
	public var tryNext:(() -> ())?
    public var didFinishSetup: (() -> ())?

    @IBOutlet weak var textView: UITextView!
	public var maxCharacters:Int?
	public var minCharacters:Int?
	public var keyboardType:UIKeyboardType = .default {
		didSet {
			textView.keyboardType = keyboardType
		}
	}
    override open func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.layer.borderColor = UIColor(named: "Primary")!.cgColor
        textView.layer.borderWidth = 2.0
        textView.layer.cornerRadius = 8.0
		textView.inputAccessoryView = getInputAccessoryView(selector: #selector(endEditing(_:)))
        textView.becomeFirstResponder()
    }
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    public func getValue() -> QuestionResponse? {
		guard textView.text.count >= minCharacters ?? 1 else {
			return nil
		}
		if let max = maxCharacters {
			guard textView.text.count <= max else {
				return nil
			}
		}
        return AnyResponse(type: .multilineText,
						   value: textView.text)
    }
	public func setValue(_ value: QuestionResponse?) {
		textView.text = String(describing:  value?.value as? String ?? "")
		if let max = maxCharacters {
			textView.text = String(textView.text.prefix(max))
		}
    }
	
	
	public func setError(message: String?) {
		if message != nil {
			textView.layer.borderColor = UIColor(named: "Error")!.cgColor

		} else {
			textView.layer.borderColor = UIColor(named: "Primary")!.cgColor

		}
	}
	
	func getError() -> String? {
		return ""
	}
	public func textViewDidChange(_ textView: UITextView) {
		if let max = maxCharacters {
			textView.text = String(textView.text.prefix(max))
		}
		didChangeValue?()
	}
}
