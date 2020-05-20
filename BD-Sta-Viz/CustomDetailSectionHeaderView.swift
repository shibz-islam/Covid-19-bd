//
//  CustomDetailSectionHeaderView.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/26/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

class CustomDetailSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var curedLabel: UILabel!
    @IBOutlet weak var deathLabel: UILabel!
    
    @IBOutlet weak var topLevelView: UIView!
    @IBOutlet weak var casesView: UIView!
    @IBOutlet weak var curedView: UIView!
    @IBOutlet weak var deathView: UIView!
    @IBOutlet weak var bottomSectionHeaderView: UIView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        topLevelView.backgroundColor = UIColor.themeLightGreen
        casesView.backgroundColor = UIColor.themeLightOrange
        curedView.backgroundColor = UIColor.themeLightOrange
        deathView.backgroundColor = UIColor.themeLightOrange
        bottomSectionHeaderView.backgroundColor = UIColor.themeWhiteSmoke
        
        topLevelView.layer.cornerRadius = 10
        casesView.layer.cornerRadius = 10
        curedView.layer.cornerRadius = 10
        deathView.layer.cornerRadius = 10
        
        //casesLabel.textColor = UIColor.white
        
        
    }
    

}
