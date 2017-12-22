//
//  PictureCell.swift
//  Instagram
//
//  Created by 徐炜楠 on 2017/11/2.
//  Copyright © 2017年 xuweinan. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    @IBOutlet weak var picImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let width = UIScreen.main.bounds.width
        picImg.frame = CGRect(x: 0, y: 0, width: 834/3, height: 834/3)
    }
}
