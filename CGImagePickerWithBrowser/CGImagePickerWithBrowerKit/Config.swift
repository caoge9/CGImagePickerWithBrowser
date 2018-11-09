//
//  Config.swift
//  CGImagePickerAndBrower
//
//  Created by Nvr on 2018/8/17.
//  Copyright © 2018年 CG. All rights reserved.
//

import Foundation
import UIKit

/// 是否开启print信息打印
public var CGPhotoAlbumEnableDebugOn = false

/// 导航条高度（不包含状态栏高度）默认44
public var CGNavigationHeight: CGFloat = 44

let CGScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let CGScreenHeight: CGFloat = UIScreen.main.bounds.size.height
let CGIsiPhoneX: Bool = UIScreen.instancesRespond(to: #selector(getter: UIScreen.currentMode)) && UIScreen.main.currentMode!.size == CGSize(width: 1125, height: 2436)
let CGStatusBarHeight: CGFloat = CGIsiPhoneX ? 44 : 20
let CGNavigationTotalHeight: CGFloat = CGStatusBarHeight + CGNavigationHeight
let CGHomeBarHeight: CGFloat = CGIsiPhoneX ? 34 : 0
