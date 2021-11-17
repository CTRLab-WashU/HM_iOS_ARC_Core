//
//  SecureTokenGenerator.swift
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

import Foundation

/**
 * This code came from Stack Exchange, with some changes to make it thread-safe. Unfortunately I
 * then lost the reference to the page I took it from. Cleaned up to our formatting standards.
 */
public class PasswordGenerator {
    
    // DIAN passwords are 9 digits long
    public static let DEFAULT_PASSWORD_LENGTH = 9;

    // Bridge password must be at least 8 characters;
    // Bridge password must contain at least one uppercase letter (a-z)
    // Letter "O" has been removed, as it shows up too similar to number "0" on bridge
    // Letter "I" has been removed, as it shows up too similar to letter "l" on bridge
    public static let UPPERCASE_ALPHA = "ABCDEFGHJKLMNPQRSTUVWXYZ"
    // Bridge password must contain at least one lowercase letter (a-z)
    // Letter "l" has been removed, as it shows up too similar to letter "I" on bridge
    public static let LOWERCASE_ALPHA = "abcdefghijkmnopqrstuvwxyz"
    // "0" has been removed, as it shows up too similar to letter "O" on bridge
    public static let NUMERIC = "123456789"
    // Bridge password must contain at least one symbol ( !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~ )
    // This subset of symbols was chosen because they would be easier to communicate over the phone
    // As well as removing some that the older participants wouldn't understand
    public static let SYMBOL = "&.!?"

    public static let ALPHANUMERIC = UPPERCASE_ALPHA + LOWERCASE_ALPHA + NUMERIC;
    // ALPHANUMERIC was added 3 times to decrease the number of symbols in a password
    public static let PASSWORD = ALPHANUMERIC + SYMBOL
    
    public static let ARC_ID_INSTANCE = PasswordGenerator(length: 6, characters: NUMERIC)

    /**
     * I used this website https://asecuritysite.com/encryption/passes and using our parameters,
     * it said a 9 character password has 66,540,410,775,079,424 available passwords,
     * and it would take 2108.59 years to crack if requests were sent.
     */
    public static let BRIDGE_PASSWORD = PasswordGenerator(length: 9, characters: PASSWORD)

    private var characters: String
    private var length: Int

    public init (length: Int, characters: String) {
        self.length = length
        self.characters = characters
        if self.characters.count > UInt8.max {
            assertionFailure("Max characters is \(UInt8.max)")
        }
    }
    
    private func getRandomIntegers(size: Int, max: Int) -> [Int]? {
        var array = [Int]()
        while (array.count < size) {
            guard let randomInt = self.getRandomInteger(max: max) else {
                return nil
            }
            array.append(randomInt)
        }
        return array
    }

    private func getUniqueRandomIntegers(size: Int, max: Int) -> [Int]? {
        var set = [Int]()
        while (set.count < size) {
            guard let randomInt = self.getRandomInteger(max: max) else {
                return nil
            }
            if (!set.contains(randomInt)) {
                set.append(randomInt)
            }
        }
        return set
    }
    
    private func getRandomInteger(max: Int) -> Int? {
        var bytes = [UInt8](repeating: 0, count: 1)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            print("Error creating secure random token with code \(status)")
            return nil
        }
        return Int(bytes[0]) % max
    }

    /**
     * Guaranteed to generate a random password string compatible with Bridge
     * @return a random password string compatible with Bridge
     */
    public func nextBridgePassword() -> String? {
        guard let randomIndices = self.getRandomIntegers(size: self.length, max: PasswordGenerator.ALPHANUMERIC.count) else {
            return nil
        }
        // Get a secure ALPHANUMERIC password first
        var alphaNumericPassword = ""
        randomIndices.forEach { idx in
            alphaNumericPassword += PasswordGenerator.ALPHANUMERIC.charAtIndex(i: idx)
        }
        // Ensure that all character types are always present by replacing characters
        // in the password with one random character from each set of character requirements
        guard let fourIndices = self.getUniqueRandomIntegers(size: 4, max: self.length) else {
            return nil
        }
        var password = ""
        for i in 0..<self.length {
            var randomIdx: Int? = -1
            if fourIndices[0] == i {
                randomIdx = self.getRandomInteger(max: PasswordGenerator.UPPERCASE_ALPHA.count)
                password += PasswordGenerator.UPPERCASE_ALPHA.charAtIndex(i: randomIdx ?? 0)
            } else if fourIndices[1] == i {
                randomIdx = self.getRandomInteger(max: PasswordGenerator.LOWERCASE_ALPHA.count)
                password += PasswordGenerator.LOWERCASE_ALPHA.charAtIndex(i: randomIdx ?? 0)
            } else if fourIndices[2] == i {
                randomIdx = self.getRandomInteger(max: PasswordGenerator.NUMERIC.count)
                password += PasswordGenerator.NUMERIC.charAtIndex(i: randomIdx ?? 0)
            } else if fourIndices[3] == i {
                randomIdx = self.getRandomInteger(max: PasswordGenerator.SYMBOL.count)
                password += PasswordGenerator.SYMBOL.charAtIndex(i: randomIdx ?? 0)
            }
            if randomIdx == nil {
                return nil
            } else if (randomIdx ?? -1) < 0 {
                password += alphaNumericPassword.charAtIndex(i: i)
            }
        }
        return password
    }
}

extension String {
    var length: Int {
        return count
    }

    public func charAtIndex (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
