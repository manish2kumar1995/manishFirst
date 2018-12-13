//
//  AppDelegate.swift
//  RestaurantApp
//
//  Created by AbhishekSir on 28/08/18.
//  Copyright © 2018 AbhishekSir. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import PushNotifications
import UserNotifications
import JWTDecode

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var alert : NSDictionary?
    var window: UIWindow?
    let pushNotifications = PushNotifications.shared
    let notificationName = Notification.Name("notificatioForStatus")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Thread.sleep(forTimeInterval: 2.0)
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyBjcfC0L5dUxF337sw3LVTzYUlZo8sakwU")
        GMSPlacesClient.provideAPIKey("AIzaSyBjcfC0L5dUxF337sw3LVTzYUlZo8sakwU")
        IQKeyboardManager.shared().isEnabled = true
        UIApplication.shared.statusBarStyle = .lightContent
        UNUserNotificationCenter.current().delegate = self
        //Pusher Configuration
        pushNotifications.start(instanceId: "c417f40c-4a6c-4685-96db-93a60615f4a5")
        try! pushNotifications.subscribe(interest: "akly_general_notifications")
        try! pushNotifications.unsubscribe(interest: "hello")
        pushNotifications.registerForRemoteNotifications()
        self.checkForAutoLogin()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RestaurantApp")
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


//MARK:- Push notifications
extension AppDelegate : UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        if let userInfo = notification.request.content.userInfo as? [String : AnyObject] {
            let aps = (userInfo["aps"] as? NSDictionary) ?? [:]
            let alert = (aps["alert"] as? NSDictionary) ?? [:]
            self.alert = alert
            let body = (alert["reservation_status"] as? String) ?? ""
            let orderId = (alert["reservation_number"] as? NSNumber ?? 0).stringValue
            if body.isEqualToString(find: "completed"){
                try! pushNotifications.unsubscribe(interest:orderId)
            }
             NotificationCenter.default.post(name: self.notificationName, object: nil, userInfo: (alert as? [AnyHashable : Any]) ?? [:])
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushNotifications.handleNotification(userInfo: userInfo)
        debugPrint("Receive :\(userInfo)")
        let aps = (userInfo[AnyHashable("aps")] as? NSDictionary) ?? [:]
        let alert = (aps["alert"] as? NSDictionary) ?? [:]
        self.alert = alert
        let body = (alert["reservation_status"] as? String) ?? ""
        let orderId = (alert["reservation_number"] as? NSNumber ?? 0).stringValue
        if body.isEqualToString(find: "completed"){
            try! pushNotifications.unsubscribe(interest:orderId)
        }
        NotificationCenter.default.post(name: self.notificationName, object: nil, userInfo: (alert as? [AnyHashable : Any]) ?? [:])
        completionHandler(.newData)
    }
    
    private func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)  {
        if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
            DispatchQueue.main.async {
                let aps = (userInfo["aps"] as? NSDictionary) ?? [:]
                let alert = (aps["alert"] as? NSDictionary) ?? [:]
                self.alert = alert
                let body = (alert["reservation_status"] as? String) ?? ""
                let orderId = (alert["reservation_number"] as? NSNumber ?? 0).stringValue
                if body.isEqualToString(find: "completed"){
                    try! self.pushNotifications.unsubscribe(interest:orderId)
                }
                NotificationCenter.default.post(name: self.notificationName, object: nil, userInfo: (alert as? [AnyHashable : Any]) ?? [:])
            }
        }
        completionHandler()
    }
    
    //MARK:- APNs
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotifications.registerDeviceToken(deviceToken)
    }
    
}

//MARK:- Custom Methods
extension AppDelegate {
    func checkForAutoLogin(){
        let user = DataBaseHelper.shared.getData().first
        let token = user?.tokenId ?? ""
        if !token.isEmpty{
            do{
                let jwt = try decode(jwt: token)
                if !jwt.expired{
                    UserShared.shared.isKnownUser = true
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "RootViewController")
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                    
                }else{
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                }
            }catch{
                print("Data not fetched")
            }
        }else{
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
    }
}

