//
//  AddToCart.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/9/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Toast_Swift


protocol AddToCartDelegate {
    func cartAdded(totalItems: String, subTotal: String, total: String, json: JSON);
    func cartNotAdded(msg: String);
}


class AddToCart {
    var userSession = UserSession();
    
    var delegate: AddToCartDelegate?
    
    var activityView: UIView?
    
    public func addToCart(productID: String, quantity: Int, replaceQuantity: Bool = false, controller: UIViewController) {
        self.userSession = UserSession()
        
        activityView = LoadingViewController().view
        activityView!.frame = controller.view.frame
        controller.view.addSubview(activityView!)
        
        activityView?.isHidden = false
        
        let url = Site.init().ADD_TO_CART + productID;
      
        var parameters: [String: AnyObject] = [
            "quantity" : quantity as AnyObject
        ]
        //logged
        if userSession.ID != "0" {
            parameters["user"] = userSession.ID as AnyObject
        }
        if replaceQuantity {
            parameters["replace_quantity"] = 1 as AnyObject
        }
        
        Alamofire.Session.default.requestWithoutCache(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            
            if let json_result = response.value {
                let json = JSON(json_result)
//                print(json)
                if (self.userSession.ID == "0" && !json["user_cart_exists"].boolValue) {
//                save the generated user id to session
                    self.userSession.createLoginSession(userID: json["user"].stringValue, xusername: "", xemail: "", logged: false)
                } else if (json["user_cart_not_exists"].boolValue) {
                    self.delegate?.cartNotAdded(msg: "Can't create cart! Please login or register.")
                }
                
                if json["code"].exists() || json["msg"].exists() {
                    var style = ToastStyle()
                    style.imageSize = CGSize(width: 20, height: 20)
                    controller.view.makeToast(json["msg"].stringValue, position: .top, image: UIImage(named: "icons8_cancel"), style: style)
                    self.activityView!.isHidden = true
                    return
                }
            
                self.userSession.update_last_cart_count(count: json["contents_count"].stringValue);
                self.userSession.reload()
                self.delegate?.cartAdded(totalItems: json["contents_count"].stringValue, subTotal: json["subtotal"].stringValue, total: json["total"].stringValue, json: json)
                //will recalculate total for other app
               
                
                
            } else {
                self.delegate?.cartNotAdded(msg: "Unable to get cart!")
            }
            
            self.activityView!.isHidden = true
        }
        
    }
}
