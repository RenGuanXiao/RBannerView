//
//  RBannerView.swift
//  Diamond
//
//  Created by ref on 16/10/19.
//  Copyright © 2016年 ref. All rights reserved.
//

/*
 * infinite scroll banner, use imageView and scrollView
 */

import UIKit

//点击的代理方法
protocol BannerDelegate {

    func clickOneBannerAction(currentPage:Int)
}

class RBannerView: UIView, UIScrollViewDelegate, UIPageViewControllerDelegate {
    
    var bottomScrollView:UIScrollView!
    var pageView:UIPageControl!
    var self_height:CGFloat!
    
    //  scroll imageView
    var leftImageView:UIImageView!
    var midImageView:UIImageView!
    var rightImageView:UIImageView!
    fileprivate var imageAry = [UIImage]()
    
    public var bannerDelegate:BannerDelegate?
    var tap:UITapGestureRecognizer!
    
    var totalPage:Int!//banner个数
    var currentIndex:Int = 0//当前显示的位置
    
    var gcd_timer:DispatchSourceTimer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self_height = frame.size.height
        
        self.setUpBannerView()
        
    }
    
    fileprivate func startTimer() {
        
        gcd_timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        gcd_timer.scheduleRepeating(deadline: DispatchTime.now() + 3, interval: DispatchTimeInterval.seconds(3))
        gcd_timer.setEventHandler { [weak self] in
            
            self?.timerFire()
            
        }
        gcd_timer.resume()
        
    }
    
    fileprivate func setUpBannerView() {

        //  scroll container
        bottomScrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self_height))
        
        // always shwo midImageView
        bottomScrollView.setContentOffset(CGPoint.init(x: SCREEN_WIDTH, y: 0), animated: false)
        bottomScrollView.showsVerticalScrollIndicator = false
        bottomScrollView.showsHorizontalScrollIndicator = false
        bottomScrollView.isPagingEnabled = true
        bottomScrollView.bounces = false
        bottomScrollView.delegate = self
        bottomScrollView.backgroundColor = UIColor.gray
        // 三个图片容器
        leftImageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: self_height))
        midImageView = UIImageView(frame: CGRect.init(x: SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: self_height))
        rightImageView = UIImageView(frame: CGRect.init(x: SCREEN_WIDTH * 2, y: 0, width: SCREEN_WIDTH, height: self_height))
        
        //点击banner触发的方法
        midImageView.isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(self.clickOneBanner(currentPage:)))
        midImageView.addGestureRecognizer(tap)

        // pagecontrol
        pageView = UIPageControl()
        pageView.frame.size = CGSize.init(width: SCREEN_WIDTH, height: 6)
        pageView.center = self.center
        pageView.frame.origin.y = self_height - 15
        pageView.numberOfPages = 5
        pageView.currentPageIndicatorTintColor = UIColor.red

        self.addSubview(bottomScrollView)
        self.addSubview(pageView)
        bottomScrollView.addSubview(leftImageView)
        bottomScrollView.addSubview(midImageView)
        bottomScrollView.addSubview(rightImageView)
        self.startTimer()
        
    }
    
    //初始化banner内容
    func setBannerImages(images:[UIImage]) {
        imageAry = images
        totalPage = images.count
        if totalPage > 2 {
            leftImageView.image = images[images.count - 1]
            midImageView.image = images[0]
            rightImageView.image = images[1]
            
            bottomScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH * 3, height: self_height)
        }else if totalPage == 2 {
            leftImageView.image = images[1]
            midImageView.image = images[0]
            rightImageView.image = images[1]
            bottomScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH * 3, height: self_height)
        }
        if totalPage == 1 {
            leftImageView.image = images[0]
            bottomScrollView.contentSize = CGSize.init(width: SCREEN_WIDTH, height: self_height)
        }
        pageView.numberOfPages = Int(totalPage)
        
    }
    //用来改变图片
    func changeImage(index:Int, isRightScroll:Bool) {
        //左滑
        if !isRightScroll {
            if index < totalPage - 2 {
                leftImageView.image = imageAry[index]
                midImageView.image = imageAry[index + 1]
                rightImageView.image = imageAry[index + 2]
                return
            }
            if index == totalPage - 2 {
                leftImageView.image = imageAry[index]
                midImageView.image = imageAry[index + 1]
                rightImageView.image = imageAry[0]
                return
            }
            if index == totalPage - 1 {
                leftImageView.image = imageAry[index]
                midImageView.image = imageAry[0]
                rightImageView.image = imageAry[1]
                return
            }
        }
        //右滑
        else {
            if index == 0 {
                leftImageView.image = imageAry[totalPage - 2]
                midImageView.image = imageAry[totalPage - 1]
                rightImageView.image = imageAry[0]
                return
            }
            
            if index == 1 {
                leftImageView.image = imageAry[totalPage - 1]
                midImageView.image = imageAry[index - 1]
                rightImageView.image = imageAry[index]
            }else {
                leftImageView.image = imageAry[index - 2]
                midImageView.image = imageAry[index - 1]
                rightImageView.image = imageAry[index]
            }
   
        }
    }

    // 滚动视图的代理，只处理用户手动滚动的情况，不设计自动滚动的情况
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 向左滑
        if scrollView.contentOffset.x == SCREEN_WIDTH * 2 {
            self.changeImage(index: currentIndex, isRightScroll: false)
            if currentIndex < totalPage - 1 {
                currentIndex += 1
            }else {
                currentIndex = 0
            }
            pageView.currentPage = currentIndex
        }
    
        // 向右滑
        if scrollView.contentOffset.x == 0 {
            self.changeImage(index: currentIndex, isRightScroll: true)
            if currentIndex == 0  {
                currentIndex = totalPage - 1
            }else {
                currentIndex -= 1
            }
            pageView.currentPage = currentIndex
        }
        scrollView.setContentOffset(CGPoint.init(x: SCREEN_WIDTH, y: 0), animated: false)
        
        
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gcd_timer.cancel()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startTimer()
    }
    
    func clickOneBanner(currentPage number:Int) {
        let page = pageView.currentPage
        if (self.bannerDelegate != nil) {
            self.bannerDelegate?.clickOneBannerAction(currentPage: page)
        }
    }
    
    //用来处理滚动视图的偏移量，改变图片
    func timerFire() {
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
                self?.bottomScrollView.contentOffset.x = SCREEN_WIDTH * 2
                self?.midImageView.isUserInteractionEnabled = false
            
        }, completion: {[weak self] (bool) in
            
            self?.changeImage(index: (self?.currentIndex)!, isRightScroll: false)
            
                if (self?.currentIndex)! < (self?.totalPage)! - 1 {
                        self?.currentIndex += 1
                }else {
                        self?.currentIndex = 0
                    }
            self?.pageView.currentPage = (self?.currentIndex)!

            self?.bottomScrollView.contentOffset = CGPoint.init(x: SCREEN_WIDTH, y: 0)
            self?.midImageView.isUserInteractionEnabled = true
        
        })
   
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
