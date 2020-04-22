//
//  LocationManager.swift
//  CovidTest
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

/// Singleton class for managing locations in the application
class LocationManager {
    static let shared = LocationManager()

    var dictForDistrictLocation = [String: LocationInfo]()
    var dictForCityLocation = [String: LocationInfo]()
    var dictForPastCases = [String: [Dictionary<String,String>]]()
    
    let kLocationLevelDistrict = "city"
    let kLocationLevelCity = "zone"
    
    private init(){}
    
    
    func getLocationData(withIsLevelCity isLevelCity: Bool?, withDate date: Date, completionHandler: @escaping(_ isSuccess: Bool?, _ message: String?)->Void){
        DispatchQueue.global(qos: .background).async {
            AuthenticationManager.shared.sendRequestForLocationData(withIsLevelCity: isLevelCity, withDate: date, completionHandler: { (isSuccess, message, locationArray) in
                if isSuccess == true {
                    //print(locationArray)
                    var count: Int = 0
                    let totalRequest: Int = locationArray?.count ?? 0
                    //print("totalRequest \(totalRequest)")
                    for loc in locationArray ?? []{
                        //count = count + 1
                        let key = loc.name + "," + loc.parent
                        AuthenticationManager.shared.sendRequestForLocationInfoWithKey(key: key) { (isSuccess, location) in
                            count = count + 1
                            if isSuccess == true{
                                loc.latitude = location?.coordinate.latitude as! Double
                                loc.longitude = location?.coordinate.longitude as! Double
                                if isLevelCity == true {
                                    self.dictForCityLocation[loc.name] = loc
                                }else{
                                    self.dictForDistrictLocation[loc.name] = loc
                                }
                                
                                if count == totalRequest {
                                    completionHandler(true, message)
                                }
                            }
                        }//end of completionHandler
                    }//end loop
                }//end if
                else{
                    completionHandler(false, message)
                }
            })//end of completionHandler
        }
    }//end of func

    
    func setLocationDictionary(withList locationList:[LocationInfo]) -> Bool {
        for location in locationList{
            if location.level ==  kLocationLevelDistrict {
                self.dictForDistrictLocation[location.name] = location
            }
            else if location.level ==  kLocationLevelCity {
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
            AuthenticationManager.shared.sendRequestForPastCasesForLocation(withLocation: location, completionHandler: { (isSuccess, listOfPastDailyCases) in
                if isSuccess == true {
                    if self.dictForPastCases[location.name] != nil {
                        var val = self.dictForPastCases[location.name]!
                        val.append(contentsOf: listOfPastDailyCases ?? [])
                        self.dictForPastCases[location.name] = val
                    }else{
                        self.dictForPastCases[location.name] = listOfPastDailyCases ?? []
                    }
                    NotificationCenter.default.post(name: .kDidLoadPastCasesInformation, object: nil)
                }
            })//end of completionHandler
        }
    }//end func


}
