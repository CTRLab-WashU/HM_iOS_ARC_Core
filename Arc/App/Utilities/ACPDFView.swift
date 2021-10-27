//
//  ACPDFView.swift
//  Arc
//
//  Created by Philip Hayes on 1/24/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import UIKit
import PDFKit

public class ACPDFView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	public var pdfView:PDFView!
	public var closeButton:ACButton!
	init() {
		super.init(frame: .zero)
		build()
	}
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		build()
		
	}
	func build() {
		let root = stack { [weak self] in
			
			$0.axis = .vertical
			$0.distribution = .fill
			$0.alignment = .fill
			$0.spacing = 8
			self?.pdfView = $0.pdfView { _ in
				
			}
			
			self?.closeButton = $0.acButton {
				$0.setTitle("Close", for: .normal)
			}
		}
		root.attachTo(view: self)
	}

}
