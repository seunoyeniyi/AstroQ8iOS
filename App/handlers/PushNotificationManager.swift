//
//  PushNotificationManager.swift
//  WhatsDownApp
//
//  Created by Seun Oyeniyi on 1/18/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//

import Firebase
import FirebaseMessaging
import UIKit
import UserNotifications
import Alamofire
import SwiftyJSON

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        updateFirestorePushTokenIfNeeded()
    }
    func updateFirestorePushTokenIfNeeded() {
        //        if let token = Messaging.messaging().fcmToken {
        //            let usersRef = Firestore.firestore().collection("users_table").document(userID)
        //            usersRef.setData(["fcmToken": token], merge: true)
        //        }
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Token Open")
//        print(fcmToken)
//        print("Token eneded")
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        
        //SAVE the device token to sever
        
        let url: String = Site.init().ADD_DEVICE + userID
        
        let parameters: [String: AnyObject] = [
            "device" : fcmToken as AnyObject
        ]
        
        Alamofire.SessionManager.default.requestWithoutCache(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            //            if let json_result = response.result.value {
            //                let json = JSON(json_result)
            //            }
            //nothing to perform
        }
        
        updateFirestorePushTokenIfNeeded()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
}
