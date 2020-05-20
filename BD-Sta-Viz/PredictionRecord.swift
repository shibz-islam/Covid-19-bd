//
//  PredictionRecord.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/11/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

class PredictionRecord: Record {
    var predCases: Int
    var predRecoveries: Int
    var predFatalities: Int
    
    override init(name: String, level: String, cases: Int, date: String) {
        self.predCases = cases
        self.predRecoveries = 0
        self.predFatalities = 0
        super.init(name: name, level: level, cases: 0, date: date)
    }
    
    override func printProperties() {
        print("Name: \(String(describing: self.name))")
        print("Level: \(String(describing: self.level))")
        print("Predicted Cases: \(String(describing: self.predCases))")
        print("Predicted Deaths: \(String(describing: self.predFatalities))")
        print("Predicted Cured: \(String(describing: self.predRecoveries))")
        print("Date: \(String(describing: self.date))")
    }
}
