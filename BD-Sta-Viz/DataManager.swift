//
//  DataManager.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

/// Singleton class for managing locations in the application
class DataManager {
    static let shared = DataManager()
    private init(){}
    
    var dictForDistrictLocation = [String: LocationInfo]()
    var dictForCityLocation = [String: LocationInfo]()
    
    var dictForAllRecords = [String: [Record]]()
    var dictForRecentRecords = [String: Record]()
    
    var dictForDistrictLevelPredictionRecords = [String: PredictionRecord]()
    
    var dictForDemographicInfo = [String: [DemographyInfo]]()
    var listForTimestamps = [String]()
    
    
    func getLocationData(withIsLevelCity isLevelCity: Bool?, withDate date: Date, completionHandler: @escaping(_ isSuccess: Bool?, _ message: String?)->Void){
        DispatchQueue.global(qos: .background).async {
            AuthenticationManager.shared.sendRequestForLocationData(withIsLevelCity: isLevelCity, withDate: date, completionHandler: { (isSuccess, message, locationArray) in
                if isSuccess == true {
                    //print(locationArray)
                    AuthenticationManager.shared.sendRequestForLocationInfoWithLocationList(withLocationList: locationArray ?? []) { (isSuccess, locationList) in
                        if isSuccess == true{
                            for loc in locationList ?? [] {
                                if isLevelCity == true {
                                    self.dictForCityLocation[loc.name] = loc
                                }else{
                                    self.dictForDistrictLocation[loc.name] = loc
                                }
                            }
                            completionHandler(true, message)
                        }
                        else{
                            completionHandler(false, message)
                        }
                    }
                }//end if
                else{
                    completionHandler(false, message)
                }
            })//end of completionHandler
        }
    }//end of func

    
    func setLocationDictionary(withList locationList:[LocationInfo]) -> Bool {
        for location in locationList{
            if location.level == Constants.KeyStrings.keyLocationLevelDistrict {
                self.dictForDistrictLocation[location.name] = location
            }
            else if location.level == Constants.KeyStrings.keyLocationLevelCity {
                self.dictForCityLocation[location.name] = location
            }
            else{
                print("Error! Unknown location level.")
                self.dictForDistrictLocation.removeAll()
                self.dictForCityLocation.removeAll()
                return false
            }
        }
        return true
    }
    
    
    func getPastCasesForLocation(withLocation location:LocationInfo) {
        if location.name.count>0 && location.level.count>0 {
            AuthenticationManager.shared.sendRequestForPastCasesForLocation(withLocation: location, completionHandler: { (isSuccess, listOfPastRecords) in
                if isSuccess == true {
                    let ordered = listOfPastRecords!.sorted(by: { $0.date < $1.date })
                    self.dictForAllRecords[location.name] = ordered
                    NotificationCenter.default.post(name: .kDidLoadPastCasesInformation, object: nil)
                }
            })//end of completionHandler
        }
    }//end func
    
    
//    func sortPastCasesDict(withKey key:String) {
//        let val = DataManager.shared.dictForPastCases[key]
//        print("loading data...-> \(String(describing: val?.count))")
//        let ordered = val?.sorted {
//            guard let s1 = $0["date"], let s2 = $1["date"] else {
//                return false
//            }
//            return s1 < s2
//        }
//        DataManager.shared.dictForPastCases[key] = ordered
//    }
    
    
    func getRecentSummary(withName name:String, withType type: String, completionHandler: @escaping(_ isSuccess: Bool?, _ message: String?)->Void){
        AuthenticationManager.shared.sendRequestForRecentSummary(withName: name, withType: type) { (isSuccess, message, record) in
            if isSuccess == true{
                if let name = record?.name {
                    self.dictForRecentRecords[name] = record
                    completionHandler(isSuccess, message)
                }
            }
            completionHandler(false, message)
        }
    }

    func getSummaryPastCasesForLocation(withLocation location:LocationInfo) {
        if location.name.count>0 && location.level.count>0 {
            AuthenticationManager.shared.sendRequestForSummaryPastCases(withLocation: location, completionHandler: { (isSuccess, listOfPastRecords) in
                if isSuccess == true {
                    //let ordered = listOfPastRecords!.sorted(by: { $0.date < $1.date })
                    let ordered = listOfPastRecords
                    self.dictForAllRecords[location.name] = ordered
                    NotificationCenter.default.post(name: .kDidLoadSummaryPastCasesInformationNotification, object: nil)
                }
            })//end of completionHandler
        }
    }//end func
    
    func getPredictionData(withIsLevelCity isLevelCity: Bool, withIsNextDay isNextDay: Bool){
        DispatchQueue.global(qos: .background).async {
            AuthenticationManager.shared.sendRequestForPredictionData(withIsLevelCity: isLevelCity, withIsNextDay: isNextDay) { (isSuccess, message, recordArray) in
                if isSuccess == true {
                    for predRecord in recordArray {
                        if isLevelCity == false && self.dictForDistrictLocation[predRecord.name] != nil {
                            predRecord.cases = self.dictForDistrictLocation[predRecord.name]?.cases ?? 0
                            predRecord.date = self.dictForDistrictLocation[predRecord.name]?.date ?? ""
                        }
                        self.dictForDistrictLevelPredictionRecords[predRecord.name] = predRecord
                    }
                    UserDefaults.standard.set(Date().getStringDate(), forKey: Constants.UserDefaults.keyPredictionRecordLastUpdateDateDistrictLevel)
                    NotificationCenter.default.post(name: .kDidLoadPredictionDataNotification, object: nil)
                }
            }
        }//Dispatch end
    }

// MARK: - Demography
    func getDemographicData() -> [DemographyInfo]{
        var demoInfoList = [DemographyInfo] ()
        let year = listForTimestamps.last
        for (key, locationList) in dictForDemographicInfo {
            if let item = locationList.first(where: {$0.date == year}) {
                demoInfoList.append(item)
            }
        }
        return demoInfoList
    }
    
    func getDemographicPopulationListByYear() -> [Int] {
        var populationListByYear = [Int]()
        for year in listForTimestamps{
            var sum: Int = 0
            for (key, locationList) in dictForDemographicInfo {
                if let item = locationList.first(where: {$0.date == year}) {
                    sum = sum + item.population
                }
            }
            populationListByYear.append(sum)
        }
        return populationListByYear
    }

}
