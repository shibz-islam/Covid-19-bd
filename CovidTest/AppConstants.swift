//
//  AppConstants.swift
//  CovidTest
//
//  Created by shihab on 5/9/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

enum Constants {
    
    static let appName:String = "Covid19-BD"
    
    enum LocationConstants {
        static let defaultCountryName: String = "Bangladesh"
        static let defaultDistrictName: String = "Dhaka"
        static let defaultLocationLatitude: Double = 23.777176
        static let defaultLocationLongitude: Double = 90.399452
        static let defaultLocationCityLatitude: Double = 23.746402
        static let defaultLocationCityLongitude: Double = 90.374574
    }
    
    enum KeyStrings {
        static let keyCountry: String = "country"
        static let keyLocationLevelDistrict = "city"
        static let keyLocationLevelCity = "zone"
        static let keyAppID: String = "keyAppID"
        static let keyAppLastUpdateDate: String = "keyAppLastUpdateDate"
        static let keyAppLastUpdateDateForLevelCity: String = "keyAppLastUpdateDateForLevelCity"
    }
    
    enum ApiConstants {
        
    }
    
    enum ViewControllerConstants {
        static let segmentedControlFirstIndex: String = "District"
        static let segmentedControlSecondIndex: String = "Dhaka City"
    }
    
    enum StoryboardConstants {
        static let sideMenuNavigationControllerID: String = "RightMenuNavigationController"
    }
    
    enum CoreDataConstants {
        
    }
}
