//
//  PredictionSectionHeaderView.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/11/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

class PredictionSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var backgroundWrapperView: UIView!
    @IBOutlet weak var backgroundWrapperViewTop: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        backgroundWrapperView.backgroundColor = UIColor.themeWhiteSmoke
        backgroundWrapperViewTop.backgroundColor = UIColor.themeWhiteSmoke
        
//        if self.traitCollection.userInterfaceStyle == .dark{
//        }
    }
    

}
