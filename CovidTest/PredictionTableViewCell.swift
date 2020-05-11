//
//  PredictionTableViewCell.swift
//  CovidTest
//
//  Created by shihab on 5/11/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

class PredictionTableViewCell: UITableViewCell {

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var caseLabel: UILabel!
    @IBOutlet weak var predLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
