//
//  ESCarouselView.swift
//
//  Created by lforxeverc on 16/3/15.
//  Copyright © 2016年 jodo. All rights reserved.
//

import UIKit



class ESCarouselView :UIView{
    var timeInterval:NSTimeInterval = 2
    
    @IBInspectable
    var bgColor:UIColor = UIColor.whiteColor()
    
    @IBInspectable
    var Padding:CGFloat = 0
    
    weak var delegate:ESCarouselDelegate?
    
    @IBInspectable
    var rawURLs:[String]?
    
    private var itemWidth:CGFloat{
        get{
            return self.frame.size.width
        }
    }
    private var scrollView:UIScrollView = UIScrollView()
    private var pageControl:UIPageControl = UIPageControl()
    private var currentPosition:Int = 0 {
        didSet{
            delegate?.onCarouselItemChange?(currentPosition)
            pageControl.currentPage = currentPosition
            
        }
    }
    private var lastAutoPosition:Int = -1
    
    private var data:[ESCarouselItem]?
    private var timer:NSTimer?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addImageNotification()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addImageNotification()
        
    }
    
    convenience init(frame:CGRect,delegate:ESCarouselDelegate){
        self.init(frame: frame)
        self.delegate = delegate
        addImageNotification()
    }
    
    deinit{
        self.timer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ESConstant.ESImageDataUpdateNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "image")
    }
    override func drawRect(rect: CGRect) {
        print("drawRect")
        
        if self.rawURLs == nil || self.rawURLs!.count <= 0 {return}
        self.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.frame = CGRect(x: 0, y: 0, width: itemWidth, height: self.bounds.height)
        self.addSubview(scrollView)
        data = [ESCarouselItem]()
        var x:CGFloat = 0
        var i = 0
        for (;i<rawURLs!.count;i++) {
            let iv = UIImageView(frame: CGRect(x: x + Padding, y: CGFloat(0), width: itemWidth - (2 * Padding), height: self.bounds.height))
            print("iv = \(iv.frame) self = \(self.frame)")
            iv.contentMode = UIViewContentMode.ScaleToFill
            iv.backgroundColor = bgColor
            iv.userInteractionEnabled = true
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onItemTap:"))
            let activityView = UIActivityIndicatorView()
            activityView.center = CGPointMake(iv.bounds.size.width / 2, iv.bounds.size.height / 2)
            activityView.sizeToFit()
            activityView.color = UIColor.lightGrayColor()
            iv.addSubview(activityView)
            activityView.startAnimating()
            scrollView.addSubview(iv)
            x = itemWidth + x
            let item = ESCarouselItem(imageURL:self.rawURLs![i],index: i,imageview:iv,indicator:activityView)
            data?.append(item)
            item.load()
        }
        scrollView.contentSize =  CGSizeMake(x, self.bounds.height)
        scrollView.backgroundColor = bgColor
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        pageControl.numberOfPages = data!.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.yellowColor()
        
        pageControl.addTarget(self, action: "pageChange:", forControlEvents: .ValueChanged)
        pageControl.sizeToFit()
        pageControl.center = CGPointMake(self.center.x, self.frame.origin.y + self.bounds.height - pageControl.bounds.height / 2)
        self.superview?.addSubview(pageControl)
        switchAuto()
        
    }
    
    func setAdapter(urlData:[String]){
        self.rawURLs = urlData
        
    }
    
    
    func pageChange(pc:UIPageControl){
        showAt(pc.currentPage)
    }
    
    func onItemTap(gest:UITapGestureRecognizer){
        
        delegate?.onCarouselItemTap(currentPosition, currentView: gest.view! as! UIImageView)
        
    }
    private func shouldAutoChange()->Bool{
        if currentPosition == lastAutoPosition {
            lastAutoPosition = lastAutoPosition++ % (data?.count)!
            return true
        }
        lastAutoPosition = currentPosition % data!.count
        return false
        
    }
    
    private func switchAuto(){
        timer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: "autouChange", userInfo: nil, repeats: true)
    }
    func autouChange(){
        if !shouldAutoChange(){
            return
        }
        if currentPosition >= data!.count - 1 {
            currentPosition = 0
            
        }
        else{
            currentPosition++
        }
        
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(currentPosition) * itemWidth, y: 0, width: itemWidth, height: self.bounds.height), animated: true)
        
    }
    private func addImageNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageDataUpdate:", name: ESConstant.ESImageDataUpdateNotification, object: nil)
    }
    
    private func showAt(index:Int){
        currentPosition = index
        scrollView.scrollRectToVisible(CGRect(x: CGFloat(currentPosition) * itemWidth, y: 0, width: itemWidth, height: self.bounds.height), animated: true)
    }
    
    func imageDataUpdate(no:NSNotification){
        if data == nil || data?.count == 0 {return}
        let url:String = no.userInfo!["url"] as! String
        let state:Int = no.userInfo!["state"] as! Int
        let index:Int = (rawURLs?.indexOf(url))!
        if index >= self.data?.count {return}
        var item = self.data![index]
        if state == ESConstant.ESImageDataFetchSuccess {
            let data = no.userInfo!["data"] as! NSData
            item.image = UIImage(data: data)
            item.status = ImageViewStatus.Fetched
            
        }
        else{
            item.status = ImageViewStatus.Error
            
        }
    }
    
}
@objc protocol ESCarouselDelegate{
    func onCarouselItemTap(position:Int,currentView:UIImageView)
    optional func onCarouselItemChange(position:Int)
}

extension ESCarouselView : UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentPosition = Int(scrollView.contentOffset.x / self.bounds.size.width)
        
    }
    
}


class ESErrorView: UIView {
    override func drawRect(rect: CGRect) {
        let layout = CAShapeLayer()
        let width = self.bounds.width
        let height = self.bounds.height
        let radius = height * 0.2
        let cosP4 = radius * CGFloat(cos(M_PI_4))
        let sinP4 = radius * CGFloat(sin(M_PI_4))
        let biz = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5)
        biz.moveToPoint(CGPoint(x: width * 0.5, y: height * 0.3))
        biz.addArcWithCenter(CGPoint(x: width / 2, y: height / 2), radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI_2 * 3), clockwise: true)
        biz.moveToPoint(CGPoint(x: width / 2 - cosP4, y: height / 2 - sinP4))
        biz.addLineToPoint(CGPoint(x: width / 2 + cosP4, y: height / 2 + sinP4))
        biz.moveToPoint(CGPoint(x: width / 2 + cosP4, y: height / 2 - sinP4))
        biz.addLineToPoint(CGPoint(x: width / 2 - cosP4, y: height / 2 + sinP4))
        layout.strokeColor = UIColor.lightGrayColor().CGColor
        layout.fillColor = UIColor.clearColor().CGColor
        layout.lineWidth = 3
        layout.path = biz.CGPath
        self.layer.addSublayer(layout)
        let morph = CABasicAnimation(keyPath: "strokeEnd")
        morph.duration = 1;
        morph.fromValue = 0.0
        morph.toValue = 1.0
        morph.autoreverses = false
        layout.addAnimation(morph, forKey: nil)
        
        
    }
}






