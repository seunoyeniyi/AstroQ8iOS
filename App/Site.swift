//
//  Site.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/7/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import Foundation
class Site {
    public final let APP_NAME: String = "AstroQ8"
    public final let PROTOCOL: String = "https";
    public final let DOMAIN: String =  "astroq8.com"; //"192.168.43.11"; // "192.168.43.223"; //"10.0.2.2"; //
    public final let ADDRESS: String
    public final let INFO: String
    public final let CART: String
    public final let ADD_TO_CART: String
    public final let PRODUCTS: String
    public final let SIMPLE_PRODUCTS: String
    public final let PRODUCT: String
    public final let PRODUCT_VARIATION: String
    public final let LOGIN: String
    public final let REGISTER: String
    public final let USER: String
    public final let UPDATE_SHIPPING: String
    public final let UPDATE_CART_SHIPPING: String
    public final let CREATE_ORDER: String
    public final let UPDATE_COUPON: String
    public final let CHANGE_CART_SHIPPING: String
    public final let ORDERS: String
    public final let ORDER: String
    public final let UPDATE_ORDER: String
    public final let CATEGORIES: String
    public final let TAGS: String
    public final let UPDATE_WALLET_ADDRESS: String
    public final let WALLET_ADDRESS: String
    public final let PHUCK_GAMERS: String
    public final let ADD_TO_WISH_LIST: String
    public final let REMOVE_FROM_WISH_LIST: String
    public final let WISH_LIST: String
    public final let BANNERS: String
    public final let ATTRIBUTES: String
    public final let COMPLETE_ORDER_PAGE: String
    public final let APPLY_REWARD: String
    public final let SAVE_DEVICE: String
    public final let ADD_DEVICE: String
    public final let SEARCH: String
    public final let ADD_REVIEW: String

    
    init() {
        ADDRESS = PROTOCOL + "://" + DOMAIN + "/";
        CART = ADDRESS + "wp-json/skye-api/v2/cart/"; //v2
        ADD_TO_CART = ADDRESS + "wp-json/skye-api/v1/add-to-cart/";
        PRODUCTS = ADDRESS + "wp-json/skye-api/v1/products/";
        SIMPLE_PRODUCTS = ADDRESS + "wp-json/skye-api/v1/simple-products/";
        PRODUCT = ADDRESS + "wp-json/skye-api/v1/product/";
        INFO = ADDRESS + "wp-json/skye-api/v1/site-info/";
        PRODUCT_VARIATION = ADDRESS + "wp-json/skye-api/v1/product-variation/";
        LOGIN = ADDRESS + "wp-json/skye-api/v1/authenticate";
        REGISTER = ADDRESS + "wp-json/skye-api/v1/register/";
        USER = ADDRESS + "wp-json/skye-api/v1/user-info/";
        UPDATE_SHIPPING = ADDRESS + "wp-json/skye-api/v2/update-user-shipping-address/"; //v2
        UPDATE_CART_SHIPPING = ADDRESS + "wp-json/skye-api/v2/update-cart-shipping/"; //v2
        CREATE_ORDER = ADDRESS + "wp-json/skye-api/v2/create-order/"; //v2
        UPDATE_COUPON = ADDRESS + "wp-json/skye-api/v1/update-cart-coupon/";
        CHANGE_CART_SHIPPING = ADDRESS + "wp-json/skye-api/v2/change-cart-shipping-method/"; //v2
        ORDERS = ADDRESS + "wp-json/skye-api/v1/orders/";
        ORDER = ADDRESS + "wp-json/skye-api/v1/order/";
        UPDATE_ORDER = ADDRESS + "wp-json/skye-api/v1/update-order/";
        CATEGORIES = ADDRESS + "wp-json/skye-api/v1/categories/";
        TAGS = ADDRESS + "wp-json/skye-api/v1/tags/";
        UPDATE_WALLET_ADDRESS = ADDRESS + "wp-json/skye-api/v1/update-wallet-address/";
        WALLET_ADDRESS = ADDRESS + "wp-json/skye-api/v1/wallet-address/";
        PHUCK_GAMERS = ADDRESS + "wp-json/phuck-gamers/";
        ADD_TO_WISH_LIST = ADDRESS + "wp-json/skye-api/v1/add-to-wishlist/";
        REMOVE_FROM_WISH_LIST = ADDRESS + "wp-json/skye-api/v1/remove-from-wishlist/";
        WISH_LIST = ADDRESS + "wp-json/skye-api/v1/wishlists/";
        BANNERS = ADDRESS + "wp-json/skye-api/v1/banners/";
        ATTRIBUTES = ADDRESS + "wp-json/skye-api/v1/attributes/";
        COMPLETE_ORDER_PAGE = ADDRESS + "app-complete-order/";
        APPLY_REWARD = ADDRESS + "wp-json/skye-api/v1/apply-cart-reward/";
        SAVE_DEVICE = ADDRESS + "wp-json/skye-api/v1/save-user-device/";
        ADD_DEVICE = ADDRESS + "wp-json/skye-api/v1/add-device/";
        SEARCH = ADDRESS + "wp-json/skye-api/v1/search/";
        ADD_REVIEW = ADDRESS + "wp-json/skye-api/v1/add-review/";

    }
    


    public final let CURRENCY: String = "‎د.ك‎‎";
    public func payment_method_title(slug: String) -> String {
    var title: String = "";
    switch (slug) {
    case "cod":
    title = "Cash On Delivery";
    break;
    case "bacs":
    title = "Direct Bank Transfer";
    break;
    case "cheque":
    title = "Check Payments";
    break;
    case "paypal":
    title = "Paypal";
    break;
    case "stripe":
    title = "Stripe";
    break;
    case "stripe_cc":
    title = "Credit Cards";
    break;
    case "accept-kiosk":
        title = "Aman"
    break
    case "accept-wallet":
        title = "Mobile Wallet"
        break
    case "accept-sympl":
        title = "Sympl"
        break
    case "myfatoorah_v2":
        title = "Credit Card"
        break
    default:
    title = "No Payment method";
    break;

    }
    return title;
    }
    
    
    
}
