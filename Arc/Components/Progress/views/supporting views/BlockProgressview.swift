//
//  BlockProgressview.swift
//  Arc
//
//  Created by Philip Hayes on 7/24/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class BlockProgressview: UIStackView {

	var maxBlockCount:Int = 12
	var currentBlock:Int = 0
	var color:UIColor = #colorLiteral(red: 0.400000006, green: 0.7799999714, blue: 0.7799999714, alpha: 1)
	
	init() {
		super.init(frame: .zero)
		spacing = 4
		axis = .horizontal
		distribution = .fillEqually
	}
	public func set(count:Int, current:Int) {
		removeSubviews()
		
		for i in 0 ..< count {
			view {
				$0.layer.cornerRadius = 2
				if i < current {
					$0.backgroundColor = color
				} else if i == current {
					$0.backgroundColor = color

				} else {
					$0.backgroundColor = .clear
					$0.layer.borderColor = color.cgColor
					$0.layer.borderWidth = 1
					
				}
			}
			
		}
	}
	required init(coder: NSCoder) {
		super.init(coder: coder)
	}
	
}
extension UIView {
	
	@discardableResult
	public func blockProgress(apply closure: (BlockProgressview) -> Void) -> BlockProgressview {
		return custom(BlockProgressview(), apply: closure)
	}
	
}
