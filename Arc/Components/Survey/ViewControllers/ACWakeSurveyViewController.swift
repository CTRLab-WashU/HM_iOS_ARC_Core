//
//  TKWakeSurveyViewController.swift
//  NSARC
//
//  Created by Philip Hayes on 2/1/19.
//  Copyright © 2019 healthyMedium. All rights reserved.
//

import UIKit

open class ACWakeSurveyViewController: SurveyNavigationViewController {
    enum WakeSurveyQuestion : String {
        case bedTimeLastNight = "wake_1"
        case sleepTimeLastNight = "wake_2"
        case wakeTimeThisMorning = "wake_4"
        case outOfBedTimeThisMorning = "wake_5"
        case workSleep = "chronotype_3"
        case workWake = "chronotype_4"
        case nonworkSleep = "chronotype_5"
        case nonworkWake = "chronotype_6"
        case nonworkSleep2 = "chronotype_7"
        case nonworkWake2 = "chronotype_8"

        case other
    }
    override open func questionDisplayed(input:SurveyInput, index:String) {
        super.questionDisplayed(input: input, index: index)
        
        
        let question = WakeSurveyQuestion(rawValue: index) ?? .other
        
        guard question != .other else {return}
        
        let date = Date()
        
        let day = WeekDay.getDayOfWeek(date)
        
        guard let today = Arc.shared.scheduleController.get(entriesForDay: day, forParticipant: Arc.shared.participantId ?? 0)?.first else {return}
        guard let yesterday = Arc.shared.scheduleController.get(entriesForDay: day.advanced(by: -1), forParticipant: Arc.shared.participantId ?? 0)?.first else {return}

        switch question {
        
        case .bedTimeLastNight, .sleepTimeLastNight:
            
            guard getAnswerFor(question: question) == nil else {return}

            input.setValue(AnyResponse(type: .time, value: yesterday.availabilityEnd))
        
        
        
        case .wakeTimeThisMorning, .outOfBedTimeThisMorning, .workWake:
            
            guard getAnswerFor(question: question) == nil else {return}
            
            input.setValue(AnyResponse(type: .time, value: today.availabilityStart))
        
        
        
        case .workSleep:
            
            guard getAnswerFor(question: question) == nil else {return}
            
            input.setValue(AnyResponse(type: .time, value: today.availabilityEnd))
        
        
        
        case .nonworkWake, .nonworkWake2:
            
            guard getAnswerFor(question: question) == nil else {return}
            
            guard let saturday = Arc.shared.scheduleController.get(entriesForDay: .saturday, forParticipant: Arc.shared.participantId ?? 0)?.first else {return}
            
            input.setValue(AnyResponse(type: .time, value: saturday.availabilityStart))
        
        
        
        case .nonworkSleep, .nonworkSleep2:
            
            guard getAnswerFor(question: question) == nil else {return}
            
            guard let saturday = Arc.shared.scheduleController.get(entriesForDay: .saturday, forParticipant: Arc.shared.participantId ?? 0)?.first else {return}
            
            input.setValue(AnyResponse(type: .time, value: saturday.availabilityEnd))
        
        default:
            return
        }
    }
    private func getAnswerFor(question:WakeSurveyQuestion) -> String? {
        let question = question.rawValue
        guard let surveyId = surveyId else {return nil}
        
        guard let answer = Arc.shared.surveyController.getResponse(forQuestion: question, fromSurveyResponse: surveyId) else {
            return nil
        }
        
        guard let value = answer.value as? String else {return nil}
        
        return value
    }
}
