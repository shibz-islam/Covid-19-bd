//
//  Record.swift
//  CovidTest
//
//  Created by shihab on 5/1/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

class Record {
    var name: String
    var level: String
    var date: String
    var cases: Int
    var recoveries: Int
    var fatalities: Int
    
    init(name: String, level: String, cases: Int, date: String) {
        self.name = name
        self.level = level
        self.cases = cases
        self.fatalities = 0
        self.recoveries = 0
        self.date = date
    }
    
    init(name: String, level: String, cases: Int, fatalities: Int, recoveries: Int, date: String) {
        self.name = name
        self.level = level
        self.cases = cases
        self.fatalities = fatalities
        self.recoveries = recoveries
        self.date = date
    }

    func printProperties() {
        print("Name: \(String(describing: self.name))")
        print("Level: \(String(describing: self.level))")
        print("Cases: \(String(describing: self.cases))")
        print("Death: \(String(describing: self.fatalities))")
        print("Cured: \(String(describing: self.recoveries))")
        print("Date: \(String(describing: self.date))")
    }
}
