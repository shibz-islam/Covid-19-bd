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

class CoreDataManager {
    static let shared = CoreDataManager()
    private init(){}
    
    let kLocationInfoEntity: String = "LocationInfo"
    
    
    func storeLocationInfo(withIsLevelCity isLevelCity: Bool) {
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
            locationEntity.setValue(UUID().uuid, forKeyPath: "id")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func isLocationInfoExist(withDate date:Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDateString = dateFormatter.string(from: date)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return false}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: kLocationInfoEntity)
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
    
    
    func fetchLocationInfo(withDate date:Date)-> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDateString = dateFormatter.string(from: date)
        print("Date = \(formattedDateString)")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return false}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: kLocationInfoEntity)
        fetchRequest.predicate = NSPredicate(format:"date == %@", formattedDateString)
        
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
    
}
