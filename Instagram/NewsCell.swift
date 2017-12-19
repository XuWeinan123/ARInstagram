//
//  NewsCell.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/8.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avaImg.layer.cornerRadius = avaImg.frame.width/2
        self.avaImg.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
