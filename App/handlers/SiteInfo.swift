//
//  SiteInfo.swift
//  WhatsDownApp
//
//  Created by Seun Oyeniyi on 1/15/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//

import UIKit

class SiteInfo: NSObject {
    var defaults = `UserDefaults`.standard
    
    var name: String = "WhatsDown"
    
    override init() {
        if let default_name = defaults.object(forKey: "name") {
            self.name = String(describing: default_name)
        }
    
    }
    
    
    func reload() {
        defaults = `UserDefaults`.standard //re-fetch defaults
        
        self.name = (defaults.object(forKey: "name") ?? self.name) as! String
    }
    
    func set(key: String, value: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    func is_banner_enabled(banner: String) -> Bool {
        if let banner_enabled = defaults.object(forKey: "banner_" + banner) {
            return banner_enabled as! Bool
        } else {
            return banner == "slide" //default is true for slide banner
        }
    }
    
    func set_banner_enable_value(banner: String, value: Bool) {
        defaults.set(value, forKey: "banner_" + banner)
        defaults.synchronize()
    }
    
    func enable_banner(banner: String) {
        defaults.set(true, forKey: "banner_" + banner)
        defaults.synchronize()
    }
    
    func disable_banner(banner: String) {
        defaults.set(false, forKey: "banner_" + banner)
        defaults.synchronize()
    }
    
    func set_last_check(last: Date) {
        defaults.set(last, forKey: "last_check")
        defaults.synchronize()
    }
    
    func get_last_check() -> Date {
        if let last_check = defaults.object(forKey: "last_check") {
            return last_check as! Date
        } else {
            return Date()
        }
    }
    
}

