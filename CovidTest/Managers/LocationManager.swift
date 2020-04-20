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
                    let key = loc.name! + "," + loc.parent!
                    AuthenticationManager.shared.sendRequestForLocationInfoWithKey(key: key) { (isSuccess, location) in
                        count = count + 1
                        if isSuccess == true{
                            loc.latitude = location?.coordinate.latitude
                            loc.longitude = location?.coordinate.longitude
                            if isLevelCity == true {
                                self.dictForCityLocation[loc.name!] = loc
                            }else{
                                self.dictForDistrictLocation[loc.name!] = loc
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




}
