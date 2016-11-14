//
//  ViewController.swift
//  RbannerViewTest
//
//  Created by ref on 2016/11/14.
//  Copyright © 2016年 ref. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BannerDelegate {
    
    var bannerImgsAry:[UIImage]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBannerView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setBannerView() {
        let bannerView: RBannerView = RBannerView(frame: CGRect.init(x: 0, y: 60, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 0.5))
        for var i:Int in 0..<3 {
            bannerImgsAry.append(UIImage(named: "image" + "\(i)")!)
        }
        
        bannerView.bannerDelegate = self
        bannerView.setBannerImages(images: bannerImgsAry)
        view.addSubview(bannerView)
        
    }
    
    //轮播图代理，处理点击事件
    func clickOneBannerAction(currentPage: Int) {
        print("点击了第\(currentPage + 1)张图片")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

