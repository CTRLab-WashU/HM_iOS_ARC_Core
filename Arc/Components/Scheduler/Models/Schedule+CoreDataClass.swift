//
//  Schedule+CoreDataClass.swift
// Arc
//
//  Created by Philip Hayes on 10/16/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//
//

import Foundation
import CoreData


open class Schedule: NSManagedObject {
	var entries:Set<ScheduleEntry> {
		get {
			return scheduleEntries as? Set<ScheduleEntry> ?? []
		}
		set {
			scheduleEntries = NSSet(set: newValue)
		}
	}
}
