//
//  YepAsset.swift
//  Yep
//
//  Created by NIX on 15/4/22.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit
import AVFoundation

func thumbnailImageOfVideoInVideoURL(_ videoURL: URL) -> UIImage? {
    let asset = AVURLAsset(url: videoURL, options: [:])
    let imageGenerator = AVAssetImageGenerator(asset: asset)

    imageGenerator.appliesPreferredTrackTransform = true

    var actualTime: CMTime = CMTimeMake(value: 0, timescale: 0)

    guard let cgImage = try? imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(0.0, preferredTimescale: 600), actualTime: &actualTime) else {
        return nil
    }

    let thumbnail = UIImage(cgImage: cgImage)

    return thumbnail
}
