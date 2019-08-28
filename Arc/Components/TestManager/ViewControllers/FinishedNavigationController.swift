//
//  FinishedNavigationController.swift
// Arc
//
//  Created by Philip Hayes on 10/24/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

open class FinishedNavigationController: SurveyNavigationViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
		//self.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
		guard let session = Arc.shared.currentTestSession else {return}
		guard let study = Arc.shared.currentStudy else {return}
		Arc.shared.studyController.mark(finished: session, studyId: study)

    }
	override open func loadSurvey(template:String) {
		survey = Arc.shared.surveyController.load(survey: template)
		
		
		//Shuffle the questions
		questions = survey?.questions ?? []
		
		
	}
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		Arc.shared.currentTestSession = nil
	}
	override open func onQuestionDisplayed(input:SurveyInput, index:String) {
		
		
	}
	
	//Override this to write to other controllers
	override open func onValueSelected(value:QuestionResponse, index:String) {
        
		guard let session = Arc.shared.currentTestSession else {return}
		guard let study = Arc.shared.currentStudy else {return}
        guard let v = value.value as? Int else {
            return
        }
		
		if v == 0 {
			Arc.shared.studyController.mark(interrupted:true, sessionId: session, studyId: study)
		} else if v == 1 {
			Arc.shared.studyController.mark(interrupted:false, sessionId: session, studyId: study)

		}
		
		
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
