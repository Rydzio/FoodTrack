//
//  RegisterViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 02/2/21.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
           let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let isError = error {
                    self.alert(present: isError)
                } else {
                    self.performSegue(withIdentifier: Constant.Segue.register, sender: self)
                }
            }
        }
    }
}
