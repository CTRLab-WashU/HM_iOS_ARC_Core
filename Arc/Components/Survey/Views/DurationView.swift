//
//  DurationView.swift
// Arc
//
//  Created by Philip Hayes on 10/22/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

open class DurationView: UIView, SurveyInput{
    public var orientation: UIStackView.Alignment = .top
    public var didChangeValue: (() -> ())?
	public var tryNext:(() -> ())?
    public var didFinishSetup: (() -> ())?

	@IBOutlet weak var picker: UIDatePicker!

	
	let calendar = Calendar.current

	override open func awakeFromNib() {
		super.awakeFromNib()
		
	}

	public func getValue() -> QuestionResponse? {
		let interval = picker.countDownDuration
		
		return AnyResponse(type: .duration, value: interval.localizedInterval())
	}

	public func setValue(_ value: QuestionResponse?) {
		
		
		var interval:TimeInterval = 0.0
		defer {
            
			picker.countDownDuration = interval
           
		}
		
		guard let v = value?.value as? String else {
			return
		}
		
		
		let components = v.components(separatedBy: CharacterSet(charactersIn: ","))
			
		for component in components {
			if component.contains("hr") {
				let hours = component.replacingOccurrences(of: " hr", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
				interval += Double(Int(hours) ?? 0) * TimeInterval.Unit.hour.rawValue
			}
			
			if component.contains("min") {
				let minutes = component.replacingOccurrences(of: " min", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
				interval += Double(Int(minutes) ?? 0) * TimeInterval.Unit.minute.rawValue
			}
		}
		
		

		
	}
    @IBAction func valueChanged(_ sender: Any) {
        self.didChangeValue?();
        
    }
    
}
