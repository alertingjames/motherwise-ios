//
//  AppDelegate.swift
//  Motherwise
//
//  Created by Andre on 9/5/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift    // when keyboard appears, move textfield or textview up
import UserNotifications
import GoogleMaps
import GooglePlaces
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import VoxeetSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, VTSessionDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        
        GMSServices.provideAPIKey(apikey)
        GMSPlacesClient.provideAPIKey(apikey)
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                gFCMToken = token
            }
        }
        
        // Voxeet SDK initialization.
        VoxeetSDK.shared.initialize(consumerKey: "DV8XrUh4iZwxMsEmakvvyg==", consumerSecret: "3nv7mIpIJZeB-NfzEQxUPLtHU0oSugtV1IC7k4wtiqs=")
        
        // Session delegate.
        VoxeetSDK.shared.session.delegate = self
        
        return true
    }
    
    /*
     *  MARK: VTSessionDelegate example
     */
    
    func sessionUpdated(state: VTSessionState) {
        // Debug.
        print("[Sample] \(String(describing: AppDelegate.self)).\(#function).\(#line) - State: \(state.rawValue)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
                
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    /// Useful below iOS 10.
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }
    
    /// Useful below iOS 10.
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
    }
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        print("Handle push from foreground \(notification.request.content.userInfo)")
        
        // Reading message body
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        
        var messageBody:String?
        var messageTitle:String = "Alert"
        
        if let alertDict = dict["alert"] as? Dictionary<String, String> {
            messageBody = alertDict["body"]!
            if alertDict["title"] != nil { messageTitle  = alertDict["title"]! }
            
        } else {
            messageBody = dict["alert"] as? String
        }
        
        print("Message body is \(messageBody!) ")
        print("Message message Title is \(messageTitle) ")
        // Let iOS to display message
        
        completionHandler([.alert,.sound, .badge])
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MotherWise")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        if fcmToken!.count > 0 {
            gFCMToken = fcmToken!
        }
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func updateBadgeCount() {
        var badgeCount = UIApplication.shared.applicationIconBadgeNumber
        if badgeCount > 0
        {
            badgeCount = badgeCount-1
        }
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
    

}

extension UIWindow {
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIWindow.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

