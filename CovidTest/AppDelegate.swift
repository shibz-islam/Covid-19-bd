//
//  AppDelegate.swift
//  CovidTest
//
//  Created by shihab on 4/16/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps

let googleApiKey = "AIzaSyBaSAHKdV38u6PGPbfvVFj2wv7XsAL0Qps"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleApiKey)
        
        /* Get App ID */
        if CoreDataManager.shared.isAppIdentifierExist() == false {
            AuthenticationManager.shared.sendRequestForAppIdentifier { (isSuccess, identifier) in
                if isSuccess == true, let id = identifier{
                    let result = CoreDataManager.shared.storeAppIdentifier(id)
                    print("Storing result: \(result)")
                }
            }
        }
        
        /* Get Location Data By Date*/
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return false}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if LocationManager.shared.dictForDistrictLocation.count == 0 {
            print("No data in memory")
            if CoreDataManager.shared.isLocationInfoExist(withDate: Date().dayBefore, withManagedContextObject: managedContext) == false {
                print("No data in core data, getting data from server")
                DispatchQueue.global(qos: .background).async {
                    LocationManager.shared.getLocationData(withIsLevelCity: false, completionHandler: { (isSuccess) in
                        if isSuccess == true {
                            print("Success from AppDelegate...")
                            print(LocationManager.shared.dictForDistrictLocation.count)
                            NotificationCenter.default.post(name: .kDidLoadLocationInformation, object: nil)
//                            DispatchQueue.main.async {
//                                CoreDataManager.shared.storeLocationInfo(withIsLevelCity: false)
//                            }
                            CoreDataManager.shared.storeLocationInfo(withIsLevelCity: false, withManagedContextObject: managedContext)
                        }
                    })
                }
                DispatchQueue.global(qos: .background).async {
                    LocationManager.shared.getLocationData(withIsLevelCity: true, completionHandler: { (isSuccess) in
                        if isSuccess == true {
                            print("Success from AppDelegate...")
                            print(LocationManager.shared.dictForCityLocation.count)
                            NotificationCenter.default.post(name: .kDidLoadLocationInformationForCity, object: nil)
//                            DispatchQueue.main.sync {
//                                CoreDataManager.shared.storeLocationInfo(withIsLevelCity: true)
//                            }
                            CoreDataManager.shared.storeLocationInfo(withIsLevelCity: true, withManagedContextObject: managedContext)
                        }
                    })
                }
            }
            else{
                DispatchQueue.global(qos: .background).async {
                    print("Data found in core data... loading data into memory")
                    let success = CoreDataManager.shared.fetchLocationInfo(withDate: Date().dayBefore, withManagedContextObject: managedContext)
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
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CovidTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

