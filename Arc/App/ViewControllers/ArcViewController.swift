//
//  MHViewController.swift
// Arc
//
//  Created by Philip Hayes on 10/8/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit


open class ArcViewController: UIViewController {
	public var app:Arc {
		get {
			return Arc.shared
		}
		set {
			
		}
	}
	public var currentHint:HintView?
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	open func get(flag:ProgressFlag) -> Bool {
		return app.appController.flags[flag.rawValue] ?? false
	}
	open func set(flag:ProgressFlag) {
		app.appController.flags[flag.rawValue] = true
	}
	open func remove(flag:ProgressFlag) {
		app.appController.flags[flag.rawValue] = false
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
