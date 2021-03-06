//
//  JournalViewModel.swift
//  Accented
//
//  Created by You, Tiangong on 5/19/16.
//  Copyright © 2016 Tiangong You. All rights reserved.
//

import UIKit

class JournalViewModel: StreamViewModel, StreamLayoutDelegate, PhotoRendererDelegate {

    private let headerReuseIdentifier = "journalHeader"
    private let photoRendererReuseIdentifier = "journalPhotoRenderer"
    private let initialLoadingRendererReuseIdentifier = "journalTnitialLoading"
    private let loadingFooterRendererReuseIdentifier = "journalLoadingFooter"
    static let backdropDecorIdentifier = "journalBackdrop"
    static let bubbleDecorIdentifier = "journalBubble"
    
    // Header section, which includes the logo, the nav bar and the buttons
    private let headerSection = 0
    
    override var photoStartSection : Int {
        return 1
    }
    
    // Inline infinite loading cell
    var loadingCell : DefaultStreamInlineLoadingCell?
    
    required init(stream : StreamModel, collectionView : UICollectionView, flowLayoutDelegate: UICollectionViewDelegateFlowLayout) {
        super.init(stream: stream, collectionView: collectionView, flowLayoutDelegate: flowLayoutDelegate)
    }
    
    override func registerCellTypes() {
        // Photo renderer
        collectionView.registerClass(JournalPhotoCell.self, forCellWithReuseIdentifier: photoRendererReuseIdentifier)
        
        // Header cell
        let headerCellNib = UINib(nibName: "JournalHeaderTitleCell", bundle: nil)
        collectionView.registerNib(headerCellNib, forCellWithReuseIdentifier: headerReuseIdentifier)
        
        // Inline loading
        let loadingCellNib = UINib(nibName: "DefaultStreamInlineLoadingCell", bundle: nil)
        collectionView.registerNib(loadingCellNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: loadingFooterRendererReuseIdentifier)
        
        // Initial loading
        let initialLoadingCellNib = UINib(nibName: "DefaultStreamInitialLoadingCell", bundle: nil)
        collectionView.registerNib(initialLoadingCellNib, forCellWithReuseIdentifier: initialLoadingRendererReuseIdentifier)
    }
    
    override func createLayoutEngine() {
        layoutEngine = JournalStreamLayout()
        layoutEngine.delegate = self
        
        // Register backdrop as decoration class
        layoutEngine.registerClass(JournalBackdropCell.self, forDecorationViewOfKind: JournalViewModel.backdropDecorIdentifier)
        layoutEngine.registerClass(JournalBubbleDecoCell.self, forDecorationViewOfKind: JournalViewModel.bubbleDecorIdentifier)
    }
    
    override func createLayoutTemplateGenerator(maxWidth: CGFloat) -> StreamTemplateGenerator {
        return StreamJournalLayoutGenerator(maxWidth: maxWidth)
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == headerSection {
            // Stream headers
            if indexPath.item == 0 {
                let headerCell = collectionView.dequeueReusableCellWithReuseIdentifier(headerReuseIdentifier, forIndexPath: indexPath) as! JournalHeaderTitleCell
                headerCell.stream = stream
                headerCell.setNeedsLayout()
                return headerCell
            } else {
                fatalError("There is no header cells beyond index 0")
            }
        } else {
            if !stream.loaded {
                let loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier(initialLoadingRendererReuseIdentifier, forIndexPath: indexPath)
                return loadingCell
            } else {
                // In the journal layout, each group only has 1 photo item
                let group = photoGroups[indexPath.section - photoStartSection]
                let photo = group[indexPath.item]
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoRendererReuseIdentifier, forIndexPath: indexPath) as! JournalPhotoCell
                cell.photo = photo
                cell.photoView.delegate = self
                cell.setNeedsLayout()
                
                return cell
            }
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if !stream.loaded {
            return photoStartSection + 1
        } else {
            return photoGroups.count + photoStartSection
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == headerSection {
            return 2
        } else {
            if !stream.loaded {
                return 1
            } else {
                return photoGroups[section - photoStartSection].count
            }
        }
    }
    
    // MARK: - Events
    
    override func streamFailedLoading(error: String) {
        super.streamFailedLoading(error)
        if let loadingView = self.loadingCell {
            loadingView.showRetryState()
        }
    }
    
    // MARK: - StreamLayoutDelegate
    
    func streamHeaderCompressionRatioDidChange(headerCompressionRatio: CGFloat) {
        // Ignore
    }

    // MARK: - PhotoRendererDelegate
    
    func photoRendererDidReceiveTap(renderer: PhotoRenderer) {
        let navContext = DetailNavigationContext(selectedPhoto: renderer.photo!, photoCollection: stream.photos, sourceImageView: renderer.imageView)
        NavigationService.sharedInstance.navigateToDetailPage(navContext)
    }
    
    // MARK: - Private
    
    private func canLoadMore() -> Bool {
        return stream.totalCount! > stream.photos.count
    }

}
