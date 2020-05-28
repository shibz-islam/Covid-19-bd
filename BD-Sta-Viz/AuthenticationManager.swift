//
//  AuthenticationManager.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//


import Foundation
import SwiftyJSON
import CoreLocation

/// Sinleton class for managing Server requests and responses
class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init(){}
    
    let kApiBaseURL: String = "http://149.165.157.107:1971/api/"
    let kApiStringForIdentifier: String = "gen_id"
    let kApiStringForlocationData: String = "data?"
    let kApiStringForLocationCoordinate: String = "get_location"
    let kApiStringForPastData: String = "loc_data_seq?"
    let kApiStringForSummary: String = "summary?"
    let kApiStringForSummaryPastData: String = "summary_seq?"
    
    let kErrorJson: String = "Json_Error"
    let kErrorServer: String = "error"
    
    
    func sendRequestForAppIdentifier(completionHandler: @escaping(_ isSuccess: Bool, _ identifier: String?)->Void) {
        let url = URL(string: kApiBaseURL + kApiStringForIdentifier)!
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
                    let json = try JSON(data: data!)
                    print(json)
                    //print(json["payload"]["id"])
                    if let idString = json["payload"]["id"].stringValue as? String{
                        completionHandler(true, idString)
                    }else{
                        completionHandler(false, nil)
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
    
    
    func sendRequestForLocationData(withIsLevelCity isLevelCity: Bool?, withDate date:Date, completionHandler: @escaping(_ isSuccess: Bool?, _ message:String?, _ locationArray: [LocationInfo]?)->Void) {

        let formattedDate = date.getStringDate()
        let nameString = isLevelCity == true ? Constants.LocationConstants.defaultDistrictName : Constants.LocationConstants.defaultCountryName
        let typeString = isLevelCity == true ? Constants.KeyStrings.keyLocationLevelDistrict : Constants.KeyStrings.keyCountry
        
        var urlComponents = URLComponents(string: kApiBaseURL + kApiStringForlocationData)!
        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: nameString),
            URLQueryItem(name: "type", value: typeString),
            URLQueryItem(name: "date", value: formattedDate)
        ]
        let url = urlComponents.url!
        print("call to server with api: \(String(describing: urlComponents.url?.absoluteString))")
        
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
                    if json!["status"] == "error" {
                        print("Received Error Status")
                        completionHandler(false, self.kErrorServer, [])
                    }else {
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
                        print("Number of location received: \(locationArray.count)")
                        if locationArray.count > 0 {
                            completionHandler(true, nil, locationArray)
                        } else {
                            completionHandler(false, self.kErrorServer, [])
                        }
                        
                    }
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, self.kErrorJson, [])
                }
            }
        }
        task.resume()
    }
    
    
    
    
    func sendRequestForLocationInfoWithKey(key: String, completionHandler: @escaping(_ isSuccess: Bool?, _ location: CLLocation?)->Void){
        let json: [String] = [key]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create post request
        let url = URL(string: kApiBaseURL + kApiStringForLocationCoordinate)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //print("call to server with api: \(String(describing: url.absoluteString))")
        
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
                    if json[Constants.ServerKeywords.keyStatus].stringValue == Constants.ServerKeywords.keyError {
                        print("Received Error Status")
                        completionHandler(false, nil)
                    }else{
                        if let latitude = json["payload"][key]["lat"].numberValue as? Double, let longitude = json["payload"][key]["lng"].numberValue as? Double {
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            completionHandler(true, location)
                        }
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
    
    
    func sendRequestForPastCasesForLocation(withLocation location: LocationInfo, completionHandler: @escaping(_ isSuccess: Bool?, _ listOfPastDailyCases: [Record]?)->Void){
        var urlComponents = URLComponents(string: kApiBaseURL + kApiStringForPastData)!
        urlComponents.queryItems = [
            URLQueryItem(name: "loc_type", value: location.level),
            URLQueryItem(name: "loc_name", value: location.name)
        ]
        let url = urlComponents.url!
        print("call to server with api: \(String(describing: urlComponents.url?.absoluteString))")
        
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
                    if json!["status"] == "error" {
                        print("Received Error Status")
                        completionHandler(false, [])
                    }else {
                        var recordArray = [Record]()
                        
                        for item in json!["payload"].arrayValue {
                            let record = Record(name: location.name,
                                                level: location.level,
                                                cases: item["data"]["cases"].intValue,
                                                date: item["date"].stringValue)
                            recordArray.append(record)
                        }
                        
                        print("Number of cases received: \(recordArray.count)")
                        if recordArray.count > 0 {
                            completionHandler(true, recordArray)
                        } else{
                            completionHandler(false, [])
                        }
                    }                    
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, [])
                }
            }
        }
        task.resume()
    }
    
    func sendRequestForRecentSummary(withName name:String, withType type: String, completionHandler: @escaping(_ isSuccess: Bool?, _ message:String?, _ record: Record?)->Void){
        
        var urlComponents = URLComponents(string: kApiBaseURL + kApiStringForSummary)!
        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "type", value: type)
        ]
        let url = urlComponents.url!
        print("call to server with api: \(String(describing: urlComponents.url?.absoluteString))")
        
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
                    if json!["status"] == "error" {
                        print("Received Error Status")
                        completionHandler(false, self.kErrorServer, nil)
                    }else {
                        let record = Record(name: json!["payload"]["name"].stringValue,
                                            level: json!["payload"]["level"].stringValue,
                                            cases: json!["payload"]["cases"].intValue,
                                            fatalities: json!["payload"]["deaths"].intValue,
                                            recoveries: json!["payload"]["cured"].intValue,
                                            date: json!["payload"]["date"].stringValue)
                        completionHandler(true, nil, record)
                    }
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, self.kErrorJson, nil)
                }
            }
        }
        task.resume()
    }
    
    func sendRequestForSummaryPastCases(withLocation location: LocationInfo, completionHandler: @escaping(_ isSuccess: Bool?, _ listOfPastRecords: [Record]?)->Void){
        var urlComponents = URLComponents(string: kApiBaseURL + kApiStringForSummaryPastData)!
        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: location.name),
            URLQueryItem(name: "type", value: location.level)
        ]
        let url = urlComponents.url!
        print("call to server with api: \(String(describing: urlComponents.url?.absoluteString))")
        
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
                    if json!["status"] == "error" {
                        print("Received Error Status")
                        completionHandler(false, [])
                    }else {
                        var recordArray = [Record]()
                        
                        for item in json!["payload"].arrayValue {
                            let record = Record(name: location.name,
                                                level: location.level,
                                                cases: item["cases"].intValue,
                                                fatalities: item["deaths"].intValue,
                                                recoveries: item["cured"].intValue,
                                                date: item["date"].stringValue)
                            recordArray.append(record)
                        }
                        
                        print("Number of cases received: \(recordArray.count)")
                        if recordArray.count > 0 {
                            completionHandler(true, recordArray)
                        } else{
                            completionHandler(false, [])
                        }
                    }
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, [])
                }
            }
        }
        task.resume()
    }
    
    
    func sendRequestForPredictionData(withIsLevelCity isLevelCity: Bool, withIsNextDay isNextDay: Bool, completionHandler: @escaping(_ isSuccess: Bool?, _ message:String?, _ locationArray: [PredictionRecord])->Void) {
        
        let levelString = isLevelCity == true ? Constants.KeyStrings.keyLocationLevelCity : Constants.KeyStrings.keyLocationLevelDistrict
        let nameString = isLevelCity == true ? Constants.LocationConstants.defaultDistrictName : Constants.LocationConstants.defaultCountryName
        let typeString = isNextDay == true ? Constants.ApiConstants.keyNextDay : Constants.ApiConstants.keyOneWeek
        
        var urlComponents = URLComponents(string: Constants.AppUrls.appBaseUrlString + Constants.ApiConstants.keyForApiPrediction)!
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.ServerKeywords.keyLevel, value: levelString),
            URLQueryItem(name: Constants.ServerKeywords.keyName, value: nameString),
            URLQueryItem(name: Constants.ServerKeywords.keyType, value: typeString)
        ]
        let url = urlComponents.url!
        print("call to server with api: \(String(describing: urlComponents.url?.absoluteString))")
        
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
                    if json![Constants.ServerKeywords.keyStatus].stringValue == Constants.ServerKeywords.keyError {
                        print("Received Error Status")
                        completionHandler(false, Constants.ServerKeywords.keyError, [])
                    }else {
                        var recordArray = [PredictionRecord]()
                        
                        for item in json![Constants.ServerKeywords.keyPayload][Constants.ServerKeywords.keyPrediction].arrayValue {
                            let record = PredictionRecord(name: item[Constants.ServerKeywords.keyCity].stringValue,
                                                level: item[Constants.ServerKeywords.keyLevel].stringValue,
                                                cases: item[Constants.ServerKeywords.keyCases].intValue,
                                                date: item[Constants.ServerKeywords.keyType].stringValue)
                            recordArray.append(record)
                        }
                        
                        print("Number of cases received: \(recordArray.count)")
                        if recordArray.count > 0 {
                            completionHandler(true, Constants.ServerKeywords.keySuccess, recordArray)
                        } else{
                            completionHandler(false, Constants.ServerKeywords.keyError, [])
                        }
                    }
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, Constants.ServerKeywords.keyError, [])
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Population
    func sendRequestForPopulationTimestamps(withName name:String, withType type:String, withRecordType recordType:String, completionHandler: @escaping(_ isSuccess: Bool?, _ message:String?, _ timestampArray: [String])->Void) {
        
        var urlComponents = URLComponents(string: Constants.PopulationConstants.appBaseUrlString + Constants.PopulationConstants.keyForApiTimestamps)!
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.ServerKeywords.keyName, value: name),
            URLQueryItem(name: Constants.ServerKeywords.keyType, value: type),
            URLQueryItem(name: Constants.ServerKeywords.keyRecordType, value: recordType)
        ]
        let url = urlComponents.url!
        print("call to server with api: \(String(describing: urlComponents.url?.absoluteString))")
        
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
                    if json![Constants.ServerKeywords.keyStatus].stringValue == Constants.ServerKeywords.keyError {
                        print("Received Error Status")
                        completionHandler(false, Constants.ServerKeywords.keyError, [])
                    }else {
                        var timestampArray = [String]()
                        
                        for item in json![Constants.ServerKeywords.keyPayload].arrayValue {
                            let yearString = item[Constants.ServerKeywords.keyYear].stringValue
                            timestampArray.append(yearString)
                        }
                        
                        print("Number of data received: \(timestampArray.count)")
                        if timestampArray.count > 0 {
                            completionHandler(true, Constants.ServerKeywords.keySuccess, timestampArray)
                        } else{
                            completionHandler(false, Constants.ServerKeywords.keyError, [])
                        }
                    }
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, Constants.ServerKeywords.keyError, [])
                }
            }
        }
        task.resume()
    }
    
    func sendRequestForDemographicData(withName name:String, withType type:String, withYear year:String, completionHandler: @escaping(_ isSuccess: Bool?, _ message:String?, _ infoArray: [DemographyInfo])->Void) {
        var urlComponents = URLComponents(string: Constants.PopulationConstants.appBaseUrlString + Constants.PopulationConstants.keyForApiData)!
        urlComponents.queryItems = [
            URLQueryItem(name: Constants.ServerKeywords.keyName, value: name),
            URLQueryItem(name: Constants.ServerKeywords.keyType, value: type),
            URLQueryItem(name: Constants.ServerKeywords.keyYear, value: year)
        ]
        let url = urlComponents.url!
        print("call to server with api: \(String(describing: urlComponents.url?.absoluteString))")
        
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
                    if json![Constants.ServerKeywords.keyStatus].stringValue == Constants.ServerKeywords.keyError {
                        print("Received Error Status")
                        completionHandler(false, Constants.ServerKeywords.keyError, [])
                    }else {
                        var infoArray = [DemographyInfo]()
                        let payload = json![Constants.ServerKeywords.keyPayload]
                        for item in payload[Constants.ServerKeywords.keyData].arrayValue {
                            let demo = DemographyInfo(name: item[Constants.ServerKeywords.keyCity].stringValue,
                                                      parent: payload[Constants.ServerKeywords.keyName].stringValue,
                                                      level: payload[Constants.ServerKeywords.keyLevel].stringValue,
                                                      population: item[Constants.ServerKeywords.keyPopulation].intValue,
                                                      area: Double(item[Constants.ServerKeywords.keyArea].intValue),
                                                      year: payload[Constants.ServerKeywords.keyYear].stringValue,
                                                      areaUnit: payload[Constants.ServerKeywords.keyMeta][Constants.ServerKeywords.keyAreaUnit].stringValue)
                            infoArray.append(demo)
                        }
                        
                        print("Number of data received: \(infoArray.count)")
                        if infoArray.count > 0 {
                            completionHandler(true, Constants.ServerKeywords.keySuccess, infoArray)
                        } else{
                            completionHandler(false, Constants.ServerKeywords.keyError, [])
                        }
                    }
                } catch {
                    print("Error: \(error)")
                    print("JSON error: \(error.localizedDescription)")
                    completionHandler(false, Constants.ServerKeywords.keyError, [])
                }
            }
        }
        task.resume()
    }
    
    // MARK: - User Location
    func sendRequestForUploadingUserLocation(withID id:String, withLocation location:CLLocation, completionHandler: @escaping(_ isSuccess: Bool, _ message:String?)->Void){
        
        let json: JSON = [
            "id": id,
            "locations": [
                [
                    "time": location.timestamp.currentUTCTimeZoneDate,
                    "lat": location.coordinate.latitude,
                    "long": location.coordinate.longitude
                ]
            ]
        ]
        //print(json)
//        if (!JSONSerialization.isValidJSONObject(json)) {
//            print("is not a valid json object")
//            return
//        }
        
        // create post request
        let url = URL(string: kApiBaseURL + Constants.ApiConstants.keyForUpdateLocation)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let jsonData = try json.rawData()
            request.httpBody = jsonData
            //Do something you want
        } catch {
            print("Error JSON \(error)")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print("call to server with api: \(String(describing: url.absoluteString))")
        
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
                    //print(response.mimeType)
                    return
                }
                do {
                    let json = try JSON(data: data!)
                    //print(json)
                    if json[Constants.ServerKeywords.keyStatus].stringValue == Constants.ServerKeywords.keyError {
                        print("Received Error Status")
                        completionHandler(false, nil)
                    }else{
                        completionHandler(true, nil)
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
