//
//  DemographyInfo.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

class DemographyInfo: LocationInfo {
    var population: Int
    var area: Double
    var areaUnit: String
    
    init(name: String, parent: String, level: String, population: Int, area: Double, year: String, areaUnit: String) {
        self.population = population
        self.area = area
        self.areaUnit = areaUnit
        super.init(name: name, parent: parent, level: level, latitude: 0, longitude: 0, cases: 0, date: year)
    }
    
    init(name: String, parent: String, level: String, latitude: Double, longitude: Double, population: Int, area: Double, year: String, areaUnit: String) {
        self.population = population
        self.area = area
        self.areaUnit = areaUnit
        super.init(name: name, parent: parent, level: level, latitude: latitude, longitude: longitude, cases: 0, date: year)
    }
}
