//
//  ActivityCell.swift
//  Yep
//
//  Created by zzzl on 2018/9/30.
//  Copyright © 2018年 Sinbane Inc. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var iconLB: UILabel!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var distanceLB: UILabel!
    @IBOutlet weak var timeLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImgView.layer.cornerRadius = 20
        userImgView.layer.masksToBounds = true
        
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        
        iconLB.textColor = UIColor.yepTintColor()
        iconLB.layer.borderWidth = 1
        iconLB.layer.borderColor = UIColor.yepTintColor().cgColor
        iconLB.layer.cornerRadius = 10
        iconLB.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
