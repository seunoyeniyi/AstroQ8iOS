//
//  RegisterViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/6/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SwiftyJSON

protocol RegisterDelegate {
    func onRegistrationDone(registered: Bool)
    func backToLogin()
}

class RegisterViewController: UIViewController {
    
    var delegate: RegisterDelegate?
    
    @IBOutlet var registerBtn: UIButton!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var usernameField: UITextField!
    
    
    let userSession = UserSession()
    let alert = UIAlertController(title: "Alert", message: "?", preferredStyle: .alert)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.outsideTouched(_:)))
        self.view.addGestureRecognizer(gesture)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        styleThisBtn(btn: registerBtn)
    }

    @objc func outsideTouched(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
   
    
    
    
    @IBAction func registerTapped(_ sender: Any) {
        if !Connectivity.isConnectedToInternet {
            self.view.makeToast("Please check your internet connection!")
            return
        }
        
        
        let username = usernameField.text
        let email = emailField.text
        let password = passwordField.text
        
        if ((username?.count)! < 2) {
            self.view.makeToast("Username or email required!", position: .top)
            return
        }
        if ((email?.count)! < 2) {
            self.view.makeToast("Email required!", position: .top)
            return
        }
        if ((password?.count)! < 2) {
            self.view.makeToast("Password required!", position: .top)
            return
        }
        
        
        let activityViewController = ActivityViewController(message: "Please wait...")
        present(activityViewController, animated: true, completion: nil)
        
        let url: String = Site.init().REGISTER;
        var parameters: [String: AnyObject] = [
            "username" : username as AnyObject,
            "email" : email as AnyObject,
            "password" : password as AnyObject
        ]
        if (userSession.ID != "0") { //ID maybe hash code for anonymoush user
            parameters["replace_cart_user"] = userSession.ID as AnyObject
        }
        
        parameters["token_key"] = Site.init().TOKEN_KEY as AnyObject
        
        Alamofire.SessionManager.default.requestWithoutCache(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.result.value {
                let json = JSON(json_result)
//                print(json)
                if json["code"].exists() || json["data"] == JSON.null {
                    activityViewController.dismiss(animated: false, completion: {
                        if json["message"].exists() {
                            self.alert.message = json["message"].stringValue
                        } else {
                            self.alert.message = "Unable to get you registered at the moment!"
                        }
                        self.present(self.alert, animated: true, completion: nil)
                    })
                    if json["message"].exists() {
                        self.view.makeToast(json["message"].stringValue, position: .top)
                    } else {
                        self.view.makeToast("Unable to get you registered at the moment!", position: .top)
                    }
                } else {
                    let data = json["data"]
                    //save user session
                    let id = data["ID"].stringValue
                    self.userSession.createLoginSession(userID: id, xusername: data["user_login"].stringValue, xemail: data["user_email"].stringValue, logged: true)
                    self.view.makeToast("Registration Completed... Welcome!")
                    self.userSession.reload()
                    activityViewController.dismiss(animated: false, completion: nil)
                    
                    self.dismiss(animated: true, completion: {
                        if let delegate = self.delegate {
                            delegate.onRegistrationDone(registered: true)
                        }
                    })
                    
                    //                    print(data)
                }
            } else {
                activityViewController.dismiss(animated: false, completion: {
                    self.alert.message = "Unable to get you registered at the moment!"
                    self.present(self.alert, animated: true, completion: nil)
                })
                self.view.makeToast("Unable to get you registered at the moment!")
            }
        }
    }
    @IBAction func loginTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.backToLogin()
            }
        })
    }
    @IBAction func cancelTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.onRegistrationDone(registered: false)
            }
        })
    }
    
    
    
    func styleThisBtn(btn: UIButton) {
        btn.layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 4.0
    }

}
