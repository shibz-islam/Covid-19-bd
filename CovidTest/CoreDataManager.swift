//
//  CoreDataManager.swift
//  CovidTest
//
//  Created by shihab on 4/20/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftKeychainWrapper

/// Singleton class for managing Core data and keychain
class CoreDataManager {
    static let shared = CoreDataManager()
    private init(){}
    
    let kLocationInfoEntity: String = "LocationInfoEntity"
    let kRecordEntity: String = "RecordEntity"
    let kAppIDKey: String = "kAppIDKey"
    let kAppLastUpdateDate: String = "kAppLastUpdateDate"
    let kAppLastUpdateDateForLevelCity: String = "kAppLastUpdateDateForLevelCity"
    
    
    func storeLocationInfo(withIsLevelCity isLevelCity: Bool) {
        if Thread.isMainThread == false{
            print("Error! Trying to access UIApplication from background thread.")
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: kLocationInfoEntity, in: managedContext)!
        
        let dict = isLevelCity == true ? LocationManager.shared.dictForCityLocation : LocationManager.shared.dictForDistrictLocation
        
        for (key, location) in dict{
            let locationEntity = NSManagedObject(entity: entity, insertInto: managedContext)
            locationEntity.setValue(location.name, forKeyPath: "name")
            locationEntity.setValue(location.parent, forKeyPath: "parent")
            locationEntity.setValue(location.level, forKeyPath: "level")
            locationEntity.setValue(location.latitude, forKeyPath: "latitude")
            locationEntity.setValue(location.longitude, forKeyPath: "longitude")
            locationEntity.setValue(location.cases, forKeyPath: "cases")
            locationEntity.setValue(location.date, forKeyPath: "date")
            locationEntity.setValue(UUID().uuidString, forKeyPath: "id")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func isLocationInfoExist(withDate date:Date) -> Bool {
        if Thread.isMainThread == false{
            print("Error! Trying to access UIApplication from background thread.")
            return false
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return false}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let formattedDateString = date.getStringDate()

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: kLocationInfoEntity)
        fetchRequest.predicate = NSPredicate(format:"date == %@", formattedDateString)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                return true
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    func fetchLocationInfo(withDate date:Date, withIsLevelCity isLevelCity: Bool)-> Bool{
        if Thread.isMainThread == false{
            print("Error! Trying to access UIApplication from background thread.")
            return false
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return false}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let formattedDateString = date.getStringDate()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: kLocationInfoEntity)
        let predicate1 = NSPredicate(format:"date == %@", formattedDateString)
        let predicate2 = isLevelCity == true ? NSPredicate(format:"level == %@", LocationManager.shared.kLocationLevelCity) : NSPredicate(format:"level == %@", LocationManager.shared.kLocationLevelDistrict)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                var locationList = [LocationInfo]()
                for data in results as! [NSManagedObject]{
                    let location = LocationInfo(name: data.value(forKeyPath: "name") as! String,
                                                parent: data.value(forKeyPath: "parent") as! String,
                                                level: data.value(forKeyPath: "level") as! String,
                                                latitude: data.value(forKeyPath: "latitude") as! Double,
                                                longitude: data.value(forKeyPath: "longitude") as! Double,
                                                cases: data.value(forKeyPath: "cases") as! Int,
                                                date: data.value(forKeyPath: "date") as! String)
                    locationList.append(location)
                }
                return LocationManager.shared.setLocationDictionary(withList: locationList)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func storeRecords(withRecords records:[Record]) {
        if Thread.isMainThread == false{
            print("Error! Trying to access UIApplication from background thread.")
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: kRecordEntity, in: managedContext)!
        
        for record in records{
            let locationEntity = NSManagedObject(entity: entity, insertInto: managedContext)
            locationEntity.setValue(record.name, forKeyPath: "name")
            locationEntity.setValue(record.level, forKeyPath: "level")
            locationEntity.setValue(record.cases, forKeyPath: "cases")
            locationEntity.setValue(record.fatalities, forKeyPath: "fatalities")
            locationEntity.setValue(record.recoveries, forKeyPath: "recoveries")
            locationEntity.setValue(record.date, forKeyPath: "date")
            locationEntity.setValue(UUID().uuidString, forKeyPath: "id")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchRecords(withName name:String, withLevel level:String)-> [Record]{
        if Thread.isMainThread == false{
            print("Error! Trying to access UIApplication from background thread.")
            return []
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: kRecordEntity)
        let predicate1 = NSPredicate(format:"name == %@", name)
        let predicate2 = NSPredicate(format:"level == %@", level)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.count > 0 {
                var recordList = [Record]()
                for data in results as! [NSManagedObject]{
                    let record = Record(name: data.value(forKeyPath: "name") as! String,
                                                level: data.value(forKeyPath: "level") as! String,
                                                cases: data.value(forKeyPath: "cases") as! Int,
                                                fatalities: data.value(forKeyPath: "fatalities") as! Int,
                                                recoveries: data.value(forKeyPath: "recoveries") as! Int,
                                                date: data.value(forKeyPath: "date") as! String)
                    recordList.append(record)
                }
                return recordList
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    
    // MARK: - KeychainWrapper
    func storeValueInKeychain(withValue value:String, withKey key:String)->Bool{
        let saveSuccessful: Bool = KeychainWrapper.standard.set(value, forKey: key)
        return saveSuccessful
    }
    func retrieveValueFromKeychain(withKey key:String) -> String {
        let retrievedString = KeychainWrapper.standard.string(forKey: key)!
        return retrievedString
    }
    func deleteValueFromKeychain(withKey key:String) -> Bool {
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: key)
        return removeSuccessful
    }
    func isValueExistInKeychain(withKey key:String) -> Bool {
        return KeychainWrapper.standard.hasValue(forKey: key)
    }
}



