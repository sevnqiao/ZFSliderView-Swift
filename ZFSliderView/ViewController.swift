//
//  ViewController.swift
//  ZFSliderView
//
//  Created by Xiong on 2018/3/8.
//  Copyright © 2018年 Xiong. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIScrollViewDelegate{

    let sliderView:ZFSliderView = ZFSliderView.init(frame: CGRect.init(x: 10, y: 80, width: 412-20, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        sliderView.itemArray = ["美术", "数学", "思想品德", "微生物", "数学2", "思想品德2", "微生物2"]
        sliderView.itemSpace = 30
        
        view.addSubview(sliderView)
        
        
        
        let scrollView:UIScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 140, width: 414, height: 400))
        scrollView.backgroundColor = UIColor.orange
        scrollView.isPagingEnabled = true
        scrollView.delegate = self;
        scrollView.contentSize = CGSize.init(width: 414 * 7, height: 400)
        view.addSubview(scrollView)
        
        for i in 0...6 {
            let view:UIView = UIView.init()
            view.frame = CGRect.init(x: i * 414, y: 0, width: 414, height: 400)
            view.backgroundColor = UIColor.init(red: CGFloat(arc4random_uniform(255))/255.0, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1)
            scrollView.addSubview(view)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index:CGFloat = scrollView.contentOffset.x / 414
        
//        print(index)
        
        sliderView.indexOffset = index
    }

}

