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
	public static func toRadians(_ number: Double) -> Double {
		return number * .pi / 180
	}
	public static func toDegrees(_ number: Double) -> Double {
		return number * 180 / .pi
	}
	
	public static func lerp<T:FloatingPoint> (a:T, b:T, t:T) -> T{
		
		return (a + t * (b - a))
		
	}
	public static func lerp(a:CGPoint, b:CGPoint, t:CGFloat) -> CGPoint {
		return CGPoint(x: lerp(a: a.x, b: b.x, t: t),
					   y:  lerp(a: a.y, b: b.y, t: t))
	}
	public static func clamp(_ value:Double) -> Double {
		
		return min(1.0, max(0.0, value))
	}
	public enum Curve {
		case none, linear, easeIn, easeOut
		
		func evaluate (currentTime:Double) -> Double {
			let t = Math.clamp(currentTime)
			
			switch self {
			case .none:
				return 1.0
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


public class Animate {
	
	
	private var _delay:Double = 0.0
	private var _duration:Double = 0.2
	private var _curve:Math.Curve = .linear
	private var _progress:Double = 0
	
	public var time:Double {
		get {
			return max(0.0, (updater?.time ?? 0.0) - (updater?.delay ?? 0.0))
		}
		set {
			updater?.time = newValue
		}
	}
	fileprivate var updater:UpdateLooper?
	public init() {
		
		
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
	public func run(_ update:@escaping (Double)->Bool) -> Animate {
		var s = self
		s.updater = UpdateLooper()
		s.updater?.time = 0
		s.updater?.maxTime = _duration
		s.updater?.curve = _curve
		s.updater?.delay = _delay
		s.updater?.run(update)
		return s
	}
	public func stop(forceEnd:Bool = false){
		guard let updater = updater else {
			return
		}
		if forceEnd {
			updater.time = updater.maxTime + updater.delay
		} else {
			updater.stop()
		}
		
	}
	public func pause() {
		updater?.pause()
	}
	public func resume() {
		updater?.resume()
	}
	
	public struct State {
		var _isValid:(()->Bool)
		func isValid(condition:((TimeInterval)->Bool)) {
			
		}
	}
	fileprivate class UpdateLooper {
		
		var displayLink:CADisplayLink?
		
		var update:((Double)->Bool)?
		var _current:Double = 0.0
		var time:Double = 0
		var delay:Double = 0
		var maxTime:Double = 1.0
		var curve:Math.Curve = .linear
		private var id = UUID().uuidString
		init() {
		}
		func start() {
			print("started:\(id)")
			displayLink?.invalidate()
			displayLink = nil
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
			
			update = nil
			print("stopped:\(id)")
		}
		public func run(_ update:@escaping (Double)->Bool) {
			
			self.update = update
			
			start()
		}
		@objc private func loop() {
			print("updating: \(id):\(time)")
			guard let dl = displayLink else {
				
				stop()
				return
			}
			time += dl.targetTimestamp - dl.timestamp
			
			if curve == .none {
				
				if time - delay < 0 {
					return
				}
				
				_current = curve.evaluate(currentTime: (time - delay)/maxTime)
				
				guard update?(_current) == true else {
					stop()
					return
				}
				time = maxTime + delay
			
				
			} else {
				_current = curve.evaluate(currentTime: (time - delay)/maxTime)
				if time - delay < 0 {
					return
				}
				
				guard update?(_current) == true else {
					stop()
					return
				}
				
				
				
			}
			if time - delay >= maxTime {
				
				stop()
			}
			
			
		}
	}
	
}
