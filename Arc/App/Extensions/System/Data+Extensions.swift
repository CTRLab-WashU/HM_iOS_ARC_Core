//
//  Data+Extensions.swift
// Arc
//
//  Created by Philip Hayes on 11/1/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import CommonCrypto
import Foundation
public extension Data {
	public func MD5() -> String {
		let digestLength = Int(CC_MD5_DIGEST_LENGTH)
		let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
		
		_ = withUnsafeBytes {
			bytes in
			CC_MD5(bytes, CC_LONG(count), md5Buffer)

		}
		
		let output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
		for i in 0..<digestLength {
			output.appendFormat("%02x", md5Buffer[i])
		}
		
		return NSString(format: output) as String
	}
}
