//
//  SideMenuHeaderView.swift
//  TabViewTest
//
//  Created by shihab on 5/10/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

class SideMenuHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundWrapperView: UIView!
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        
        titleLabel.text = Constants.appName
        titleLabel.textColor = UIColor.white
        
        backgroundWrapperView.backgroundColor = UIColor.themeSlateGray
    }
}
