//
//  ACPDFViewController.swift
//  Arc
//
//  Created by Philip Hayes on 1/24/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import Foundation
import PDFKit
public class ACPDFViewController : CustomViewController<ACPDFView> {
	public override func viewDidLoad() {
		super.viewDidLoad()
		customView.closeButton.addAction {[weak self] in
			self?.dismiss(animated: true){self?.customView.pdfView.document = nil}
		}
	}
	public func setDocument(url:URL) {
		customView.pdfView.document = PDFDocument(url: url)
		customView.pdfView.autoScales = true
		
	}
}
