//
//  IntroViewController.swift
//  WhatsDownApp
//
//  Created by Seun Oyeniyi on 1/18/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//

import UIKit

protocol IntroDelegate {
    func registerTapped()
    func loginTapped()
}

class IntroViewController: UIViewController {

    var delegate: IntroDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func registerTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            self.delegate?.registerTapped()
        })
    }
    @IBAction func loginTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            self.delegate?.loginTapped()
        })
    }
    
    

   

}
