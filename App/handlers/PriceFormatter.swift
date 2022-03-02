//
//  PriceFormatter.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/9/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import Foundation

class PriceFormatter {
    public static func format(price: String) -> String {
        var priceDouble: Double = 0;
        if (price.count > 0) {
            priceDouble = Double(price)!
        }
        
        //back to double
        let toDouble = Double(String(format: "%.2f", priceDouble))
        
        var ret = (toDouble?.formattedWithSeparator)!
        
        //issue from astroq8
        let arr = ret.components(separatedBy: ".")
        if (arr.count > 1) {
            if (arr[1].count == 1) {
                ret = ret + "00"
            } else if (arr[1].count == 2) {
                ret = ret + "0"
            }
        } else {
            ret = ret + ".000"
        }
        //issue from astroq8 - will be removed for other projects
        
        return ret
    }
    
    public static func format(price: Double) -> String {
        //back to double
        let toDouble = Double(String(format: "%.2f", price))
        
        return (toDouble?.formattedWithSeparator)!
    }
}

extension Double {
    mutating func roundToPlaces(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}
