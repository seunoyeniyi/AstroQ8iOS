//
//  ReviewsCollectionViewCell.swift
//  WhatsDownApp
//
//  Created by Seun Oyeniyi on 1/17/22.
//  Copyright © 2022 WhatsDown. All rights reserved.
//

import UIKit

class ReviewsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userRating: CosmosView!
    @IBOutlet var userComment: UILabel!
    @IBOutlet var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
