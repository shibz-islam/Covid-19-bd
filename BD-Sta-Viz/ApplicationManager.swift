//
//  ApplicationManager.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/21/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SwiftLocation


/// Singleton Class for managing Application flow
class ApplicationManager {
    static let shared = ApplicationManager()
    private init(){}
    
    func loadApplication() {
        checkAppIdentifier()
        fetchDemographicInfoFromServer()
        checkForStatisticalData(withIsLevelCity: false)
        checkForStatisticalData(withIsLevelCity: true)
        checkForStatisticalDataSummary()
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
    
    // MARK: - Statistical info
    func checkForStatisticalData(withIsLevelCity isLevelCity: Bool) {
        let defaultCallCounter: Int = 3
        let lastUpdateDate = isLevelCity == false ? UserDefaults.standard.string(forKey: Constants.UserDefaults.keyAppLastUpdateDate) : UserDefaults.standard.string(forKey: Constants.UserDefaults.keyAppLastUpdateDateForLevelCity)
        if lastUpdateDate == nil
        {
            print("No data in store. Need to fetch new data from server. isLevelCity: \(isLevelCity)")
            fetchStatisticalDataFromServer(withDate: Date(), withIsLevelCity: isLevelCity, withCallCounter: defaultCallCounter)
        }
        else{
            print("UserDefaults date: \(String(describing: lastUpdateDate)), isLevelCity: \(isLevelCity)")
            if CoreDataManager.shared.isLocationInfoExist(withDate: lastUpdateDate?.toDate() ?? Date()) == false
            {
                print("No data found in core data, getting data from server. isLevelCity: \(isLevelCity)")
                fetchStatisticalDataFromServer(withDate: Date(), withIsLevelCity: isLevelCity, withCallCounter: defaultCallCounter)
            }
            else
            {
                print("Data found in core data... loading data into memory. isLevelCity: \(isLevelCity)")
                loadStatisticalData(withDate: lastUpdateDate?.toDate() ?? Date(), withIsLevelCity: isLevelCity)
                if lastUpdateDate != Date().getStringDate(){
                    print("Data not upto date. Need to fetch new data from server. isLevelCity: \(isLevelCity)")
                    fetchStatisticalDataFromServer(withDate: Date(), withIsLevelCity: isLevelCity, withCallCounter: defaultCallCounter)
                }
            }
        }
    }
    
    func loadStatisticalData(withDate date:Date, withIsLevelCity isLevelCity: Bool) {
        print("Load data from date: \(date.getStringDate())")
        DispatchQueue.main.async {
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
    
    func fetchStatisticalDataFromServer(withDate date:Date, withIsLevelCity isLevelCity: Bool, withCallCounter counter: Int) {
        DataManager.shared.getLocationData(withIsLevelCity: isLevelCity, withDate: date, completionHandler: { (isSuccess, message) in
            if isSuccess == true {
                if isLevelCity {
                    //print("Success, total count: \(DataManager.shared.dictForCityLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformationForCity, object: nil)
                    DispatchQueue.main.async {
                        CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                        UserDefaults.standard.set(date.getStringDate(), forKey: Constants.UserDefaults.keyAppLastUpdateDateForLevelCity)
                    }
                }
                else{
                    //print("Success, total count: \(DataManager.shared.dictForDistrictLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
                    DispatchQueue.main.async {
                        CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                        UserDefaults.standard.set(date.getStringDate(), forKey: Constants.UserDefaults.keyAppLastUpdateDate)
                    }
                }
            }
            else{
                if counter - 1 > 0 {
                    self.fetchStatisticalDataFromServer(withDate: date.dayBefore, withIsLevelCity: isLevelCity, withCallCounter: counter-1)
                }else{
                    print("Counter completed.")
                }
            }
        })
    }
    
    
    func checkForStatisticalDataSummary() {
        if let record = DataManager.shared.dictForRecentRecords[Constants.LocationConstants.defaultCountryName]{
            if record.date == Date().getStringDate() {
                print("Summary already upto date.")
                return
            }
        }
        DataManager.shared.getRecentSummary(withName:Constants.LocationConstants.defaultCountryName, withType: Constants.KeyStrings.keyCountry) { (isSuccess, message) in
            if isSuccess == true {
                NotificationCenter.default.post(name: .kDidLoadSummaryInformation, object: nil)
            }
        }
    }

    // MARK: - Population info
    func fetchDemographicInfoFromServer() {
        DispatchQueue.global(qos: .background).async {
            AuthenticationManager.shared.sendRequestForPopulationTimestamps(withName: Constants.LocationConstants.defaultCountryName, withType: Constants.KeyStrings.keyCountry, withRecordType: Constants.KeyStrings.keyPopulation) { (isSuccess, message, timestampArray) in
                if isSuccess == true {
                    DataManager.shared.listForTimestamps.removeAll()
                    let timeList = timestampArray.sorted(by: { $0 < $1 })
                    DataManager.shared.listForTimestamps = timeList
                    if DataManager.shared.dictForDemographicInfo.count == 0 {
                        // Fetch data from CoreData
                        DispatchQueue.main.async {
                            var infolist = CoreDataManager.shared.fetchDemographyInfo(withName: "", withDate: timeList.last!)
                            if infolist.count > 0 {
                                print("DemographyInfo available in CoreData...")
                                infolist = CoreDataManager.shared.fetchDemographyInfo(withName: "", withDate: timeList.last!)
                                for loc in infolist {
                                    DataManager.shared.dictForDemographicInfo[loc.name] = [loc]
                                }
                                for i in 0..<timeList.count-1{
                                    infolist = CoreDataManager.shared.fetchDemographyInfo(withName: "", withDate: timeList[i])
                                    for loc in infolist {
                                        DataManager.shared.dictForDemographicInfo[loc.name]?.append(loc)
                                    }
                                    NotificationCenter.default.post(name: .kDidLoadDemographyDataNotification, object: nil)
                                }
                            }
                            else{
                                print("DemographyInfo not available in CoreData...")
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
        }
    }
    
    func fetchDemographicInfoFromServer(withTimestamp year: String) {
        AuthenticationManager.shared.sendRequestForDemographicData(withName: Constants.LocationConstants.defaultCountryName, withType: Constants.KeyStrings.keyCountry, withYear: year) { (isSuccess, message, infoArray) in
            if isSuccess == true {
                /* if no data stored in dict, set a flag and load the data for tableview */
                var isEmpty: Bool = false
                if DataManager.shared.dictForDemographicInfo.count == 0 {
                    for loc in infoArray {
                        DataManager.shared.dictForDemographicInfo[loc.name] = [loc]
                        //NotificationCenter.default.post(name: .kDidLoadDemographyDataNotification, object: nil)
                    }
                    isEmpty = true
                }
                if isEmpty {
                    AuthenticationManager.shared.sendRequestForLocationInfoWithLocationList(withLocationList: infoArray) { (isSuccess, locationList) in
                        if isSuccess == true{
                            for loc in locationList ?? []{
                                if let demoLoc = infoArray.first(where: {$0.name == loc.name}) {
                                    demoLoc.latitude = loc.latitude
                                    demoLoc.longitude = loc.longitude
                                    DataManager.shared.dictForDemographicInfo[loc.name] = [demoLoc]
                                }
                            }
                            NotificationCenter.default.post(name: .kDidLoadDemographyDataNotification, object: nil)
                            DispatchQueue.main.async {
                                CoreDataManager.shared.storeDemographyInfo(withList: infoArray)
                            }
                        }
                    }
                }
                else{
                    for loc in infoArray{
                        if let demoList = DataManager.shared.dictForDemographicInfo[loc.name] {
                            let item = demoList.first
                            loc.latitude = item?.latitude ?? 0
                            loc.longitude = item?.longitude ?? 0
                            DataManager.shared.dictForDemographicInfo[loc.name]?.append(loc)
                        }
                    }
                    DispatchQueue.main.async {
                        CoreDataManager.shared.storeDemographyInfo(withList: infoArray)
                    }
                }
            }
        }
    }
    
    // MARK: - Location Service
    func startLocationService() {
        print("startLocationService")
        LocationManager.shared.requireUserAuthorization(.whenInUse)
        let distance: CLLocationDistance = 50 //meter
        let request = LocationManager.shared.locateFromGPS(.significant, accuracy: .block, distance: distance) { result in
            switch result {
                case .failure(let error):
                    debugPrint("Received error: \(error)")
                case .success(let location):
                    debugPrint("Location received: \(location)")
                    self.sendUserLocationData(withLocation: location)
                    //NotificationCenter.default.post(name: .kDidLoadLocationServiceNotification, object: nil)
            }
        }
        //request.dataFrequency = .fixed(minInterval: 30, minDistance: 100)
    }
    
    func sendUserLocationData(withLocation location: CLLocation) {
        if let id = CoreDataManager.shared.retrieveValueFromKeychain(withKey: Constants.KeyStrings.keyAppID) {
            AuthenticationManager.shared.sendRequestForUploadingUserLocation(withID: id, withLocation: location) { (isSuccess, message) in
                if isSuccess {
                    print("Successfully logged user location")
                }
            }
        }else{
            checkAppIdentifier()
        }
    }
    
}//end of Class
