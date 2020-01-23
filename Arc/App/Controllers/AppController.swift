//
//  AppController.swift
// Arc
//
//  Created by Philip Hayes on 10/26/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
open class AppController : MHController {
    public enum Commitment : String, Codable {
        case committed, rebuked
    }
    
	public var testCount:Int = 0
    public var locale:ACLocale {
        return ACLocale(rawValue: "\(language ?? "en")_\(country ?? "US")") ?? .en_US
    }
    public var language:String? {
        get {
            
            return defaults.string(forKey:"language");
            
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"language");
            defaults.synchronize();
        }
    }
    public var country:String? {
        get {
            
            return defaults.string(forKey:"country");
            
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"country");
            defaults.synchronize();
        }
    }
	public var participantId:Int? {
		get {

			if let id = defaults.value(forKey:"participantId") as? Int
			{
				return id;
			}
			return nil;
		}
		set (newVal)
		{
			defaults.setValue(newVal, forKey:"participantId");
			defaults.synchronize();
		}
	}
    public var finishedPart:Int? {
        get {
            if let part = defaults.value(forKey:"finishedPart") as? Int
            {
                return part;
            }
            return nil;
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"finishedPart");
            defaults.synchronize()
        }
    }
    public var showMindfulness:Bool? {
        get {
            if let show = defaults.value(forKey:"showMindfulness") as? Bool
            {
                return show;
            }
            return nil;
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"showMindfulness");
            defaults.synchronize()
        }
    }
    public var lastFlaggedMissedTestCount:Int {
        get {
            
            if let id = defaults.value(forKey:"lastFlaggedMissedTestCount") as? Int
            {
                return id;
            }
            return 0;
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"lastFlaggedMissedTestCount");
            defaults.synchronize();
        }
    }
    public var isFirstLaunch:Bool {
        get {
            if (defaults.value(forKey:"hasLaunched") as? Bool) != nil
            {
                return false;
            }
            return true;
        }
        set (newVal)
        {
            defaults.setValue(true, forKey:"hasLaunched");
            defaults.synchronize();
        }
    }
    public var isOnboarded:Bool {
        get {
            if let value = (defaults.value(forKey:"isOnboarded") as? Bool)
            {
                return value;
            }
            return false;
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"isOnboarded");
            defaults.synchronize();
        }
    }
    public var commitment:Commitment? {
        get {
            return Commitment(rawValue: defaults.string(forKey: "commitment") ?? "")
            
        }
        set (newVal)
        {
            defaults.setValue(newVal?.rawValue, forKey:"commitment");
            defaults.synchronize();
        }
    }
    public var deviceId:String {
        get {
            if let value = (defaults.value(forKey:"deviceId") as? String)
            {
                return value;
            }
            let id = UUID().uuidString;
            defaults.setValue(id, forKey:"deviceId");
            defaults.synchronize();
            return id
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"deviceId");
            defaults.synchronize();
        }
    }
	
	public var wakeSleepUploaded:Bool {
		get {
			if let value = (defaults.value(forKey:"wakeSleepUploaded") as? Bool)
			{
				return value;
			}
			return false;
		}
		set (newVal)
		{
			defaults.setValue(newVal, forKey:"wakeSleepUploaded");
			defaults.synchronize();
		}
	}
	public var wakeSleepUploading:Bool {
		get {
			if let value = (defaults.value(forKey:"wakeSleepUploading") as? Bool)
			{
				return value;
			}
			return false;
		}
		set (newVal)
		{
			defaults.setValue(newVal, forKey:"wakeSleepUploading");
			defaults.synchronize();
		}
	}
	public var testScheduleUploaded:Bool {
		get {
			if let value = (defaults.value(forKey:"testScheduleUploaded") as? Bool)
			{
				return value;
			}
			return false;
		}
		set (newVal)
		{
			defaults.setValue(newVal, forKey:"testScheduleUploaded");
			defaults.synchronize();
		}
	}
	public var testScheduleUploading:Bool {
		get {
			if let value = (defaults.value(forKey:"testScheduleUploading") as? Bool)
			{
				return value;
			}
			return false;
		}
		set (newVal)
		{
			defaults.setValue(newVal, forKey:"testScheduleUploading");
			defaults.synchronize();
		}
	}
	public var lastClosedDate:Date?

	
	public var lastUploadDate:Date? {
		get {
			if let _lastUploadDate = defaults.value(forKey:"lastUploadDate") as? Date
			{
				return _lastUploadDate;
			}
			return nil;
		}
		set (newVal)
		{
			defaults.setValue(newVal, forKey:"lastUploadDate");
			defaults.synchronize();
		}
	}
    public var lastBackgroundFetch:Date? {
        get {
            if let _lastUploadDate = defaults.value(forKey:"lastBackgroundFetch") as? Date
            {
                return _lastUploadDate;
            }
            return nil;
        }
        set (newVal)
        {
            defaults.setValue(newVal, forKey:"lastBackgroundFetch");
            defaults.synchronize();
        }
    }
	public var lastWeekScheduled:Date? {
		get {
			if let _lastUploadDate = defaults.value(forKey:"lastWeekScheduled") as? Date
			{
				return _lastUploadDate;
			}
			return nil;
		}
		set (newVal)
		{
			defaults.setValue(newVal, forKey:"lastWeekScheduled");
			defaults.synchronize();
		}
	}
    public func fetch(signature sessionId:Int64, tag:Int32) -> Signature?{
        var signature:Signature?
        MHController.dataContext.performAndWait {
            let predicate = NSPredicate(format: "tag == \(tag) AND sessionId == \(sessionId)")
            signature = fetch(predicate: predicate, sort: nil, limit: 1)?.first
        }
        
        return signature
    }
    public func save(signature image:UIImage, sessionId:Int64, tag:Int32) -> Bool {
        var signature:Signature = new()
        guard let data = image.pngData() else {
            return false
        }
        signature.data = data
        signature.sessionId = sessionId
        signature.tag = tag
        return true
    }
}
