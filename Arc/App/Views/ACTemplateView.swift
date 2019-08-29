//
//  ACTemplateView.swift
//  Arc
//
//  Created by Philip Hayes on 7/1/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
import HMMarkup


/** ACTemplate view is a view that is automatically nested in a scrollview exposed as
 	"root"

	There is an ImageView called backgroundView. It can be used to layer things behind all
	content on the screen.

	The when subclassing override the header, content, and footer functions accordingly to organize your views.

	If a view becomes scrollable then a scroll indicator will appear on the screen.
*/
open class ACTemplateView: UIView, UIScrollViewDelegate {
	var root:UIScrollView!
	var backgroundView:UIImageView!
	public var nextButton:ACButton?
	var renderer:HMMarkupRenderer!
	var shouldShowScrollIndicator: Bool = true
	var spacerView:UIView!
	var scrollIndicatorView: UIView!
	var scrollIndicatorLabel:UILabel!

	public init() {
		super.init(frame: .zero)
		
		self.backgroundColor = .white
		build()
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
	}
	open override func didMoveToWindow() {
		super.didMoveToWindow()
		scrollIndicatorState(root)
	}
	/// creates the views contents
	/// Creates an imageview and scrollview in front of it. 
	func build() {
		if root != nil {
			root.removeFromSuperview()
		}
		let v = self
		backgroundView = image {
			$0.backgroundColor = .clear
			$0.contentMode = .scaleAspectFill
			$0.layout {
				
				// select an anchor give a priority of 999 (almost Required)
				$0.top == v.topAnchor ~ 999
				$0.trailing == v.trailingAnchor ~ 999
				$0.bottom <= v.bottomAnchor ~ 999
				$0.leading == v.leadingAnchor ~ 999
				
			}
		}
		root = scroll {[unowned self] in
			
			
			let v = $0.stack {
				$0.spacing = 8
				$0.axis = .vertical
				$0.alignment = .fill
				$0.isLayoutMarginsRelativeArrangement = true
				$0.layoutMargins = UIEdgeInsets(top: 24,
												left: 24,
												bottom: 24,
												right: 24)
				//An internal override point for handling content that will appear above all other content.
				header($0)
				
				//This will be where the main content of a view should go.
				content($0)
				
				//This vew allows the footer to stack from the bottom of the screen up.
				//Once space runs out the view will expand downward and become scrollable.
				spacerView = $0.view {
					$0.accessibilityLabel = "spacer"
					$0.translatesAutoresizingMaskIntoConstraints = false
					$0.isHidden = true
					$0.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .vertical)
				}
				
				//This is for items that you want to always be below all other content.
				footer($0)
			}
			
			v.layout {
				
				// select an anchor give a priority of 999 (almost Required)
				$0.top == v.superview!.topAnchor ~ 999
				$0.trailing == v.superview!.trailingAnchor ~ 999
				$0.bottom == v.superview!.bottomAnchor ~ 999
				$0.leading == v.superview!.leadingAnchor ~ 999
				$0.width == self.widthAnchor ~ 999
				$0.height >= self.safeAreaLayoutGuide.heightAnchor ~ 500
			}
			
		}
		root.layout { [unowned self] in
			$0.top == safeAreaLayoutGuide.topAnchor ~ 999
			$0.trailing == safeAreaLayoutGuide.trailingAnchor ~ 999
			$0.bottom == safeAreaLayoutGuide.bottomAnchor ~ 999
			$0.leading == safeAreaLayoutGuide.leadingAnchor ~ 999
			$0.width == self.widthAnchor ~ 999
			$0.height == self.heightAnchor ~ 999
		}

		self.scrollIndicatorView = scrollIndicator {
			$0.configure(with: IndicatorView.Config(primaryColor: ACColor.primaryText,
												 secondaryColor: ACColor.primaryText,
												 textColor: .white,
												 cornerRadius: 20.0,
												 arrowEnabled: false))
			$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
			$0.acLabel{
				$0.textAlignment = .center
				$0.text = "Scroll".localized("")
				Roboto.Style.body($0, color: ACColor.secondary)
				$0.layout {
					
//					$0.trailing >= v.safeAreaLayoutGuide.trailingAnchor + 20 ~ 999
					$0.bottom == v.safeAreaLayoutGuide.bottomAnchor - 20 ~ 999
//					$0.leading >= v.safeAreaLayoutGuide.leadingAnchor + 20 ~ 999
					$0.width >= 80
					$0.centerX == v.centerXAnchor
					$0.height >= 40
				}
			}
		}
		root.delegate = self
		
		scrollIndicatorState(root)

	}
	open func header(_ view:UIView) {
		
	}
	/// Layout content for the view override this method to add content to a
	/// pre-constrained scrollview, this will also  automatically add a scroll
	/// indicator to the view. Keyboard insets will be handled when they appear.
	///
	/// - Parameter view: the root view to add content to. You will need to constrain the view to the edges and ensure that the height and width can be determined by the inner content.
	open func content(_ view:UIView) {
	
	}
	
	open func footer(_ view:UIView) {
		
		
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		print("keyboardWillShow")
		setBottomScrollInset(value: 40)
	}
	
	@objc func keyboardWillHide(notification: NSNotification){
		print("keyboardWillHide")
		setBottomScrollInset(value: 0)
		
	}
	public func setBottomScrollInset(value:CGFloat) {
		var inset = root.contentInset
		
		inset.bottom = value
		
		root.contentInset = inset
	}

	// MARK: ScrollView
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)
	}
	public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)
		
	}
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.scrollIndicatorState(scrollView)
		
	}
	private func scrollIndicatorState(_ scrollView: UIScrollView) {
		guard scrollIndicatorView != nil else {
			return 
		}
		guard shouldShowScrollIndicator else {
			scrollIndicatorView.alpha = 0
			return
		}
		guard let nextButton = nextButton else {
			scrollIndicatorView.alpha = 0

			return
		}
		let contentHeight = scrollView.contentSize.height
		
		let viewHeight = scrollView.bounds.height
		let offset = scrollView.contentOffset.y
		
		let effectiveHeight = contentHeight - viewHeight - 20
		let maxProgress = contentHeight - viewHeight - effectiveHeight
		
		let progress = min(maxProgress, max(offset - effectiveHeight, 0))
		let convertedRect = nextButton.convert(nextButton.frame, to: scrollView)
		
		guard !scrollView.bounds.contains(convertedRect) && !scrollView.bounds.intersects(convertedRect) else {
			scrollIndicatorView.alpha = 0
			return
		}
		let alpha:CGFloat = 1.0 - (progress/maxProgress)
		scrollIndicatorView.alpha = alpha
		
	}
}
