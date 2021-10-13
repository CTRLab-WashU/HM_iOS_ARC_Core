//
//  SageEarningsControllerTests.swift
//  Arc
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

import XCTest
@testable import Arc

class SageEarningsContrllerTests: XCTestCase {

    let controller = MockSageEarningsController()
    
    func startDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: "2021/08/10 11:21")!
    }
    
    func studyPeriod1Start() -> TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: "2021/08/10 00:00")!.timeIntervalSince1970
    }
    
    func studyPeriod1End() -> TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.date(from: "2021/08/17 00:00")!.timeIntervalSince1970
    }
    
    func studyPeriod2Start() -> TimeInterval {
        return Date(timeIntervalSince1970: studyPeriod1Start()).addingDays(days: 182).timeIntervalSince1970
    }
    
    func studyPeriod2End() -> TimeInterval {
        return Date(timeIntervalSince1970: studyPeriod1Start()).addingDays(days: 182 + 7).timeIntervalSince1970
    }
    
    override func setUp() {
        super.setUp()
        controller.overridingStudyStartDate = startDate().timeIntervalSince1970
    }
    
    func testDay0() {
        // User should not get earnings for day 0, which is the tutorial
        controller.overrideCompletedTests = [createTest(0, 0)]
        controller.overridingNow = startDate().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress, 0)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress, 0)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNil(fourOfFourGoal) // no 4 of 4 on baseline tutorial day
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress, 0)
        
        XCTAssertEqual(earnings?.cycle_earnings, "$0.00")
        XCTAssertEqual(earnings?.total_earnings, "$0.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 0)
        XCTAssertEqual(summary?.goals_met, 0)
        XCTAssertEqual(summary?.tests_taken, 0)
        XCTAssertEqual(summary?.total_earnings, "$0.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$0.00")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$0.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testDay1Unfinished() {
        // User should not get earnings for day 0, but gets earnings from day 1, 3 sessions complete
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2)]
        
        controller.overridingNow = startDate().addingDays(days: 1).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [3])
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 0, 0, 0, 0, 0, 0])
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [3])
        
        // 3 .testSession goals at $0.50 each
        XCTAssertEqual(earnings?.cycle_earnings, "$1.50")
        XCTAssertEqual(earnings?.total_earnings, "$1.50")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 0)
        XCTAssertEqual(summary?.goals_met, 0)
        XCTAssertEqual(summary?.tests_taken, 3)
        XCTAssertEqual(summary?.total_earnings, "$1.50")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$1.50")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$1.50")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testDay1Finished() {
        // User should not get earnings for day 0, but gets earnings from day 1, 3 sessions complete
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 1).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [4])
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 0, 0, 0, 0, 0, 0])
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [4])
        
        // 4 .testSession goals at $0.50 each, and the 4 of 4 goal of $1
        XCTAssertEqual(earnings?.cycle_earnings, "$3.00")
        XCTAssertEqual(earnings?.total_earnings, "$3.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 0)
        XCTAssertEqual(summary?.goals_met, 1)
        XCTAssertEqual(summary?.tests_taken, 4)
        XCTAssertEqual(summary?.total_earnings, "$3.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$3.00")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$3.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testWeek1Unfinished() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1),
            createTest(0, 2, 0), createTest(0, 2, 1),
            createTest(0, 3, 0), createTest(0, 3, 1),
            createTest(0, 4, 0), createTest(0, 4, 1),
            createTest(0, 5, 0), createTest(0, 5, 1),
            createTest(0, 6, 0), createTest(0, 6, 1),
            createTest(0, 7, 0)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [13])
        XCTAssertFalse(twentyOneGoal?.completed ?? true)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 0])
        XCTAssertFalse(twoADayGoal?.completed ?? true)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 0, 0, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [13])
        
        // 13 .testSession goals at $0.50 each
        XCTAssertEqual(earnings?.cycle_earnings, "$6.50")
        XCTAssertEqual(earnings?.total_earnings, "$6.50")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 6)
        XCTAssertEqual(summary?.goals_met, 0)
        XCTAssertEqual(summary?.tests_taken, 13)
        XCTAssertEqual(summary?.total_earnings, "$6.50")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$6.50")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$6.50")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testWeek1Finished() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [21])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [21])
        
        // 21 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        XCTAssertEqual(earnings?.cycle_earnings, "$21.50")
        XCTAssertEqual(earnings?.total_earnings, "$21.50")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 6)
        XCTAssertEqual(summary?.goals_met, 2)
        XCTAssertEqual(summary?.tests_taken, 21)
        XCTAssertEqual(summary?.total_earnings, "$21.50")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$21.50")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$21.50")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testWeek1PerfectiOS() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [28])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [28])
        
        // 28 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        // 7 four of four goals at $1 each
        XCTAssertEqual(earnings?.cycle_earnings, "$32.00")
        XCTAssertEqual(earnings?.total_earnings, "$32.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 6)
        XCTAssertEqual(summary?.goals_met, 9)
        XCTAssertEqual(summary?.tests_taken, 28)
        XCTAssertEqual(summary?.total_earnings, "$32.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$32.00")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testWeek1PerfectAndroid() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            // Android labels week 0, day 7 as week 1, day 7, make sure algo accounts for it
            createTest(1, 7, 0), createTest(1, 7, 1), createTest(1, 7, 2), createTest(1, 7, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [28])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [28])
        
        // 28 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        // 7 four of four goals at $1 each
        XCTAssertEqual(earnings?.cycle_earnings, "$32.00")
        XCTAssertEqual(earnings?.total_earnings, "$32.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 6)
        XCTAssertEqual(summary?.goals_met, 9)
        XCTAssertEqual(summary?.tests_taken, 28)
        XCTAssertEqual(summary?.total_earnings, "$32.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$32.00")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testWeek1PerfectExtraBadData() {
        // Test if user's data is duplicated or outside the study period window that we don't give them more money than the max
        controller.overrideCompletedTests = [
            createTest(0, 0), createTest(20, 0), createTest(8, 0), createTest(179, 0),
            createTest(0, 1, 0), createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2),  createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            createTest(0, 7, 0), createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [35])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [35])
        
        // 28 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        // 7 four of four goals at $1 each
        XCTAssertEqual(earnings?.cycle_earnings, "$32.00")
        XCTAssertEqual(earnings?.total_earnings, "$32.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 6)
        XCTAssertEqual(summary?.goals_met, 9)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 38)
        XCTAssertEqual(summary?.total_earnings, "$32.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$32.00")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testWeekDay181() {
        // Test if user's data is duplicated or outside the study period window that we don't give them more money than the max
        controller.overrideCompletedTests = [
            createTest(0, 0), createTest(20, 0), createTest(8, 0), createTest(180, 0),
            createTest(0, 1, 0), createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2),  createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            createTest(0, 7, 0), createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 181).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [35])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNil(fourOfFourGoal)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [35])
        
        // 28 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        // 7 four of four goals at $1 each
        XCTAssertEqual(earnings?.cycle_earnings, "$32.00")
        XCTAssertEqual(earnings?.total_earnings, "$32.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 7)
        XCTAssertEqual(summary?.goals_met, 9)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 38)
        XCTAssertEqual(summary?.total_earnings, "$32.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$32.00")
        XCTAssertEqual(details?.cycles?.count, 1)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        
        let goals = studyPeriod1?.details
        XCTAssertEqual(goals?.count, 4)
    }
    
    func testDay182NotStarted() {
        // User should not get earnings for day 0, which is the tutorial
        controller.overrideCompletedTests = [
            createTest(0, 0), createTest(20, 0), createTest(8, 0), createTest(180, 0),
            createTest(0, 1, 0), createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2),  createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            createTest(0, 7, 0), createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3)]
        controller.overridingNow = startDate().addingDays(days: 182).addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress, 0)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress, 0)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [0, 0, 0, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress, 0)
        
        XCTAssertEqual(earnings?.cycle_earnings, "$0.00")
        XCTAssertEqual(earnings?.total_earnings, "$32.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 7)
        XCTAssertEqual(summary?.goals_met, 9)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 38)
        XCTAssertEqual(summary?.total_earnings, "$32.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$32.00")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$0.00")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testDay182CompletedDay1iOS() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3),
            // iOS mis-labels study period 1 as week 25, make sure algo accounts for it
            createTest(25, 0, 0), createTest(25, 0, 1), createTest(25, 0, 2), createTest(25, 0, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 182).addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [4])
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 0, 0, 0, 0, 0, 0])
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [4])
        
        // 4 at $0.50 for all sessions, and four of four complete at $1
        XCTAssertEqual(earnings?.cycle_earnings, "$3.00")
        XCTAssertEqual(earnings?.total_earnings, "$35.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 7)
        XCTAssertEqual(summary?.goals_met, 10)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 32)
        XCTAssertEqual(summary?.total_earnings, "$35.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$35.00")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$3.00")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testDay182CompletedDay1Android() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3),
            // iOS mis-labels study period 1 as week 25, make sure algo accounts for it
            createTest(26, 0, 0), createTest(26, 0, 1), createTest(26, 0, 2), createTest(26, 0, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 182).addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [4])
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 0, 0, 0, 0, 0, 0])
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [4])
        
        // 4 at $0.50 for all sessions, and four of four complete at $1
        XCTAssertEqual(earnings?.cycle_earnings, "$3.00")
        XCTAssertEqual(earnings?.total_earnings, "$35.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 7)
        XCTAssertEqual(summary?.goals_met, 10)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 32)
        XCTAssertEqual(summary?.total_earnings, "$35.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$35.00")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$3.00")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testWeek26UnfinishediOS() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            // iOS mis-labels study period 1 as week 25, make sure algo accounts for it
            createTest(25, 0, 0), createTest(25, 0, 1),
            createTest(25, 1, 0), createTest(25, 1, 1),
            createTest(25, 2, 0), createTest(25, 2, 1),
            createTest(25, 3, 0), createTest(25, 3, 1),
            createTest(25, 4, 0), createTest(25, 4, 1),
            createTest(25, 5, 0), createTest(25, 5, 1),
            createTest(25, 6, 0)]
        
        controller.overridingNow = startDate().addingDays(days: 188).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [13])
        XCTAssertFalse(twentyOneGoal?.completed ?? true)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 0])
        XCTAssertFalse(twoADayGoal?.completed ?? true)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 0, 0, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [13])
        
        // 14 .testSession goals at $0.50 each
        XCTAssertEqual(earnings?.cycle_earnings, "$6.50")
        XCTAssertEqual(earnings?.total_earnings, "$6.50")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 13)
        XCTAssertEqual(summary?.goals_met, 0)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 13)
        XCTAssertEqual(summary?.total_earnings, "$6.50")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$6.50")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$0.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$6.50")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testWeek26UnfinishedAndroid() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(26, 0, 0), createTest(26, 0, 1),
            createTest(26, 1, 0), createTest(26, 1, 1),
            createTest(26, 2, 0), createTest(26, 2, 1),
            createTest(26, 3, 0), createTest(26, 3, 1),
            createTest(26, 4, 0), createTest(26, 4, 1),
            createTest(26, 5, 0), createTest(26, 5, 1),
            createTest(26, 6, 0)]
        
        controller.overridingNow = startDate().addingDays(days: 188).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [13])
        XCTAssertFalse(twentyOneGoal?.completed ?? true)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 0])
        XCTAssertFalse(twoADayGoal?.completed ?? true)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 0, 0, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [13])
        
        // 14 .testSession goals at $0.50 each
        XCTAssertEqual(earnings?.cycle_earnings, "$6.50")
        XCTAssertEqual(earnings?.total_earnings, "$6.50")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 13)
        XCTAssertEqual(summary?.goals_met, 0)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 13)
        XCTAssertEqual(summary?.total_earnings, "$6.50")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$6.50")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$0.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$6.50")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testWeek26FinishediOS() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(25, 0, 0), createTest(25, 0, 1), createTest(25, 0, 2),
            createTest(25, 1, 0), createTest(25, 1, 1), createTest(25, 1, 2),
            createTest(25, 2, 0), createTest(25, 2, 1), createTest(25, 2, 2),
            createTest(25, 3, 0), createTest(25, 3, 1), createTest(25, 3, 2),
            createTest(25, 4, 0), createTest(25, 4, 1), createTest(25, 4, 2),
            createTest(25, 5, 0), createTest(25, 5, 1), createTest(25, 5, 2),
            createTest(25, 6, 0), createTest(25, 6, 1), createTest(25, 6, 2)]
        
        controller.overridingNow = startDate().addingDays(days: 188).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [21])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [21])
        
        // 21 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        XCTAssertEqual(earnings?.cycle_earnings, "$21.50")
        XCTAssertEqual(earnings?.total_earnings, "$21.50")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 13)
        XCTAssertEqual(summary?.goals_met, 2)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 21)
        XCTAssertEqual(summary?.total_earnings, "$21.50")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$21.50")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$0.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$21.50")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testWeek26FinishedAndroid() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(26, 0, 0), createTest(26, 0, 1), createTest(26, 0, 2),
            createTest(26, 1, 0), createTest(26, 1, 1), createTest(26, 1, 2),
            createTest(26, 2, 0), createTest(26, 2, 1), createTest(26, 2, 2),
            createTest(26, 3, 0), createTest(26, 3, 1), createTest(26, 3, 2),
            createTest(26, 4, 0), createTest(26, 4, 1), createTest(26, 4, 2),
            createTest(26, 5, 0), createTest(26, 5, 1), createTest(26, 5, 2),
            createTest(26, 6, 0), createTest(26, 6, 1), createTest(26, 6, 2)]
        
        controller.overridingNow = startDate().addingDays(days: 188).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [21])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 0])
        XCTAssertFalse(fourOfFourGoal?.completed ?? true)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [21])
        
        // 21 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        XCTAssertEqual(earnings?.cycle_earnings, "$21.50")
        XCTAssertEqual(earnings?.total_earnings, "$21.50")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 13)
        XCTAssertEqual(summary?.goals_met, 2)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 21)
        XCTAssertEqual(summary?.total_earnings, "$21.50")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$21.50")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$0.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$21.50")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testWeek26PerfectiOS() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3),
            createTest(25, 0, 0), createTest(25, 0, 1), createTest(25, 0, 2), createTest(25, 0, 3),
            createTest(25, 1, 0), createTest(25, 1, 1), createTest(25, 1, 2), createTest(25, 1, 3),
            createTest(25, 2, 0), createTest(25, 2, 1), createTest(25, 2, 2), createTest(25, 2, 3),
            createTest(25, 3, 0), createTest(25, 3, 1), createTest(25, 3, 2), createTest(25, 3, 3),
            createTest(25, 4, 0), createTest(25, 4, 1), createTest(25, 4, 2), createTest(25, 4, 3),
            createTest(25, 5, 0), createTest(25, 5, 1), createTest(25, 5, 2), createTest(25, 5, 3),
            createTest(25, 6, 0), createTest(25, 6, 1), createTest(25, 6, 2), createTest(25, 6, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 188).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [28])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [28])
        
        // 28 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        // 7 four of four goals at $1 each
        XCTAssertEqual(earnings?.cycle_earnings, "$32.00")
        XCTAssertEqual(earnings?.total_earnings, "$64.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 13)
        XCTAssertEqual(summary?.goals_met, 18)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 56)
        XCTAssertEqual(summary?.total_earnings, "$64.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$64.00")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$32.00")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testWeek26PerfectAndroid() {
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2), createTest(0, 2, 3),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2), createTest(0, 3, 3),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2), createTest(0, 4, 3),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2), createTest(0, 5, 3),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2), createTest(0, 6, 3),
            // Android labels week 0, day 7 as week 1, day 7, make sure algo accounts for it
            createTest(1, 7, 0), createTest(1, 7, 1), createTest(1, 7, 2), createTest(1, 7, 3),
            // Android labels the rest of the study periods as expected
            createTest(26, 0, 0), createTest(26, 0, 1), createTest(26, 0, 2), createTest(26, 0, 3),
            createTest(26, 1, 0), createTest(26, 1, 1), createTest(26, 1, 2), createTest(26, 1, 3),
            createTest(26, 2, 0), createTest(26, 2, 1), createTest(26, 2, 2), createTest(26, 2, 3),
            createTest(26, 3, 0), createTest(26, 3, 1), createTest(26, 3, 2), createTest(26, 3, 3),
            createTest(26, 4, 0), createTest(26, 4, 1), createTest(26, 4, 2), createTest(26, 4, 3),
            createTest(26, 5, 0), createTest(26, 5, 1), createTest(26, 5, 2), createTest(26, 5, 3),
            createTest(26, 6, 0), createTest(26, 6, 1), createTest(26, 6, 2), createTest(26, 6, 3)]
        
        controller.overridingNow = startDate().addingDays(days: 188).startOfDay().addingMinutes(minutes: 1)
        
        let all = controller.recalculateEarnings()
        let overview = all.earningOverview
        XCTAssertNotNil(overview)
        let earnings = overview?.response?.earnings
        
        let twentyOneGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.totalSessions.rawValue })
        XCTAssertNotNil(twentyOneGoal)
        XCTAssertEqual(twentyOneGoal?.progress_components, [28])
        XCTAssertTrue(twentyOneGoal?.completed ?? false)
        
        let twoADayGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.twoADay.rawValue })
        XCTAssertNotNil(twoADayGoal)
        XCTAssertEqual(twoADayGoal?.progress_components, [100, 100, 100, 100, 100, 100, 100])
        XCTAssertTrue(twoADayGoal?.completed ?? false)
        
        let fourOfFourGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.fourOfFour.rawValue })
        XCTAssertNotNil(fourOfFourGoal)
        XCTAssertEqual(fourOfFourGoal?.progress_components, [100, 100, 100, 100])
        XCTAssertTrue(fourOfFourGoal?.completed ?? false)
        
        let allSessionsGoal = earnings?.goals.first(where: { $0.name == EarningsViewController.GoalDisplayName.testSession.rawValue })
        XCTAssertNotNil(allSessionsGoal)
        XCTAssertEqual(allSessionsGoal?.progress_components, [28])
        
        // 28 .testSession goals at $0.50 each,
        // two a day goal at $6
        // and 21 session goal at $5
        // 7 four of four goals at $1 each
        XCTAssertEqual(earnings?.cycle_earnings, "$32.00")
        XCTAssertEqual(earnings?.total_earnings, "$64.00")
        
        let summary = all.studySummary?.response.summary
        XCTAssertNotNil(summary)
        XCTAssertEqual(summary?.days_tested, 13)
        XCTAssertEqual(summary?.goals_met, 18)
        // This is the raw completed tests, we don't filter them based on if they were "within"
        // a study period or not, but it should never really happen as participants can only
        // complete a test during a specific time window within the study period
        XCTAssertEqual(summary?.tests_taken, 56)
        XCTAssertEqual(summary?.total_earnings, "$64.00")
        
        let details = all.earningDetail?.response?.earnings
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.total_earnings, "$64.00")
        XCTAssertEqual(details?.cycles?.count, 2)
        
        let studyPeriod1 = details?.cycles?.first
        XCTAssertNotNil(studyPeriod1)
        XCTAssertEqual(studyPeriod1?.cycle, 0)
        XCTAssertEqual(studyPeriod1?.total, "$32.00")
        XCTAssertEqual(studyPeriod1?.start_date, studyPeriod1Start())
        XCTAssertEqual(studyPeriod1?.end_date, studyPeriod1End())
        let goals1 = studyPeriod1?.details
        XCTAssertEqual(goals1?.count, 4)
        
        let studyPeriod2 = details?.cycles?[1]
        XCTAssertNotNil(studyPeriod2)
        XCTAssertEqual(studyPeriod2?.cycle, 1)
        XCTAssertEqual(studyPeriod2?.total, "$32.00")
        XCTAssertEqual(studyPeriod2?.start_date, studyPeriod2Start())
        XCTAssertEqual(studyPeriod2?.end_date, studyPeriod2End())
        let goals2 = studyPeriod2?.details
        XCTAssertEqual(goals2?.count, 4)
    }
    
    func testAchievement4Of4() {
        // Set to nil
        controller.mostRecentEarnings = nil
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2)]
        
        controller.overridingNow = startDate().addingDays(days: 1).addingMinutes(minutes: 1)
        
        let oldEarnings = controller.recalculateEarnings()
        let oldAchievements = oldEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(oldAchievements?.count, 0)
        controller.mostRecentEarnings = oldEarnings
        
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2), createTest(0, 1, 3)]
        
        let newEarnings = controller.recalculateEarnings()
        let newAchievements = newEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(newAchievements?.count, 1)
        let achievement = newAchievements?.first
        XCTAssertEqual(achievement?.name, "4-out-of-4")
        XCTAssertEqual(achievement?.amount_earned, "$1.00")
        
        controller.mostRecentEarnings = newEarnings
        let repeatEarnings = controller.recalculateEarnings()
        let repeatAchievements = repeatEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(repeatAchievements?.count, 0)
    }
    
    func testAchievement21Sessions() {
        // Set to nil
        controller.mostRecentEarnings = nil
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2),
            createTest(0, 7, 0), createTest(0, 7, 1)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let oldEarnings = controller.recalculateEarnings()
        let oldAchievements = oldEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(oldAchievements?.count, 0)
        controller.mostRecentEarnings = oldEarnings
        
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1), createTest(0, 1, 2),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2)]
        
        let newEarnings = controller.recalculateEarnings()
        let newAchievements = newEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(newAchievements?.count, 1)
        let achievement = newAchievements?.first
        XCTAssertEqual(achievement?.name, "21-sessions")
        XCTAssertEqual(achievement?.amount_earned, "$5.00")
        
        controller.mostRecentEarnings = newEarnings
        let repeatEarnings = controller.recalculateEarnings()
        let repeatAchievements = repeatEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(repeatAchievements?.count, 0)
    }
    
    func testAchievement2ADay() {
        // Set to nil
        controller.mostRecentEarnings = nil
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2),
            createTest(0, 7, 0)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let oldEarnings = controller.recalculateEarnings()
        let oldAchievements = oldEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(oldAchievements?.count, 0)
        controller.mostRecentEarnings = oldEarnings
        
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2)]
        
        let newEarnings = controller.recalculateEarnings()
        let newAchievements = newEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(newAchievements?.count, 1)
        let achievement = newAchievements?.first
        XCTAssertEqual(achievement?.name, "2-a-day")
        XCTAssertEqual(achievement?.amount_earned, "$6.00")
        
        controller.mostRecentEarnings = newEarnings
        let repeatEarnings = controller.recalculateEarnings()
        let repeatAchievements = repeatEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(repeatAchievements?.count, 0)
    }
    
    func testAchievement21And4of4() {
        // Set to nil
        controller.mostRecentEarnings = nil
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2)]
        
        controller.overridingNow = startDate().addingDays(days: 7).startOfDay().addingMinutes(minutes: 1)
        
        let oldEarnings = controller.recalculateEarnings()
        let oldAchievements = oldEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(oldAchievements?.count, 0)
        controller.mostRecentEarnings = oldEarnings
        
        controller.overrideCompletedTests = [
            createTest(0, 0),
            createTest(0, 1, 0), createTest(0, 1, 1),
            createTest(0, 2, 0), createTest(0, 2, 1), createTest(0, 2, 2),
            createTest(0, 3, 0), createTest(0, 3, 1), createTest(0, 3, 2),
            createTest(0, 4, 0), createTest(0, 4, 1), createTest(0, 4, 2),
            createTest(0, 5, 0), createTest(0, 5, 1), createTest(0, 5, 2),
            createTest(0, 6, 0), createTest(0, 6, 1), createTest(0, 6, 2),
            createTest(0, 7, 0), createTest(0, 7, 1), createTest(0, 7, 2), createTest(0, 7, 3)]
        
        let newEarnings = controller.recalculateEarnings()
        let newAchievements = newEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(newAchievements?.count, 2)
        let achievement = newAchievements?.first(where: { $0.name == "21-sessions" })
        XCTAssertEqual(achievement?.name, "21-sessions")
        XCTAssertEqual(achievement?.amount_earned, "$5.00")
        
        let achievement2 = newAchievements?.first(where: { $0.name == "4-out-of-4" })
        XCTAssertEqual(achievement2?.name, "4-out-of-4")
        XCTAssertEqual(achievement2?.amount_earned, "$1.00")
        
        controller.mostRecentEarnings = newEarnings
        let repeatEarnings = controller.recalculateEarnings()
        let repeatAchievements = repeatEarnings.earningOverview?.response?.earnings?.new_achievements
        XCTAssertEqual(repeatAchievements?.count, 0)
    }
    
    func createTest(_ week: Int, _ day: Int, _ session: Int = 0) -> CompletedTest {
        // completedOn not used in algo
        return CompletedTest(week: week, day: day, session: session, completedOn: Date().timeIntervalSince1970)
    }
}

open class MockSageEarningsController: SageEarningsController {
    
    var overridingStudyStartDate: TimeInterval?
    override open var studyStartDate: TimeInterval? {
        return overridingStudyStartDate
    }
    
    override open var arcStartDays: Dictionary<Int, Int> {
        // This is the test cycle for HASD
        return [0: 0,   // Test Cycle A
                1: 182,  // Test Cycle B
                2: 182 * 2, // Test Cycle C
                3: 182 * 3, // Test Cycle D
                4: 182 * 4, // Test Cycle E
                5: 182 * 5, // Test Cycle F
                6: 182 * 6, // Test Cycle G
                7: 182 * 7, // Test Cycle H
                8: 182 * 8, // Test Cycle I
                9: 182 * 9  // Test Cycle I
        ]
    }
    
    var overridingNow: Date = Date()
    override open var now: Date {
        return overridingNow
    }
    
    var overrideCompletedTests: Array<CompletedTest> = []
    override open var completedTests: Array<CompletedTest> {
        // All completed tests except for the tutorial baseline test on week 0, day 0
        return self.filterAndConvertTests(tests: overrideCompletedTests)
    }
    
    public override init() {
        super.init()
    }
}
