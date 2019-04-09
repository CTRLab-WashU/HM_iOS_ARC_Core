//
//  UIViewController+Extensions.swift
// Arc
//
//  Created by Philip Hayes on 9/28/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
public extension UIViewController {
	static public func get<T:UIViewController>(nib:String? = nil, bundle:Bundle? = nil) -> T {
		//For multi-module functionality.
		var _bundle:Bundle? = bundle
		if bundle == nil {
			_bundle = Bundle(for: T.self)

		}
		dump(_bundle)
        let vc = T(nibName: nib ?? String(describing: self), bundle: _bundle)
        
        return vc
    }
    static public func present<T:UIViewController>(nib:String? = nil, onSetup:((T)->Void)? = nil, onCompletion:(()->Void)? = nil) -> T {
        
        let vc:T = .get()
        
        onSetup?(vc)
        
        let window = UIApplication.shared.keyWindow?.rootViewController
        
        window?.present(vc, animated: true, completion: {
            
            onCompletion?()
            
        })
        
        return vc
    }
    static public func replace<T:UIViewController>(nib:String? = nil, onSetup:((T)->Void)? = nil, onCompletion:((T)->Void)? = nil) -> T {
        
        let vc:T = .get()
        
        onSetup?(vc)
        
        UIApplication.shared.keyWindow?.rootViewController = vc
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
        
        onCompletion?(vc)
        return vc
    }
}
