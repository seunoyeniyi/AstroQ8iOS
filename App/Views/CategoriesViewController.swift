//
//  CategoriesViewController.swift
//  WhatsDownApp
//
//  Created by Seun Oyeniyi on 1/16/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CategoriesViewController: NoBarViewController {
    
    @IBOutlet var categoriesCollectionView: UICollectionView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingActivity: UIActivityIndicatorView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var loadingTryAgain: UIButton!
    
    let userSession = UserSession()
    let searchController = SearchViewController()
    let wishListController = WishlistViewController()
    
    let categoryReuseIdentifier: String = "CategoriesCollectionViewCell"
    var categories: Array<Dictionary<String, String>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let categoryCell = UINib(nibName: categoryReuseIdentifier, bundle: nil)
        self.categoriesCollectionView.register(categoryCell, forCellWithReuseIdentifier: categoryReuseIdentifier)
        
        self.categoriesCollectionView.delegate = self
        self.categoriesCollectionView.dataSource = self
        
        fetchCategories()
       
    }
    
    func fetchCategories() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.loadingView.isHidden = false
            self.loadingActivity.isHidden = true
            self.loadingLabel.isHidden = true
            self.loadingTryAgain.isHidden = false
            return
        }
        
        self.loadingView.isHidden = false
        self.loadingActivity.isHidden = false
        self.loadingLabel.isHidden = false
        self.loadingLabel.text = "Loading..."
        self.loadingTryAgain.isHidden = true
        
        let url = Site.init().CATEGORIES + "?hide_empty=1&order_by=menu_order" + Site.init().TOKEN_KEY_APPEND;
        
        Alamofire.SessionManager.default.requestWithoutCache(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
               
                    let json = JSON(json_result)
                    
                    for (_, category): (String, JSON) in json {
                        self.categories.append([
                            "name": category["name"].stringValue,
                            "slug": category["slug"].stringValue,
                            "image": category["image"].stringValue
                        ])
                    }
                    
                 
                    DispatchQueue.main.async {
                        self.categoriesCollectionView.reloadData()
                        self.loadingView.isHidden = true
                    }
                    
                    
                    
                
            } else {
                //no result
                self.loadingView.isHidden = false
                self.loadingActivity.isHidden = true
                self.loadingLabel.isHidden = false
                self.loadingLabel.text = "No categories"
                self.loadingTryAgain.isHidden = false
                
            }
        }
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismissWithCondition(animated: true, completion: nil)
    }
    @IBAction func searchTapped(_ sender: Any) {
        self.presentWithCondition(controller: searchController, animated: true, completion: nil)
    }
    func login() {
        let login = LoginViewController()
        self.present(login, animated: true, completion: nil)
    }
    @IBAction func wishlistTapped(_ sender: Any) {
        if (!userSession.logged()) {
            self.login();
            return
        }
        self.presentWithCondition(controller: wishListController, animated: true, completion: nil)
    }
    @IBAction func tryAgainTapped(_ sender: Any) {
        fetchCategories()
    }
    

}

extension CategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryReuseIdentifier, for: indexPath) as! CategoriesCollectionViewCell
        cell.categoryImage.pin_setImage(from: URL(string: self.categories[indexPath.row]["image"]!))
        cell.categoryTitle.text = (self.categories[indexPath.row]["name"]!).htmlToString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width) - 20, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let archivePage = ArchiveViewController()
        archivePage.category_name = self.categories[indexPath.row]["slug"]!
        archivePage.category_title = self.categories[indexPath.row]["name"]!
        self.presentWithCondition(controller: archivePage, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF1F1F1)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
    
    
}
