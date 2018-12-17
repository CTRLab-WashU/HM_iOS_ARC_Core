//
//  FatalErrorUtil.swift
// Arc
//
//  Created by Philip Hayes on 10/4/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import Foundation
// overrides Swift global `fatalError`
func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    
    FatalErrorUtil.fatalErrorClosure(message(), file, line)

}

/// This is a `noreturn` function that pauses forever
func unreachable() -> Never  {
    repeat {
        RunLoop.current.run()
    } while (true)
}

public struct FatalErrorUtil {
    
    // 1
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure
    
    // 2
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
    
    // 3
    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }
    
    // 4
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}
