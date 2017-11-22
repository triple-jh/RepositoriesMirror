//
//  Loading.swift
//  Beer
//
//  Created by JJaeyang on 2017/09/06.
//  Copyright © 2017年 JJaeyang. All rights reserved.
//

import UIKit

class Loading: UIView
{
    static let shared: Loading = Loading()
    
    var image: UIImageView!
    var isAnimating = false
    
    var updater: CADisplayLink? = nil
    var count: Double = 0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.frame = UIScreen.main.bounds
        self.isUserInteractionEnabled = true
        
        image = UIImageView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        image.backgroundColor = UIColor.black
        image.layer.cornerRadius = image.frame.width/2
        image.clipsToBounds = true
        image.image = UIImage(named: "loading")
        image.center = self.center
        self.addSubview(image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 빙글빙글시작
    func start()
    {
        DispatchQueue.main.async
        {
            self.isAnimating = true
            
            self.updater = CADisplayLink(target: self, selector: #selector(self.animating))
            if #available(iOS 10.0, *) {
                self.updater?.preferredFramesPerSecond = 60
            } else {
                self.updater?.frameInterval = 60
            }
            self.updater?.add(to: .current, forMode: .commonModes)
            self.isAnimating = true
        }
    }
    
    func stop()
    {
        self.updater?.invalidate()
        self.updater = nil
        self.count = 0

        isAnimating = false
        
        DispatchQueue.main.async
        {
            self.removeFromSuperview()
        }
    }
    
    @objc func animating()
    {
        self.image.transform = CGAffineTransform(scaleX: cos(CGFloat((self.count/180)*Double.pi)), y: 1)
        
        self.count = self.count+4
        if self.count >= 360
        {
            self.count = 0
        }
    }

}
