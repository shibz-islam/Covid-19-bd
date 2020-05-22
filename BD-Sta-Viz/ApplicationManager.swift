//
//  ApplicationManager.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/21/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation
import UIKit


/// Singleton Class for managing Application flow
class ApplicationManager {
    static let shared = ApplicationManager()
    private init(){}
    
    func loadApplication() {
        checkAppIdentifier()
        //checkForNewData(withIsLevelCity: false)
        //checkForNewData(withIsLevelCity: true)
        //checkForSummary()
        fetchDemographicInfoFromServer()
    }
    
    /// Check if App id is fetched from server
    func checkAppIdentifier() {
        if CoreDataManager.shared.isValueExistInKeychain(withKey: Constants.KeyStrings.keyAppID) == false {
            AuthenticationManager.shared.sendRequestForAppIdentifier { (isSuccess, identifier) in
                if isSuccess == true, let id = identifier{
                    let result = CoreDataManager.shared.storeValueInKeychain(withValue: id, withKey: Constants.KeyStrings.keyAppID)
                    print("Storing result: \(result)")
                }
            }
        }
    }
    
    
    /// Check for new data in server
    func checkForNewData(withIsLevelCity isLevelCity: Bool) {
        let isRecordsExist = isLevelCity == false ? CoreDataManager.shared.isValueExistInKeychain(withKey: Constants.KeyStrings.keyAppLastUpdateDate) : CoreDataManager.shared.isValueExistInKeychain(withKey: Constants.KeyStrings.keyAppLastUpdateDateForLevelCity)
        if isRecordsExist == false {
            print("No data in store. Need to fetch new data from server. isLevelCity: \(isLevelCity)")
            fetchNewDataFromServer(withDate: Date(), withIsLevelCity: isLevelCity, withIsPreviousDataExist: false)
        }
        else{
            let lastUpdateDate = isLevelCity == false ? CoreDataManager.shared.retrieveValueFromKeychain(withKey: Constants.KeyStrings.keyAppLastUpdateDate) : CoreDataManager.shared.retrieveValueFromKeychain(withKey: Constants.KeyStrings.keyAppLastUpdateDateForLevelCity)
            print("CoreData date: \(lastUpdateDate), isLevelCity: \(isLevelCity)")
            if lastUpdateDate == Date().getStringDate(){
                print("Data already upto date. isLevelCity: \(isLevelCity)")
                loadData(withDate: Date(), withIsLevelCity: isLevelCity)
            }
            else{
                print("Data not upto date. Need to fetch new data from server. isLevelCity: \(isLevelCity)")
                fetchNewDataFromServer(withDate: Date(), withIsLevelCity: isLevelCity, withIsPreviousDataExist: true)
            }
        }
    }
    
    
    /// Fetch data from Server according to date
    /// - Parameters:
    ///   - date: date of data
    ///   - isLevelCity: City or District level
    ///   - isPreviousData: is previous date stored in keychain
    func fetchNewDataFromServer(withDate date:Date, withIsLevelCity isLevelCity: Bool, withIsPreviousDataExist isPreviousData: Bool) {
        LocationManager.shared.getLocationData(withIsLevelCity: isLevelCity, withDate: date, completionHandler: { (isSuccess, message) in
            if isSuccess == true {
                if isLevelCity {
                    print("Success, total count: \(LocationManager.shared.dictForCityLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformationForCity, object: nil)
                    DispatchQueue.main.async {
                        CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                        CoreDataManager.shared.storeValueInKeychain(withValue: date.getStringDate(), withKey: Constants.KeyStrings.keyAppLastUpdateDateForLevelCity)
                    }
                }
                else{
                    print("Success, total count: \(LocationManager.shared.dictForDistrictLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
                    DispatchQueue.main.async {
                        CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                        CoreDataManager.shared.storeValueInKeychain(withValue: date.getStringDate(), withKey: Constants.KeyStrings.keyAppLastUpdateDate)
                    }
                }
            }
            else{
                if message == AuthenticationManager.shared.kErrorServer {
                    if isPreviousData == true {
                        self.loadData(withDate: date.dayBefore, withIsLevelCity: isLevelCity)
                    }else{
                        self.fetchPreviousDataFromServer(withDate: date.dayBefore, withIsLevelCity: isLevelCity)
                    }
                }
            }
        })
    }
    
    /// Fetch previous data from Server according to date
    /// - Parameters:
    ///   - date: date of data (not today)
    ///   - isLevelCity: City or District level
    func fetchPreviousDataFromServer(withDate date:Date, withIsLevelCity isLevelCity: Bool) {
        LocationManager.shared.getLocationData(withIsLevelCity: isLevelCity, withDate: date, completionHandler: { (isSuccess, message) in
            if isSuccess == true {
                if isLevelCity {
                    print("Success, total count: \(LocationManager.shared.dictForCityLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformationForCity, object: nil)
                    DispatchQueue.main.async {
                        CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                        CoreDataManager.shared.storeValueInKeychain(withValue: date.getStringDate(), withKey: Constants.KeyStrings.keyAppLastUpdateDateForLevelCity)
                    }
                }
                else{
                    print("Success, total count: \(LocationManager.shared.dictForDistrictLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
                    DispatchQueue.main.async {
                        CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                        CoreDataManager.shared.storeValueInKeychain(withValue: date.getStringDate(), withKey: Constants.KeyStrings.keyAppLastUpdateDate)
                    }
                }
            }
            else{
                print("Error message from fetchPreviousDataFromServer: \(String(describing: message))")
            }
        })
    }
    
    
    /// Load data from Core data according to date
    /// - Parameter date: date of data
    func loadData(withDate date:Date, withIsLevelCity isLevelCity: Bool) {
        print("Load data from date: \(date.getStringDate())")
        DispatchQueue.main.async {
            if CoreDataManager.shared.isLocationInfoExist(withDate: date) == false {
                print("No data found in core data, getting data from server. isLevelCity: \(isLevelCity)")
                self.fetchNewDataFromServer(withDate: date, withIsLevelCity: isLevelCity, withIsPreviousDataExist: false)
            }
            else{
                print("Data found in core data... loading data into memory. isLevelCity: \(isLevelCity)")
                let success = CoreDataManager.shared.fetchLocationInfo(withDate: date, withIsLevelCity: isLevelCity)
                if success {
                    print("Successfully loaded into memory")
                    if isLevelCity {
                        NotificationCenter.default.post(name: .kDidLoadLocationInformationForCity, object: nil)
                    }else{
                        NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
                    }
                } else {
                    print("Failed to load into memory")
                }
            }
        }
    }
    
    
    func checkForSummary() {
        if let record = LocationManager.shared.dictForRecentRecords[Constants.LocationConstants.defaultCountryName]{
            if record.date == Date().getStringDate() {
                print("Summary already upto date.")
                return
            }
        }
        LocationManager.shared.getRecentSummary(withName:Constants.LocationConstants.defaultCountryName, withType: Constants.KeyStrings.keyCountry) { (isSuccess, message) in
            if isSuccess == true {
                NotificationCenter.default.post(name: .kDidLoadSummaryInformation, object: nil)
            }
        }
    }
    
    // MARK: - Location Service
    func startLocationService() {
        print("startLocationService")
        NotificationCenter.default.post(name: .kDidLoadLocationServiceNotification, object: nil)
    }

    // MARK: - Population info
    func fetchDemographicInfoFromServer() {
        DispatchQueue.global(qos: .background).async {
            AuthenticationManager.shared.sendRequestForPopulationTimestamps(withName: Constants.LocationConstants.defaultCountryName, withType: Constants.KeyStrings.keyCountry, withRecordType: Constants.KeyStrings.keyPopulation) { (isSuccess, message, timestampArray) in
                if isSuccess == true {
                    LocationManager.shared.listForTimestamps.removeAll()
                    let timeList = timestampArray.sorted(by: { $0 < $1 })
                    LocationManager.shared.listForTimestamps = timeList
                    if LocationManager.shared.dictForDemographicInfo.count == 0 {
                        self.fetchDemographicInfoFromServer(withTimestamp: timeList.last ?? "")
                        for i in 0..<timeList.count-1{
                            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                                self.fetchDemographicInfoFromServer(withTimestamp: timeList[i])
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchDemographicInfoFromServer(withTimestamp year: String) {
        AuthenticationManager.shared.sendRequestForDemographicData(withName: Constants.LocationConstants.defaultCountryName, withType: Constants.KeyStrings.keyCountry, withYear: year) { (isSuccess, message, infoArray) in
            if isSuccess == true {
                /* if no data stored in dict, set a flag and load the data for tableview */
                var isEmpty: Bool = false
                if LocationManager.shared.dictForDemographicInfo.count == 0 {
                    for loc in infoArray {
                        LocationManager.shared.dictForDemographicInfo[loc.name] = [loc]
                        //NotificationCenter.default.post(name: .kDidLoadDemographyDataNotification, object: nil)
                    }
                    isEmpty = true
                }
                
                var count: Int = 0
                let totalRequest: Int = infoArray.count
                for loc in infoArray {
                    /* if no coordinate is available for locations, fetch the coordinates */
                    if isEmpty == false{
                        if let demoList = LocationManager.shared.dictForDemographicInfo[loc.name] {
                            let item = demoList.first
                            loc.latitude = item?.latitude ?? 0
                            loc.longitude = item?.longitude ?? 0
                            LocationManager.shared.dictForDemographicInfo[loc.name]?.append(loc)
                        }
                    }
                    else{
                        let key = loc.name + "," + loc.parent
                        AuthenticationManager.shared.sendRequestForLocationInfoWithKey(key: key) { (isSuccess, location) in
                            count = count + 1
                            if isSuccess == true{
                                loc.latitude = location?.coordinate.latitude ?? 0
                                loc.longitude = location?.coordinate.longitude ?? 0
                                LocationManager.shared.dictForDemographicInfo[loc.name] = [loc]
                                if count == totalRequest {
                                    NotificationCenter.default.post(name: .kDidLoadDemographyDataNotification, object: nil)
                                }
                            }
                        }//end of completionHandler
                    }
                }//end loop
            }
        }

    }
    
    
    
}//end of Class
