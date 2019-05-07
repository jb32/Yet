//
//  SearchedFeedNormalImagesCell.swift
//  Yep
//
//  Created by NIX on 16/4/19.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import UIKit
import YepKit
import YepPreview
import AsyncDisplayKit

final class SearchedFeedNormalImagesCell: SearchedFeedBasicCell {

    override class func heightOfFeed(_ feed: DiscoveredFeed) -> CGFloat {

        let height = super.heightOfFeed(feed) + (10 + YepConfig.SearchedFeedNormalImagesCell.imageSize.height)
        return ceil(height)
    }

    var tapImagesAction: FeedTapImagesAction?

    fileprivate func createImageNode() -> ASImageNode {

        let node = ASImageNode()
        node.frame = CGRect(origin: CGPoint.zero, size: YepConfig.SearchedFeedNormalImagesCell.imageSize)
        node.contentMode = .scaleAspectFill
        node.backgroundColor = YepConfig.FeedMedia.backgroundColor
        node.borderWidth = 1
        node.borderColor = UIColor.yepBorderColor().cgColor

        node.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchedFeedNormalImagesCell.tap(_:)))
        node.view.addGestureRecognizer(tap)

        return node
    }

    fileprivate lazy var imageNode1: ASImageNode = {
        return self.createImageNode()
    }()

    fileprivate lazy var imageNode2: ASImageNode = {
        return self.createImageNode()
    }()

    fileprivate lazy var imageNode3: ASImageNode = {
        return self.createImageNode()
    }()

    fileprivate lazy var imageNode4: ASImageNode = {
        return self.createImageNode()
    }()

    fileprivate var imageNodes: [ASImageNode] = []

    fileprivate let needAllImageNodes: Bool = SearchFeedsViewController.feedNormalImagesCountThreshold == 4
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        if needAllImageNodes {
            imageNodes = [imageNode1, imageNode2, imageNode3, imageNode4]
        } else {
            imageNodes = [imageNode1, imageNode2, imageNode3]
        }

        imageNodes.forEach({
            contentView.addSubview($0.view)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageNodes.forEach({ $0.image = nil })
    }

    override func configureWithFeed(_ feed: DiscoveredFeed, layout: SearchedFeedCellLayout, keyword: String?) {

        super.configureWithFeed(feed, layout: layout, keyword: keyword)

        if let attachments = feed.imageAttachments {

            for i in 0..<imageNodes.count {

                if let attachment = attachments[safe: i] {

                    if attachment.isTemporary {
                        imageNodes[i].image = attachment.image

                    } else {
                        imageNodes[i].yep_showActivityIndicatorWhenLoading = true
                        imageNodes[i].yep_setImageOfAttachment(attachment, withSize: YepConfig.FeedNormalImagesCell.imageSize)
                    }

                    imageNodes[i].isHidden = false

                } else {
                    imageNodes[i].isHidden = true
                }
            }
        }

        let normalImagesLayout = layout.normalImagesLayout!
        imageNode1.frame = normalImagesLayout.imageView1Frame
        imageNode2.frame = normalImagesLayout.imageView2Frame
        imageNode3.frame = normalImagesLayout.imageView3Frame
        if needAllImageNodes {
            imageNode4.frame = normalImagesLayout.imageView4Frame
        }
    }

    // MARK: Actions

    @objc fileprivate func tap(_ sender: UITapGestureRecognizer) {

        guard let attachments = feed?.imageAttachments else {
            return
        }

        guard let firstAttachment = attachments.first, !firstAttachment.isTemporary else {
            return
        }

        let views = imageNodes.map({ $0.view })
        guard let view = sender.view, let index = views.index(of: view) else {
            return
        }

        let transitionReferences: [Reference?] = imageNodes.map({
            Reference(view: $0.view, image: $0.image)
        })
        let image = imageNodes[index].image
        tapImagesAction?(transitionReferences, attachments, image, index)
    }
}

