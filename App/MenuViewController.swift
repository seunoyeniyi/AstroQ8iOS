//
//  MenuViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/1/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

enum MenuType: Int {
    case home
    case shop
    case category
    case wishlist
    case orders
    case blog
    case sales
    case support
    case faq
    case contact
    case about
    case cancel
    case login
    case logout
    case account
}

protocol ModalDelegate {
    func menuItemsClicked(menuType: MenuType)
}

class MenuViewController: UIViewController {
    
    let userSession = UserSession()
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var logoutBtn: UIButton!
    @IBOutlet var viewProfileBtn: UIButton!
    @IBOutlet var ordersNotificationLbl: CircleLabel!
    
    //MENU LISTS
    @IBOutlet var homeListView: ListView!
    @IBOutlet var shopListView: ListView!
    @IBOutlet var categoryListView: ListView!
    @IBOutlet var wishlistListView: ListView!
    @IBOutlet var ordersListView: ListView!
    @IBOutlet var blogListView: ListView!
    @IBOutlet var supportListView: ListView!
    @IBOutlet var faqListView: ListView!
    @IBOutlet var contactListView: ListView!
    @IBOutlet var aboutListView: ListView!
    
    
    var delegate: ModalDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userSession.logged()) {
            usernameLabel.text = userSession.username
            viewProfileBtn.setTitle("Account Settings", for: .normal)
            logoutBtn.setTitle("Log Out", for: .normal)
        } else {
            usernameLabel.text = "Hi!"
            viewProfileBtn.setTitle("Login", for: .normal)
            logoutBtn.setTitle("Login", for: .normal)
        }
    
        if (Int(userSession.last_orders_count) ?? 0 > 0) {
            ordersNotificationLbl.isHidden = false
            ordersNotificationLbl.text = userSession.last_orders_count
        } else {
            ordersNotificationLbl.isHidden = true
            ordersNotificationLbl.text = "0"
        }
        
        
        homeListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.homeTapped(_:))))
        shopListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.shopTapped(_:))))
        categoryListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.categoryTapped(_:))))
        wishlistListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.wishListTapped(_:))))
        ordersListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.ordersTapped(_:))))
        blogListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.blogTapped(_:))))
        supportListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.supportTapped(_:))))
        faqListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.faqTapped(_:))))
        contactListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.contactTapped(_:))))
        aboutListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.aboutTapped(_:))))
        
        
    }
    
    @objc func homeTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.home)
            }
        })
    }
    @objc func shopTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.shop)
            }
        })
    }
    @objc func categoryTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.category)
            }
        })
    }
    @objc func wishListTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.wishlist)
            }
        })
    }
    @objc func ordersTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.orders)
            }
        })
    }
    @objc func blogTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.blog)
            }
        })
    }
    @objc func supportTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                    delegate.menuItemsClicked(menuType: MenuType.support)
                }
        })
    }
    @objc func faqTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.faq)
            }
        })
    }
    @objc func contactTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.contact)
            }
        })
    }
    @objc func aboutTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.about)
            }
        })
    }
    
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func profileFunc() {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                if (self.userSession.logged()) {
                    delegate.menuItemsClicked(menuType: MenuType.account)
                } else {
                    delegate.menuItemsClicked(menuType: MenuType.login)
                }
            }
        })
    }
    @IBAction func viewProfileTapped(_ sender: Any) {
        profileFunc()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                if (self.userSession.logged()) {
                    delegate.menuItemsClicked(menuType: MenuType.logout)
                } else {
                    delegate.menuItemsClicked(menuType: MenuType.login)
                }
                
            }
        })
    }
    
    func myDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}

