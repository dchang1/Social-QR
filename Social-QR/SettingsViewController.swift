//
//  SettingsViewController.swift
//  Social-QR
//
//  Created by David Chang on 7/28/17.
//  Copyright © 2017 David Chang. All rights reserved.
//

import UIKit
import TwitterKit

let defaults = UserDefaults.standard

class SettingsViewController: UIViewController {

    @IBOutlet weak var contactInfo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userID))");
                defaults.set((session?.userID), forKey: "twitterID")
                defaults.set((defaults.object(forKey: "contacts") as! String) + ", " + (defaults.object(forKey: "instagramID") as! String) + ", " + (defaults.object(forKey: "twitterID") as! String), forKey: "code")
            }
            else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
                defaults.set((session?.userID), forKey: "twitterID")
                defaults.set((defaults.object(forKey: "contacts") as! String) + ", " + (defaults.object(forKey: "instagramID") as! String) + ", " + (defaults.object(forKey: "twitterID") as! String), forKey: "code")
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        })
         //Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func updateContactInfo(_ sender: UIButton) {
        let alert = UIAlertController(title: "Update Contact Info", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "First Name"
        }
        alert.addTextField { (textField) in textField.placeholder = "Last Name"
        }
        alert.addTextField { (textField) in textField.placeholder = "Phone Number"
        }
        alert.addTextField { (textField) in textField.placeholder = "Email"
        }
        alert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: {
            (action) in
            for index in 0...3 {
                if alert.textFields![index].text! == "" {
                    alert.textFields![index].text! = "NONE"
                }
            }
            let contactsCode = alert.textFields![0].text! + ", " + alert.textFields![1].text! + ", " +  alert.textFields![2].text! + ", " + alert.textFields![3].text!
            defaults.set(contactsCode, forKey: "contacts")
            defaults.set((defaults.object(forKey: "contacts") as! String) + ", " + (defaults.object(forKey: "instagramID") as! String) + ", " + (defaults.object(forKey: "twitterID") as! String), forKey: "code")
            defaults.set(alert.textFields![0].text!, forKey: "firstName")
            defaults.set(alert.textFields![1].text!, forKey: "lastName")
            defaults.set(alert.textFields![2].text!, forKey: "phoneNumber")
            defaults.set(alert.textFields![3].text!, forKey: "email")
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (action) in print("CANCEL")}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


