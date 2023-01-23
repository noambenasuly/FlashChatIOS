//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text , let password = passwordTextfield.text {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // Navigate to the ChatViewController ( From Constants )
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
    }
}
