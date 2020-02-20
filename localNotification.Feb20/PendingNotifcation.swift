//
//  PendingNotifcation.swift
//  localNotification.Feb20
//
//  Created by Pursuit on 2/20/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import Foundation
import UserNotifications

// want a class to get the info.. to query the one class for the info.. 

// using a class because we only want one instance of the class

class PendingNotification {
    
    public func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) ->()) {
        // will return the data we need.. the data we get from here will be for our request.
        // the request are made from the app
        
        // request are pending until they are delivered ..
       // gets pending notification for the data for the table view.
        UNUserNotificationCenter.current().getPendingNotificationRequests { (request) in
            print("there are \(request.count) pending request.")
            completion(request)
            
        }
        
    }
    
}
