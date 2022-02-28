//
//  AddedToCartViewController.swift
//  MyShirtEg
//
//  Created by Seun Oyeniyi on 2/10/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//


//
//  AttributesDialogViewController.swift
//  MyShirtEg
//
//  Created by Seun Oyeniyi on 1/25/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift


protocol AddedToCartDialogDelegate {
    func fromCartViewCartTapped()
    func fromCartCheckoutTapped()
    func fromCartContinueTapped()
}

class AddedToCartViewController: UIViewController {
    
    var delegate: AddedToCartDialogDelegate?
    
    @IBOutlet var dialogView: UIView!
    @IBOutlet var productTileLabel: UILabel!
    @IBOutlet var selectedLabel: UILabel!
    @IBOutlet var viewCartBtn: UIButton!
    @IBOutlet var checkoutBtn: UIButton!
    @IBOutlet var continueBtn: UIButton!
    @IBOutlet var successLabel: UILabel!
    
    static var json: JSON = JSON.null
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //adding an overlay to the view to give focus to the dialog box
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.backTouched(_:)))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
        
        //customizing the dialog box view
        dialogView.layer.cornerRadius = 6.0
        dialogView.layer.borderWidth = 1.2
        dialogView.layer.borderColor = UIColor(named: "dialogBoxGray")?.cgColor
        
        let the_json = AddedToCartViewController.json
        let items = AddedToCartViewController.json["items"]
        
        selectedLabel.isHidden = true
        
        var found = false
        for (_, item): (String, JSON) in items {
            if (item["ID"].stringValue == the_json["to_be_added"].stringValue) {
                found = true
                self.productTileLabel.text = ("<b>" + item["quantity"].stringValue + "x</b> " + item["product_title"].stringValue).htmlToString
            }
        }
        
        if (!found) {
            successLabel.text = "Login Error"
            productTileLabel.text = "Try login again!"
        }
        
    }
    @objc func backTouched(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func viewCartTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if let delegate = self.delegate {
                delegate.fromCartViewCartTapped()
            }
        })
    }
    @IBAction func checkoutTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if let delegate = self.delegate {
                delegate.fromCartCheckoutTapped()
            }
        })
    }
    @IBAction func continueTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if let delegate = self.delegate {
                delegate.fromCartContinueTapped()
            }
        })
    }
    
    
    static func showPopup(parentVC: UIViewController, json: JSON){
        self.json = json
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "Dialogs", bundle: nil).instantiateViewController(withIdentifier: "AddedToCartViewController") as? AddedToCartViewController {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            //setting the delegate of the dialog box to the parent viewController
            popupViewController.delegate = parentVC as? AddedToCartDialogDelegate
            //presenting the pop up viewController from the parent viewController
            parentVC.present(popupViewController, animated: true)
        }
    }
    
    
}

extension AddedToCartViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}


