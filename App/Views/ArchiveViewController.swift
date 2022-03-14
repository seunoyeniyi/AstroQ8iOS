//
//  ArchiveViewController.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/26/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class ArchiveViewController: NoBarViewController {
    @IBOutlet var topNavigationItem: UINavigationItem!
    @IBOutlet var topCartBtn: UIBarButtonItem!
    @IBOutlet var productCollectionView: UICollectionView!
    @IBOutlet var productShimmerContainer: ShimmerViewContainer!
    @IBOutlet var categoryTitleLbl: UILabel!
    @IBOutlet var categoryDescription: UILabel!
    @IBOutlet var refreshBtn: UIButton!
    @IBOutlet var errorLbl: UILabel!
    
    var cartNotification: UILabel!
    
    var category_name: String = ""
    var product_tag = ""
    var product_price_range: Array<String> = []
    
    var category_title: String = ""
    var category_description: String = "Category" //for banner
    
    var selected_size: String = ""
    
    let productReuseIdentifier: String = "ProductCardCollectionViewCell"
    
    var products: Array<ProductObject> = []
    
    var defaultPaged = 1
    var currentPaged: Int = 1
    
    var productIsFetching = false
    
    let userSession = UserSession()
    
    let theCart = AddToCart()
    
    let filterController = FilterViewController()
    var searchController = SearchViewController()
    var productPage = ProductViewController()
    var cartController = CartViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavLogo(theNavigationItem: self.topNavigationItem)
        
        theCart.delegate = self
        
        categoryTitleLbl.text = category_title
        categoryDescription.text = category_description
        
        errorLbl.isHidden = true
        
        let productsShimmerlayout = ProductsShimmerController()
        productShimmerContainer.addSubview(productsShimmerlayout.view)
        productShimmerContainer.sendSubview(toBack: productsShimmerlayout.view)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.view.frame.size.width/2) - 25, height: 265)
        self.productCollectionView.collectionViewLayout = layout
        let productCell = UINib(nibName: productReuseIdentifier, bundle: nil)
        self.productCollectionView.register(productCell, forCellWithReuseIdentifier: productReuseIdentifier)
        
        self.productCollectionView.delegate = self
        self.productCollectionView.dataSource = self
        
        setupCartNotification()
        
        filterController.delegate = self
        
        
        fetchProducts(category: self.category_name, tag: self.product_tag, priceRange: self.product_price_range, paged: defaultPaged, shim: true)
    
        
    }
    

    func fetchProducts(category: String, tag: String, priceRange: Array<String>, paged: Int, shim: Bool, emptyProducts: Bool = false) {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            if (shim) {
                self.productShimmerContainer.isHidden = false
                self.productShimmerContainer.stopShimmering()
                self.refreshBtn.isHidden = false
            }
            return
        }
        
        self.productIsFetching = true
        
        if (shim) {
            self.productShimmerContainer.isHidden = false
            self.productShimmerContainer.startShimmering()
            self.refreshBtn.isHidden = true
            self.errorLbl.isHidden = true
        }
        
       
        var url = Site.init().SIMPLE_PRODUCTS + "?per_page=20" + "&paged=\(paged)" + "&hide_description=1&show_variation=1&user_id=" + userSession.ID;
        if (category.count > 0) {
            url += "&cat=" + category
        }
        if (tag.count > 0) {
            url += "&tag=" + tag
        }
        if (priceRange.count > 1) {
            url += "&price_range=" + priceRange[0] + "," + priceRange[1]
        }
        
        if (selected_size.count > 0) {
            url += "&size=" + selected_size
        }
        
        url = url + Site.init().TOKEN_KEY_APPEND
        
        
//        print(url)
        
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.Session.default.requestWithoutCache(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.value {
                
                    let json = JSON(json_result)
                let results = json["results"] //array
                
                if (emptyProducts) {
                    self.products = []
                }
                
                for (_, subJson): (String, JSON) in results {
                    let id = subJson["ID"].stringValue;
                    let name = subJson["name"].stringValue;
                    let image = subJson["image"].stringValue;
                    let price = subJson["price"].stringValue;
                    let product_type = subJson["product_type"].stringValue;
                    let ptype = subJson["type"].stringValue;
                    let description = subJson["description"].stringValue;
                    let in_wishlist = subJson["in_wishlist"].stringValue;
                    //                    let categories = subJson["categories"].stringValue;
                    let stock_status = subJson["stock_status"].stringValue;
                    let attributes = subJson["attributes"]
                    let variations = subJson["variations"]
                    let categories = subJson["categories"]
                    let regular_price = subJson["regular_price"].stringValue
                    
                    let productObject = ProductObject()
                    productObject.setID(value: id)
                    productObject.setName(value: name)
                    productObject.setImage(value: image)
                    productObject.setPrice(value: price)
                    productObject.setProductType(value: product_type)
                    productObject.setType(value: ptype)
                    productObject.setDescription(value: description)
                    productObject.setInWishlist(value: in_wishlist)
                    productObject.setStockStatus(value: stock_status)
                    productObject.setAttributes(value: attributes)
                    productObject.setVariations(value: variations)
                    productObject.setCategories(value: categories)
                    productObject.setRegularPrice(value: regular_price)
                    
                    self.products.append(productObject)
                }
                
                DispatchQueue.main.async {
                    self.productCollectionView.reloadData()
                    //                    self.productCollectionView.layoutIfNeeded()
                }
                
                if json["pagination"].exists() {
                    if json["paged"].exists() {
                        self.currentPaged = Int(json["paged"].stringValue)!
                    }
                }
                //                print(json)
                
                if (shim) {
                    self.productShimmerContainer.isHidden = true
                    self.productShimmerContainer.stopShimmering()
                    self.refreshBtn.isHidden = true
                }
                
            } else {
                //no result
                if (shim) {
                    self.productShimmerContainer.isHidden = false
                    self.productShimmerContainer.stopShimmering()
                    self.refreshBtn.isHidden = false
                    self.errorLbl.isHidden = false
                }
            }
            //after every thing
            self.productIsFetching = false
        }
    }
    
    
    @IBAction func refreshBtnTapped(_ sender: Any) {
        fetchProducts(category: self.category_name, tag: self.product_tag, priceRange: self.product_price_range, paged: currentPaged, shim: true, emptyProducts: true)
    }
    @IBAction func backTapped(_ sender: Any) {
        if (self.isModal) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
   
    @IBAction func filterTapped(_ sender: Any) {
        self.present(self.filterController, animated: false, completion: nil)
    }
    @IBAction func searchTapped(_ sender: Any) {
        searchController = SearchViewController()
        if (self.isModal) {
            self.present(searchController, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(searchController, animated: true)
        }
    }
    
    
    @objc func cartMenuTapped(_ sender: UIButton) {
        cartController = CartViewController()
        self.presentWithCondition(controller: cartController, animated: true, completion: nil)
    }
    
    func setupCartNotification() {
        let filterBtn = UIButton(type: .system)
        filterBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        filterBtn.setImage(UIImage(named: "icons8_shopping_bag")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterBtn.tintColor = UIColor.black
        filterBtn.addTarget(self, action: #selector(cartMenuTapped(_:)), for: .touchUpInside)
        
        cartNotification = UILabel.init(frame: CGRect.init(x: 20, y: 2, width: 15, height: 15))
        cartNotification.backgroundColor = UIColor.black
        cartNotification.clipsToBounds = true
        cartNotification.layer.cornerRadius = 7
        cartNotification.textColor = UIColor.white
        cartNotification.font = cartNotification.font.withSize(10)
        cartNotification.textAlignment = .center
        cartNotification.text = "0"
        filterBtn.addSubview(cartNotification)
        topCartBtn.customView = filterBtn
        
        cartNotification.isHidden = true //hidden by default
        
        //update cartNofication from server
        updateCartNotification()
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
        let wishPage = WishlistViewController()
        self.presentWithCondition(controller: wishPage, animated: true, completion: nil)
    }
    
    func updateCartNotification() {
        let url = Site.init().CART + userSession.ID + "?token_key=" + Site.init().TOKEN_KEY
        
        Alamofire.Session.default.requestWithoutCache(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.value {
                let json = JSON(json_result)
                if (json["contents_count"].intValue > 0) {
                    self.cartNotification.text = json["contents_count"].stringValue
                    self.cartNotification.isHidden = false
                } else {
                    self.cartNotification.isHidden = true
                }
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.userSession.reload()
        self.updateCartNotification()
    }
}




extension ArchiveViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCardCollectionViewCell
        cell.parentView = self.view
        cell.cardDelegate = self
        cell.productID = self.products[indexPath.row].getID()
        cell.hasWishList = self.products[indexPath.row].getInWishlist() == "true"
        cell.productImage.pin_setImage(from: URL(string: self.products[indexPath.row].getImage()))
        cell.productTitle.text = self.products[indexPath.row].getName().htmlToString
        
        //variable
        if self.products[indexPath.row].getProductType() == "variable" || self.products[indexPath.row].getType() == "variable" {
            cell.productPrice.text = "From " + Site.init().CURRENCY + PriceFormatter.format(price: self.products[indexPath.row].getPrice())
            cell.regularPrice.isHidden = true
        } else { //single product
            cell.productPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: self.products[indexPath.row].getPrice())
            
            if (self.products[indexPath.row].getRegularPrice() != self.products[indexPath.row].getPrice()) {
                let regularPriceAtt: NSMutableAttributedString = NSMutableAttributedString(string: Site.init().CURRENCY + PriceFormatter.format(price: self.products[indexPath.row].getRegularPrice()))
                regularPriceAtt.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, regularPriceAtt.length))
                cell.regularPrice.attributedText = regularPriceAtt
                cell.regularPrice.isHidden = false
            } else {
                cell.regularPrice.isHidden = true
            }
            
            
        }
        //wishlist button
        if (cell.hasWishList) {
            cell.wishListBtn.setImage(UIImage(named: "icons8_heart_outline_1"), for: .normal)
        } else {
            cell.wishListBtn.setImage(UIImage(named: "icons8_heart_outline"), for: .normal)
        }
        
        if self.products[indexPath.row].getCategories().count > 0 {
            let categories = self.products[indexPath.row].getCategories()
            cell.categoryLabel.text = ("   " + categories[0]["name"].stringValue + "   ").replacingOccurrences(of: "&amp;", with: "&")
        } else {
            cell.categoryLabel.text = ""
        }
        
        
        //MORE
        cell.productType = self.products[indexPath.row].getProductType()
        if self.products[indexPath.row].getStockStatus() == "outofstock" {
            cell.productPrice.text = "Out of Stock"
            cell.productPrice.textAlignment = .center
//            cell.addToCartBtn.isHidden = true
        }
        
        //FOR THE ATTRIBUTES
        
        if self.products[indexPath.row].getProductType() == "variable" || self.products[indexPath.row].getType() == "variable" {
            
            cell.variations = self.products[indexPath.row].getVariations()
            
            cell.attributes = self.products[indexPath.row].getAttributes()
            
        }
            
            
            return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (self.view.frame.size.width/2) - 25, height: 265)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF1F1F1)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
    
    //SELECTION
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        productPage = ProductViewController()
        productPage.productID = self.products[indexPath.item].getID()
        productPage.productName = self.products[indexPath.item].getName()
        productPage.productImage = self.products[indexPath.item].getImage()
        productPage.productPrice = self.products[indexPath.item].getPrice()
        productPage.productType = self.products[indexPath.item].getProductType()
        productPage.productType2 = self.products[indexPath.item].getType()
        productPage.productDescription = self.products[indexPath.item].getDescription()
        productPage.in_wishlist = self.products[indexPath.item].getInWishlist() == "true"
        self.presentWithCondition(controller: productPage, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == self.products.count - 5 && !self.productIsFetching) {
            let nextPage = self.currentPaged + 1
            fetchProducts(category: self.category_name, tag: self.product_tag, priceRange: self.product_price_range, paged: nextPage, shim: false)
        }
    }
}

extension ArchiveViewController: ProductCardDelegate {
    func addProductToCart(parent_id: String, type: String, attributes: JSON, variations: JSON) {
        if (type == "variable") {
            AttributesDialogViewController.showPopup(parentVC: self, attributes: attributes, variations: variations)
        } else {
            self.view.makeToast("Adding Product to cart...", position: .top)
            self.theCart.addToCart(productID: parent_id, quantity: 1, controller: self)
        }
    }
    
    func updateWishlist(product_id: String, action: String) {
        if (userSession.logged()) {
            self.doUpdateWishlist(user_id: userSession.ID, product_id: product_id, action: action)
        } else {
            self.view.makeToast("Please login first!")
        }
        
    }
}

extension ArchiveViewController: AddToCartDelegate, AddedToCartDialogDelegate {
    func cartAdded(totalItems: String, subTotal: String, total: String, json: JSON) {
        var style = ToastStyle()
        style.imageSize = CGSize(width: 20, height: 20)
        
        let totalItemsInt: Int = Int(totalItems) ?? 0
        
        if (totalItemsInt > 0) {
            self.cartNotification.text = totalItems
            self.cartNotification.isHidden = false
            self.view.makeToast("Product added to cart!", position: .top, image: UIImage(named: "icons8_checked"), style: style)
        } else {
            self.cartNotification.isHidden = true
        }
//        AddedToCartViewController.showPopup(parentVC: self, json: json)
        
    }
    
    func cartNotAdded(msg: String) {
        self.view.makeToast(msg)
    }
    
    func fromCartViewCartTapped() {
        self.cartController = CartViewController()
        self.presentWithCondition(controller: cartController, animated: true, completion: nil)
    }
    
    func fromCartCheckoutTapped() {
        self.cartController = CartViewController()
        self.presentWithCondition(controller: cartController, animated: true, completion: nil)
    }
    
    func fromCartContinueTapped() {
        self.dismissWithCondition(animated: true, completion: nil)
    }
    
}

extension ArchiveViewController: AttributesDialogDelegate {
    func addToCartFromAttributesDialog(product_id: String) {
        self.view.makeToast("Adding Product to cart...", position: .top)
        self.theCart.addToCart(productID: product_id, quantity: 1, controller: self)
    }
}


extension ArchiveViewController: FilterDelegate {
    func onFilterSubmit(category: String, tag: String, priceRange: Array<String>, size: String) {
        if (category.count > 0) {
            self.category_name = category
            self.categoryTitleLbl.text = category.capitalizingFirstLetter().replacingOccurrences(of: "-", with: " ")
            self.categoryDescription.text = "Category"
        }
        
        self.product_tag = tag
    
        if (priceRange.count > 1) {
            self.product_price_range = priceRange
        }
        
        if size.count > 0 {
            self.selected_size = size
        }
        
        self.currentPaged = 1 //reset to 1
      
        self.fetchProducts(category: self.category_name, tag: self.product_tag, priceRange: self.product_price_range, paged: self.currentPaged, shim: true, emptyProducts: true)
        
    }
}




