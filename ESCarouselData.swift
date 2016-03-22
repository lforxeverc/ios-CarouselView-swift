//
//  ESCarouselData.swift
//
//  Created by lforxeverc on 16/3/15.
//  Copyright © 2016年 lforxeverc. All rights reserved.
//

import UIKit

protocol ESCarouselWrap{
    var status:ImageViewStatus{set get}
    var imageURL:String{set get}
    var index:Int{get}
    weak var imageView:UIImageView?{get}
    var image:UIImage?{set get}
    weak var indicator:UIActivityIndicatorView?{get set}
}
enum ImageViewStatus{
    case Loading
    case Fetched
    case Error
}
struct ESCarouselItem:ESCarouselWrap {
    var status:ImageViewStatus{
        didSet{
            dispatch_async(dispatch_get_main_queue(), {
                
                if self.status == .Error {
                    let errorview = ESErrorView(frame: CGRect(x: 2, y: 2, width: self.imageView!.frame.width - 4, height:self.imageView!.frame.height - 4))
                    errorview.backgroundColor = UIColor.whiteColor()
                    errorview.tag = 1000
                    self.imageView?.addSubview(errorview)
                }
                if self.status == .Fetched {
                    if self.image != nil {
                        self.imageView?.image = self.image
                        self.indicator?.stopAnimating()
                    }
                }
                
            })
            
        }
    }
    var image:UIImage?
    var imageURL:String
    var index:Int
    weak var indicator:UIActivityIndicatorView?
    weak var imageView:UIImageView?
    init(status:ImageViewStatus = .Loading,image:UIImage? = nil ,imageURL:String,index:Int ,indicator:UIActivityIndicatorView? = UIActivityIndicatorView(),imageview:UIImageView? = UIImageView()){
        self.status = status
        self.image = image
        self.imageURL = imageURL
        self.index = index
        self.indicator = indicator
        self.imageView = imageview
        
    }
    
}
extension ESCarouselItem{
    func load(){
        ESCarouselDataHelper.defaultHelper().fetch(self.imageURL)
    }
    
}

class ESConstant {
    static let ESImageDataUpdateNotification = "escarousel.imagedata.update"
    static let ESImageDataFetchFail = 0
    static let ESImageDataFetchSuccess = 1
}

