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


protocol AttributesDialogDelegate {
    func addToCartFromAttributesDialog(product_id: String)
}

class AttributesDialogViewController: UIViewController {
    
    var delegate: AttributesDialogDelegate?
    
    @IBOutlet var dialogView: UIView!
    @IBOutlet var attributeTableView: UITableView!
    @IBOutlet var addToCartBtn: UIButton!
    @IBOutlet var attributeTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var attributePrice: UILabel!
    @IBOutlet var attributePriceHeightConstraint: NSLayoutConstraint!
    
    static var attributesJSON: JSON = JSON.null
    static var variations: JSON = JSON.null
    
    var attributes: Array<Dictionary<String, Any>> = []
    let attributeCellReuseIdentifier = "AttributeTableViewCell"
    
    var selectedOptions: Dictionary<String, String> = [:]
    
    var cartProductID: String = "0"
    
    
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
        
        attributePrice.isHidden = true
        attributePriceHeightConstraint.constant = 0
        
        let attrCell = UINib(nibName: attributeCellReuseIdentifier, bundle: nil)
        self.attributeTableView.register(attrCell, forCellReuseIdentifier: attributeCellReuseIdentifier)
        self.attributeTableView.tableFooterView = UIView()//to remove the extra empty cell divider lines
        
        attributeTableView.delegate = self
        attributeTableView.dataSource = self
        
        for (_, attribute): (String, JSON) in AttributesDialogViewController.attributesJSON {
            self.attributes.append([
                "name": attribute["name"].stringValue,
                "options": attribute["options"],
                "label": attribute["label"].stringValue,
                ])
        }
        
        attributeTableView.reloadData()
        self.attributeTableViewHeightConstraint.constant = CGFloat(80 * attributes.count)
        
   
        
    }
    @objc func backTouched(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    static func showPopup(parentVC: UIViewController, attributes: JSON, variations: JSON){
        self.attributesJSON = attributes
        self.variations = variations
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "Dialogs", bundle: nil).instantiateViewController(withIdentifier: "AttributesDialogViewController") as? AttributesDialogViewController {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            //setting the delegate of the dialog box to the parent viewController
            popupViewController.delegate = parentVC as? AttributesDialogDelegate
            //presenting the pop up viewController from the parent viewController
            parentVC.present(popupViewController, animated: true)
        }
    }

    @IBAction func addToCartTapped(_ sender: Any) {
        if (cartProductID == "0") {
            return
        }
        if let delegate = self.delegate {
            delegate.addToCartFromAttributesDialog(product_id: self.cartProductID)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}



extension AttributesDialogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attributes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.attributeTableView.dequeueReusableCell(withIdentifier: attributeCellReuseIdentifier) as! AttributeTableViewCell
        cell.titleLabel?.text = (self.attributes[indexPath.row]["label"] as? String)?.capitalizingFirstLetter()
        cell.attributeName = self.attributes[indexPath.row]["name"] as? String
        cell.attributeDelegate = self
        
        if let options = self.attributes[indexPath.row]["options"] as? JSON {
            for (_, option): (String, JSON) in options {
                cell.options.append([
                    "name": option["name"].stringValue,
                    "value": option["value"].stringValue
                    ])
            }
        }
        
        cell.dropDown.isSearchEnable = false
        
        var optionsString: Array<String> = []
        for option in cell.options {
            optionsString.append(option["value"]!)
        }
        
        
        cell.dropDown.optionArray = optionsString
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//FOR ATTRIBUTE OPTIONS SELECTION
extension AttributesDialogViewController: AttributeSelect {
    
    func attributeSelected(name: String, value: String) {
        selectedOptions[name] = value;
        getMatchedAttributesOfVariation();
    }
    
    func getMatchedAttributesOfVariation() {
        
        if AttributesDialogViewController.variations != JSON.null {
            var matchFound = false;
            for (_, variation): (String, JSON) in AttributesDialogViewController.variations {
                let attributes = variation["attributes"]
                //now let convert it's attributes to Dictionary to be able to compare with selected options
                var compareAttributes: Dictionary<String, String> = [:]
                for (_, attribute): (String, JSON) in attributes {
                    for (key, value): (String, JSON) in attribute {
                        compareAttributes[key] = value.stringValue
                    }
                }
                //now let compare selectedOptions with each compareAttributes in the loop
                if NSDictionary(dictionary: selectedOptions).isEqual(to: compareAttributes) {
                    matchFound = true
                    self.attributePrice.text = Site.init().CURRENCY + PriceFormatter.format(price: variation["price"].stringValue)
                    self.cartProductID = variation["ID"].stringValue
                    self.attributePrice.isHidden = false
                    self.attributePriceHeightConstraint.constant = 21
                    self.addToCartBtn.isEnabled = true
                }
            }
            if (!matchFound) {
                self.attributePrice.isHidden = true
                self.attributePriceHeightConstraint.constant = 0
                self.addToCartBtn.isEnabled = false
                self.cartProductID = "0"
            }
        }
        
        
    }
    
    
}

extension AttributesDialogViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}

