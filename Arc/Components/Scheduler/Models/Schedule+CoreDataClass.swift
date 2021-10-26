//
//  Schedule+CoreDataClass.swift
//  Arc
//
//  Created by Michael L DePhillips on 10/26/21.
//  Copyright © 2021 HealthyMedium. All rights reserved.
//
//

import Foundation
import CoreData


public class Schedule: NSManagedObject {
    public var entries:Set<ScheduleEntry> {
        get {
            return scheduleEntries as? Set<ScheduleEntry> ?? []
        }
        set {
            scheduleEntries = NSSet(set: newValue)
        }
    }
}
