//
//  ImagePickerLayoutCollectionViewCell.swift
//  CGImagePickerWithBrowser
//
//  Created by yj on 2018/10/29.
//  Copyright © 2018年 CaoDeDi. All rights reserved.
//

import UIKit

class ImagePickerLayoutCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    var deleteCallBack:CallBack?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func deteBtnClick(_ sender: UIButton) {
        deleteCallBack!()
    }
}
