//
//  AuthenticationManager.swift
//  CovidTest
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

/* Singleton Class*/
import Foundation
import SwiftyJSON
import CoreLocation

class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init(){}
    
    let kApiStringForDistrictLevelData: String = "http://149.165.157.107:1971/api/data?name=Bangladesh&type=country&date="
    let kApiStringForCityLevelData: String = "http://149.165.157.107:1971/api/data?name=Dhaka&type=city&date="
    let kApiStringForLocation: String = "http://149.165.157.107:1971/api/get_location"
    
    func sendRequestForLocationData(withIsLevelCity isLevelCity: Bool?, completionHandler: @escaping(_ isSuccess: Bool?, _ locationArray: [LocationInfo]?)->Void) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formattedDate = dateFormatter.string(from: Date())
        //let formattedDate = "2020-04-19"
        
        let apiString = isLevelCity == true ? kApiStringForCityLevelData : kApiStringForDistrictLevelData
        let urlString = apiString + formattedDate
        print("call to server with api: \(urlString)")
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    print("Server error!")
                    return
                }
                guard let mime = response.mimeType, mime == "application/json" else {
                    print("Wrong MIME type!")
                    return
                }
                
                do {
                    let json = try?JSON(data: data!)
                    //print(json)
                    var locationArray = [LocationInfo]()
                    let parent: String = json!["payload"]["name"].stringValue
                    let level: String = json!["payload"]["level"].stringValue
                    let dateString = json!["payload"]["date"].stringValue
                    
                    for item in json!["payload"]["data"].arrayValue {
                        //print(item["city"].stringValue)
                        let areaName = isLevelCity == true ? item["zone"].stringValue : item["city"].stringValue
                        var location = LocationInfo(name: areaName,
                                                    parent: parent,
                                                    level: level,
                                                    latitude: 0.0,
                                                    longitude: 0.0,
                                                    cases: item["cases"].intValue,
                                                    date: dateString)
                        locationArray.append(location)
                    }
                    print("Numner of location received: \(locationArray.count)")
                    completionHandler(true, locationArray)
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, [])
                }
            }
        }
        task.resume()
    }
    
    
    
    
    func sendRequestForLocationInfoWithKey(key: String, completionHandler: @escaping(_ isSuccess: Bool?, _ location: CLLocation?)->Void){
        let json: [String] = [key]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: kApiStringForLocation)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        //HTTP Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("error: \(error)")
            } else {
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    print("Server error!")
                    return
                }
                guard let mime = response.mimeType, mime == "application/json" else {
                    print("Wrong MIME type!")
                    return
                }
                do {
                    let json = try JSON(data: data!)
                    //print(json)
                    //print(json["payload"][key])
                    if let latitude = json["payload"][key]["lat"].numberValue as? Double, let longitude = json["payload"][key]["lng"].numberValue as? Double {
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        completionHandler(true, location)
                    }
                    
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, nil)
                }
            }
        }
        
        task.resume()
    }
}
