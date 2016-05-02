//
//  StreamSelectorView.swift
//  Accented
//
//  Created by Tiangong You on 5/1/16.
//  Copyright © 2016 Tiangong You. All rights reserved.
//

import UIKit

class StreamSelectorView: UIView {

    var topLine = CALayer()
    var bottomLine = CALayer()
    
    private let hGap : CGFloat = 20
    private var contentWidth : CGFloat = 0
    
    let displayStreamTypes : [StreamType] = [StreamType.Popular, StreamType.FreshToday, StreamType.Upcoming, StreamType.Editors]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        topLine.backgroundColor = UIColor(red: 162 / 255.0, green: 162 / 255.0, blue: 162 / 255.0, alpha: 1.0).CGColor
        bottomLine.backgroundColor = topLine.backgroundColor
        
        self.layer.addSublayer(topLine)
        self.layer.addSublayer(bottomLine)
        
        createTabs()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = CGRectGetWidth(self.bounds)
        let h = CGRectGetHeight(self.bounds)
        topLine.frame = CGRectMake(0, 0, w, 1)
        bottomLine.frame = CGRectMake(0, h - 1, w, 1)
        
        // Distrubute tabs
        var currentX = w / 2 - contentWidth / 2
        for tabView in self.subviews {
            var f = tabView.frame
            f.origin.x = currentX
            f.origin.y = h / 2 - CGRectGetHeight(f) / 2
            tabView.frame = f
            
            currentX += CGRectGetWidth(f) + hGap
        }
    }
    
    private func createTabs() {
        for streamType in displayStreamTypes {
            let button = UIButton()
            button.setTitle(displayName(streamType), forState: .Normal)
            button.titleLabel!.font = UIFont(name: "Futura-CondensedMedium", size: 12)
            button.sizeToFit()
            self.addSubview(button)
            
            contentWidth += CGRectGetWidth(button.bounds)
        }
        
        contentWidth += hGap * CGFloat(displayStreamTypes.count - 1)
    }
    
    private func displayName(streamType : StreamType) -> String {
        switch streamType {
        case .Popular:
            return "POPULAR"
        case .FreshToday:
            return "LATEST"
        case .Upcoming:
            return "UPCOMING"
        case .Editors:
            return "EDITORS' CHOICE"
        default:
            fatalError("StreamType not implemented")
        }
    }
}
