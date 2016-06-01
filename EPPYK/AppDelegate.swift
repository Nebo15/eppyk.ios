//
//  AppDelegate.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 19/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import UIKit
import CoreData
import Mixpanel

var agManagedObjectContext: NSManagedObjectContext?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let sharedInstance = self
    static var mixpanel: Mixpanel?

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        application.applicationSupportsShakeToEdit = false
        
        self.configCoreData()
        
        // Mixpanel push
        AppDelegate.mixpanel = Mixpanel.sharedInstanceWithToken("ee8c37904fb6e9b30bb56b3a945c9dad")
        
        // This code will work in iOS 8.0 xcode 6.0 or later:
        if UIApplication.sharedApplication().respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else
        {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        // Call .identify to flush the People record to Mixpanel
        AppDelegate.mixpanel?.identify((AppDelegate.mixpanel?.distinctId)!)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let mixpanel = Mixpanel.sharedInstance()
        mixpanel.people.addPushDeviceToken(deviceToken)
    }
    
    func configCoreData() {
        guard let modelURL = NSBundle.mainBundle().URLForResource("QADataModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        agManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        agManagedObjectContext!.persistentStoreCoordinator = psc
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        
        /* The directory the application uses to store the Core Data store file.
        This code uses a file named "DataModel.sqlite" in the application's documents directory.
        */
        let storeURL = docURL.URLByAppendingPathComponent("QADataModel.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

