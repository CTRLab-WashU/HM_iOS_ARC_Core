//
//  Schedule+CoreDataProperties.swift
//  
//
//  Created by Philip Hayes on 10/1/18.
//
//

import Foundation
import CoreData


extension Schedule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule> {
        return NSFetchRequest<Schedule>(entityName: "Schedule")
    }

    @NSManaged public var hasConfirmedDate: Bool
    @NSManaged public var hasScheduledNotifications: Bool
    @NSManaged public var participantID: Int64
    @NSManaged public var scheduleID: String?
    @NSManaged public var testEndDate: Date?
    @NSManaged public var testStartDate: Date?
    @NSManaged public var userEndDate: Date?
    @NSManaged public var userStartDate: Date?
    @NSManaged public var scheduleEntries: Set<ScheduleEntry>?
    @NSManaged public var sessions: Set<Session>?

}

// MARK: Generated accessors for scheduleEntries
extension Schedule {

    @objc(addScheduleEntriesObject:)
    @NSManaged public func addToScheduleEntries(_ value: ScheduleEntry)

    @objc(removeScheduleEntriesObject:)
    @NSManaged public func removeFromScheduleEntries(_ value: ScheduleEntry)

    @objc(addScheduleEntries:)
    @NSManaged public func addToScheduleEntries(_ values: NSSet)

    @objc(removeScheduleEntries:)
    @NSManaged public func removeFromScheduleEntries(_ values: NSSet)

}

// MARK: Generated accessors for sessions
extension Schedule {

    @objc(insertObject:inSessionsAtIndex:)
    @NSManaged public func insertIntoSessions(_ value: Session, at idx: Int)

    @objc(removeObjectFromSessionsAtIndex:)
    @NSManaged public func removeFromSessions(at idx: Int)

    @objc(insertSessions:atIndexes:)
    @NSManaged public func insertIntoSessions(_ values: [Session], at indexes: NSIndexSet)

    @objc(removeSessionsAtIndexes:)
    @NSManaged public func removeFromSessions(at indexes: NSIndexSet)

    @objc(replaceObjectInSessionsAtIndex:withObject:)
    @NSManaged public func replaceSessions(at idx: Int, with value: Session)

    @objc(replaceSessionsAtIndexes:withSessions:)
    @NSManaged public func replaceSessions(at indexes: NSIndexSet, with values: [Session])

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSOrderedSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSOrderedSet)

}
