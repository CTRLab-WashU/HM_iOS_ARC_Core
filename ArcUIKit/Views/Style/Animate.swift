//
//  Lerp.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 7/1/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Math{
	public static func lerp<T:FloatingPoint> (a:T, b:T, t:T) -> T{
		
		return (a + t * (b - a))
		
	}
	public static func clamp(_ value:Double) -> Double {
		
		return min(1.0, max(0.0, value))
	}
	public enum Curve {
		case linear, easeIn, easeOut
		
		func evaluate (currentTime:Double) -> Double {
			let t = Math.clamp(currentTime)
			
			switch self {
			case .linear:
				return Math.lerp(a: 0.0, b: 1.0, t: t)
			case .easeOut:
				return sin(t * Double.pi * 0.5)

			case .easeIn:
				return  1.0 - cos(t * Double.pi * 0.5)

			}
		}
	}
}


public struct Animate {
	public struct State {
		var _isValid:(()->Bool)
		func isValid(condition:((TimeInterval)->Bool)) {
			
		}
	}
	private class UpdateLooper {
		
		var displayLink:CADisplayLink?
		
		var update:((Double)->())?
		var _current:Double = 0.0
		var time:Double = 0
		var delay:Double = 0
		var maxTime:Double = 1.0
		var curve:Math.Curve = .linear
		init() {
		}
		func start() {
			displayLink = CADisplayLink(target: self, selector: #selector(loop))
			displayLink?.add(to: .current, forMode: .common)
		}
		func pause() {
			displayLink?.isPaused = true
		}
		func resume() {
			displayLink?.isPaused = false
		}
		func stop() {
			displayLink?.invalidate()
			displayLink = nil
			print("stopped")
		}
		public func run(_ update:@escaping (Double)->()) {
			self.update = update
			start()
		}
		@objc private func loop() {
			print("updating: \(_current)")
			guard let dl = displayLink else {
				return
			}
			time += dl.targetTimestamp - dl.timestamp
			_current = curve.evaluate(currentTime: (time - delay)/maxTime)
			 update?(_current)
			if time - delay >= maxTime {
				
				stop()
			}
		}
	}
	private var _delay:Double = 0.0
	private var _duration:Double = 0.2
	private var _curve:Math.Curve = .linear
	private var _progress:Double = 0

	private var updater:UpdateLooper
	init() {
		updater = UpdateLooper()
		
	}
	public func duration(_ value:Double) -> Animate {
		var t = self
		t._duration = value
		return t
	}
	public func delay(_ value:Double) -> Animate {
		var t = self
		t._delay = value
		return t
	}
	public func curve(_ value:Math.Curve) -> Animate {
		var t = self
		t._curve = value
		return t
	}
	
	
	/// Provides a context that passes in an animated time value. This can be used
	/// to perform various rudimentary animations
	/// - Parameter update: <#update description#>
	@discardableResult
	public func run(_ update:@escaping (Double)->()) -> Animate {
		updater.time = 0
		updater.maxTime = _duration
		updater.curve = _curve
		updater.delay = _delay
		updater.run(update)
		return self
	}
	public func stop(forceEnd:Bool = false){
		if forceEnd {
			updater.time = updater.maxTime + updater.delay
		} else {
			updater.stop()
		}
	}
	public func pause() {
		updater.pause()
	}
	public func resume() {
		updater.resume()
	}
	
}
