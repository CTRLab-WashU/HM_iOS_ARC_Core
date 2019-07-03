//
//  TimeView.swift
// Arc
//
//  Created by Philip Hayes on 10/2/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

open class TimeView: UIView, SurveyInput {
    public var orientation: UIStackView.Alignment = .top
    public var didChangeValue: (() -> ())?
	public var tryNext:(() -> ())?
    public var didFinishSetup: (() -> ())?

	@IBOutlet weak var picker:UIDatePicker!
    
    let calendar = Calendar.current
    
    private let dateFormatter:DateFormatter = DateFormatter()
    
    private var _value:String?
	
	
    override open func awakeFromNib() {
        super.awakeFromNib()
		
        self.dateFormatter.dateFormat = "h:mm a"

        if let date = self.dateFormatter.date(from: "12:00 PM") {
            picker.setDate(date, animated: false)
        }
		didFinishSetup?()
    }
 
    public func getValue() -> QuestionResponse? {
		
        let value = self.dateFormatter.string(from: picker.date)

        return AnyResponse(type: .time, value: value)
    }
    
    public func setValue(_ value: QuestionResponse?) {
		
		guard let value = value?.value as? String else {
			return
		}
		guard let date = dateFormatter.date(from: value) else {
			return
		}
		picker.date = date

    }
    
    @IBAction func valueChanged(_ sender: Any) {
        self.didChangeValue?();
    }
    
    //MARK: TextFields
	
	
	public func setError(message: String?) {
		if message != nil {
			
			
		} else {
			
			
		}
	}
}
