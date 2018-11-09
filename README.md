# CGImagePickerWithBrowser
![image](https://github.com/caoge9/CGImagePickerWithBrowser/CGimge/预览.png) 
// 预览
func showSelctImg(index: Int) {
    let photoPreviewVC = CGPhotoPreviewDeleteViewController()
    photoPreviewVC.previewPhotoArray = photos //传入预览源，为[CGPhotoModel]，支持缩略图，原图和网络图
    photoPreviewVC.currentIndex = index
    photoPreviewVC.isAllowDelete = false
    self.navigationController?.pushViewController(photoPreviewVC, animated: true)
}

// 裁剪
@IBAction func clip(_ sender: Any) {
    let photoAlbumVC = CGPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .clipPhoto)
    photoAlbumVC.clipBounds = CGSize(width: self.view.frame.width-40, height: self.view.frame.width-40) //自定义设置尺寸，默认是1：1的
    self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
}
// 选择照片
func  goPickerController() {
    // 如果你不想每次都是重新选的话，初始化可以在viewDidLoad里
    let photoAlbumVC = CGPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .selectPhoto)    //初始化需要设置代理对象
    photoAlbumVC.maxSelectCount = 9   //设置最大可选择张数
    self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
}
// 选择和裁剪后的代理，这里获得新的图片
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
