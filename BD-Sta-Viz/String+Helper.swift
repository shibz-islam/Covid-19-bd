//
//  String+Helper.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/11/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: self) else {
            preconditionFailure("Take a look to your format")
        }
        return date
    }
}
