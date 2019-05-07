//
//  NewFeedsController.swift
//  Yep
//
//  Created by zzzl on 2018/10/6.
//  Copyright © 2018年 Sinbane Inc. All rights reserved.
//

import UIKit
import CoreServices

import YepPreview
import Proposer

class NewFeedsController: SegueTableController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var textPlaceholdLB: UILabel!
    
    fileprivate var mediaImages = [UIImage]()
    fileprivate var previewReferences: [Reference?]?
    fileprivate var previewNewFeedPhotos = [PreviewNewFeedPhoto]()
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionUI()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK - collection view setup
extension NewFeedsController {
    func setCollectionUI() -> Void {
        collectionView.registerNibOf(FeedMediaAddCell.self)
        collectionView.registerNibOf(FeedMediaCell.self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension NewFeedsController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    enum Section: Int {
        case photos
        case add
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError("Invalid section!")
        }
        
        switch section {
        case .photos:
            return mediaImages.count
        case .add:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section!")
        }
        
        switch section {
            
        case .photos:
            let cell: FeedMediaCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            
            let image = mediaImages[indexPath.item]
            
            cell.configureWithImage(image)
            cell.delete = { [weak self] in
                self?.mediaImages.remove(at: indexPath.item)
            }
            
            return cell
            
        case .add:
            let cell: FeedMediaAddCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: IndexPath!) -> CGSize {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section!")
        }
        
        switch section {
            
        case .photos:
            return CGSize(width: 80, height: 80)
            
        case .add:
            guard mediaImages.count != YepConfig.Feed.maxImagesCount else {
                return CGSize.zero
            }
            return CGSize(width: 80, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section!")
        }
        
        switch section {
            
        case .photos:
            return true
            
        case .add:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceIndex = sourceIndexPath.item
        let destinationIndex = destinationIndexPath.item
        
        guard sourceIndex != destinationIndex else {
            return
        }
        
        let image = mediaImages[sourceIndex]
        mediaImages.remove(at: sourceIndex)
        mediaImages.insert(image, at: destinationIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section!")
        }
        
        switch section {
            
        case .photos:
            
            let index = indexPath.row
            
            let references: [Reference?] = (0..<mediaImages.count).map({
                let cell = collectionView.cellForItem(at: IndexPath(item: $0, section: indexPath.section)) as? FeedMediaCell
                return cell?.transitionReference
            })
            
            self.previewReferences = references
            
            let previewNewFeedPhotos = mediaImages.map({ PreviewNewFeedPhoto(image: $0) })
            
            self.previewNewFeedPhotos = previewNewFeedPhotos
            
            let photos: [Photo] = previewNewFeedPhotos.map({ $0 })
            let initialPhoto = photos[index]
            
            let photosViewController = PhotosViewController(photos: photos, initialPhoto: initialPhoto, delegate: self)
            self.present(photosViewController, animated: true, completion: nil)
            
        case .add:
            
            messageTextView.resignFirstResponder()
            
            if mediaImages.count == YepConfig.Feed.maxImagesCount {
                YepAlert.alertSorry(message: String.trans_promptFeedCanOnlyHasXPhotos, inViewController: self)
                return
            }
            
            let pickAlertController = UIAlertController(title: String.trans_titleChooseSource, message: nil, preferredStyle: .actionSheet)
            
            let cameraAction: UIAlertAction = UIAlertAction(title: String.trans_titleCamera, style: .default) { _ in
                
                proposeToAccess(.camera, agreed: { [weak self] in
                    
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                        self?.alertCanNotOpenCamera()
                        return
                    }
                    
                    if let strongSelf = self {
                        strongSelf.imagePicker.sourceType = .camera
                        strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                    }
                    
                    }, rejected: { [weak self] in
                        self?.alertCanNotOpenCamera()
                })
            }
            
            pickAlertController.addAction(cameraAction)
            
            let albumAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("title.albums", comment: ""), style: .default) { [weak self] _ in
                
                proposeToAccess(.photos, agreed: { [weak self] in
                    self?.performSegue(withIdentifier: "showPickPhotos", sender: nil)
                    
                    }, rejected: { [weak self] in
                        self?.alertCanNotAccessCameraRoll()
                })
            }
            
            pickAlertController.addAction(albumAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: String.trans_cancel, style: .cancel) { _ in
            }
            
            pickAlertController.addAction(cancelAction)
            
            self.present(pickAlertController, animated: true, completion: nil)
        }
    }
}

extension NewFeedsController {
    func isHiddenTxtViewPlaceholder() -> Void {
        
        guard let text = messageTextView.text else {
            textPlaceholdLB.isHidden = false
            return
        }
        if text.isEmpty {
            messageTextView.text = nil
            textPlaceholdLB.isHidden = false
        } else {
            textPlaceholdLB.isHidden = true
        }
    }
}

// MARK: - UIScrollViewDelegate

extension NewFeedsController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        isHiddenTxtViewPlaceholder()
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        isHiddenTxtViewPlaceholder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        isHiddenTxtViewPlaceholder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
//        hideSkillPickerView()
    }
}

// MARK: - UIScrollViewDelegate

extension NewFeedsController {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        messageTextView.resignFirstResponder()
    }
}
// MARK: - PhotosViewControllerDelegate

extension NewFeedsController: PhotosViewControllerDelegate {
    
    func photosViewController(_ vc: PhotosViewController, referenceForPhoto photo: Photo) -> Reference? {
        
        println("photosViewController:referenceViewForPhoto:\(photo)")
        
        if let previewNewFeedPhoto = photo as? PreviewNewFeedPhoto {
            if let index = previewNewFeedPhotos.index(of: previewNewFeedPhoto) {
                return previewReferences?[index]
            }
        }
        
        return nil
    }
    
    func photosViewController(_ vc: PhotosViewController, didNavigateToPhoto photo: Photo, atIndex index: Int) {
        
        println("photosViewController:didNavigateToPhoto:\(photo):atIndex:\(index)")
    }
    
    func photosViewControllerWillDismiss(_ vc: PhotosViewController) {
        
        println("photosViewControllerWillDismiss")
    }
    
    func photosViewControllerDidDismiss(_ vc: PhotosViewController) {
        
        println("photosViewControllerDidDismiss")
        
        previewReferences = nil
        previewNewFeedPhotos = []
    }
}
//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension NewFeedsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            
            switch mediaType {
                
            case String(kUTTypeImage):
                
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    if mediaImages.count <= 3 {
                        mediaImages.append(image)
                        collectionView.reloadData()
                    }
                }
                
            default:
                break
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
