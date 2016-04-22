//
//  SignInLogoView.swift
//  Accented
//
//  Created by Tiangong You on 4/11/16.
//  Copyright © 2016 Tiangong You. All rights reserved.
//

import UIKit

class SignInLogoView: UIView {

    let layerCount = 11
    let upperFlipWings = [7, 8]
    let lowerFlipWings = [3, 6, 10, 11]
    let upperSlideWings = [1, 2, 9]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeLayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeLayers()
    }
    
    func initializeLayers() {
        for i in 1...self.layerCount {
            let layerImage = UIImage(named: "Logo.Layer\(i)")
            let layerView = UIImageView(image: layerImage)
            layerView.contentMode = UIViewContentMode.ScaleAspectFit
            self.insertSubview(layerView, atIndex: 0)
            
            layerView.layer.anchorPoint = CGPointMake(1.0, 0.55)
            layerView.layer.transform.m34 = 1 / 3500.0
            layerView.layer.zPosition = 100.0 * CGFloat(i)
        }
    }
    
    override func layoutSubviews() {
        for layerView in self.subviews as [UIView] {
            layerView.frame = self.bounds
        }
    }
    
    func performPerspectiveAnimation()  {
        let animationOptions : UIViewKeyframeAnimationOptions = [.Repeat, .Autoreverse, .BeginFromCurrentState]
        UIView.animateKeyframesWithDuration(10, delay: 0.2, options: animationOptions, animations: {
            for layerView in self.subviews as [UIView] {
                let layerIndex = self.subviews.indexOf(layerView)
                let imageIndex = self.layerCount - layerIndex!
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.8 * Double(rand()), animations: {
                    var angle:Double
                    if self.upperFlipWings.contains(imageIndex) {
                        angle = Double(imageIndex) * 1.6 * M_PI / 180.0
                        layerView.layer.transform = CATransform3DRotate(layerView.layer.transform, -CGFloat(angle), 1, 0, 0)
                    } else if self.lowerFlipWings.contains(imageIndex) {
                        angle = Double(imageIndex) * 2.6 * M_PI / 180.0
                        layerView.layer.transform = CATransform3DRotate(layerView.layer.transform, CGFloat(angle), 1, 0, 0)
                    } else if self.upperSlideWings.contains(imageIndex) {
                        angle = Double(imageIndex) * 2.2 * M_PI / 180.0
                        layerView.layer.transform = CATransform3DRotate(layerView.layer.transform, -CGFloat(angle), 0, 0, 1)
                    } else {
                        angle = Double(imageIndex) * 1.8 * M_PI / 180.0
                        layerView.layer.transform = CATransform3DRotate(layerView.layer.transform, CGFloat(angle), 1, 0, 1)
                    }
                    
                    layerView.alpha = CGFloat(10 + Double(arc4random_uniform(80)) / 100.0)
                })
            }
        }, completion: { (Bool) in
            
        })
    
    }
}
