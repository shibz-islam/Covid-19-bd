//
//  AppConstants.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/9/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

enum Constants {
    
    static let appName:String = "BD Sta-Viz"
    
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
        static let keyPopulation: String = "population"
        static let keyLocationLevelDistrict = "city"
        static let keyLocationLevelCity = "zone"
        static let keyAppID: String = "keyAppID"
        static let keyAppLastUpdateDate: String = "keyAppLastUpdateDate"
        static let keyAppLastUpdateDateForLevelCity: String = "keyAppLastUpdateDateForLevelCity"
    }
    
    enum ApiConstants {
        static let keyForApiPrediction: String = "predictions/?"
        static let keyNextDay: String = "nextday"
        static let keyOneWeek: String = "7days"
        static let keyForUpdateLocation: String = "log_location"
    }
    
    enum ServerKeywords {
        static let keySuccess: String = "success"
        static let keyError: String = "error"
        static let keyStatus: String = "status"
        static let keyPayload: String = "payload"
        static let keyData: String = "data"
        static let keyPrediction: String = "preds"
        static let keyCases: String = "cases"
        static let keyCity: String = "city"
        static let keyLevel: String = "level"
        static let keyName: String = "name"
        static let keyType: String = "type"
        static let keyDate: String = "date"
        static let keyRecordType: String = "record_type"
        static let keyYear: String = "year"
        static let keyPopulation: String = "pop"
        static let keyArea: String = "area"
        static let keyAreaUnit: String = "area_unit"
        static let keyMeta: String = "meta"
    }
    
    enum StoryboardConstants {
        static let sideMenuNavigationControllerID: String = "RightMenuNavigationController"
    }
    
    enum AppUrls{
        static let appBaseUrlString: String = "http://149.165.157.107:1971/api/"
        static let websiteBaseUrl: URL = URL(string:"https://www.lrkhan.com/bd-sta-viz")!
        static let helpfulSites: URL = URL(string:"https://www.lrkhan.com/bd-sta-viz")!
        static let aboutApp: URL = URL(string:"https://www.lrkhan.com/bd-sta-viz")!
        static let aboutUs: URL = URL(string:"https://www.lrkhan.com/")!
    }
    
    enum UserDefaults {
        static let keyPredictionRecordLastUpdateDateDistrictLevel: String = "PredictionRecordLastUpdateDateDistrictLevel"
    }
    
    enum CoreDataConstants {
        
    }
    
    enum PopulationConstants {
        static let appBaseUrlString: String = "http://149.165.157.107:1972/api/"
        static let keyForApiTimestamps: String = "timestamps?"
        static let keyForApiData: String = "data?"
    }
    
    
    enum ViewControllerConstants {
        static let segmentedControlFirstIndex: String = NSLocalizedString("District", comment: "")
        static let segmentedControlSecondIndex: String = NSLocalizedString("Dhaka", comment: "") + " " + NSLocalizedString("City", comment: "")
        static let defaultCountryName: String = NSLocalizedString("Bangladesh", comment: "")
        static let defaultCityName: String = NSLocalizedString("Dhaka", comment: "")
        static let labelRegion: String = NSLocalizedString("Region", comment: "")
        static let labelPopulation: String = NSLocalizedString("Population", comment: "")
    }
}
