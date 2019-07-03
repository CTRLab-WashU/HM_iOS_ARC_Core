import UIKit
import SceneKit
import SpriteKit
import WebKit
import MapKit
import MetalKit

public func view(apply closure: (UIView) -> Void) -> UIView {
	let view = UIView()
	closure(view)
	return view
}

public func stack(apply closure: (UIStackView) -> Void) -> UIStackView {
	let stack = UIStackView()
	closure(stack)
	return stack
}

extension UIView {
	func add(_ view: UIView) {
		if let stack = self as? UIStackView {
			stack.addArrangedSubview(view)
		} else {
			addSubview(view)
			
		}
	}
}

extension UIView {
	@discardableResult
	public func custom<View: UIView>(_ view: View, apply closure: (View) -> Void) -> View {
		add(view)
		closure(view)
		return view
	}
}

extension UIView {
	@discardableResult
	public func stack(apply closure: (UIStackView) -> Void) -> UIStackView {
		custom(UIStackView(), apply: closure)
	}
	
	@discardableResult
	public func view(apply closure: (UIView) -> Void) -> UIView {
		custom(UIView(), apply: closure)
	}
	
	@discardableResult
	public func button(with type: UIButton.ButtonType = .system,
					   apply closure: (UIButton) -> Void) -> UIButton {
		custom(UIButton(type: type), apply: closure)
	}
	
	@discardableResult
	public func label(apply closure: (UILabel) -> Void) -> UILabel {
		custom(UILabel(), apply: closure)
	}
	
	@discardableResult
	public func segmentedControl(with items: [Any]? = nil,
								 apply closure: (UISegmentedControl) -> Void) -> UISegmentedControl {
		custom(UISegmentedControl(items: items), apply: closure)
	}
	
	@discardableResult
	public func textField(apply closure: (UITextField) -> Void) -> UITextField {
		custom(UITextField(), apply: closure)
	}
	
	@discardableResult
	public func slider(apply closure: (UISlider) -> Void) -> UISlider {
		custom(UISlider(), apply: closure)
	}
	
	@discardableResult
	public func uiswitch(apply closure: (UISwitch) -> Void) -> UISwitch {
		custom(UISwitch(), apply: closure)
	}
	
	@discardableResult
	public func activityIndicator(with style: UIActivityIndicatorView.Style = .white,
								  apply closure: (UIActivityIndicatorView) -> Void) -> UIActivityIndicatorView {
		custom(UIActivityIndicatorView(style: style), apply: closure)
	}
	
	@discardableResult
	public func progress(with style: UIProgressView.Style = .default,
						 apply closure: (UIProgressView) -> Void) -> UIProgressView {
		custom(UIProgressView(progressViewStyle: style), apply: closure)
	}
	
	@discardableResult
	public func pageControl(apply closure: (UIPageControl) -> Void) -> UIPageControl {
		custom(UIPageControl(), apply: closure)
	}
	
	@discardableResult
	public func stepper(apply closure: (UIStepper) -> Void) -> UIStepper {
		custom(UIStepper(), apply: closure)
	}
	
	@discardableResult
	public func table(with style: UITableView.Style = .plain,
					  apply closure: (UITableView) -> Void) -> UITableView {
		custom(UITableView(frame: .zero, style: style), apply: closure)
	}
	
	@discardableResult
	public func image(apply closure: (UIImageView) -> Void) -> UIImageView {
		custom(UIImageView(), apply: closure)
	}
	
	@discardableResult
	public func collection(apply closure: (UICollectionView) -> Void) -> UICollectionView {
		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: UICollectionViewFlowLayout()
		)
		return custom(collectionView, apply: closure)
	}
	
	@discardableResult
	public func textView(apply closure: (UITextView) -> Void) -> UITextView {
		custom(UITextView(), apply: closure)
	}
	
	@discardableResult
	public func datePicker(apply closure: (UIDatePicker) -> Void) -> UIDatePicker {
		custom(UIDatePicker(), apply: closure)
	}
	
	@discardableResult
	public func scroll(apply closure: (UIScrollView) -> Void) -> UIScrollView {
		custom(UIScrollView(), apply: closure)
	}
	
	@discardableResult
	public func picker(apply closure: (UIPickerView) -> Void) -> UIPickerView {
		custom(UIPickerView(), apply: closure)
	}
	
	@discardableResult
	public func searchBar(apply closure: (UISearchBar) -> Void) -> UISearchBar {
		custom(UISearchBar(), apply: closure)
	}
	
	@discardableResult
	public func toolbar(apply closure: (UIToolbar) -> Void) -> UIToolbar {
		custom(UIToolbar(), apply: closure)
	}
	
	@discardableResult
	public func tabBar(apply closure: (UITabBar) -> Void) -> UITabBar {
		custom(UITabBar(), apply: closure)
	}
	
	@discardableResult
	public func navigationBar(apply closure: (UINavigationBar) -> Void) -> UINavigationBar {
		custom(UINavigationBar(), apply: closure)
	}
	
	@discardableResult
	public func webView(with config: WKWebViewConfiguration,
						apply closure: (WKWebView) -> Void) -> WKWebView {
		custom(WKWebView(frame: .zero, configuration: config), apply: closure)
	}
	
	@discardableResult
	public func sceneView(apply closure: (SCNView) -> Void) -> SCNView {
		custom(SCNView(), apply: closure)
	}
	
	@discardableResult
	public func spriteView(apply closure: (SKView) -> Void) -> SKView {
		custom(SKView(), apply: closure)
	}
	
	@discardableResult
	public func map(apply closure: (MKMapView) -> Void) -> MKMapView {
		custom(MKMapView(), apply: closure)
	}
	
	@discardableResult
	public func metal(apply closure: (MTKView) -> Void) -> MTKView {
		custom(MTKView(), apply: closure)
	}
	
	@discardableResult
	public func visualEffect(with effect: UIVisualEffect? = nil,
							 apply closure: (UIVisualEffectView) -> Void) -> UIVisualEffectView {
		custom(UIVisualEffectView(effect: effect), apply: closure)
	}
	
	
}
