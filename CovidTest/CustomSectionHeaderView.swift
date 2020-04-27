//
//  CustomSectionHeaderView.swift
//  CovidTest
//
//  Created by shihab on 4/22/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

class CustomSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundWrapperView: UIView!
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let color: UIColor = UIColor(red: CGFloat(220/255.0), green: CGFloat(220/255.0), blue: CGFloat(220/255.0), alpha: CGFloat(1.0))
        self.backgroundWrapperView.backgroundColor = UIColor.themeLightOrange
    }
    

}
