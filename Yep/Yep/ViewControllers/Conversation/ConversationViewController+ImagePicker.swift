//
//  ConversationViewController+ImagePicker.swift
//  Yep
//
//  Created by NIX on 16/6/29.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import UIKit
import MobileCoreServices.UTType
import YepKit

extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {

            switch mediaType {

            case String(kUTTypeImage):

                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

                    let fixedSize = image.yep_fixedSize

                    // resize to smaller, not need fixRotation

                    if let fixedImage = image.resizeToSize(fixedSize, withInterpolationQuality: .high) {
                        sendImage(fixedImage)
                    }
                }

            case String(kUTTypeMovie):

                if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    println("videoURL \(videoURL)")
                    sendVideo(at: videoURL)
                }

            default:
                break
            }
        }

        dismiss(animated: true, completion: nil)
    }
}

