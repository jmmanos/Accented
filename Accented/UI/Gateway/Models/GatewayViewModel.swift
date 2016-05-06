//
//  GatewayViewModel.swift
//  Accented
//
//  Created by Tiangong You on 5/2/16.
//  Copyright © 2016 Tiangong You. All rights reserved.
//

import UIKit

class GatewayViewModel: StreamViewModel {
    
    // Header logo cell
    private let headerLogoReuseIdentifier = "headerLogo"

    // Header navigation cell
    private let headerNavReuseIdentifier = "headerNav"

    // Header Buttons cell
    private let headerButtonsReuseIdentifier = "headerButtons"

    private let cardRendererReuseIdentifier = "renderer"
    private let initialLoadingRendererReuseIdentifier = "initialLoading"
    private let cardSectionHeaderRendererReuseIdentifier = "sectionHeader"
    private let cardSectionFooterRendererReuseIdentifier = "sectionFooter"
    private let loadingFooterRendererReuseIdentifier = "loadingFooter"
    
    // Header section, which includes the logo, the nav bar and the buttons
    private let headerSection = 0
    
    override var photoStartSection : Int {
        return 1
    }

    // Cell for infinite loading
    var loadingCell : StreamLoadingCell?
    
    required init(stream : StreamModel, collectionView : UICollectionView, flowLayoutDelegate: UICollectionViewDelegateFlowLayout) {
        super.init(stream: stream, collectionView: collectionView, flowLayoutDelegate: flowLayoutDelegate)
    }
    
    override func registerCellTypes() {
        collectionView.registerClass(StreamPhotoCell.self, forCellWithReuseIdentifier: cardRendererReuseIdentifier)
        
        // Header logo cell
        let headerLogoCellNib = UINib(nibName: "StreamHeaderLogoCell", bundle: nil)
        collectionView.registerNib(headerLogoCellNib, forCellWithReuseIdentifier: headerLogoReuseIdentifier)

        // Header navigation cell
        let headerNavCellNib = UINib(nibName: "StreamHeaderNavCell", bundle: nil)
        collectionView.registerNib(headerNavCellNib, forCellWithReuseIdentifier: headerNavReuseIdentifier)

        // Header buttons cell
        let headerButtonsCellNib = UINib(nibName: "StreamButtonsCell", bundle: nil)
        collectionView.registerNib(headerButtonsCellNib, forCellWithReuseIdentifier: headerButtonsReuseIdentifier)
        
        // Section header
        let sectionHeaderCellNib = UINib(nibName: "StreamSectionHeaderCell", bundle: nil)
        collectionView.registerNib(sectionHeaderCellNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: cardSectionHeaderRendererReuseIdentifier)
        
        // Section footer
        let sectionFooterCellNib = UINib(nibName: "StreamSectionFooterCell", bundle: nil)
        collectionView.registerNib(sectionFooterCellNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: cardSectionFooterRendererReuseIdentifier)
        
        // Inline loading
        let loadingCellNib = UINib(nibName: "StreamLoadingCell", bundle: nil)
        collectionView.registerNib(loadingCellNib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: loadingFooterRendererReuseIdentifier)
        
        // Initial loading
        let initialLoadingCellNib = UINib(nibName: "StreamInitialLoadingCell", bundle: nil)
        collectionView.registerNib(initialLoadingCellNib, forCellWithReuseIdentifier: initialLoadingRendererReuseIdentifier)
    }
    
    override func createLayoutEngine() {
        layoutEngine = GatewayCardLayout()
        layoutEngine.headerReferenceSize = CGSizeMake(50, 50)
        layoutEngine.footerReferenceSize = CGSizeMake(50, 50)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == headerSection {
            // Stream headers
            if indexPath.item == 0 {
                // Logo
                return collectionView.dequeueReusableCellWithReuseIdentifier(headerLogoReuseIdentifier, forIndexPath: indexPath)
            } else if indexPath.item == 1 {
                return collectionView.dequeueReusableCellWithReuseIdentifier(headerNavReuseIdentifier, forIndexPath: indexPath)
            } else if indexPath.item == 2 {
                let buttonsCell = collectionView.dequeueReusableCellWithReuseIdentifier(headerButtonsReuseIdentifier, forIndexPath: indexPath) as! StreamButtonsCell
                buttonsCell.stream = stream
                buttonsCell.setNeedsLayout()
                return buttonsCell
            } else {
                fatalError("There is no header cells beyond index 2")
            }
        } else {
            if !stream.loaded {
                let loadingCell = collectionView.dequeueReusableCellWithReuseIdentifier(initialLoadingRendererReuseIdentifier, forIndexPath: indexPath)
                return loadingCell
            } else {
                let group = photoGroups[indexPath.section - photoStartSection]
                let photo = group[indexPath.item]
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cardRendererReuseIdentifier, forIndexPath: indexPath) as! StreamPhotoCell
                cell.photo = photo
                cell.setNeedsLayout()
                
                return cell
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if indexPath.section == headerSection {
            fatalError("Header section should not have any supplementary elements!")
        }
        
        if !stream.loaded {
            fatalError("Header section should not have any supplementary elements!")
        }
        
        let group = photoGroups[indexPath.section - photoStartSection]
        
        if kind == UICollectionElementKindSectionHeader {
            let sectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: cardSectionHeaderRendererReuseIdentifier, forIndexPath: indexPath) as! StreamSectionHeaderCell
            return sectionHeaderView
        } else if kind == UICollectionElementKindSectionFooter {
            // If the stream has more content, show the loading cell for the last section
            let totalSectionCount = self.numberOfSectionsInCollectionView(collectionView)
            if indexPath.section == totalSectionCount - 1 && canLoadMore() {
                let loadingView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: loadingFooterRendererReuseIdentifier, forIndexPath: indexPath) as! StreamLoadingCell
                loadingView.streamViewModel = self
                
                // If there are no more items in the stream to load, show the ending status
                if stream.photos.count >= stream.totalCount! {
                    loadingView.showEndingState()
                } else {
                    // Otherwise, always show the loading state, even if the previous attempt of loading failed. This is because we'll trigger loadNextPage() regardless of footer state
                    loadingView.showLoadingState()
                }
                
                self.loadingCell = loadingView
                return loadingView
            } else {
                let sectionFooterView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: cardSectionFooterRendererReuseIdentifier, forIndexPath: indexPath) as! StreamSectionFooterCell
                sectionFooterView.photoGroup = group
                sectionFooterView.setNeedsLayout()
                return sectionFooterView
            }
        }
        
        return UICollectionViewCell()
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
            return 3
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
    
    // MARK: - Private
    
    private func canLoadMore() -> Bool {
        return stream.totalCount! > stream.photos.count
    }
    
}
