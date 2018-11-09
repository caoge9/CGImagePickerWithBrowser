//
//  CGPhotoPreviewDeleteViewController.swift
//  CGImagePickerWithBrowser
//
//  Created by yj on 2018/10/29.
//  Copyright © 2018年 CaoDeDi. All rights reserved.
//

import UIKit
import Photos

public class CGPhotoPreviewDeleteViewController: CGBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// 当前展示第几张，默认0
    public var currentIndex = 0
    /// 浏览数据源
    public var previewPhotoArray: [CGPhotoModel] = []
    /// 是否支持删除，默认不支持
    public var isAllowDelete = true
    // 设为封面
    public var setFirstOn = false
    public var setFirstOne: ((_ index: Int, _ previewPhotoArray: [CGPhotoModel]) -> ())?
    var isStatusBarHidden = false //设置状态栏
    /// 删除闭包，设置该闭包后删除功能默认打开
    public var deleteClicked: ((_ photos: [CGPhotoModel], _ deleteIndex: Int) -> Void)? {
        didSet {
            if deleteClicked != nil {
                isAllowDelete = true
            }
        }
    }
    
    private let cellIdentifier = "PreviewCollectionCell"
    
    private var scrollDistance: CGFloat = 0
    
    private lazy var photoCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: CGScreenWidth+10, height: CGScreenHeight)
        flowLayout.scrollDirection = .horizontal
        //  collectionView
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: CGScreenWidth+10, height: CGScreenHeight), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        //  添加协议方法
        collectionView.delegate = self
        collectionView.dataSource = self
        //  设置 cell
        collectionView.register(CGPreviewCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        return collectionView
    }()
    @objc func setFirst() {
        previewPhotoArray.insert(previewPhotoArray[currentIndex], at: 0)
        previewPhotoArray.remove(at: currentIndex+1)
        self.setFirstOne?(self.currentIndex, previewPhotoArray)
        self.navigationController!.popViewController(animated: true)
    }
    // 设为封面
    private lazy var oriView: UIButton = {
        let btn = UIButton(frame: CGRect(x: (CGScreenWidth-70)/2, y: CGScreenHeight-50, width: 70, height: 33))
        btn.backgroundColor = UIColor.orange
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(setFirst), for: .touchUpInside)
        btn.setTitle("设为封面", for: .normal)
        return btn
    }()
    deinit {
        if CGPhotoAlbumEnableDebugOn {
            print("=====================\(self)未内存泄露")
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        if #available(iOS 11.0, *) {
            self.photoCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(self.photoCollectionView)
        if setFirstOn {
            self.view.addSubview(oriView)
        }
        self.initNavigation()
    }
    // 设置状态栏
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.photoCollectionView.selectItem(at: IndexPath(item: self.currentIndex, section: 0), animated: false, scrollPosition: .left)
        self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
    }
    

    override public func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            isStatusBarHidden = false
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    //  MARK:- private method
    private func initNavigation() {
        self.setBackNav()
        self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
        if isAllowDelete {
            self.setRightImageButton(normalImage: UIImage.CGImageFromeBundle(named: "album_photo_delete.png"), selectedImage: CGSelectSkinImage, isSelected: false)
        }
        self.view.bringSubview(toFront: self.naviView)
    }
    
    // handle events
    override func rightButtonClick(button: UIButton) {
        let deleteAlert = UIAlertController(title: nil, message: "确定要删除此照片吗？", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancleAction)
        let deleteAction = UIAlertAction(title: "删除", style: .default, handler: { [unowned self] (alertAction) in
            let deleteIndex = self.currentIndex
            self.previewPhotoArray.remove(at: self.currentIndex)
            self.photoCollectionView.deleteItems(at: [IndexPath(item: self.currentIndex, section: 0)])
            if self.currentIndex >= self.previewPhotoArray.count-1 {
                self.currentIndex = self.previewPhotoArray.count-1
            }
            self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
            if self.deleteClicked != nil {
                self.deleteClicked!(self.previewPhotoArray, deleteIndex)
            }
            if self.previewPhotoArray.count == 0 {
                self.navigationController!.popViewController(animated: true)
            }
        })
        deleteAlert.addAction(deleteAction)
        self.navigationController?.present(deleteAlert, animated: true, completion: nil)
    }
    
    func oneTapClick(tap: UITapGestureRecognizer) {
        var moveY = -CGNavigationTotalHeight
        if self.naviView.frame.origin.y < 0 {
            moveY = 0
        }
         isStatusBarHidden = !UIApplication.shared.isStatusBarHidden
        setNeedsStatusBarAppearanceUpdate()
        UIView.animate(withDuration: 0.25) {
            self.naviView.frame.origin.y = CGFloat(moveY)
        }
    }
    
    // MARK:- delegate
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.previewPhotoArray.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CGPreviewCollectionViewCell
        let photoTuple: CGPhotoModel = self.previewPhotoArray[indexPath.row]
        if let originImage = photoTuple.originImage {
            cell.photoImage = originImage
        } else if let imageURL = photoTuple.imageURL {
            if let thumbnailImage = photoTuple.thumbnailImage {
                cell.photoImage = thumbnailImage
            }
            let loading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            loading.center = CGPoint(x: cell.photoImageView.frame.width/2, y: cell.photoImageView.frame.height/2)
            loading.startAnimating()
            cell.photoImageView.addSubview(loading)
            cell.photoImageView.setWebImage(url: imageURL, defaultImage: photoTuple.thumbnailImage, isCache: true, downloadSuccess: { (image: UIImage?) in
                loading.removeFromSuperview()
                cell.photoImage = image
            })
        } else {
            cell.photoImage = photoTuple.thumbnailImage
        }
        cell.oneTapClosure = { [unowned self] (tap) in
            self.oneTapClick(tap: tap)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! CGPreviewCollectionViewCell).defaultScale = 1
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDistance = scrollView.contentOffset.x
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIndex = Int(round(scrollView.contentOffset.x/scrollView.bounds.width))
        if self.currentIndex >= self.previewPhotoArray.count {
            self.currentIndex = self.previewPhotoArray.count-1
        } else if self.currentIndex < 0 {
            self.currentIndex = 0
        }
        self.setNavTitle(title: "\(self.currentIndex+1)/\(self.previewPhotoArray.count)")
    }
}
