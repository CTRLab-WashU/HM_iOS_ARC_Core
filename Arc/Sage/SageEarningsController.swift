//
//  SageEarningsController.swift
//  HASD
//
//  Copyright © 2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import BridgeSDK

open class SageEarningsController: EarningsController {
    
    public static let fourFourEarning = "$1.00"
    public static let fourFourEarningVal = Float(1.0)
    public static let twoADayEarning = "$6.00"
    public static let twoADayEarningVal = Float(6.0)
    public static let twentyOneEarning = "$5.00"
    public static let twentyOneEarningVal = Float(5.0)
    public static let allSessionEarning = "$0.50"
    public static let allSessionEarningVal = Float(0.5)
    
    // The most recent earnings is used to compute how earnings change and new achievements made
    public var mostRecentEarnings: EarningsStruct? = nil
    
    private func earningValueStr(for goalName: String) -> String {
        switch goalName {
        case EarningsViewController.GoalDisplayName.fourOfFour.rawValue:
            return SageEarningsController.fourFourEarning
        case EarningsViewController.GoalDisplayName.twoADay.rawValue:
            return SageEarningsController.twoADayEarning
        case EarningsViewController.GoalDisplayName.totalSessions.rawValue:
            return SageEarningsController.twentyOneEarning
        default: // Any test session
            return SageEarningsController.allSessionEarning
        }
    }
    
    public override init() {
        super.init()
    }
    
    open var studyStartDate: TimeInterval? {
        // If it is an old install/login, firstTest is used
        return Arc.shared.studyController.firstTest?.session_date ??
            // If it is a fresh install, beginningOfStudy is used
            Arc.shared.studyController.beginningOfStudy.timeIntervalSince1970
    }
    
    open var arcStartDays: Dictionary<Int, Int> {
        return Arc.shared.studyController.ArcStartDays
    }
    
    open var now: Date {
        return Date()
    }
    
    open func cycleIdx(for week: Int) -> Int {
        for key in self.arcStartDays.keys {
            let val = self.arcStartDays[key]
            if week == val {
                return key
            }
        }
        return 0
    }
    
    open var currentPeriod: SessionInfoResponse.TestState? {
        guard let start = self.studyStartDate else {
            return nil
        }
        
        let studyPeriodStartDays = self.arcStartDays.values.sorted(by: <)
        
        let nowVal = now
        let calendar = Calendar.current
        let startDate = Date(timeIntervalSince1970: start).startOfDay()
                        
        guard let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: nowVal).day else {
            return nil
        }
        
        // Get the arc start day that is for the current period
        var currentArcIdx = studyPeriodStartDays.filter({ daysSinceStart >= $0 }).count - 1
        if (currentArcIdx < 0) {
            currentArcIdx = 0
        } else if (currentArcIdx >= studyPeriodStartDays.count) {
            currentArcIdx = studyPeriodStartDays.count - 1
        }
        
        // Check for baseline week which has slightly diff scheduling logic
        if (daysSinceStart <= 7) {
            return SessionInfoResponse.TestState(session_date: nowVal.timeIntervalSince1970, week: 0, day: daysSinceStart, session: 0, session_id: "")
        }
        
        let weeksSinceStart = studyPeriodStartDays[currentArcIdx] / 7
        let dayOfWeek = daysSinceStart - (weeksSinceStart * 7)
        
        return SessionInfoResponse.TestState(session_date: nowVal.timeIntervalSince1970, week: weeksSinceStart, day: dayOfWeek, session: 0, session_id: "")
    }
    
    open var completedTests: Array<CompletedTest> {
        // All completed tests except for the tutorial baseline test on week 0, day 0
        return filterAndConvertTests(tests: TaskListScheduleManager.shared.completedTestList)
    }
    
    // The completed test data coming down from the web is inconsistent and includes the baseline test
    // First, filter out the baseline tutorial test, since that does not earn anything
    // Also, unforuntaely on iOS there is a "week" field bug where all study period weeks,
    // are labeled incorrectly, being one off the correct one, so fix that by
    // snapping the week number to the expected.
    // This same fix will correct an issue on Android where week 0, day 7 shows up
    // as week 1, day 7, the week will snap back to week 0
    public func filterAndConvertTests(tests: Array<CompletedTest>) -> Array<CompletedTest> {
        // If a week number is less than or equal to two weeks away, we snap to it
        let minAcceptableDistance = 2
        let expectedWeeks = self.arcStartDays.values.map({ $0 / 7 })
        let converted = tests.map { (test) -> CompletedTest in
            var newWeek = test.week
            if (!expectedWeeks.contains(test.week)) {
                expectedWeeks.forEach { (weekNum) in
                    if (abs(test.week - weekNum) <= minAcceptableDistance) {
                        newWeek = weekNum
                    }
                }
            }
            return CompletedTest(week: newWeek, day: test.day, session: test.session, completedOn: test.completedOn)
        }
        return converted.filter({ $0.week != 0 || $0.day != 0 })
    }
    
    public func calculateAllSessionsGoal(completed: Array<CompletedTest>,
                                         for testState: SessionInfoResponse.TestState) -> SageGoal {
                
        let completedCount = completed.filter { (test) -> Bool in
            return test.week == testState.week
        }.count
              
        let targetCompleteCout = 28 // 7 days with 4 sessions a day
        let name = EarningsViewController.GoalDisplayName.testSession.rawValue
        let value = SageEarningsController.allSessionEarning
        let progress = Int(100 * Float(completedCount) / Float(targetCompleteCout))
        let progressComponents: [Int] = [completedCount]
        let amountEarned = "$1?"  // not sure what this is?
        let isComplete = false // this is not really a completable goal, always make it false
        let completedOn: TimeInterval? = nil
        
        let earningsVal = SageEarningsController.allSessionEarningVal * Float(min(completedCount, 28))
        
        let goal = EarningOverview.Response.Earnings.Goal(name: name, value: value, progress: progress, amount_earned: amountEarned, completed: isComplete, completed_on: completedOn, progress_components: progressComponents)
        
        return SageGoal(goal: goal, earnings: earningsVal, testState: testState)
    }
    
    public func calculateTwentyOneGoal(completed: Array<CompletedTest>,
                                       for testState: SessionInfoResponse.TestState) -> SageGoal {
                
        let completedCount = completed.filter { (test) -> Bool in
            return test.week == testState.week
        }.count
                       
        var earningsVal = Float(0.0)
        let targetCompleteCout = 21
        let name = EarningsViewController.GoalDisplayName.totalSessions.rawValue
        let value = SageEarningsController.twentyOneEarning
        let progress = Int(100 * Float(completedCount) / Float(targetCompleteCout))
        let progressComponents: [Int] = [completedCount]
        let amountEarned = "$1?"  // not sure what this is?
        let isComplete = completedCount >= targetCompleteCout
        var completedOn: TimeInterval? = nil
        if (isComplete) {
            earningsVal = SageEarningsController.twentyOneEarningVal
            let lastCompleted = completed.filter { (test) -> Bool in
                return test.week == testState.week
            }.sorted { (test1, test2) -> Bool in
                return test1.completedOn < test2.completedOn
            }.last
            completedOn = lastCompleted?.completedOn ?? Date().timeIntervalSince1970
        }

        let goal = EarningOverview.Response.Earnings.Goal(name: name, value: value, progress: progress, amount_earned: amountEarned, completed: isComplete, completed_on: completedOn, progress_components: progressComponents)
        
        return SageGoal(goal: goal, earnings: earningsVal, testState: testState)
    }
    
    public func calculateTwoADayGoal(completed: Array<CompletedTest>,
                                     for testState: SessionInfoResponse.TestState) -> SageGoal {
        
        let targetDaySessionCompleteCout = 2
        var progressComponents: [Int] = [0, 0, 0, 0, 0, 0, 0]
        let startDayIdx = testState.week == 0 ? 1 : 0
        let dayIdxAdjustment = testState.week == 0 ? -1 : 0
        for dayIdx in startDayIdx ..< (startDayIdx + 7) {
            let count = completed.filter { (test) -> Bool in
                return test.week == testState.week && test.day == dayIdx
            }.count
            let progressIdx = dayIdx + dayIdxAdjustment
            if (progressIdx < progressComponents.count &&
                    count >= targetDaySessionCompleteCout) {
                progressComponents[progressIdx] = 100
            }
        }
                       
        var earningsVal = Float(0.0)
        let targetCompleteCout = 7
        let completedCount = progressComponents.filter({ $0 >= 100 }).count
        let name = EarningsViewController.GoalDisplayName.twoADay.rawValue
        let value = SageEarningsController.twoADayEarning
        let progress = Int(100 * Float(completedCount) / Float(targetCompleteCout))
        let amountEarned = "$1?"  // not sure what this is?
        let isComplete = completedCount >= targetCompleteCout
        var completedOn: TimeInterval? = nil
        if (isComplete) {
            earningsVal = SageEarningsController.twoADayEarningVal
            let lastCompleted = completed.filter { (test) -> Bool in
                return test.week == testState.week
            }.sorted { (test1, test2) -> Bool in
                return test1.completedOn < test2.completedOn
            }.last
            completedOn = lastCompleted?.completedOn ?? Date().timeIntervalSince1970
        }

        let goal = EarningOverview.Response.Earnings.Goal(name: name, value: value, progress: progress, amount_earned: amountEarned, completed: isComplete, completed_on: completedOn, progress_components: progressComponents)
        
        return SageGoal(goal: goal, earnings: earningsVal, testState: testState)
    }
    
    public func calculateFourFourGoal(completed: Array<CompletedTest>,
                                      for testState: SessionInfoResponse.TestState) -> SageGoal {
        
        var earningsVal = Float(0.0)
        var progressComponents: [Int] = [0, 0, 0, 0]
        let applicableTests = completed.filter { (test) -> Bool in
            let isApplicable = test.week == testState.week && test.day == testState.day
            if (isApplicable && test.session < progressComponents.count) {
                progressComponents[test.session] = 100
            }
            return isApplicable
        }.sorted { (test1, test2) -> Bool in
            return test1.completedOn < test2.completedOn
        }
                
        let targetCompleteCout = 4
        let name = EarningsViewController.GoalDisplayName.fourOfFour.rawValue
        let value = SageEarningsController.fourFourEarning
        let progress = Int(100 * Float(applicableTests.count) / Float(targetCompleteCout))
        let amountEarned = "$1?"  // not sure what this is?
        let isComplete = applicableTests.count >= targetCompleteCout
        var completedOn: TimeInterval? = nil
        if (isComplete) {
            earningsVal = SageEarningsController.fourFourEarningVal
            completedOn = applicableTests.last?.completedOn ?? Date().timeIntervalSince1970
        }
        
        let goal = EarningOverview.Response.Earnings.Goal(name: name, value: value, progress: progress, amount_earned: amountEarned, completed: isComplete, completed_on: completedOn, progress_components: progressComponents)

        return SageGoal(goal: goal, earnings: earningsVal, testState: testState)
    }
    
    public func calculateAllGoals(completed: Array<CompletedTest>,
        for studyPeriod: SessionInfoResponse.TestState) -> [SageGoal] {
        
        // These are the current week/day that show up on the earnings tab
        let twoADayGoal = self.calculateTwoADayGoal(completed: completed, for: studyPeriod)
        let twentyOneGoal = self.calculateTwentyOneGoal(completed: completed, for: studyPeriod)
        let allSessionsGoal = self.calculateAllSessionsGoal(completed: completed, for: studyPeriod)
        
        // Calculate the other 4 of 4 goals for the period
        let startDay = (studyPeriod.week == 0) ? 1 : 0
        let all4of4Goals = (startDay ..< startDay + 7).map { (i) -> SageGoal in
            let testState = SessionInfoResponse.TestState(session_date: studyPeriod.session_date, week: studyPeriod.week, day: i, session: studyPeriod.session, session_id: studyPeriod.session_id)
            return self.calculateFourFourGoal(completed: completed, for: testState)
        }
        
        var allGoals = [twoADayGoal, twentyOneGoal, allSessionsGoal]
        allGoals.append(contentsOf: all4of4Goals)
        
        return allGoals
    }    
    
    // Returns an array where the index of each element corresponds to the study period id
    public func calculateEarningsMap(
        completed: Array<CompletedTest>,
        atAndBefore current: SessionInfoResponse.TestState) -> [[SageGoal]] {
        
        let nowVal = self.now.timeIntervalSince1970
        
        // Get all study periods before the current to get past earnings
        let studyPeriods = self.arcStartDays.values.sorted(by: <)
            .filter({ ($0 / 7) <= current.week })
            // session_date isn't used, so just make it "now"
            // also, use day 1, as every study period has a day 1
            .map({ SessionInfoResponse.TestState(session_date: nowVal, week: ($0 / 7), day: 1, session: 0, session_id: "" )})
        
        return studyPeriods.map { (state) -> [SageGoal] in
            return self.calculateAllGoals(completed: completed, for: state)
        }
    }
    
    public func calculateEarningsOverview(
        completed: Array<CompletedTest>,
        current: SessionInfoResponse.TestState,
        allGoals: [[SageGoal]]) -> EarningOverview? {
        
        // These are the current week/day that show up on the earnings tab
        let currentGoals = allGoals.last ?? []
        
        // Calculate the cycle earnings
        let cycleEarnings = currentGoals.map({ $0.earnings }).reduce(0, +)
        let cycelEarningsStr = String(format: "$%.2f", cycleEarnings)
        
        // Calculate the total earnings of all study periods
        var totalEarnings = Float(0)
        allGoals.forEach({
            totalEarnings += $0.map({ $0.earnings }).reduce(0, +)
        })
        let totalEarningsStr = String(format: "$%.2f", totalEarnings)
        
        // For the earnings overview goals, we should only include today's 4 of 4 goal
        var overviewGoals = currentGoals.filter({ $0.goal.name !=
            EarningsViewController.GoalDisplayName.fourOfFour.rawValue
        })
        if let todays4of4Goal = currentGoals.filter({ $0.goal.name ==
            EarningsViewController.GoalDisplayName.fourOfFour.rawValue &&
            $0.testState.week == current.week && $0.testState.day == current.day
        }).first {
            overviewGoals.append(todays4of4Goal)
        }
        
        let goals = overviewGoals.map({ $0.goal })
        
        var newAchievements = [EarningOverview.Response.Earnings.Achievement]()
        if let oldGoals = self.mostRecentEarnings?.earningOverview?.response?.earnings?.goals {
            newAchievements = self.calculateAchievements(old: oldGoals, new: goals)
        }
        
        let cycle = max(0, allGoals.count - 1)
        
        let earnings = EarningOverview.Response.Earnings(total_earnings: totalEarningsStr, cycle: cycle, day: current.day, cycle_earnings: cycelEarningsStr, goals: goals, new_achievements: newAchievements)
        
        let response = EarningOverview.Response(success: true, earnings: earnings)
        let overview = EarningOverview(response: response, errors: [:])
        
        return overview
    }
    
    public func calculateEarningsDetail(
        studyStart: Date,
        completed: Array<CompletedTest>,
        current: SessionInfoResponse.TestState,
        allGoals: [[SageGoal]]) -> EarningDetail? {
        
        let detailNames = [
            EarningsViewController.GoalDisplayName.fourOfFour.rawValue,
            EarningsViewController.GoalDisplayName.twoADay.rawValue,
            EarningsViewController.GoalDisplayName.totalSessions.rawValue,  // 21 goal
            EarningsViewController.GoalDisplayName.testSession.rawValue]
        
        var totalEarnings = Float(0)
        var cycles = [EarningDetail.Response.Earnings.Cycle]()
        for studyPeriodIdx in 0 ..< allGoals.count {
            let periodGoals = allGoals[studyPeriodIdx]
            
            let details = detailNames.map { (name) -> EarningDetail.Response.Earnings.Cycle.Detail in
                let value = earningValueStr(for: name)
                let goals = periodGoals.filter({ $0.goal.name == name })
                let completed = goals.filter({ $0.goal.completed == true }).count
                let amountEarned = goals.map({ $0.earnings }).reduce(0, +)
                let amountEarnedStr = String(format: "$%.2f", amountEarned)
                return EarningDetail.Response.Earnings.Cycle.Detail(name: name, value: value, count_completed: completed, amount_earned: amountEarnedStr)
            }
            
            // These are only used in showing earnings details, doesn't need to perfectly match
            // what is stored in the app for StudyPeriod start/stop
            let periodStartDayOffset = self.arcStartDays[studyPeriodIdx] ?? 0
            let periodStart = studyStart.startOfDay().addingDays(days: periodStartDayOffset)
            let periodEnd = studyStart.startOfDay().addingDays(days: periodStartDayOffset + 7)
            
            let periodEarnings = periodGoals.map({ $0.earnings }).reduce(0, +)
            let periodEarningsStr = String(format: "$%.2f", periodEarnings)
            
            totalEarnings += periodEarnings
            
            cycles.append(EarningDetail.Response.Earnings.Cycle(cycle: studyPeriodIdx, total: periodEarningsStr, start_date: periodStart.timeIntervalSince1970, end_date: periodEnd.timeIntervalSince1970, details: details))
        }
        
        let totalEarningsStr = String(format: "$%.2f", totalEarnings)
        
        let earningsObj = EarningDetail.Response.Earnings(total_earnings: totalEarningsStr, cycles: cycles)
        let response = EarningDetail.Response(success: true, earnings: earningsObj)
        
        return EarningDetail(response: response, errors: [:])
    }
    
    public func calculateStudySummary(
        completed: Array<CompletedTest>,
        current: SessionInfoResponse.TestState,
        allGoals: [[SageGoal]]) -> StudySummary? {
        
        var totalEarnings = Float(0)
        allGoals.forEach({
            totalEarnings += $0.map({ $0.earnings }).reduce(0, +)
        })
        let totalEarningsStr = String(format: "$%.2f", totalEarnings)
        
        var goalsMet = 0
        allGoals.forEach { (goals) in
            goalsMet += goals.filter({ $0.goal.completed == true }).count
        }
       
        // Get the days through the current period, and then all other periods are 7 days of tests
        var daysTested = min(7, (current.week == 0) ? current.day - 1 : current.day)
        if (allGoals.count > 1) {
            daysTested += (allGoals.count - 1) * 7
        }
        daysTested = max(0, daysTested) // fix baseline day being -1
        
        let testsTaken = completed.count
        
        let summary = StudySummary.Response.Summary(total_earnings: totalEarningsStr, tests_taken: testsTaken, days_tested: daysTested, goals_met: goalsMet)
        let response = StudySummary.Response(success: true, summary: summary)
        
        return StudySummary(response: response)
    }
    
    open func recalculateEarnings() -> EarningsStruct {
        
        guard let current = self.currentPeriod,
              let studyStart = self.studyStartDate else {
            return EarningsStruct(earningOverview: nil, earningDetail: nil, studySummary: nil)
        }
        let startDate = Date(timeIntervalSince1970: studyStart)
        
        // This getter does some converting and filtering, so only compute once and pass
        // around to other functions that need it
        let completed = self.completedTests
        
        // Calculate all the goals for the current study period, and all previous
        let allGoals = self.calculateEarningsMap(completed: completed, atAndBefore: current)
        
        let overview = self.calculateEarningsOverview(completed: completed, current: current, allGoals: allGoals)
        let detail = self.calculateEarningsDetail(studyStart: startDate, completed: completed, current: current, allGoals: allGoals)
        let summary = self.calculateStudySummary(completed: completed, current: current, allGoals: allGoals)
        
        return EarningsStruct(earningOverview: overview, earningDetail: detail, studySummary: summary)
    }
    
    open func calculateTotalEarnings() -> String {
        guard let current = self.currentPeriod else {
            return ""
        }
        
        // This getter does some converting and filtering, so only compute once and pass
        // around to other functions that need it
        let completed = self.completedTests
        
        let allGoals = self.calculateEarningsMap(completed: completed, atAndBefore: current)
        
        var totalEarnings = Float(0)
        allGoals.forEach { (goals) in
            totalEarnings += goals.map({ $0.earnings }).reduce(0, +)
        }
        
        return String(format: "$%.2f", totalEarnings)
    }
    
    override open func updateEarnings() {
        
        debugPrint("Sage updateEarnings")
    
        self.mostRecentEarnings = self.recalculateEarnings()
        
        if let overview = self.mostRecentEarnings?.earningOverview {
            Arc.shared.appController.lastFetched[EarningsController.overviewKey] = Date().timeIntervalSince1970
            Arc.shared.appController.store(value: overview, forKey: EarningsController.overviewKey)
            NotificationCenter.default.post(name: .ACEarningsUpdated, object: overview)
        }
        
        if let detail = self.mostRecentEarnings?.earningDetail {
            Arc.shared.appController.lastFetched[EarningsController.detailKey] = Date().timeIntervalSince1970
            Arc.shared.appController.store(value: detail, forKey: EarningsController.detailKey)
            NotificationCenter.default.post(name: .ACEarningDetailsUpdated, object: detail)
        }
        
        if let summary = self.mostRecentEarnings?.studySummary {
            Arc.shared.appController.lastFetched[EarningsController.studySummaryKey] = Date().timeIntervalSince1970
            Arc.shared.appController.store(value: summary, forKey: EarningsController.studySummaryKey)
            NotificationCenter.default.post(name: .ACStudySummaryUpdated, object: summary)
        }        
    }
    
    open func calculateAchievements(old: [EarningOverview.Response.Earnings.Goal],
                                    new: [EarningOverview.Response.Earnings.Goal]) -> [EarningOverview.Response.Earnings.Achievement] {
        
        var achievements = [EarningOverview.Response.Earnings.Achievement]()
        
        // There are three goals that earn you achievements
        [EarningsViewController.GoalDisplayName.twoADay.rawValue,
         EarningsViewController.GoalDisplayName.totalSessions.rawValue,
         EarningsViewController.GoalDisplayName.fourOfFour.rawValue].forEach { (name) in
            
            if let newGoal = new.first(where: { $0.name == name }),
               let oldGoal = old.first(where: { $0.name == name }) {
                if (newGoal.completed == true && oldGoal.completed == false) {
                    achievements.append(EarningOverview.Response.Earnings.Achievement(name: name, amount_earned: newGoal.value))
                }
            }
         }

        return achievements
    }
}

public struct EarningsStruct {
    public var earningOverview: EarningOverview?
    public var earningDetail: EarningDetail?
    public var studySummary: StudySummary?
}

public struct SageGoal {
    public var goal: EarningOverview.Response.Earnings.Goal
    public var earnings: Float
    public var testState: SessionInfoResponse.TestState
}
