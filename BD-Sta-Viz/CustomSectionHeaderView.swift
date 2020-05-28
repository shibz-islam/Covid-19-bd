//
//  CustomSectionHeaderView.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/22/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerSubTitleLabel: UILabel!
    
    @IBOutlet weak var backgroundWrapperViewTop: UIView!
    @IBOutlet weak var backgroundWrapperViewBottom: UIView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.backgroundWrapperViewTop.backgroundColor = UIColor.themeLightGreen
        self.backgroundWrapperViewBottom.backgroundColor = UIColor.themeWhiteSmoke
    }
}
