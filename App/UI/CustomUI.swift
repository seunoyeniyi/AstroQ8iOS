//
//  CustomUI.swift
//  SkyeCommerce
//
//  Created by Seun Oyeniyi on 12/23/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit



@IBDesignable
class StyleButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            setupView()
        }
    }
    override func awakeFromNib() {
        setupView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    func setupView() {
        self.layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = cornerRadius
    }
}

class CustomButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            setupView()
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            setupView()
        }
    }
    override func awakeFromNib() {
        setupView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    func setupView() {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
}



