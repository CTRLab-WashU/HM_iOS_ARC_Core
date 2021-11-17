//
//  SecureTokenGeneratorTests.swift
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

class PasswordGeneratorTests: XCTestCase {
    
    func testGeneratePasswords() throws {
        var counts = [Int: Int]()
        // Test 10000 bridge passwords for validity
        for _ in 0..<10000 {
            let password = PasswordGenerator.BRIDGE_PASSWORD.nextBridgePassword()
            XCTAssertNotNil(password)
            XCTAssertEqual(9, password!.count)
            XCTAssertTrue(isValidBridgePassword(password: password))
            
            // Add to the counts of where each symbol is
            for j in 0..<9 {
                for k in 0..<4 {
                    if password!.charAtIndex(i: j) == PasswordGenerator.SYMBOL.charAtIndex(i: k) {
                        counts[j] = (counts[j] ?? 0) + 1
                    }
                }
            }
        }
        
        for i in 0..<9 {
            // Make sure that the distribution has at least 1% of the distribution
            XCTAssertTrue((counts[i] ?? 0) > 10)
        }
    }
        
    private func isValidBridgePassword(password: String?) -> Bool {
        guard let passwordUnwrapped = password else {
            return false
        }
        var containsUppercase = false
        var containsLowercase = false
        var containsNumeric = false
        var containsSpecial = false
        var specialCount = 0

        for i in 0..<passwordUnwrapped.count {
            let character = passwordUnwrapped.charAtIndex(i: i)
            containsUppercase = containsUppercase ||
                PasswordGenerator.UPPERCASE_ALPHA.contains(character)
            containsLowercase = containsLowercase ||
                PasswordGenerator.LOWERCASE_ALPHA.contains(character)
            containsNumeric = containsNumeric ||
                PasswordGenerator.NUMERIC.contains(character)
            containsSpecial = containsSpecial ||
                PasswordGenerator.SYMBOL.contains(character)
            if (PasswordGenerator.SYMBOL.contains(character)) {
                specialCount += 1
            }
        }

        // We want only 1 special character in the password
        return containsUppercase && containsLowercase &&
                containsNumeric && containsSpecial && (specialCount == 1)
    }
}
