//
//  GridImageChoiceView.swift
//  Arc
//
//  Created by Andrew Pearson on 8/3/20.
//  Copyright © 2020 HealthyMedium. All rights reserved.
//

import UIKit


@IBDesignable public class GridTestSelectionView : UIView {
    
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var keyView: UIView!
    @IBOutlet weak var keyButton: UIButton!
    @IBOutlet weak var keyImage: UIImageView!
    @IBOutlet weak var penView: UIView!
    @IBOutlet weak var penButton: UIButton!
    @IBOutlet weak var penImage: UIImageView!
    @IBOutlet weak var removeItem: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var selectLabel: UILabel!
    
    @objc func hideRemoveItemButton()
    {
        removeItem.isHidden = true
        divider.isHidden = true
    }
}

