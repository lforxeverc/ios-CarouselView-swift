//
//  ViewController.swift
//  EsCarouselView
//
//  Created by jodo on 16/3/22.
//  Copyright © 2016年 lforxeverc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ESCarouselDelegate{

    @IBOutlet weak var mCarouselView: ESCarouselView!
    var urls:[String] = [
        
        "http://pic.sc.chinaz.com/files/pic/pic9/201508/apic14052.jpg",
        "http://stackoverflow.com/questions/15844057/how-can-i-draw-a-dot-on-the-screen-on-touchesended-using-uibezierpath",
        "http://www.hua.com/flower_picture/meiguihua/images/r17.jpg",
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mCarouselView.setAdapter(urls)
        mCarouselView.delegate = self
        
        let v = ESCarouselView(frame: CGRectMake(0, 500, self.view.bounds.width, 300), delegate: self)
        self.view.addSubview(v)
        v.setAdapter(urls)
    }
    func onCarouselItemTap(position:Int,currentView:UIImageView){
        print("click on \(position)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

