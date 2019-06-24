//
//  ACScheduleController.swift
//  AC
//
//  Created by Philip Hayes on 11/13/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
public class ACScheduleViewController : SurveyNavigationViewController {
    
    open override func templateForQuestion(questionId:String) -> Dictionary<String, String> {
        
        guard QuestionIndex.init(rawValue: questionId) == .schedule_3 else {
            return [:]
        }
        
        let wake_time = wakeSleeptimes[.schedule_1]?.time
        let sleep_time = wakeSleeptimes[.schedule_2]?.time
        
        return ["wake_time":wake_time!, "sleep_time":sleep_time!, "TIME1":wake_time!, "TIME2":sleep_time!]
    }
    
    // enum values:
    // schedule_1, schedule_2: Monday wake/sleep
    // schedule_3: "Do you usually wake up/go to bed..."
    // schedule_sub_1, schedule_sub_2: Tuesday
    // schedule_sub_3, schedule_sub_4: Wednesday
    // schedule_sub_5, schedule_sub_6: Thursday
    // schedule_sub_7, schedule_sub_8: Friday
    // schedule_4, schedule_5: Saturday
    // schedule_6, schedule_7: Sunday
    
	enum QuestionIndex : String, CaseIterable {
		case schedule_1, schedule_2, schedule_3, schedule_sub_1, schedule_sub_2, schedule_sub_3, schedule_sub_4, schedule_sub_5, schedule_sub_6, schedule_sub_7, schedule_sub_8, schedule_4, schedule_5, schedule_6, schedule_7
		
		var day:Int? {
			switch self {
			case .schedule_1, .schedule_2:
				return 1
			case .schedule_sub_1, .schedule_sub_2:
				return 2
			case .schedule_sub_3, .schedule_sub_4:
				return 3
			case .schedule_sub_5, .schedule_sub_6:
				return 4
			case .schedule_sub_7, .schedule_sub_8:
				return 5
			case .schedule_4, .schedule_5:
				return 6
			case .schedule_6, .schedule_7:
				return 0
			default:
				return nil
			}
		}
		static var wakeTimeQuestion:Array<QuestionIndex> {
			return [.schedule_1,
				 .schedule_sub_1,
				 .schedule_sub_3,
				 .schedule_sub_5,
				 .schedule_sub_7,
				 .schedule_4,
				 .schedule_6]

			
		}
		static var sleepTimeQuestion:Array<QuestionIndex> {
			return [.schedule_2,
					.schedule_sub_2,
					.schedule_sub_4,
					.schedule_sub_6,
					.schedule_sub_8,
					.schedule_5,
					.schedule_7]
		
		
        }
    }

	
	struct DayTime {
		var time:String
		var day:Int
	}
    
    
	var wakeSleeptimes:[QuestionIndex:DayTime] = [:]
	public var isChangingSchedule = false
	var error:String?
    
    public var shouldLimitWakeTime = false
	override open func loadSurvey(template:String) {
		survey = Arc.shared.surveyController.load(survey: template)
		self.surveyId = Arc.shared.surveyController.get(surveyResponse: "availability")?.id ??
			Arc.shared.surveyController.create(surveyResponse: "availability",type: SurveyType.schedule)
		shouldShowHelpButton = true
		
		shouldNavigateToNextState = false
		
		
		questions = survey.questions
		
		for question in questions  {
			guard let v = Arc.shared.surveyController.getResponse(forQuestion: question.questionId, fromSurveyResponse: surveyId!) else  {
				continue
			}
			guard let index = QuestionIndex(rawValue: question.questionId) else {
				continue
			}
			guard let day = index.day else {
				continue
			}
			guard let value = v.value as? String else {
				continue
			}
			
			
			wakeSleeptimes[index] = DayTime(time: value, day: day)
			
		}
	}
	
	override open func onQuestionDisplayed(input:SurveyInput, index:String) {
		let qIndex = QuestionIndex(rawValue: index)!
		let responseValue = Arc.shared.surveyController.getResponse(forQuestion: index, fromSurveyResponse: surveyId!)
		guard qIndex != .schedule_3 else {
			
			input.setValue(responseValue)

			return
		}
		if let value = wakeSleeptimes[qIndex] {
			input.setValue(AnyResponse(type: .time, value: value.time))
		}
        
        
		
	}
    public override func onFinishSetup(index: String) {
        if let newValue = getValue(), isValid(value: newValue, index: index)
        {
            enableNextButton();
            
        }
        else
        {
            disableNextButton();
            
        }
        setError(message:error)
    }
    public override func onValueChanged(index: String) {
        
        
        if let newValue = getValue(), isValid(value: newValue, index: index)
        {
            enableNextButton();
            
        }
        else
        {
            disableNextButton();
            
        }
        setError(message:error)
    }
    public override func isValid(value: QuestionResponse, index: String) -> Bool {
     	error = nil
        guard let index = QuestionIndex(rawValue: index) else { return false; }
        
        // If we're attempting to set a sleep time, we need to check and make sure that it's not
        // too close to the set wake time (and that it's not set to the same exact time)
        
        guard let sleepTimeIdx = QuestionIndex.sleepTimeQuestion.firstIndex(of: index), let day = index.day else {
            return !value.isEmpty()
        }
        let wakeIndex = QuestionIndex.wakeTimeQuestion[sleepTimeIdx];
        let sleepTime = DayTime(time: value.value as! String, day: day);
        guard let wakeTime = wakeSleeptimes[wakeIndex] else { return false; }
        
        let formatter = DateFormatter()
        formatter.defaultDate = Date();
        formatter.dateFormat = "h:mm a"
        
        if let wake = formatter.date(from: wakeTime.time),
            var sleep = formatter.date(from: sleepTime.time)
        {
            // If the sleep time is actually "before" the wake time (like they go to sleep at 1am and wake up at 11 am),
            // then we need to add a day to the sleep date, to make the math work right.
            // We can't just look at fabs(sleep.timeIntervalSince(wake)), because it won't take into account the change in day
            // properly. If they, for instance, set their sleep time to 1am, and their wake time to 4am, checking the absolute
            // value would only give us 3 hours, but the reality is that it's 21 hours.
            
            if wake.compare(sleep) == .orderedDescending
            {
                sleep = sleep.addingDays(days: 1);
            }
            
            if sleep.timeIntervalSince(wake) < 28800
            {
                
                error = "Please set a minimum of 8 hours of wake time.".localized("error4")
                return false;
            }
            
            if sleep.timeIntervalSince(wake) > 18 * 60 * 60 && shouldLimitWakeTime
            {
                
                error = " " //Please enter less than 18 hours of wake time.".localized("error5")
                return false;
            }
        }
        
        return true;
    
    }
	
	//Override this to write to other controllers
	override open func onValueSelected(value:QuestionResponse, index:String) {
		super.onValueSelected(value: value, index: index)

		let index = QuestionIndex(rawValue: index)!
		if let day = index.day {
			wakeSleeptimes[index] = DayTime(time: value.value as! String, day: day)
		}
        
        if let wakeIndex = QuestionIndex.wakeTimeQuestion.firstIndex(of: index) {
            if (index != .schedule_6) {
                var wakeTime = wakeSleeptimes[index]
                
                let newIndex = QuestionIndex.wakeTimeQuestion[wakeIndex+1]
                
                wakeTime?.day = newIndex.day!
                wakeSleeptimes[newIndex] = wakeTime
            }
        }
            
        else if let sleepIndex = QuestionIndex.sleepTimeQuestion.firstIndex(of: index) {
            if (index != .schedule_7) {
                var sleepTime = wakeSleeptimes[index]
                
                let newIndex = QuestionIndex.sleepTimeQuestion[sleepIndex+1]
                
                sleepTime?.day = newIndex.day!
                wakeSleeptimes[newIndex] = sleepTime
            }
        }
		
		//If we say yes to the rest of the weekdays being the same
		//set those days to the selections chosen for monday
        if index == .schedule_3 && (value.value as! Int) == 0 /* Yes is the 0 index */ {
            var wakeTime = wakeSleeptimes[.schedule_1]
            for index in QuestionIndex.wakeTimeQuestion {
                guard index != .schedule_1 else {
                    continue
                }
                wakeTime?.day = index.day!
                wakeSleeptimes[index] = wakeTime
            }

            var sleepTime = wakeSleeptimes[.schedule_2]
            for index in QuestionIndex.sleepTimeQuestion {
                guard index != .schedule_2 else {
                    continue
                }
                sleepTime?.day = index.day!
                wakeSleeptimes[index] = sleepTime
            }

        }
		
		//this is the id of the final question
		//once we've answered the final question lets produce results
		guard index == .schedule_7  else {
			return
			
		}
		
		let _ = Arc.shared.scheduleController.delete(schedulesForParticipant: self.participantId!)
		
		for day in 0 ... 6 {
			let weekDay = WeekDay.init(rawValue: Int64(day))!
			let wakeKey = QuestionIndex.allCases.filter({
				$0.day == day && QuestionIndex.wakeTimeQuestion.contains($0)
			}).first!
			let sleepKey = QuestionIndex.allCases.filter({
				$0.day == day && QuestionIndex.sleepTimeQuestion.contains($0)
			}).first!

			let wake = wakeSleeptimes[wakeKey]!.time
			let sleep = wakeSleeptimes[sleepKey]!.time
			let _ = Arc.shared.scheduleController.create(entry: wake,
														endTime: sleep,
														weekDay: weekDay,
														participantId: self.participantId!)
		}
		let _ = Arc.shared.scheduleController.get(confirmedSchedule: self.participantId!)

		

		//Probably see where the app wants to go next
		if let top = self.topViewController as? SurveyViewController {
			top.nextButton.showSpinner(color: UIColor(white: 1.0, alpha: 0.8), backgroundColor:UIColor(named:"Primary") )
		}
	
	
		//			DispatchQueue.global(qos: .userInteractive).async {
        MHController.dataContext.performAndWait {

        
            // If firstTest is set, that means we've probably recently re-installed the app, and are recreating a schedule.
            // So set beginningOfStudy to be the session_date of the first test.
            // Othwerwise, we'll just let beginningOfStudy's get handler set the date for us.
            
            if let firstTest = Arc.shared.studyController.firstTest {
                Arc.shared.studyController.beginningOfStudy = Date(timeIntervalSince1970: firstTest.session_date)
            }
            
            let date = Arc.shared.studyController.beginningOfStudy;
            if self.isChangingSchedule {
				
                let studies = Arc.shared.studyController.getAllStudyPeriods().sorted(by: {$0.studyID < $1.studyID})
                let sessions = Arc.shared.studyController.getUpcomingSessions(withLimit: 5)
				var dayIndex:Int?
				var afterDate:Date?
				for session in sessions {
					if dayIndex == nil {
						dayIndex = Int(session.day)
					}
					if dayIndex == Int(session.day) {
						afterDate = session.sessionDate
					}
				}
				
                for study in studies {
                    	Arc.shared.notificationController.clear(sessionNotifications: Int(study.studyID))
                    Arc.shared.studyController.clear(sessions: Int(study.studyID), afterDate: afterDate!)

                }
            } else {
                _ = Arc.shared.studyController.createAllStudyPeriods(startingID: 0, startDate: date)
            }
            var studies = Arc.shared.studyController.getAllStudyPeriods().sorted(by: {$0.studyID < $1.studyID})
            for i in 0 ..< studies.count{
				
                let study = studies[i]
				
				let sc = Arc.shared.studyController
                sc.createTestSessions(studyId: Int(study.studyID), isRescheduling: self.isChangingSchedule);
               
                
                _ = Arc.shared.studyController.mark(confirmed: Int(study.studyID))
                Arc.shared.notificationController.clear(sessionNotifications: Int(study.studyID))
            }
            
            // And now, delete any test sessions that have already passed.
            // studyController.latestTest is the most recent test that has passed, according to the server.
            
            for i in 0 ..< studies.count {
                if let latestTest = Arc.shared.studyController.latestTest, let session = Int(latestTest.session_id){
                    Arc.shared.studyController.delete(sessionsUpTo: session, inStudy: i)
                }
            }
            
            //Refetch the studies and upload
            
            studies = Arc.shared.studyController.getAllStudyPeriods().sorted(by: {$0.studyID < $1.studyID})
            
            Arc.shared.notificationController.schedule(upcomingSessionNotificationsWithLimit: 32)
             _ = Arc.shared.notificationController.scheduleDateConfirmationsForUpcomingStudy()
            Arc.shared.sessionController.uploadSchedule(studyPeriods: studies)
            
            if let study = studies.first
            {
                Arc.shared.scheduleController.upload(confirmedSchedule: Int(study.studyID));
            }
            
            
            Arc.shared.studyController.save()
            
            DispatchQueue.main.async { [weak self] in
                self?.view.hideSpinner()
                if let top = self?.topViewController as? SurveyViewController {
                    top.nextButton.hideSpinner()

                }
                self?.didFinishScheduling()
            }
        }

		

	}
    open func didFinishScheduling() {
        //If we have a latest test then we shouldn't be going straight into anything.
        if Arc.shared.studyController.latestTest == nil && isChangingSchedule == false{
            _ = Arc.shared.startTestIfAvailable()
        }
        Arc.shared.nextAvailableState()
    }
	
}
