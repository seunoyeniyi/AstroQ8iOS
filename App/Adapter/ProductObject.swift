//
//  ProductObject.swift
//  MyShirtEg
//
//  Created by Seun Oyeniyi on 1/24/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//
import SwiftyJSON

class ProductObject {
    
    var id: String!
    var name: String!
    var image: String!
    var price: String!
    var regular_price: String!
    var product_type: String!
    var type: String!
    var description: String!
    var in_wishlist: String!
    var stock_status: String!
    var attributes: JSON!
    var variations: JSON!
    var categories: JSON!
    
    //setters
    func setID(value: String) {
        self.id = value
    }
    func setName(value: String) {
        self.name = value
    }
    func setImage(value: String) {
        self.image = value
    }
    func setPrice(value: String) {
        self.price = value
    }
    func setRegularPrice(value: String) {
        self.regular_price = value
    }
    func setProductType(value: String) {
        self.product_type = value
    }
    func setType(value: String) {
        self.type = value
    }
    func setDescription(value: String) {
        self.description = value
    }
    func setInWishlist(value: String) {
        self.in_wishlist = value
    }
    func setStockStatus(value: String) {
        self.stock_status = value
    }
    func setAttributes(value: JSON) {
        self.attributes = value
    }
    func setVariations(value: JSON) {
        self.variations = value
    }
    func setCategories(value: JSON) {
        self.categories = value
    }
    
    
    //GETTERS
    func getID() -> String {
        return self.id
    }
    func getName() -> String {
        return self.name
    }
    func getImage() -> String {
        return self.image
    }
    func getPrice() -> String {
        return self.price
    }
    func getRegularPrice() -> String {
        return self.regular_price
    }
    func getProductType() -> String {
        return self.product_type
    }
    func getType() -> String {
        return self.type
    }
    func getDescription() -> String {
        return self.description
    }
    func getInWishlist() -> String {
        return self.in_wishlist
    }
    func getStockStatus() -> String {
        return self.stock_status
    }
    func getAttributes() -> JSON {
        return self.attributes
    }
    func  getVariations() -> JSON {
        return self.variations
    }
    func  getCategories() -> JSON {
    return self.categories
    }
    
}
