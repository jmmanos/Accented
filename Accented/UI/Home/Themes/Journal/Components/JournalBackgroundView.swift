//
//  JournalBackgroundView.swift
//  Accented
//
//  Created by Tiangong You on 5/19/16.
//  Copyright © 2016 Tiangong You. All rights reserved.
//

import UIKit

class JournalBackgroundView: ThemeableBackgroundView {
    
    var compressionRate : CGFloat = 0
    let fullCompressionDist : CGFloat = 100
    
    var imageView : UIImageView = UIImageView()
    var blurView : BlurView = DefaultNavBlurView()
    
    required init() {
        super.init()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() -> Void {
        // Image view
        addSubview(imageView)
        imageView.contentMode = .ScaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        imageView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        imageView.widthAnchor.constraintEqualToAnchor(self.widthAnchor, multiplier: 0.5).active = true
        
        if ThemeManager.sharedInstance.currentTheme is JournalTheme {
            let journalStyle = ThemeManager.sharedInstance.currentTheme as! JournalTheme
            imageView.image = journalStyle.backgroundLogoImage
        } else {
            imageView.image = nil;
        }
        
        // Blur view
        addSubview(blurView)
        blurView.alpha = 0
        
        // Perform the initial animation states
        imageView.alpha = 0
        imageView.transform = CGAffineTransformMakeTranslation(0, -30)

        // Events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appThemeDidChange(_:)), name: ThemeManagerEvents.appThemeDidChange, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func performEntranceAnimation(completed: (() -> Void)) {
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseOut], animations: { [weak self] in
            self?.imageView.alpha = 1
            self?.imageView.transform = CGAffineTransformIdentity

            }) { (finished) in
                completed()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = self.bounds
    }
    
    // MARK : - Events
    func appThemeDidChange(notification : NSNotification) {
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.blurView.blurEffect = ThemeManager.sharedInstance.currentTheme.backgroundBlurEffect
        }
    }
    
    override func streamViewContentOffsetDidChange(contentOffset: CGFloat) {
        if contentOffset <= 0 {
            compressionRate = 0
        }
        
        compressionRate = 1 - (fullCompressionDist - contentOffset) / fullCompressionDist
        if compressionRate < 0 {
            compressionRate = 0
        }
        
        if compressionRate > 1 {
            compressionRate = 1
        }
        
        blurView.alpha = compressionRate
        blurView.setNeedsLayout()
        
        let scaleFactor = 1.0 + compressionRate
        imageView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
    }
}