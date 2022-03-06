//
//  PaymentViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/15/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift
//import AcceptSDK

//protocol PaymentViewDelegate {
//    func orderCreated(paymentMethod: String, status: String, checkout_url: String)
//}

class PaymentViewController: NoBarViewController {
    
//    var paymentDelegate: PaymentViewDelegate?
    
    @IBOutlet var apartmentLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var houseLbl: UILabel!
    @IBOutlet var cityStateCountryLbl: UILabel!
    @IBOutlet var phoneLbl: UILabel!
    @IBOutlet var couponField: UITextField!
    @IBOutlet var couponBtn: UIButton!
    @IBOutlet var couponPriceLbl: UILabel!
    @IBOutlet var couponView: UIStackView!
    @IBOutlet var couponViewHeightC: NSLayoutConstraint! //20
    @IBOutlet var subtotalPrice: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var shippingTitleLbl: UILabel!
    @IBOutlet var shippingView: UIView!
    @IBOutlet var shippingViewHeightC: NSLayoutConstraint!
    @IBOutlet var codPaymentRadio: SSRadioButton!
    @IBOutlet var cardPaymentRadio: SSRadioButton!
    @IBOutlet var orderPlacedView: UIView!
    
    
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingViewLbl: UILabel!
    @IBOutlet var shippingTableView: UITableView!
    @IBOutlet var shippingTableViewHeightConstraint: NSLayoutConstraint!
    
    var webPay = WebPaymentViewController()
    var ordersController = OrdersViewController()
    let userSession = UserSession()
    
    var shippings: Array<Dictionary<String, String>> = []
    let shippingCellReuseIdentifier = "ShippingTableViewCell"
    var shippingSelectedIndex: Int = 0;
    
    var shippingRadio: SSRadioButtonsController!
    
    var parseData: JSON = JSON.null
    
    var paymentMethodRadioGroup: SSRadioButtonsController!
    var selected_payment_method = "cod"
    
//    let accept = AcceptSDK()
//    let PAYMOD_KEY = "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnVZVzFsSWpvaWFXNXBkR2xoYkNJc0luQnliMlpwYkdWZmNHc2lPakUxTmprM01Dd2lZMnhoYzNNaU9pSk5aWEpqYUdGdWRDSjkuUjhYaEo4WF9UTDlOUjFkaHVsVkRyX1BOdkQ5LUg5RlBndVdjQUVuZVRYLWRGbkRjUGdLM0ZYYjRDX2VoWkpiWE9DMkJpX05LX2JlNXVHVkhwMFJuOXc="
//    var the_order_id: String = "0"
//    var the_order_total_amount: Double = 0
//    var order_in_processing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        accept.delegate = self
        
        self.orderPlacedView.isHidden = true
        
        let shippingCell = UINib(nibName: shippingCellReuseIdentifier, bundle: nil)
        self.shippingTableView.register(shippingCell, forCellReuseIdentifier: shippingCellReuseIdentifier)
        self.shippingTableView.tableFooterView = UIView()//to remove the extra empty cell divider lines
        
        shippingTableView.delegate = self
        shippingTableView.dataSource = self

        
        styleThisBtn(btn: couponBtn)
        styleThisBtn(btn: confirmBtn)
        
        self.couponView.isHidden = true
        self.couponViewHeightC.constant = 0
        
        self.paymentMethodRadioGroup = SSRadioButtonsController(buttons: codPaymentRadio, cardPaymentRadio)
        self.codPaymentRadio.isSelected = true
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (userSession.logged()) {
            fetchAddress()
        } else {
            fetchCart()
            if parseData != JSON.null {
                let address = parseData
                self.nameLbl.text = address["first_name"].stringValue + " " + address["last_name"].stringValue
                self.houseLbl.text = address["address_1"].stringValue
                self.apartmentLbl.text = address["address_2"].stringValue
                self.cityStateCountryLbl.text = address["city"].stringValue + " " + address["state"].stringValue + ", " + address["country"].stringValue
                self.phoneLbl.text = address["phone"].stringValue + ", " + address["email"].stringValue
            }
        }
    }
    
    
    func fetchAddress() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad Internet connection!")
            return
        }
        
        
        self.loadingView.isHidden = false
        
        let url = Site.init().USER + userSession.ID;
        
        Alamofire.Session.default.requestWithoutCache(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.value {
                let json = JSON(json_result)
                let address = json["shipping_address"]
                self.parseData = address
                self.nameLbl.text = address["shipping_first_name"].stringValue + " " + address["shipping_last_name"].stringValue
                self.houseLbl.text = address["shipping_address_1"].stringValue
                self.apartmentLbl.text = address["shipping_address_2"].stringValue
                self.cityStateCountryLbl.text = address["shipping_city"].stringValue + " " + address["shipping_state"].stringValue + ", " + address["shipping_country"].stringValue
                self.phoneLbl.text = address["shipping_phone"].stringValue + ", " + address["shipping_email"].stringValue
                
                self.fetchCart()
            
            } else {
                //no result
                self.view.makeToast("Cannot get your account! Try Again")
                self.dismissWithCondition(animated: true, completion: nil)
            }
        }
        
    }
   
    func fetchCart() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.dismissWithCondition(animated: true, completion: nil)
            return
        }
        
        self.loadingView.isHidden = false
        
        let url = Site.init().CART + userSession.ID
        
        Alamofire.Session.default.requestWithoutCache(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.value {
                let json = JSON(json_result)
                if (json["contents_count"].intValue > 0) {
                    let subtotal = json["subtotal"].doubleValue
                    let total = json["total"].doubleValue
                    
                    self.subtotalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotal)
                    self.totalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: total)
                    
                    if (json["has_coupon"].stringValue == "true") {
                        let couponDiscount = json["coupon_discount"].doubleValue
                        self.couponViewHeightC.constant = 20
                        self.couponView.isHidden = false
                        self.couponPriceLbl.text = "-" + Site.init().CURRENCY + PriceFormatter.format(price: couponDiscount)
                    }
                    
//                    print(json)
                    
                    if (json["has_shipping"].stringValue == "true") {
                        
                        if (json["shipping_methods"] != JSON.null) {
                            let shipping_methods = json["shipping_methods"]
                            
                            for (_, method): (String, JSON) in shipping_methods {
                                self.shippings.append([
                                    "title": method["title"].stringValue,
                                    "rate_id": method["rate_id"].stringValue,
                                    "cost": method["cost"].stringValue
                                    ])
                            }
                            
                            DispatchQueue.main.async {
                                self.shippingTableView.reloadData()
                                self.shippingTableViewHeightConstraint.constant = CGFloat(48 * self.shippings.count)
                                self.shippingTableView.isHidden = false
                                self.shippingTitleLbl.text = "Shipping"
                            }
                            
                          
                        
                        }  else { //no shipping methods available
                            self.shippingTitleLbl.text = "No shipping method found"
                            self.shippingViewHeightC.constant = 0
                            self.shippingTableViewHeightConstraint.constant = 0
                            
                        }
                        
                        
                    } else {
                        self.shippingTitleLbl.text = "No shipping method found"
                        self.shippingViewHeightC.constant = 0
                        self.shippingTableViewHeightConstraint.constant = 0
                    }
                    
                    
                } else {
                    self.view.makeToast("Empty Cart!")
                    self.dismissWithCondition(animated: true, completion: nil)
                }
                
            } else {
                //no result
                self.view.makeToast("Can't get your cart items")
                self.dismissWithCondition(animated: true, completion: nil)
                
            }
            //after every thing
            self.loadingView.isHidden = true
            
        }
        
    }
    
    func changeShippingMethod(method: String) {
        self.loadingView.isHidden = false
        
        let url = Site.init().CHANGE_CART_SHIPPING + userSession.ID + "/" + method;
        let parameters: [String: AnyObject] = [:]
        
        Alamofire.Session.default.requestWithoutCache(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.value {
                let json = JSON(json_result)
                
                if json["has_shipping"].stringValue == "true" {
                    
                    let subtotal = json["subtotal"].doubleValue
                    let total = json["total"].doubleValue
                    let couponDiscount = json["coupon_discount"].doubleValue
                    
                    self.subtotalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotal)
                    self.totalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: total)
                    self.couponPriceLbl.text = "-" + Site.init().CURRENCY + PriceFormatter.format(price: couponDiscount)
                    
                } else {
                    self.view.makeToast("Cart has no shipping go back and update your address!")
                }
                
            } else {
                self.view.makeToast("Unable to change shipping method. Try Again")
            }
            self.loadingView.isHidden = true
        }
    }
    
    
    func applyCouponCode() {
        self.loadingView.isHidden = false
        
        let coupon: String = (self.couponField.text?.isEmpty)! ? "null" : self.couponField.text!
        
        let url = Site.init().UPDATE_COUPON + userSession.ID + "/" + coupon;
        let parameters: [String: AnyObject] = [:]
        
        Alamofire.Session.default.requestWithoutCache(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.value {
                let json = JSON(json_result)
                if json["has_coupon"].stringValue == "true" {
                    let subtotal = json["subtotal"].doubleValue
                    let couponDiscount = json["coupon_discount"].doubleValue
                    let total = subtotal - couponDiscount
                    
                    self.subtotalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotal)
                    self.totalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: total)
                    self.couponPriceLbl.text = "-" + Site.init().CURRENCY + PriceFormatter.format(price: couponDiscount)
                    
                    self.couponViewHeightC.constant = 20
                    self.couponView.isHidden = false
                    
                    self.view.makeToast("Coupon Applied!")
                    
                } else {
                    self.view.makeToast("Invalid Coupon!")
                }
            } else {
                self.view.makeToast("Unable to apply coupon. Try Again");
            }
            self.loadingView.isHidden = true
        }
        
    }

    func createOrder(paymentMethod: String, status: String) {
//        if (!userSession.logged()) {
//            self.view.makeToast("Can't aunthenticate your loggin session!")
//            self.loadingView.isHidden = true
//            self.loadingViewLbl.isHidden = true
//            self.loadingViewLbl.text = "Please wait..."
//            return;
//        }
        self.loadingView.isHidden = false
        self.loadingViewLbl.isHidden = false
        self.loadingViewLbl.text = "Creating Order..."
        
        let url = Site.init().CREATE_ORDER + userSession.ID;
    
        var parameters: [String: AnyObject] = [
            "status": status as AnyObject,
            "clear_cart": "1" as AnyObject
        ]
        
        if (!userSession.logged()) {
            parameters["allow_guest"] = 1 as AnyObject
            parameters["shipping_first_name"] = parseData["first_name"].stringValue as AnyObject
            parameters["shipping_last_name"] = parseData["last_name"].stringValue as AnyObject
            parameters["shipping_company"] = parseData["company"].stringValue as AnyObject
            parameters["shipping_country"] = parseData["country"].stringValue as AnyObject
            parameters["shipping_state"] = parseData["state"].stringValue as AnyObject
            parameters["shipping_city"] = parseData["city"].stringValue as AnyObject
            parameters["shipping_postcode"] = parseData["postcode"].stringValue as AnyObject
            parameters["shipping_address_1"] = parseData["address_1"].stringValue as AnyObject
            parameters["shipping_address_2"] = parseData["address_2"].stringValue as AnyObject
            parameters["shipping_email"] = parseData["email"].stringValue as AnyObject
            parameters["shipping_phone"] = parseData["phone"].stringValue as AnyObject
            //"selected_country": self.selectedCountry as AnyObject
            //"selected_state": self.selectedState as AnyObject
        }
        
        if (paymentMethod != "web") {
            parameters["payment_method"] = paymentMethod as AnyObject
        }
        
        Alamofire.Session.default.requestWithoutCache(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.value {
                let json = JSON(json_result)
                if (json["cart_empty"].stringValue == "true" || json["cart_exists"].stringValue == "false" || !json["info"].exists()) {
                    //cannot create order because cart is empty or not found
                    self.loadingView.isHidden = true
                    self.loadingViewLbl.isHidden = true
                    self.loadingViewLbl.text = "Please wait..."
                    
                    let alert = UIAlertController(title: "Alert", message: "Cannot create order because cart is empty or not found.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style {
                        case .default:
                            alert.dismissWithCondition(animated: true, completion: nil)
                        case .cancel:
                            alert.dismissWithCondition(animated: true, completion: nil)
                        case .destructive:
                            alert.dismissWithCondition(animated: true, completion: nil)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    //order created
                    if (self.userSession.logged()) {
                        self.userSession.update_last_orders_count(count: String(Int(self.userSession.last_orders_count)! + 1));
                    }
                    
                    let info = json["info"]
                    
                    if self.selected_payment_method == "cod" {
                        self.loadingView.isHidden = true
                        self.loadingViewLbl.isHidden = true
                        self.orderPlacedView.isHidden = false
                        return
                    }
                    
                    var checkout_url = info["checkout_payment_url"].stringValue
                    checkout_url += "&sk-web-payment=1&sk-browser=1&sk-user-checkout=" + self.userSession.ID;
                    checkout_url += "&in_sk_app=1"
//                    checkout_url += "&hide_elements=div*topbar.topbar, div.joinchat__button"
                    //go to browser
                    self.loadingView.isHidden = true
                    self.loadingViewLbl.isHidden = true
                    self.webPay = WebPaymentViewController()
//                    self.webPay.webPaymentDelegate = self
                    self.webPay.url = checkout_url
                    self.presentWithCondition(controller: self.webPay, animated: false, completion: nil)
                }
                
            } else {
                self.view.makeToast("Unable to complete your order. Please contact us OR Try Again!")
                self.loadingView.isHidden = true
                self.loadingViewLbl.isHidden = true
                self.loadingViewLbl.text = "Please wait..."
            }
            
        }
        
    }
    
//    func proceedAcceptCard(order_id: String, amount: Double) {
//        self.the_order_id = order_id
//        self.the_order_total_amount = amount
//        //        let bData = [
//        //            "apartment": ""
//        //        ]
//        do {
//            try accept.presentPayVC(vC: self, paymentKey: PAYMOD_KEY, saveCardDefault: true, showSaveCard: true, showAlerts: true)
//        } catch AcceptSDKError.MissingArgumentError(let errorMessage) {
//            print(errorMessage)
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }

    @IBAction func confirmTapped(_ sender: Any) {
        if self.selected_payment_method == "cod" {
            createOrder(paymentMethod: self.selected_payment_method, status: "processing")
        } else if self.selected_payment_method == "accept-online"  {
            createOrder(paymentMethod: self.selected_payment_method, status: "pending")
        } else {
            createOrder(paymentMethod: self.selected_payment_method, status: "pending")
        }
        
    }
    
    @IBAction func orderPlacedContinueTapped(_ sender: Any) {
        self.ordersController = OrdersViewController()
        self.ordersController.orderStatus = "all"
        self.presentWithCondition(controller: self.ordersController, animated: true, completion: nil)
    }
    
    @IBAction func applyCouponTapped(_ sender: Any) {
        self.applyCouponCode()
    }
    
    @IBAction func codMethodTapped(_ sender: Any) {
        self.selected_payment_method = "cod"
    }
    @IBAction func cardMethodTapped(_ sender: Any) {
        self.selected_payment_method = "accept-online"
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismissWithCondition(animated: true, completion: nil)
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

extension PaymentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shippings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.shippingTableView.dequeueReusableCell(withIdentifier: shippingCellReuseIdentifier) as! ShippingTableViewCell
        
        if (indexPath.row == self.shippingSelectedIndex) {
            cell.backgroundColor = UIColor(rgb: 0xF1F1F1)
            cell.checkedImage.isHidden = false
        } else {
            cell.backgroundColor = UIColor(rgb: 0xFFFFFF)
            cell.checkedImage.isHidden = true
        }
        
        let title: String = self.shippings[indexPath.row]["title"]!
        let cost: String = self.shippings[indexPath.row]["cost"]!
        cell.rateLabel.attributedText = ("<font size='4' face='Montserrat, Verdana, Geneva, sans-serif'>" + title + " (<strong>" + Site.init().CURRENCY + PriceFormatter.format(price: cost) + "</strong>)</font>").htmlToAttributedString
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeShippingMethod(method: self.shippings[indexPath.row]["rate_id"]!)
        self.shippingSelectedIndex = indexPath.row
        self.shippingTableView.reloadData()
    }
    
}


//extension PaymentViewController: AcceptSDKDelegate {
//    func userDidCancel() {
//        self.view.makeToast("Payment cancelled")
//    }
//
//    func paymentAttemptFailed(_ error: AcceptSDKError, detailedDescription: String) {
//        self.view.makeToast(detailedDescription)
//    }
//
//    func transactionRejected(_ payData: PayResponse) {
//        self.view.makeToast("Transaction rejected")
//    }
//
//    func transactionAccepted(_ payData: PayResponse) {
//        self.view.makeToast("Transaction Accepted")
//        updateOrderStatus(order_id: the_order_id, status: "processing")
//    }
//
//    func transactionAccepted(_ payData: PayResponse, savedCardData: SaveCardResponse) {
//        self.view.makeToast("Transaction rejected")
//        updateOrderStatus(order_id: the_order_id, status: "processing")
//    }
//
//    func userDidCancel3dSecurePayment(_ pendingPayData: PayResponse) {
//        self.view.makeToast("You cancelled the payment.")
//    }
//
//
//    func updateOrderStatus(order_id: String, status: String) {
//
//        self.order_in_processing = true
//        self.loadingView.isHidden = false
//        self.loadingViewLbl.text = "Updating your order status"
//        self.loadingViewLbl.isHidden = false
//
//        let url = Site.init().UPDATE_ORDER + order_id + "/" + userSession.ID;
//
//        var parameters: [String: AnyObject] = [
//            "status": status as AnyObject,
//            "clear_cart": "1" as AnyObject
//        ]
//
//        if (!userSession.logged()) {
//            parameters["allow_guest"] = 1 as AnyObject
//        }
//
//        Alamofire.Session.default.requestWithoutCache(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
//            (response:DataResponse) in
//            if let json_result = response.value {
//                let json = JSON(json_result)
//                if json["order_status_updated"].boolValue {
//                    self.loadingView.isHidden = true
//                    self.orderPlacedView.isHidden = false
//                } else {
//                    self.ordersController = OrdersViewController()
//                    self.ordersController.orderStatus = "all"
//                    self.presentWithCondition(controller: self.ordersController, animated: true, completion: nil)
//                }
//            }
//            self.loadingView.isHidden = true
//        }
//
//    }
//}


