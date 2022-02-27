//
//  ProductCardCollectionViewCell.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/24/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ProductCardDelegate {
    func updateWishlist(product_id: String, action: String)
    func addProductToCart(parent_id: String, type: String, attributes: JSON, variations: JSON)
}

class ProductCardCollectionViewCell: UICollectionViewCell {
    
    var cardDelegate: ProductCardDelegate?
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var productPrice: UILabel!
    @IBOutlet var wishListBtn: WishListButton!
//    @IBOutlet var addToCartBtn: UIButton!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var regularPrice: UILabel!
    
    var cartNotification: UILabel!
    
    var productID: String!
    var productType: String!
    var hasWishList: Bool = false
    var parentView: UIView!
    
    var selectedOptions: Dictionary<String, String> = [:]
    var attributes: JSON = JSON.null
    var variations: JSON = JSON.null
    
    var cartProductID: String = "0"
    
    let userSession = UserSession()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func wishListBtnTapped(_ sender: WishListButton) {

        userSession.reload()
        if (!userSession.logged()) {
            parentView.makeToast("Please login first!")
            return
        }
        if (hasWishList) {
            self.cardDelegate?.updateWishlist(product_id: productID, action: "remove")
            hasWishList = false
            wishListBtn.setImage(UIImage(named: "icons8_heart_outline"), for: .normal)
        } else {
            self.cardDelegate?.updateWishlist(product_id: productID, action: "add")
            hasWishList = true
            wishListBtn.setImage(UIImage(named: "icons8_heart_outline_1"), for: .normal)
        }
    }
    
    
    
    @IBAction func addToCartTapped(_ sender: Any) {
        if let delegate = self.cardDelegate {
            delegate.addProductToCart(parent_id: productID, type: productType, attributes: attributes, variations: variations)
        }
    }
    
    
}
