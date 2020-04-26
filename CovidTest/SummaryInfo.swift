//
//  SummaryInfo.swift
//  CovidTest
//
//  Created by shihab on 4/26/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

class SummaryInfo {
    let name: String
    let level: String
    let cases: Int
    let death: Int
    let cured: Int
    let date: String
    
    init(name: String, level: String, cases: Int, death: Int, cured: Int, date: String) {
        self.name = name
        self.level = level
        self.cases = cases
        self.death = death
        self.cured = cured
        self.date = date
    }
    
    func printProperties() {
        print("Name: \(String(describing: self.name))")
        print("Level: \(String(describing: self.level))")
        print("Cases: \(String(describing: self.cases))")
        print("Death: \(String(describing: self.death))")
        print("Cured: \(String(describing: self.cured))")
        print("Date: \(String(describing: self.date))")
    }
}
