//
//  ACSignatureNavigationController.swift
//  Arc
//
//  Created by Philip Hayes on 3/29/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
open class ACSignatureNavigationController: SurveyNavigationViewController {
    public var sessionId:Int64 = -1
    public var tag:Int32 = -1
    open override func viewDidLoad() {
        super.viewDidLoad()
        guard let session = Arc.shared.currentTestSession else {return}
        
        sessionId = Int64(session)
    }
    
    open override func valueSelected(value: QuestionResponse, index: String) {
        //Do things here
        guard let image = value.value as? UIImage else {
            return
        }
        
        if Arc.shared.appController.save(signature: image, sessionId: sessionId, tag: tag) {
            print("saved")
        } else {
            print("Not saved")
        }
    }

}
