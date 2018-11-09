//
//  CGImagePickerLayoutView.swift
//  CGImagePickerWithBrowser
//
//  Created by yj on 2018/10/29.
//  Copyright © 2018年 CaoDeDi. All rights reserved.
//

import UIKit

public typealias CallBack = ()->()

public struct ItemSize {
    var width:CGFloat = 70
    var height:CGFloat = 70
    var minimumInteritemSpacing:CGFloat = 10
    var minimumLineSpacing:CGFloat = 10
}

public class CGImagePickerView: UIView {
    public typealias DeleteCallBack = (_ dataSource:[CGPhotoModel]?, _ index: Int)->()
    public typealias ItemSelectBack = (_ index: Int, _ dataSource:[CGPhotoModel]?)->()

    let cellIdentifier = "ImagePickerLayoutCollectionViewCellId"
    public var itemSize:ItemSize!
    public var space:CGFloat = 10
    public var datasourceHeight:CGFloat = 0
    var deletBlock: DeleteCallBack?
    var itemSelectBack: ItemSelectBack?
    
    private lazy var imageCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        //  collectionView
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        //  添加协议方法
        collectionView.delegate = self
        collectionView.dataSource = self
        //  设置 cell
        collectionView.register(UINib.init(nibName: "ImagePickerLayoutCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(UINib.init(nibName: "PlusCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PlusCollectionViewCellId")
        return collectionView
    }()
    
    //添加回调
    public var addCallBack:CallBack?
    //image个数
    public var dataSource:[CGPhotoModel]?
    //是否需要加号
    public var hiddenPlus = false
    //一行个数
    public var numberOfLine = 4 {
        didSet{
            
        }
    }
    //最大几个数
    public var maxNumber = 9
    public var hiddenDelete = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
}

//MARK:- UI
extension CGImagePickerView{
    override public func layoutSubviews() {
        super.layoutSubviews()
        for constanst in  self.constraints {
            let a: CGFloat = (dataSource?.count ?? 0) > 0 ? CGFloat((dataSource?.count)! + 1) : 0
            let lineNumber = ceilf(Float(a/CGFloat(numberOfLine)))
            constanst.constant = CGFloat(lineNumber) * (itemSize.width + 10.0)
            imageCollectionView.frame.size.width = self.frame.width
            imageCollectionView.frame.size.height = constanst.constant
        }
  
    }
    
    func setupView(){
        //初始化Collectview
        self.addSubview(imageCollectionView)
        itemSize = ItemSize()
    }

    public func reloadView(){
        let spaceNumber = CGFloat(numberOfLine) - 1
        let width =  (self.frame.size.width - (space * spaceNumber))/CGFloat(numberOfLine)
        itemSize = ItemSize.init(width:width , height: width, minimumInteritemSpacing: space, minimumLineSpacing: space)
        self.layoutSubviews()
        //照片最大的时候，隐藏加号
        if maxNumber == dataSource?.count {
            hiddenPlus = true
        }else{
            hiddenPlus = false
        }
        imageCollectionView.reloadData()
    }
}

//MARK:- UICollectionViewDelegate
extension CGImagePickerView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if hiddenPlus == true{
            return dataSource?.count ?? 0
        }else{
            return (dataSource?.count ?? 0) + 1
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row >= (dataSource?.count ?? 0)! {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"PlusCollectionViewCellId", for: indexPath) as? PlusCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:cellIdentifier, for: indexPath) as? ImagePickerLayoutCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.imageView.image = dataSource![indexPath.row].thumbnailImage
            cell.deleteCallBack = { () in
                self.dataSource?.remove(at: indexPath.row)
                 self.reloadView()
                self.deletBlock?(self.dataSource, indexPath.row)
            }
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= (dataSource?.count ?? 0)! { //加号按钮
            addCallBack?()
        }else{
            itemSelectBack?(indexPath.row, dataSource)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSize.minimumLineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSize.minimumInteritemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:itemSize.width, height: itemSize.height)
    }
}
