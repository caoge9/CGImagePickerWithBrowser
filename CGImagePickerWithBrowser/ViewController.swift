//
//  ViewController.swift
//  CGImagePickerWithBrowser
//
//  Created by yj on 2018/10/29.
//  Copyright © 2018年 CaoDeDi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   var photos: [CGPhotoModel] = [] //存放返回的后的照片源
    var imgs: [UIImage] = [] //存放返回的image
    
    var clipImg: UIImage? //裁剪的照片
    
    @IBOutlet weak var clipimg: UIImageView!
    
    @IBOutlet weak var imgPicker: CGImagePickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         let imgP = CGImagePickerLayoutView(frame: CGRect(x: 0, y: 100, width: 350, height: 200))
         imgP.backgroundColor = .red
         view.addSubview(imgP)
         */
        
         // 删除：如果有其他删除操作在这里开始吧
        imgPicker.deletBlock = { [weak self] imgSouces, index in
            // 删除后的代理，这里要重新赋值你的存放集合
            if let imgdatas = imgSouces {
                self?.photos = imgdatas
                self?.imgs = imgdatas.map { $0.thumbnailImage! }
            }
        }
        /*
         // 图片预览：
           imgDatas :[CGPhotoModel] //图片源
           index：int  当前选择第几张
         */
        imgPicker.itemSelectBack = { [weak self] (index, imgSouces) in
                self?.showSelctImg(index: index)
        }
    }
    func showSelctImg(index: Int) {
        let photoPreviewVC = CGPhotoPreviewDeleteViewController()
        /*
         photoPreviewVC.setFirstOn = true
          //这是一个福利：项目需求有个设为封面有需要的可以用一下。此处本想不暴露在外面，但是考虑都有其他需求的操作所以还是 暴露出一个block，尽情享用吧
         photoPreviewVC.setFirstOne = { [weak self] (index, imgSouces) in
             //  print(index)
             //1、从新赋值数据源
                self?.photos = imgSouces
             //2、刷新imgPicker
             self?.imgPicker.dataSource = imgSouces
             self?.imgPicker.reloadView()
         }
        */
        
        photoPreviewVC.previewPhotoArray = photos //传入预览源，为[CGPhotoModel]，支持缩略图，原图和网络图
        /*
         // 想要自己转化的可以参考一下喽
         previewPhotoArray：[CGPhotoModel]
         let im = CGPhotoModel(thumbnailImage: nil, originImage: nil, imageURL: "your img url")
         let imgarr = [im]
         photoPreviewVC.previewPhotoArray = imgarr
         */
        photoPreviewVC.currentIndex = index
        photoPreviewVC.isAllowDelete = false
        self.navigationController?.pushViewController(photoPreviewVC, animated: true)
    }
    @IBAction func showImg(_ sender: Any) {
        goPickerController()
    }
    // 裁剪
    @IBAction func clip(_ sender: Any) {
        let photoAlbumVC = CGPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .clipPhoto)
        photoAlbumVC.clipBounds = CGSize(width: self.view.frame.width-40, height: self.view.frame.width-40) //自定义设置尺寸，默认是1：1的
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
    func  goPickerController() {
        // 如果你不想每次都是重新选的话，初始化可以在viewDidLoad里
        let photoAlbumVC = CGPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .selectPhoto)    //初始化需要设置代理对象
        photoAlbumVC.maxSelectCount = 9   //设置最大可选择张数
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
}

extension ViewController:  CGPhotoAlbumProtocol {
    //裁剪图片
    func photoAlbum(clipPhoto: UIImage?) {
        clipimg.image = clipPhoto //你想查看的话自己加手势然后调用showSelctImg()，记得转为CGPhotoModel
    }
    // 选择图片源
    func photoAlbum(selectPhotos: [CGPhotoModel]) {
        let imageArray = selectPhotos.map { $0.thumbnailImage! }
        imgs = imageArray // 拿到UIimage放起来使用吧
        photos = selectPhotos //赋值
        imgPicker.dataSource = selectPhotos
        imgPicker.numberOfLine = 4
        imgPicker.reloadView()
        imgPicker.addCallBack = { () in
            self.goPickerController()
        }
    }
}
// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    // 如果遇到选择器是添加在滑动视图上有用到手势的话需要实现UIGestureRecognizerDelegate不然点击图片无响应
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: imgPicker))! {
            return false
        }
        return true
    }
}
