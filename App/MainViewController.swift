//
//  MainViewController.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/24/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift
import PINRemoteImage

class MainViewController: UIViewController {
    
    @IBOutlet var bannerCollectionView: UICollectionView!
    @IBOutlet var productCollectionView: UICollectionView!
    @IBOutlet var productCollectionViewHeightC: NSLayoutConstraint!
    @IBOutlet var bannerShimmer: ShimmerViewContainer!
    @IBOutlet var bannerRefreshBtn: UIButton!
    @IBOutlet var productsShimmer: ShimmerViewContainer!
    @IBOutlet var productRefreshBtn: UIButton!
    @IBOutlet var topCartBtn: UIBarButtonItem!
    @IBOutlet var splashLoadingView: UIView!
    @IBOutlet var splashLogo: UIImageView!
    @IBOutlet var signInContainer: UIView!
    @IBOutlet var signInContainerHeightC: NSLayoutConstraint!
    
    //Banners
    @IBOutlet var bigBannerCollectionView: UICollectionView!
    @IBOutlet var thinBannerCollectionView: UICollectionView!
    @IBOutlet var gridBannerCollectionView: UICollectionView!
    @IBOutlet var carouselBannerCollectionView: UICollectionView!
    @IBOutlet var videoBannerCollectionView: UICollectionView!
    
    
    //Banners constraints
    @IBOutlet var slideBannerHeightConstraint: NSLayoutConstraint! //150
    @IBOutlet var bigBannerHeightConstraint: NSLayoutConstraint! //350
    @IBOutlet var thinBannerHeightConstraint: NSLayoutConstraint! //100
    @IBOutlet var gridBannerHeightConstraint: NSLayoutConstraint! //120
    @IBOutlet var carouselBannerHeightConstraint: NSLayoutConstraint! //180
    @IBOutlet var videoBannerHeightConstraint: NSLayoutConstraint! //180
    
    
    
    
    
    
    
    let transition = SlideInTransition()
    var menuViewController: MenuViewController!
    let loginViewController = LoginViewController()
    var orderController = OrdersViewController()
    let profileAddress = ProfileAddressViewController()
    var browser = BrowserViewController()
    var searchController = SearchViewController()
    var shopController = ShopViewController()
    var productPage = ProductViewController()
    var cartController = CartViewController()
    var wishlistController = WishlistViewController()
    var archiveController = ArchiveViewController()
    var categoriesController = CategoriesViewController()
    
    var cartNotification: UILabel!
    
    //banners identifiers
    let bannerReuseIdentifier: String = "BannerCollectionViewCell"
    let bigBannerReuseIdentifier: String =  "BigBannerCollectionViewCell"
    let thinBannerReuseIdentifier: String = "ThinBannerCollectionViewCell"
    let gridBannerReuseIdentifier: String = "GridBannerCollectionViewCell"
    let carouselBannerReuseIdentifier: String = "CarouselBannerCollectionViewCell"
    let videoBannerReuseIdentifier: String = "VideoBannerCollectionViewCell"
    
    let productReuseIdentifier: String = "ProductCardCollectionViewCell"
    
    //banners arrays
    var banners: Array<Dictionary<String, String>> = []
    var bigBanners: Array<Dictionary<String, String>> = []
    var thinBanners: Array<Dictionary<String, String>> = []
    var gridBanners: Array<Dictionary<String, String>> = []
    var carouselBanners: Array<Dictionary<String, String>> = []
    var videoBanners: Array<Dictionary<String, String>> = []
    
    
    var products: Array<ProductObject> = []
    
    var defaultPaged = 1
    var currentPaged: Int = 1
    
    var productIsFetching = false
    
    let userSession = UserSession()
    let siteInfo = SiteInfo()

//    var introController = IntroViewController()
    var registerController = RegisterViewController()
    
    let theCart = AddToCart()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if (!userSession.logged()) {
        //    introController = IntroViewController()
        //    introController.delegate = self
        //    self.present(introController, animated: true, completion: nil)
        //}
      
        let gifImage = UIImage.gifImageWithName("loading")
        splashLogo.image = gifImage
        
        fetchSiteSettings()
    
        setupMenuController()
        self.setupNavLogo(theNavigationItem: self.navigationItem)
        self.removeNavBarBorder()
        
        loginViewController.delegate = self
        
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        
        bigBannerCollectionView.delegate = self
        bigBannerCollectionView.dataSource = self
        
        thinBannerCollectionView.delegate = self
        thinBannerCollectionView.dataSource = self
        
        gridBannerCollectionView.delegate = self
        gridBannerCollectionView.dataSource = self
        
        carouselBannerCollectionView.delegate = self
        carouselBannerCollectionView.dataSource = self
        
        videoBannerCollectionView.delegate = self
        videoBannerCollectionView.dataSource = self
        
        registerController.delegate = self
        
        theCart.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.size.width - 30, height: 265)
        self.productCollectionView.collectionViewLayout = layout
        let productCell = UINib(nibName: productReuseIdentifier, bundle: nil)
        self.productCollectionView.register(productCell, forCellWithReuseIdentifier: productReuseIdentifier)
        
        self.productCollectionView.delegate = self
        self.productCollectionView.dataSource = self
        
        setupCartNotification()
        
        
        //hide banners by defaults
        bigBannerHeightConstraint.constant = 0
        thinBannerHeightConstraint.constant = 0
        gridBannerHeightConstraint.constant = 0
        carouselBannerHeightConstraint.constant = 0
        videoBannerHeightConstraint.constant = 0
        
        bigBannerCollectionView.isHidden = true
        thinBannerCollectionView.isHidden = true
        gridBannerCollectionView.isHidden = true
        carouselBannerCollectionView.isHidden = true
        videoBannerCollectionView.isHidden = true
        
        if (need_checkup()) {
            self.splashLoadingView.isHidden = false
            fetchSiteSettings()
        } else {
            startView()
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func startView() {
        fetchAvailableBanners()
        fetchProducts(paged: defaultPaged, shim: true)
    }
    
    func setupMenuController() {
        transition.myDelegate = self
        self.modalPresentationStyle = .fullScreen
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        menuViewController.delegate = self
    }
    
    
    func fetchAvailableBanners() {
        if (siteInfo.is_banner_enabled(banner: "slide")) {
            
            self.bannerShimmer.isHidden = false
            self.bannerShimmer.startShimmering()
            self.bannerRefreshBtn.isHidden = true
            
            fetchForBanner(type: "slide", completion: { (banner_results) -> Void in
                self.banners = banner_results
                if (banner_results.count > 0) {
                    self.slideBannerHeightConstraint.constant = 150
                    self.bannerCollectionView.isHidden = false
                    self.bannerCollectionView.reloadData()
                } else {
                    self.slideBannerHeightConstraint.constant = 0
                }
                self.bannerShimmer.isHidden = true
                self.bannerRefreshBtn.isHidden = true
            })
        }
        
        
        if (siteInfo.is_banner_enabled(banner: "big")) {
            fetchForBanner(type: "big", completion: { (banner_results) -> Void in
                self.bigBanners = banner_results
                if (banner_results.count > 0) {
                    self.bigBannerCollectionView.reloadData()
                    self.bigBannerCollectionView.isHidden = false
                    self.bigBannerHeightConstraint.constant = 350
                } else {
                    self.bigBannerCollectionView.isHidden = true
                    self.bigBannerHeightConstraint.constant = 0
                }
            })
        }
        
        
        if (siteInfo.is_banner_enabled(banner: "thin")) {
            fetchForBanner(type: "thin", completion: { (banner_results) -> Void in
                self.thinBanners = banner_results
                if (banner_results.count > 0) {
                    self.thinBannerCollectionView.reloadData()
                    self.thinBannerCollectionView.isHidden = false
                    self.thinBannerHeightConstraint.constant = 180
                } else {
                    self.thinBannerCollectionView.isHidden = true
                    self.thinBannerHeightConstraint.constant = 0
                }
            })
        }
        if (siteInfo.is_banner_enabled(banner: "grid")) {
            fetchForBanner(type: "grid", completion: { (banner_results) -> Void in
                self.gridBanners = banner_results
                if (banner_results.count > 0) {
                    self.gridBannerCollectionView.reloadData()
                    self.gridBannerCollectionView.isHidden = false
                    self.gridBannerHeightConstraint.constant = 120
                } else {
                    self.gridBannerCollectionView.isHidden = true
                    self.gridBannerHeightConstraint.constant = 0
                }
            })
        }
        if (siteInfo.is_banner_enabled(banner: "carousel")) {
            fetchForBanner(type: "carousel", completion: { (banner_results) -> Void in
                self.carouselBanners = banner_results
                if (banner_results.count > 0) {
                    self.carouselBannerCollectionView.reloadData()
                    self.carouselBannerCollectionView.isHidden = false
                    self.carouselBannerHeightConstraint.constant = 180
                    self.startCarouselTimer()
                } else {
                    self.carouselBannerCollectionView.isHidden = true
                    self.carouselBannerHeightConstraint.constant = 0
                }
            })
        }
        
        
    }
    
    @objc func scrollCarouselToNextCell() {
        if let coll  = carouselBannerCollectionView {
            for cell in coll.visibleCells {
                let indexPath: IndexPath? = coll.indexPath(for: cell)
                if ((indexPath?.row)! < self.carouselBanners.count - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    
                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
                }
                
            }
        }
        
    }
    
    func startCarouselTimer() {
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.scrollCarouselToNextCell), userInfo: nil, repeats: true)
    }
    
    
    func fetchForBanner(type: String, completion: @escaping (_ banner_results: Array<Dictionary<String, String>>) -> Void) {
       
            if (!Connectivity.isConnectedToInternet) {
                self.view.makeToast("Bad internet connection!")
                if (type == "slide") {
                    self.bannerShimmer.isHidden = false
                    self.bannerShimmer.stopShimmering()
                    self.bannerRefreshBtn.isHidden = false
                }
                return
            }
            
        
        var returnBanners: Array<Dictionary<String, String>> = []
            
            
            let url = Site.init().BANNERS + "?type=" + type;
            
            Alamofire.Session.default.requestWithoutCache(url).responseJSON { (response) -> Void in
                //check if the result has a value
                if let json_result = response.value {
                    
                        let json = JSON(json_result)
                    //print(json)
                    let banners = json["results"]
                    
                    if (banners.count > 0) {
                        returnBanners = []
                        for (_, banner): (String, JSON) in banners {
                            returnBanners.append([
                                "title": banner["title"].stringValue,
                                "description": banner["description"].stringValue,
                                "image": banner["image"].stringValue,
                                "on_click_to": banner["on_click_to"].stringValue,
                                "category": banner["category"].stringValue,
                                "url": banner["url"].stringValue
                                ])
                        }
                        
                        DispatchQueue.main.async {
                            completion(returnBanners)
                        }
                        
             
                        
                    } else {
                        DispatchQueue.main.async {
                            completion(returnBanners)
                        }
                    }
                    
                   
                } else {
                    //no result
                    if (type == "slide") {
                        self.bannerShimmer.isHidden = false
                        self.bannerRefreshBtn.isHidden = false
                    }
                }
                
                if (type == "slide") {
                    self.bannerShimmer.stopShimmering()
                }
           
            }
        
        
    }
    
    
    
    func fetchProducts(paged: Int, shim: Bool) {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            if (shim) {
                self.productsShimmer.isHidden = false
                self.productsShimmer.stopShimmering()
                self.productRefreshBtn.isHidden = false
            }
            return
        }
        
        self.productIsFetching = true
        
        if (shim) {
            self.productsShimmer.isHidden = false
            self.productsShimmer.startShimmering()
            self.productRefreshBtn.isHidden = true
        }
        
        var url = Site.init().SIMPLE_PRODUCTS + "?orderby=popularity&hide_description=1&show_variation=1&per_page=20&paged=\(paged)";
        if (userSession.logged()) {
            url += "&user_id=" + userSession.ID;
        }
        
    
        Alamofire.Session.default.requestWithoutCache(url).responseJSON { (response) -> Void in
            //check if the result has a value

            if let json_result = response.value {
//                print(json_result);
                
                    let json = JSON(json_result)
//                    print(json)
                    let results = json["results"] //array
                    
                    self.products = []
                    for (_, subJson): (String, JSON) in results {
                        let id = subJson["ID"].stringValue;
                        let name = subJson["name"].stringValue;
                        let image = subJson["image"].stringValue;
                        let price = subJson["price"].stringValue;
                        let product_type = subJson["product_type"].stringValue;
                        let ptype = subJson["type"].stringValue;
                        let description = subJson["description"].stringValue;
                        let in_wishlist = subJson["in_wishlist"].stringValue;
                        //let categories = subJson["categories"].stringValue;
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
                        self.productCollectionViewHeightC.constant = CGFloat((265 + 10) * 10)
                        //                    self.productCollectionView.layoutIfNeeded()
                    }
                    
                    if json["pagination"].exists() {
                        if json["paged"].exists() {
                            self.currentPaged = Int(json["paged"].stringValue)!
                        }
                    }
                    //                print(json)
                    
                    if (shim) {
                        self.productsShimmer.isHidden = true
                        self.productsShimmer.stopShimmering()
                        self.productRefreshBtn.isHidden = true
                    }
                
                
            } else {
//                print("no result");
                //no result
                if (shim) {
                    self.productsShimmer.isHidden = false
                    self.productsShimmer.stopShimmering()
                    self.productRefreshBtn.isHidden = false
                }
            }
            //after every thing
            self.productIsFetching = false
        }
    }

    
 
    @IBAction func bannerRefreshTapped(_ sender: Any) {
        fetchAvailableBanners()
    }
    @IBAction func productRefreshTapped(_ sender: Any) {
        fetchProducts(paged: defaultPaged, shim: true)
    }
    
    @IBAction func newReleaseViewAllTapped(_ sender: Any) {
        shopController = ShopViewController()
        shopController.sort_by = "date"
        self.presentWithCondition(controller: shopController, animated: true, completion: nil)
    }
    
    @IBAction func trendingViewAllTapped(_ sender: Any) {
        let shopController = ShopViewController()
        shopController.sort_by = "popularity"
        self.presentWithCondition(controller: shopController, animated: true, completion: nil)
    }
    @IBAction func endViewAllTapped(_ sender: Any) {
        shopController = ShopViewController()
        self.presentWithCondition(controller: shopController, animated: true, completion: nil)
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        searchController = SearchViewController()
        if (self.isModal) {
            self.present(searchController, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(searchController, animated: true)
        }
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        //to avoid bad width sizing
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        menuViewController.delegate = self
        present(menuViewController, animated: true)
    }
    
    func login() {
        self.present(loginViewController, animated: true)
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
    
    
    func updateCartNotification() {
        
        let url = Site.init().CART + userSession.ID
        

        
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
        self.loginContainerCheck()
    }
    func loginContainerCheck() {
        if userSession.logged() {
            self.signInContainer.isHidden = true
            self.signInContainerHeightC.constant = 0
        } else {
            self.signInContainer.isHidden = false
            self.signInContainerHeightC.constant = 50
        }
    }
    
    
    func fetchSiteSettings() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.splashLoadingView.isHidden = true
            startView()
            return
        }
        
        
        self.splashLoadingView.isHidden = false
        
        
        
        let url = Site.init().INFO
        
        AF.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.value {
                
                    let json = JSON(json_result)
                    let site = json
//                    print(site)
                    self.siteInfo.set(key: "name", value: site["name"].stringValue)
                    self.siteInfo.set_banner_enable_value(banner: "slide", value: site["enable_slide_banners"].stringValue == "1")
                    self.siteInfo.set_banner_enable_value(banner: "big", value: site["enable_big_banners"].stringValue == "1")
                    self.siteInfo.set_banner_enable_value(banner: "carousel", value: site["enable_carousel_banners"].stringValue == "1")
                    self.siteInfo.set_banner_enable_value(banner: "thin", value: site["enable_thin_banners"].stringValue == "1")
                    self.siteInfo.set_banner_enable_value(banner: "grid", value: site["enable_grid_banners"].stringValue == "1")
                    self.siteInfo.set_banner_enable_value(banner: "video", value: site["enable_video_banners"].stringValue == "1")
                    
                    self.siteInfo.set_last_check(last: Date())
                }
            
            
            self.splashLoadingView.isHidden = true
            self.startView()
        }
    }
    
    func need_checkup() -> Bool {
        
        let last_check = siteInfo.get_last_check()
        let current_date = Date()
        let diffCompnents = Calendar.current.dateComponents([.hour], from: last_check, to: current_date)
        let diffHours = diffCompnents.hour
        if (diffHours! < 24) {
            return false; //continue presentation
        } else {
            return true; //fetch site settings first
        }
    }

    @IBAction func wishlistTapped(_ sender: Any) {
        if (!userSession.logged()) {
            self.login();
            return
        }
        self.wishlistController = WishlistViewController()
        self.presentWithCondition(controller: wishlistController, animated: true, completion: nil)
    }
    
    func styleThisBtn(btn: UIButton) {
        btn.layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 4.0
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        self.login()
    }
    @IBAction func signUpTapped(_ sender: Any) {
        self.register()
    }
    
    func register() {
        self.present(registerController, animated: true, completion: nil)
    }


}



extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.bannerCollectionView {
            return self.banners.count
        } else if collectionView == self.bigBannerCollectionView {
            return self.bigBanners.count
        } else if collectionView == self.thinBannerCollectionView {
            return self.thinBanners.count
        } else if collectionView == self.gridBannerCollectionView {
            return self.gridBanners.count
        } else if collectionView == self.carouselBannerCollectionView {
            return self.carouselBanners.count
        } else if collectionView == self.videoBannerCollectionView {
            return self.videoBanners.count
        } else if collectionView == self.productCollectionView {
            return self.products.count
        }
        
        return 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.bannerCollectionView { //for banner
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerReuseIdentifier, for: indexPath) as! BannerCollectionViewCell
            cell.bannerImage.pin_setImage(from: URL(string: self.banners[indexPath.row]["image"]!))
            cell.bannerTitle.text = (self.banners[indexPath.row]["title"]!).replacingOccurrences(of: "\\", with: "")
            cell.bannerDescription.text = (self.banners[indexPath.row]["description"]!).replacingOccurrences(of: "\\", with: "")
            
            return cell
        } else if (collectionView == self.bigBannerCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bigBannerReuseIdentifier, for: indexPath) as! BigBannerCollectionViewCell
            cell.bannerImage.pin_setImage(from: URL(string: self.bigBanners[indexPath.row]["image"]!))
            return cell
        } else if (collectionView == self.thinBannerCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: thinBannerReuseIdentifier, for: indexPath) as! ThinBannerCollectionViewCell
            cell.bannerImage.pin_setImage(from: URL(string: self.thinBanners[indexPath.row]["image"]!))
            return cell
        } else if (collectionView == self.gridBannerCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridBannerReuseIdentifier, for: indexPath) as! GridBannerCollectionViewCell
            cell.bannerImage.pin_setImage(from: URL(string: self.gridBanners[indexPath.row]["image"]!))
            cell.bannerImage.layer.cornerRadius = 5.0
            cell.bannerImage.clipsToBounds = true
            cell.bannerTitle.text = (self.gridBanners[indexPath.row]["title"]!).replacingOccurrences(of: "\\", with: "")
            return cell
        } else if (collectionView == self.carouselBannerCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: carouselBannerReuseIdentifier, for: indexPath) as! CarouselBannerCollectionViewCell
            cell.bannerImage.pin_setImage(from: URL(string: self.carouselBanners[indexPath.row]["image"]!))
            cell.bannerImage.layer.cornerRadius = 5.0
            cell.bannerImage.clipsToBounds = true
            return cell
        } else if (collectionView == self.videoBannerCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoBannerReuseIdentifier, for: indexPath) as! VideoBannerCollectionViewCell
            cell.bannerImage.pin_setImage(from: URL(string: self.videoBanners[indexPath.row]["image"]!))
            return cell
        } else if collectionView == self.productCollectionView { //else for product
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCardCollectionViewCell
            cell.parentView = self.view
            cell.cardDelegate = self
            cell.productID = self.products[indexPath.row].getID()
            cell.hasWishList = self.products[indexPath.row].getInWishlist() == "true"
            cell.productImage.pin_setImage(from: URL(string: self.products[indexPath.row].getImage()))
            cell.productTitle.text = self.products[indexPath.row].getName()
            
            //variable
            if self.products[indexPath.row].getProductType() == "variable" || self.products[indexPath.row].getType() == "variable" {
                cell.productPrice.text = "From " + Site.init().CURRENCY + PriceFormatter.format(price: self.products[indexPath.row].getPrice())
                cell.regularPrice.isHidden = true
            } else { //single product
                cell.productPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: self.products[indexPath.row].getPrice())
                
                let regularPriceAtt: NSMutableAttributedString = NSMutableAttributedString(string: Site.init().CURRENCY +  self.products[indexPath.row].getRegularPrice())
                regularPriceAtt.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, regularPriceAtt.length))
                cell.regularPrice.attributedText = regularPriceAtt
                cell.regularPrice.isHidden = false
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
//                cell.addToCartBtn.isHidden = true
            }
            
            //FOR THE ATTRIBUTES
            
            if self.products[indexPath.row].getProductType() == "variable" || self.products[indexPath.row].getType() == "variable" {
                
                cell.variations = self.products[indexPath.row].getVariations()
                
                cell.attributes = self.products[indexPath.row].getAttributes()
                
            }
                
            
            
            
            
            
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCardCollectionViewCell
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.bannerCollectionView {
            return CGSize(width: self.view.frame.size.width - 30, height: 150)
        } else if collectionView == self.bigBannerCollectionView {
            return CGSize(width: self.view.frame.size.width, height: 350)
        } else if collectionView == self.thinBannerCollectionView {
            return CGSize(width: self.view.frame.size.width, height: 100)
        } else if collectionView == self.gridBannerCollectionView {
            return CGSize(width: 100, height: 120)
        } else if collectionView == self.carouselBannerCollectionView {
            return CGSize(width: self.view.frame.size.width - 20, height: 180)
        } else if collectionView == self.videoBannerCollectionView {
            return CGSize(width: self.view.frame.size.width, height: 180)
        } else {
            return CGSize(width: (self.view.frame.size.width/2) - 25, height: 265)
        }
        
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
    func bannerClickedFromCollection(bannerDict: Dictionary<String, String>) {
        if (bannerDict["on_click_to"]! == "category") {
            let archiveController = ArchiveViewController()
            archiveController.category_name = bannerDict["category"]!
            var cat_title: String = bannerDict["category"]!
            cat_title = cat_title.capitalizingFirstLetter()
            cat_title = cat_title.replacingOccurrences(of: "-", with: " ")
            archiveController.category_title = cat_title
            archiveController.category_description = bannerDict["description"]!
            self.navigationController?.pushViewController(archiveController, animated: true)
        } else if (bannerDict["on_click_to"]! == "shop") {
            shopController = ShopViewController()
            self.presentWithCondition(controller: shopController, animated: true, completion: nil)
        } else if (bannerDict["on_click_to"]! == "url") {
            browser = BrowserViewController()
            browser.url = bannerDict["url"]!
            self.presentWithCondition(controller: browser, animated: true, completion: nil)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.bannerCollectionView) { //for banners
            bannerClickedFromCollection(bannerDict: self.banners[indexPath.row])
        } else if (collectionView == self.bigBannerCollectionView) {
            bannerClickedFromCollection(bannerDict: self.bigBanners[indexPath.row])
        } else if (collectionView == self.thinBannerCollectionView) {
            bannerClickedFromCollection(bannerDict: self.thinBanners[indexPath.row])
        } else if (collectionView == self.gridBannerCollectionView) {
            bannerClickedFromCollection(bannerDict: self.gridBanners[indexPath.row])
        } else if (collectionView == self.carouselBannerCollectionView) {
            bannerClickedFromCollection(bannerDict: self.carouselBanners[indexPath.row])
        } else if (collectionView == self.videoBannerCollectionView) {
            bannerClickedFromCollection(bannerDict: self.videoBanners[indexPath.row])
        } else { //for products
            
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
            
            
            return
        }
    }
    
    
}

extension MainViewController: ProductCardDelegate {
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

extension MainViewController: AttributesDialogDelegate {
    
    func addToCartFromAttributesDialog(product_id: String) {
        self.view.makeToast("Adding Product to cart...", position: .top)
        self.theCart.addToCart(productID: product_id, quantity: 1, controller: self)
    }
}

extension MainViewController: AddToCartDelegate, AddedToCartDialogDelegate {
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



//FOR MENU CONTROLLER
extension MainViewController: ModalDelegate {
    

    func menuItemsClicked(menuType: MenuType) {
        switch menuType {
        case .home:
//            fetchBanners()
            self.fetchProducts(paged: defaultPaged, shim: true)
        case .cancel:
            self.menuViewController.dismiss(animated: true, completion: nil)
            return
        case .login:
            self.login()
            return
        case .wishlist:
            wishlistController = WishlistViewController()
            self.presentWithCondition(controller: wishlistController, animated: true, completion: nil)
            return
        case .orders:
            if (self.userSession.logged()) {
                self.orderController = OrdersViewController()
                self.orderController.orderStatus = "all"
//                self.present(self.orderController, animated: true, completion: nil)
                self.navigationController?.pushViewController(orderController, animated: true)
            } else {
                self.view.makeToast("Please login first!")
            }
        case .account:
            if (self.userSession.logged()) {
                self.present(self.profileAddress, animated: true, completion: nil)
            } else {
                self.view.makeToast("Please login first!")
            }
            return
        case .support:
            self.browser = BrowserViewController()
            self.browser.headTitle = "Support"
            self.browser.url = Site.init().ADDRESS + "support?in_sk_app=1"
            self.present(self.browser, animated: true, completion: nil)
            return
        case .logout:
            self.userSession.logout()
            self.userSession.reload()
            self.fetchProducts(paged: 1, shim: true)
            self.loginContainerCheck()
        case .shop:
            self.shopController = ShopViewController()
            self.presentWithCondition(controller: self.shopController, animated: true, completion: nil)
        case .category:
            self.categoriesController = CategoriesViewController()
            self.presentWithCondition(controller: self.categoriesController, animated: true, completion: nil)
        case .blog:
            self.browser = BrowserViewController()
            self.browser.headTitle = "Blog"
            self.browser.url = Site.init().ADDRESS + "blog?in_sk_app=1"
            self.present(self.browser, animated: true, completion: nil)
        case .sales:
            self.archiveController = ArchiveViewController()
            self.archiveController.category_name = "sale"
            self.archiveController.category_title = "Sale"
            self.archiveController.category_description = "With Discount"
            self.presentWithCondition(controller: self.archiveController, animated: true, completion: nil)
        case .faq:
            self.browser = BrowserViewController()
            self.browser.headTitle = "FAQs"
            self.browser.url = Site.init().ADDRESS + "faqs?in_sk_app=1"
            self.present(self.browser, animated: true, completion: nil)
        case .contact:
            self.browser = BrowserViewController()
            self.browser.headTitle = "Contact"
            self.browser.url = Site.init().ADDRESS + "contact-us?in_sk_app=1"
            self.present(self.browser, animated: true, completion: nil)
        case .about:
            self.browser = BrowserViewController()
            self.browser.headTitle = "About"
            self.browser.url = Site.init().ADDRESS + "about-us?in_sk_app=1"
            self.present(self.browser, animated: true, completion: nil)
        }
    }
}

extension MainViewController: MySlideTransitionDelegate {
    func onBackTapped() { //on menu back tapped
        menuViewController.myDismiss()
    }
    
    
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return self.transition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return self.transition
    }
}

extension MainViewController: LoginDelegate, RegisterDelegate {
    func backToLogin() {
        self.login()
    }
    
    func onLoginDone(logged: Bool) {
        userSession.reload()
        fetchProducts(paged: defaultPaged, shim: true)
        if logged {
            self.signInContainer.isHidden = true
            self.signInContainerHeightC.constant = 0
        } else {
            self.signInContainer.isHidden = false
            self.signInContainerHeightC.constant = 50
        }
    }
    
    
    func onRegistrationDone(registered: Bool) {
        userSession.reload()
        fetchProducts(paged: defaultPaged, shim: true)
        if registered {
            self.signInContainer.isHidden = true
            self.signInContainerHeightC.constant = 0
        } else {
            self.signInContainer.isHidden = false
            self.signInContainerHeightC.constant = 50
        }
    }
}

extension MainViewController: IntroDelegate {
    func registerTapped() {
        self.register()
    }
    func loginTapped() {
        self.login()
    }
}




