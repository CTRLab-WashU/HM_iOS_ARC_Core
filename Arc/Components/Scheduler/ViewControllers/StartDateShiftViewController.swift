//
//  StartDateShiftViewController.swift
//  Arc
//
//  Created by Philip Hayes on 3/11/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit



open class StartDateShiftViewController: SurveyNavigationViewController {
    enum QuestionId : String {
        case user_schedule_1, user_schedule_2
    }
    
    var selectedDate:Int = 7
    var dates:[Date] = []
    let longFormat = ACDateStyle.longWeekdayMonthDay.rawValue
    let mediumFormat = ACDateStyle.mediumWeekDayMonthDay.rawValue
    let upComingStudy = Arc.shared.studyController.getUpcomingStudyPeriod()

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let upcoming = upComingStudy, let userDate = upcoming.userStartDate else {
            return
        }
        print(userDate.localizedString())
        let date = upComingStudy?.startDate ?? Date()
        for i in -7 ... 7 {
            let d = date.startOfDay().addingDays(days: i)
            guard Date().endOfDay().timeIntervalSince1970 < d.timeIntervalSince1970 else {
                continue
            }
            
            dates.append(d)
        }
        for i in 0 ..< dates.count {
            let possibleDate = dates[i]
            if possibleDate.compare(userDate) == .orderedSame{
                selectedDate = i

            }
        }
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    open override func templateForQuestion(questionId: String) -> Dictionary<String, String> {
        super.templateForQuestion(questionId: questionId)
        guard let index = QuestionId(rawValue: questionId) else {return [:]}
		
		if index == .user_schedule_2 {
            #warning("Use arc length")
            return ["start":  dates[selectedDate].localizedFormat(template:longFormat),
                    "DATE1":  dates[selectedDate].localizedFormat(template:longFormat),
                    "end":  dates[selectedDate].addingDays(days: 6).localizedFormat(template:longFormat),
                    "DATE2":  dates[selectedDate].addingDays(days: 6).localizedFormat(template:longFormat)]
        }
        return [:]
    }
    
    override open func onQuestionDisplayed(input: SurveyInput, index: String) {
        super.onQuestionDisplayed(input: input, index: index)
        guard let index = QuestionId(rawValue: index) else {return}
        
        switch index {
        case .user_schedule_1:
            guard let picker = input as? ACPickerView else {
                fatalError("Wrong input type, needs ACPickerView")
            }
            
            picker.set(dates.map({ (dateItem) -> String in
                //TODO: Refactor for reusability as needed
                return "\(dateItem.localizedFormat(template:mediumFormat)) - \(dateItem.addingDays(days: 6).localizedFormat(template:mediumFormat))"
            }))
            picker.setValue(AnyResponse(type: .picker, value: selectedDate))
            break
        case .user_schedule_2:
            let start = dates[selectedDate].startOfDay().addingDays(days: -3)
            let end = dates[selectedDate].startOfDay().addingDays(days: 10)

            let selectedStart = dates[selectedDate]
            let selectedEnd = selectedStart.startOfDay().addingDays(days: 6)
            
            var store = ACCalendarStore(range: start ... end)
            store.selectedDateRange = (selectedStart ... selectedEnd)
            
            input.setValue(AnyResponse(type: .calendar, value: store))
            
            
            break
        
        }
    }
    
    override open func onValueSelected(value: QuestionResponse, index: String) {
        //super.onValueSelected(value: value, index: index)
        guard let index = QuestionId(rawValue: index) else {return}

        
        switch index {
        case .user_schedule_1:
            guard let selectedIndex = value.value as? Int else {fatalError("Expected Int")}
            selectedDate = selectedIndex
            break
        case .user_schedule_2:
            
            guard let study = upComingStudy else {
                return
            }
            MHController.dataContext.performAndWait {

                study.userStartDate = dates[selectedDate]
                let new = Arc.shared.studyController.set(userStartDate: dates[selectedDate], forStudyId: Int(study.studyID))
                print(new?.userStartDate?.localizedString())
                
               let id = Int(study.studyID)
                
                Arc.shared.studyController.clear(upcomingSessions: id)
                Arc.shared.studyController.createTestSessions(studyId: id, isRescheduling: true)
                _ = Arc.shared.studyController.mark(confirmed: id)
                Arc.shared.notificationController.clear(sessionNotifications: id)
                Arc.shared.notificationController.schedule(upcomingSessionNotificationsWithLimit: 32)
                _ = Arc.shared.notificationController.scheduleDateConfirmationsForUpcomingStudy(force: true)

                Arc.shared.scheduleController.upload(confirmedSchedule: id);

                Arc.shared.studyController.save()
                Arc.shared.nextAvailableState()
            }
            break
            
        }
    }
    
}
