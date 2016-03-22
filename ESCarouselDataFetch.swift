//
//  ESCarouselDataFetch.swift
//
//  Created by lforxeverc on 16/3/15.
//  Copyright © 2016年 jodo. All rights reserved.
//

import UIKit

protocol ESDataAchieve{
    var url:String{get set}
    var localSavePath:String{get}
    func isExist()->Bool
    func fetch()
    
}

struct LocalFetch:ESDataAchieve {
    var url:String
    var localSavePath:String{
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        let all = "\(path!)/\(url.hashValue).archiver)"
        return all
    }
    func isExist() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(localSavePath)
    }
    func fetch() {
        if isExist(){
            let data:NSData? = NSKeyedUnarchiver.unarchiveObjectWithFile(localSavePath) as? NSData
            if data != nil {
                if nil != UIImage(data: data!) {
                    NSNotificationCenter.defaultCenter().postNotificationName(ESConstant.ESImageDataUpdateNotification, object: nil, userInfo: ["state":ESConstant.ESImageDataFetchSuccess,"url":self.url,"data":data!])
                }
            }
        }
    }
}

struct OnlineFetch:ESDataAchieve {
    var url:String
    var localSavePath:String{
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last
        let all = "\(path!)/\(url.hashValue).archiver)"
        return all
    }
    func isExist() -> Bool {
        
        return NSFileManager.defaultManager().fileExistsAtPath(localSavePath)
    }
    
    func postDataUpdate(state:Int,data:NSData? = nil){
        if state == ESConstant.ESImageDataFetchSuccess && data != nil {
            
            NSNotificationCenter.defaultCenter().postNotificationName(ESConstant.ESImageDataUpdateNotification, object: nil, userInfo: ["state":state,"url":self.url,"data":data!])
        }
        else{
            NSNotificationCenter.defaultCenter().postNotificationName(ESConstant.ESImageDataUpdateNotification, object: nil, userInfo: ["state":state,"url":self.url])
        }
    }
    
    func fetch(){
        let u = NSURL(string: url)
        if u != nil {
            let req = NSURLRequest(URL: u!)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(req){
                data,respon,error in
                
                if error != nil {
                    self.postDataUpdate(ESConstant.ESImageDataFetchFail)
                }
                else if data != nil && respon != nil {
                    let resp:NSHTTPURLResponse = respon as! NSHTTPURLResponse
                    if  resp.statusCode == 200 {
                        if nil != UIImage(data: data!) {
                            self.saveLocal(data!)
                            self.postDataUpdate(ESConstant.ESImageDataFetchSuccess, data: data)
                        }
                        else{
                            self.postDataUpdate(ESConstant.ESImageDataFetchFail)
                        }
                        
                    }
                    else{
                        self.postDataUpdate(ESConstant.ESImageDataFetchFail)
                    }
                }
                else{
                    self.postDataUpdate(ESConstant.ESImageDataFetchFail)
                }
            }
            task.resume()
        }
    }
    
    
}

extension OnlineFetch {
    func saveLocal(data:NSData)->Bool{
        return NSKeyedArchiver.archiveRootObject(data, toFile: self.localSavePath)
    }
    
}

class ESCarouselDataHelper{
    static let instance:ESCarouselDataHelper = ESCarouselDataHelper()
    static func defaultHelper()->ESCarouselDataHelper{
        return instance
    }
    private init(){
    }
    
    func fetch(url:String){
        let local = LocalFetch(url:url)
        if local.isExist() {
            local.fetch()
        }
        else{
            let network = OnlineFetch(url:url)
            network.fetch()
        }
    }
}



