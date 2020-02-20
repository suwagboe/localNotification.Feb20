//
//  ViewController.swift
//  localNotification.Feb20
//
//  Created by Pursuit on 2/20/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import UIKit
// when dealing with notifcations you need to import the below protocol UserNotifications

import UserNotifications

class NotificationsController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // data for tableView
    // upate from an array of string as a place holder to UNNotificationRequest
    // because we want the array of notificaiton made for the app
    private var notifications = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()

            }
        }
    }
    
    private let notificationCenterCheckSingleton = UNUserNotificationCenter.current() // this is a singleton.
    
    // indtansited the class to use where we want to
    private let pendingNotification = PendingNotification()
    
    private var refreshControl: UIRefreshControl! // for the effect of the spinner reloading the data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        checkForNotificationAuthorization()
        loadNotification()
      configureRefreshControl() // it needs a target
        
        // setting this view controller as the delegate object
        notificationCenterCheckSingleton.delegate = self
        
    }
    
   private func configureRefreshControl(){
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        // function is loadNotification which is called when a new item is added
    
    refreshControl.addTarget(self, action: #selector(loadNotification), for: .valueChanged) // assigning the target
    

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // will need to access the nav controller to then be able to access the view controller
        guard let navController = segue.destination as? UINavigationController, let createVC = navController.viewControllers.first as? CreateNotificationController else {
            // need to downcast both properties to tell it what it should actually be.
            fatalError("could not downcast to CreateNotificationViewController")
        }
        // if you dont conform to the create delegate .. it will give you an error...
        createVC.delegate  = self
         
    }    
    
    @objc private func loadNotification(){
        pendingNotification.getPendingNotifications { (requests) in
            // we are querying the class that has a function that has a completion that returns the amount of requests that were called in the table view. 
            self.notifications = requests
            // stop the refresh controller from animating
            // remove from the UI
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func checkForNotificationAuthorization(){
    
        // when using notificaiton you should always create these functions
        notificationCenterCheckSingleton.getNotificationSettings { (settings) in
            // settings come from the thing that is being captured
            if settings.authorizationStatus == .authorized {
                print("app is authorized for notifcation")
            } else {
                self.requestNotificationPermissions()
            }
        }
    }

    private func requestNotificationPermissions(){
        
        notificationCenterCheckSingleton.requestAuthorization(options: [.alert, .sound]) {
            // only want a sound to play.. only want an alert.
            (granted, error) in
            
            // first check if there is an error
            
            if let error = error {
                print("error requesting authorization: \(error)")
                return
            }
            // if granted is a bool so it does not need to be if granted == true because by default it is true
            if granted {
                print("access was granted ")
            } else {
                print("access was denied")
            }
            
        }
        
    }


}


extension NotificationsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificatoinCell", for: indexPath)
        
        let notification = notifications[indexPath.row]
        
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        
        return cell 
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // this function ALONE now allows for the action of swiping to register
        if editingStyle == .delete {
            // we will delete the pending notification
            removeNotification(atIndexPath: indexPath)
        }
    }
    
    private func removeNotification(atIndexPath indexPath: IndexPath){
        let notification = notifications[indexPath.row] // this gives the function a notification
        let stringIdentifier = notification.identifier
        
        // remove notification from UNNNotification Center
        notificationCenterCheckSingleton.removePendingNotificationRequests(withIdentifiers: [stringIdentifier])
        
        // remove from array of notifications
        // calling the array and removing it from the notificationS array from above 
        notifications.remove(at: indexPath.row)
        
        // remove from tableView
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension NotificationsController: UNUserNotificationCenterDelegate {
    // will only call when the app is on screen.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
        
        
        
    }
}

extension NotificationsController: CreateNotificationControllerDelegate {
    func didCreateNotification(_ createNotificatoinController: CreateNotificationController) {
        // to get the request showing.
        loadNotification()
        
    }
}
