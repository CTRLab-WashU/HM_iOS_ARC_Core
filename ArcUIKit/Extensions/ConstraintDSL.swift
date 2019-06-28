//
//  ConstraintDSL.swift
//  ArcUIKit
//
//  Created by Philip Hayes on 6/25/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit

public protocol LayoutAnchor {
	
	
	func constraint(equalTo anchor: Self,
					constant: CGFloat) -> NSLayoutConstraint
	func constraint(greaterThanOrEqualTo anchor: Self,
					constant: CGFloat) -> NSLayoutConstraint
	func constraint(lessThanOrEqualTo anchor: Self,
					constant: CGFloat) -> NSLayoutConstraint
}
extension LayoutAnchor where Self : NSLayoutDimension{
	
	func constraint(equalToConstant c: CGFloat) -> NSLayoutConstraint {
		return self.constraint(equalToConstant: c)
	}
	
	func constraint(greaterThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint {
		return self.constraint(greaterThanOrEqualToConstant: c)
	}
	
	func constraint(lessThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint {
		return self.constraint(lessThanOrEqualToConstant: c)
	}
	
}
extension NSLayoutAnchor: LayoutAnchor {}

public struct LayoutProperty<Anchor: LayoutAnchor> {
	fileprivate let anchor: Anchor
}

public class LayoutProxy {
	lazy public var leading = property(with: view.leadingAnchor)
	lazy public var trailing = property(with: view.trailingAnchor)
	lazy public var top = property(with: view.topAnchor)
	lazy public var bottom = property(with: view.bottomAnchor)
	lazy public var width = property(with: view.widthAnchor)
	lazy public var height = property(with: view.heightAnchor)
	
	private let view: UIView
	
	fileprivate init(view: UIView) {
		self.view = view
	}
	
	private func property<A: LayoutAnchor>(with anchor: A) -> LayoutProperty<A> {
		return LayoutProperty(anchor: anchor)
	}
}
extension LayoutProperty where Anchor : NSLayoutDimension {
	
	
	
	func equal(to constant: CGFloat, priority:UILayoutPriority = .required) {
		let c =  anchor.constraint(equalToConstant: constant)
		c.priority = priority
		c.isActive = true
	}
	
	func greaterThanOrEqual(to constant: CGFloat, priority:UILayoutPriority = .required) {
		let c = anchor.constraint(greaterThanOrEqualToConstant: constant)
		c.priority = priority
		c.isActive = true
	}
	
	func lessThanOrEqual(to constant: CGFloat, priority:UILayoutPriority = .required) {
		let c = anchor.constraint(lessThanOrEqualToConstant: constant)
		c.priority = priority
		c.isActive = true
		
	}
}
extension LayoutProperty {
	
	func equal(to otherAnchor: Anchor, offsetBy
		constant: CGFloat = 0, priority:UILayoutPriority = .required) {
		let c = anchor.constraint(equalTo: otherAnchor,
						  constant: constant)
		c.priority = priority

		c.isActive = true
	}
	
	func greaterThanOrEqual(to otherAnchor: Anchor,
							offsetBy constant: CGFloat = 0, priority:UILayoutPriority = .required) {
		let c = anchor.constraint(greaterThanOrEqualTo: otherAnchor,
						  constant: constant)
		c.priority = priority

		c.isActive = true
	}
	
	func lessThanOrEqual(to otherAnchor: Anchor,
						 offsetBy constant: CGFloat = 0, priority:UILayoutPriority = .required) {
		let c = anchor.constraint(lessThanOrEqualTo: otherAnchor,
						  constant: constant)
		c.priority = priority
		c.isActive = true
	}
}

extension UIView {
	public func layout(using closure: (LayoutProxy) -> Void) {
		translatesAutoresizingMaskIntoConstraints = false
		closure(LayoutProxy(view: self))
	}
}

public func +<A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
	return (lhs, rhs)
}
public func -<A: LayoutAnchor>(lhs: A, rhs: CGFloat) -> (A, CGFloat) {
	return (lhs, -rhs)
}
public func +<A: LayoutAnchor>(lhs: A, rhs: Int) -> (A, CGFloat) {
	return (lhs, CGFloat(rhs))
}
public func -<A: LayoutAnchor>(lhs: A, rhs: Int) -> (A, CGFloat) {
	return (lhs, CGFloat(-rhs))
}
infix operator ~ : AdditionPrecedence
public func ~<A: LayoutAnchor>(lhs:(A, CGFloat), rhs: Int) -> (A, CGFloat, UILayoutPriority) {
	return (lhs.0, lhs.1, UILayoutPriority(rawValue: Float(rhs)))
}
public func ~(lhs:CGFloat, rhs: Int) -> (CGFloat, UILayoutPriority) {
	return (lhs, UILayoutPriority(rawValue: Float(rhs)))
}
public func ~(lhs:Int, rhs: Int) -> (CGFloat, UILayoutPriority) {
	return (CGFloat(lhs), UILayoutPriority(rawValue: Float(rhs)))
}
public func ~(lhs:Double, rhs: Int) -> (CGFloat, UILayoutPriority) {
	return (CGFloat(lhs), UILayoutPriority(rawValue: Float(rhs)))
}
public func ~<A: LayoutAnchor>(lhs:A, rhs: Int) -> (A, CGFloat, UILayoutPriority) {
	return (lhs, CGFloat(0), UILayoutPriority(rawValue: Float(rhs)))
}
public func ==(lhs: LayoutProperty<NSLayoutDimension>, rhs: CGFloat){
	lhs.equal(to: rhs)
}
public func ==(lhs: LayoutProperty<NSLayoutDimension>,
		rhs: (CGFloat, UILayoutPriority)) {
	lhs.equal(to: rhs.0, priority: rhs.1)
}
public func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>,
						 rhs: (A, CGFloat)) {
	lhs.equal(to: rhs.0, offsetBy: rhs.1)
}
public func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>,
						 rhs: (A, CGFloat, UILayoutPriority)) {
	lhs.equal(to: rhs.0, offsetBy: rhs.1, priority: rhs.2)
}

public func ==<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
	lhs.equal(to: rhs)
}


public func >=(lhs: LayoutProperty<NSLayoutDimension>, rhs: CGFloat){
	lhs.greaterThanOrEqual(to: rhs)
}
public func >=(lhs: LayoutProperty<NSLayoutDimension>,
		rhs: (CGFloat, UILayoutPriority)) {
	lhs.greaterThanOrEqual(to: rhs.0, priority: rhs.1)
}

public func >=<A: LayoutAnchor>(lhs: LayoutProperty<A>,
						 rhs: (A, CGFloat)) {
	lhs.greaterThanOrEqual(to: rhs.0, offsetBy: rhs.1)
}

public func >=<A: LayoutAnchor>(lhs: LayoutProperty<A>,
						 rhs: (A, CGFloat, UILayoutPriority)) {
	lhs.greaterThanOrEqual(to: rhs.0, offsetBy: rhs.1, priority: rhs.2)
}

public func >=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
	lhs.greaterThanOrEqual(to: rhs)
}



public func <=(lhs: LayoutProperty<NSLayoutDimension>, rhs: CGFloat){
	lhs.lessThanOrEqual(to: rhs)
}
public func <=(lhs: LayoutProperty<NSLayoutDimension>,
		rhs: (CGFloat, UILayoutPriority)) {
	lhs.lessThanOrEqual(to: rhs.0, priority: rhs.1)
}
public func <=<A: LayoutAnchor>(lhs: LayoutProperty<A>,
						 rhs: (A, CGFloat)) {
	lhs.lessThanOrEqual(to: rhs.0, offsetBy: rhs.1)
}
public func <=<A: LayoutAnchor>(lhs: LayoutProperty<A>,
						 rhs: (A, CGFloat, UILayoutPriority)) {
	lhs.lessThanOrEqual(to: rhs.0, offsetBy: rhs.1, priority: rhs.2)
}
public func <=<A: LayoutAnchor>(lhs: LayoutProperty<A>, rhs: A) {
	lhs.lessThanOrEqual(to: rhs)
}
