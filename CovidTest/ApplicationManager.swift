//
//  ApplicationManager.swift
//  CovidTest
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
        checkForNewData()
    }
    
    /// Check if App id is fetched from server
    func checkAppIdentifier() {
        if CoreDataManager.shared.isValueExistInKeychain(withKey: CoreDataManager.shared.kAppIDKey) == false {
            AuthenticationManager.shared.sendRequestForAppIdentifier { (isSuccess, identifier) in
                if isSuccess == true, let id = identifier{
                    let result = CoreDataManager.shared.storeValueInKeychain(withValue: id, withKey: CoreDataManager.shared.kAppIDKey)
                    print("Storing result: \(result)")
                }
            }
        }
    }
    
    
    /// Check for new data in server
    func checkForNewData() {
        if CoreDataManager.shared.isValueExistInKeychain(withKey: CoreDataManager.shared.kAppLastUpdateDate) == false {
            fetchNewDataFromServer(withDate: Date(), withIsLevelCity: false, withIsPreviousDataExist: false)
            fetchNewDataFromServer(withDate: Date(), withIsLevelCity: true, withIsPreviousDataExist: false)
        }
        else{
            let lastUpdateDate = CoreDataManager.shared.retrieveValueFromKeychain(withKey: CoreDataManager.shared.kAppLastUpdateDate)
            if lastUpdateDate == Date().getStringDate(){
                loadData(withDate: Date())
            }
            else{
                fetchNewDataFromServer(withDate: Date(), withIsLevelCity: false, withIsPreviousDataExist: true)
                fetchNewDataFromServer(withDate: Date(), withIsLevelCity: true, withIsPreviousDataExist: true)
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
                }
                else{
                    print("Success, total count: \(LocationManager.shared.dictForDistrictLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
                }
                DispatchQueue.main.async {
                    CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                    CoreDataManager.shared.storeValueInKeychain(withValue: date.getStringDate(), withKey: CoreDataManager.shared.kAppLastUpdateDate)
                }
            }
            else{
                if message == AuthenticationManager.shared.kErrorServer {
                    if isPreviousData == true {
                        self.loadData(withDate: date.dayBefore)
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
                }
                else{
                    print("Success, total count: \(LocationManager.shared.dictForDistrictLocation.count)")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
                }
                DispatchQueue.main.async {
                    CoreDataManager.shared.storeLocationInfo(withIsLevelCity: isLevelCity)
                    CoreDataManager.shared.storeValueInKeychain(withValue: date.getStringDate(), withKey: CoreDataManager.shared.kAppLastUpdateDate)
                }
            }
            else{
                print("Error message from fetchPreviousDataFromServer: \(String(describing: message))")
            }
        })
    }
    
    
    /// Load data from Core data according to date
    /// - Parameter date: date of data
    func loadData(withDate date:Date) {
        DispatchQueue.main.async {
            if CoreDataManager.shared.isLocationInfoExist(withDate: date) == false {
                print("No data found in core data, getting data from server")
                self.fetchNewDataFromServer(withDate: date, withIsLevelCity: false, withIsPreviousDataExist: false)
                self.fetchNewDataFromServer(withDate: date, withIsLevelCity: true, withIsPreviousDataExist: false)
            }
            else{
                print("Data found in core data... loading data into memory")
                let success = CoreDataManager.shared.fetchLocationInfo(withDate: date)
                if success {
                    print("Successfully loaded into memory")
                    NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
                    NotificationCenter.default.post(name: .kDidLoadLocationInformationForCity, object: nil)
                } else {
                    print("Failed to load into memory")
                }
            }
        }
    }
    
    
    
    
    
    
}//end of Class
