//
//  ScheduleEntry+CoreDataProperties.swift
//  Arc
//
//  Created by Michael L DePhillips on 10/26/21.
//  Copyright © 2021 HealthyMedium. All rights reserved.
//
//

import Foundation
import CoreData


extension ScheduleEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleEntry> {
        return NSFetchRequest<ScheduleEntry>(entityName: "ScheduleEntry")
    }

    @NSManaged public var availabilityEnd: String?
    @NSManaged public var availabilityStart: String?
    @NSManaged public var createdOn: Date?
    @NSManaged public var modifiedOn: Date?
    @NSManaged public var participantID: Int64
    @NSManaged public var weekday: Int64
    @NSManaged public var schedule: Schedule?

}
