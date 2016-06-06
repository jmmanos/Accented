//
//  DrawerViewController.swift
//  Accented
//
//  Created by Tiangong You on 6/5/16.
//  Copyright © 2016 Tiangong You. All rights reserved.
//

import UIKit

class DrawerViewController: UIViewController {

    // Curtain view
    private var curtainView = UIView()
    
    // Hosted view controller
    private var drawer : UIViewController
    
    init(viewController : UIViewController) {
        drawer = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup curtain view
        self.view.addSubview(curtainView)
        curtainView.alpha = 0
        curtainView.backgroundColor = UIColor.blackColor()
        curtainView.translatesAutoresizingMaskIntoConstraints = false
        curtainView.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor).active = true
        curtainView.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor).active = true
                
        // Setup host view
        addChildViewController(drawer)
        self.view.addSubview(drawer.view)
        drawer.view.translatesAutoresizingMaskIntoConstraints = false
        drawer.didMoveToParentViewController(self)
        drawer.view.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        drawer.view.widthAnchor.constraintEqualToAnchor(self.view.widthAnchor, multiplier: 0.8).active = true
        drawer.view.heightAnchor.constraintEqualToAnchor(self.view.heightAnchor).active = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        drawer.view.layer.shadowPath = UIBezierPath(rect: drawer.view.bounds).CGPath
        drawer.view.layer.shadowColor = UIColor.blackColor().CGColor
        drawer.view.layer.shadowOpacity = 0.65;
        drawer.view.layer.shadowRadius = 5
        drawer.view.layer.shadowOffset = CGSizeMake(-3, 0)
    }

    func willPerformOpenAnimation() {
        drawer.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(drawer.view.bounds), 0)
    }
    
    func performanceOpenAnimation() {
        curtainView.alpha = 0.7
        drawer.view.transform = CGAffineTransformIdentity
    }
    
}