//
//  FilterViewController.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/26/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import WARangeSlider
import iOSDropDown
import Alamofire
import SwiftyJSON

protocol FilterDelegate {
    func onFilterSubmit(category: String, tag: String, priceRange: Array<String>, size: String)
}

class FilterViewController: UIViewController {
    
    var delegate: FilterDelegate?
   
//    @IBOutlet var cateogryDropDown: DropDown!
//    @IBOutlet var categoryActivity: UIActivityIndicatorView!
    @IBOutlet var sizeDropDown: DropDown!
    @IBOutlet var sizeActivity: UIActivityIndicatorView!
    @IBOutlet var kidSizeActivity: UIActivityIndicatorView!
    @IBOutlet var sliderViewContainer: UIView!
    @IBOutlet var priceRangeLbl: UILabel!
    
    @IBOutlet var sizeContainer: UIView!
    
    @IBOutlet var sizeHeightC: NSLayoutConstraint!
    
    
    let priceSlider = RangeSlider()
    let maximumPrice = 1500.0
    let initialLower = 100.0
    let initialUpper = 1400.0
    
    var categories: Array<Dictionary<String, String>> = []
    var categoriesString: Array<String> = []
    var tags: Array<Dictionary<String, String>> = []
    var tagsString: Array<String> = []
    var sizes: Array<Dictionary<String, String>> = []
    var sizesString: Array<String> = []
    
    var selected_category = ""
//    var selected_tag = ""
    var selected_size = ""
    var filter_type: String = "normal"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceRangeLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: initialLower) + "  - " + Site.init().CURRENCY + PriceFormatter.format(price: initialUpper)

        priceSlider.frame = CGRect(x: 0, y: 0, width: sliderViewContainer.frame.width, height: sliderViewContainer.frame.height)
        priceSlider.minimumValue = 0.0
        priceSlider.maximumValue = maximumPrice
        priceSlider.lowerValue = initialLower
        priceSlider.upperValue = initialUpper
        priceSlider.trackHighlightTintColor = UIColor(named: "Primary")!
        priceSlider.thumbTintColor = UIColor(named: "Primary")!
        priceSlider.thumbBorderColor = UIColor(named: "Primary")!
        sliderViewContainer.addSubview(priceSlider)

        priceSlider.addTarget(self, action: #selector(self.priceSliderValueChanged(_:)), for: .valueChanged)
        
        
        
//        cateogryDropDown.didSelect{(selectedText, index, id) in
//            self.selected_category = self.categories[index]["slug"]!
//        }
        sizeDropDown.didSelect{(selectedText, index, id) in
            self.selected_size = self.sizes[index]["slug"]!
        }
        
//       fetchCategories()
//        fetchSizes()
//        fetchKidSizes()
    }
    
//    func fetchCategories() {
//
//        self.categoryActivity.isHidden = false
//
    //        let url = Site.init().CATEGORIES + "?hide_empty=1&order_by=menu_order" + Site.init().TOKEN_KEY_APPEND;
//
//        AF.request(url).responseJSON { (response) -> Void in
//            //check if the result has a value
//            if let json_result = response.value {
//
//                    let json = JSON(json_result)
//
//                self.categories = []
//                for (_, parent): (String, JSON) in json {
//                    self.categories.append([
//                        "name": parent["name"].stringValue,
//                        "slug": parent["slug"].stringValue
//                        ])
//                    self.categoriesString.append(parent["name"].stringValue)
//                }
//
//                self.cateogryDropDown.optionArray = self.categoriesString
//
//
//            } else {
//                self.view.makeToast("No Category")
//            }
//            self.categoryActivity.isHidden = true
//        }
//
//    }
    
    func fetchSizes() {
     
        
        self.sizeActivity.isHidden = false
        
        let url = Site.init().ATTRIBUTES + "?name=size" + Site.init().TOKEN_KEY_APPEND;
        
        AF.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.value {
                
                let json = JSON(json_result)
                let terms = json["terms"]
                
                self.sizes = []
                self.sizesString = []
                for (_, term): (String, JSON) in terms {
                    self.sizes.append([
                        "name": term["name"].stringValue,
                        "taxonomy": term["taxonomy"].stringValue,
                        "slug": term["slug"].stringValue
                        ])
                    self.sizesString.append(term["name"].stringValue)
                }
                
                self.sizeDropDown.optionArray = self.sizesString
                
            } else {
                self.view.makeToast("No Sizes")
            }
            self.sizeActivity.isHidden = true
        }
        
    }


    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func priceSliderValueChanged(_ rangeSlider: RangeSlider) {
        self.priceRangeLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: rangeSlider.lowerValue) + " -  " + Site.init().CURRENCY + PriceFormatter.format(price: rangeSlider.upperValue)
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if let delegate = self.delegate {
                var priceRange: Array<String> = [String(format: "%.2f", self.priceSlider.lowerValue), String(format: "%.2f", self.priceSlider.upperValue)]
                
                if (self.priceSlider.lowerValue == self.initialLower && self.priceSlider.upperValue == self.initialUpper) {
                    priceRange = []
                }
                
//                if (self.cateogryDropDown.text?.isEmpty)! {
//                    self.selected_category = ""
//                }
                //todo later: causing empty return
                if (self.sizeDropDown.text?.isEmpty)! {
                    self.selected_size = ""
                }
                
                delegate.onFilterSubmit(category: self.selected_category, tag: "", priceRange: priceRange, size: self.selected_size)
            }
        })
    }

}
