//
//  MHViewController.swift
// Arc
//
//  Created by Philip Hayes on 10/8/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit

open class ArcViewController: UIViewController {
	public let app = Arc.shared
    override open func viewDidLoad() {
        super.viewDidLoad()
		modalPresentationStyle = .fullScreen
        // Do any additional setup after loading the view.
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
