//
//  LocationInfo.swift
//  CovidTest
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

class LocationInfo {
    let name: String?
    let parent: String?
    let level: String?
    var latitude: Double?
    var longitude: Double?
    let cases: Int?
    let date: Date?
    
    init(name: String?, parent: String?, level: String?, latitude: Double?, longitude: Double?, cases: Int?, date: Date?) {
        self.name = name
        self.parent = parent
        self.level = level
        self.latitude = latitude
        self.longitude = longitude
        self.cases = cases
        self.date = date
    }
    
    func printProperties() {
        print("Name: \(String(describing: self.name))")
        print("Parent: \(String(describing: self.parent))")
        print("Level: \(String(describing: self.level))")
        print("Latitude:\(String(describing: self.latitude)), Longitude:\(String(describing: longitude))")
        print("Cases: \(String(describing: self.cases))")
        print("Date: \(String(describing: self.date))")
    }
}
