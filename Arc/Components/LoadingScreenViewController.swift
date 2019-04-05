//
//  LoadingScreenViewController.swift
//  Arc
//
//  Created by Philip Hayes on 11/20/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import Arc
class LoadingScreenViewController: UIViewController {
	@IBOutlet weak var progress:UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	open func didProgress(_ items:Int, _ total:Int) {
		let prog = Float(items) / Float(total)
		//print(items, total, prog)
			self.progress.progress = prog

		
		
		if items >= total {
			
			Arc.shared.nextAvailableState()
			
		}
	}
	

}
