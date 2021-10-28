//
//  Arc4To5MigrationPolicy.swift
//  Arc
//
//  Created by Michael L DePhillips on 10/27/21.
//  Copyright © 2021 HealthyMedium. All rights reserved.
//

import Foundation
import CoreData

public class Arc4To5MigrationPolicy: NSEntityMigrationPolicy {
    public override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
    }
}

