//
//  CreateNotificationController.swift
//  localNotification.Feb20
//
//  Created by Pursuit on 2/20/20.
//  Copyright © 2020 Pursuit. All rights reserved.
//

import UIKit

// custom delegation to pass information
protocol CreateNotificationControllerDelegate: AnyObject {
    func didCreateNotification(_ createNotificatoinController: CreateNotificationController)
}

class CreateNotificationController: UIViewController {
    // why do we need a story board id
    
    // property in text field is sentences so that way the sentence starts with a capitial
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: CreateNotificationControllerDelegate?
    // this is an optional because we dont want it to lie an say there is a value here
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 5 // this is based on seconds at some point
    // giving it a default value should the user not use the date picker instead of it crashing.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textfield delegate
    }
    
    // MARK: done to create notification
    private func createLocalNotification(){
        // MARK: where the work actually starts
        // step m=1: create the content
        let content = UNMutableNotificationContent()
        // the content is the model for the notification...
        content.title = titleTextField.text ?? "No title was given" // gotta give a default value if they dont put anything
        content.body = "Local notifications are assume when used appropriatly"
        content.subtitle = "learning local notifications"
        content.sound = .default // only works in the background and the app is not silent - please test device
        // ToDO: import your own sounf
        // content.sound = UNNotificationSound(named: UNNotificationSound(rawValue: "file.mp3"))
        
        // TODO: userInfo dictionary can hold additional data.
        
        // create identifier
               let identifier = UUID().uuidString // unique string
        // want a new id with each NEW notification...
        
        // get image
        // if it in the assests we wont be able to see it.
        if let imageURL = Bundle.main.url(forResource: "swift-logo", withExtension: "png") {
            do{
        // attachments
            // unnotification throws so it needs to be put inside of a do catch
        let attachment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("the error is with attachment \(error)")
            }
        } else {
            // in case there is something is wrong with the image
            print("image resource cannot be found")
        }
        // create trigger
            // 3 possible triggers for local notifcations:
                // - time interval - calendar - location
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval , repeats: false)
        // if it was a reoccuring event it would be true.
        
        // create a request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
       
        // add requst to the unnotification center
        UNUserNotificationCenter.current().add(request) { (error) in
            // once this runs it will get in the pending notification...
            if let error = error {
                print("error adding the request \(error)")
            } else {
                print("request was successfully added and clicked done. ")
            }
            
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        createLocalNotification()// once they click the done button the notification will get added to pending notifications
         delegate?.didCreateNotification(self) // only want it to be called when they press the done button not every time the picker changes
        dismiss(animated: true)
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        // to avoid time being in the past.
        guard sender.date > Date() else { return}
        // time intervalSinceNow created a time stamp of the exact date
        timeInterval = sender.date.timeIntervalSinceNow
        
    }
    

}
