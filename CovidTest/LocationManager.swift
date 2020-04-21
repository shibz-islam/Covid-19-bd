//
//  LocationManager.swift
//  CovidTest
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation

class LocationManager {
    static let shared = LocationManager()

    var dictForDistrictLocation = [String: LocationInfo]()
    var dictForCityLocation = [String: LocationInfo]()
    
    let kLocationLevelDistrict = "city"
    let kLocationLevelCity = "zone"
    
    private init(){}
    
    
    func getLocationData(withIsLevelCity isLevelCity: Bool?, completionHandler: @escaping(_ isSuccess: Bool?)->Void){
        AuthenticationManager.shared.sendRequestForLocationData(withIsLevelCity: isLevelCity, completionHandler: { (isSuccess, locationArray) in
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
                                completionHandler(true)
                            }
                        }
                    }//end of completionHandler
                }//end loop
            }//end if
            else{
                completionHandler(false)
            }
        })//end of completionHandler
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


}
