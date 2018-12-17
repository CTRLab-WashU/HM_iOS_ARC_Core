//
//  JSONData.swift
// Arc
//
//  Created by Philip Hayes on 9/27/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
public extension JSONData {
    public func get<T:Codable>() -> T? {
		do{
        guard let data = self.data else {
            return nil
        }
        return try JSONDecoder().decode(T.self, from: data)
		} catch {
			print(error)
		}
        return nil
    }
}
