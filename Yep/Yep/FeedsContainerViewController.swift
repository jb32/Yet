//
//  FeedsContainerViewController.swift
//  Yep
//
//  Created by zzzl on 2018/9/29.
//  Copyright © 2018年 Sinbane Inc. All rights reserved.
//

import UIKit
import YepKit
import Ruler
import RxSwift
import RxCocoa

class FeedsContainerViewController: UIPageViewController, CanScrollsToTop {
    // CanScrollsToTop
    var scrollView: UIScrollView? {
        return (viewControllers?.first as? CanScrollsToTop)?.scrollView
    }
    
    fileprivate lazy var disposeBag = DisposeBag()
    fileprivate lazy var feedvc = UIStoryboard.Scene.feedsVc
    fileprivate lazy var activityvc = UIStoryboard.Scene.activityVC
    
    var currentOption: Option = .feed {
        didSet {
            switch currentOption {
                
            case .feed:
                feedvc.parentVC = self
                setViewControllers([feedvc], direction: .reverse, animated: true, completion: nil)
            case .activity:
                setViewControllers([activityvc], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.removeAllSegments()
            
            (0..<Option.count).forEach({
                let option = Option(rawValue: $0)
                segmentedControl.insertSegment(withTitle: option?.title, at: $0, animated: false)
            })
            
            let font = UIFont.systemFont(ofSize: Ruler.iPhoneHorizontal(13, 14, 15).value)
            let padding: CGFloat = Ruler.iPhoneHorizontal(8, 11, 12).value
            segmentedControl.yep_setTitleFont(font, withPadding: padding)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentOption = .feed
        segmentedControl.selectedSegmentIndex = currentOption.rawValue
        
        segmentedControl.rx.value
            .map({ Option(rawValue: $0) })
            .subscribe(onNext: { [weak self] in self?.currentOption = $0 ?? .feed })
            .disposed(by: disposeBag)
        
        dataSource = self
        delegate = self
        
//        if traitCollection.forceTouchCapability == .available {
//            registerForPreviewing(with: self, sourceView: view)
//        }
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

extension FeedsContainerViewController {
    enum Option: Int {
        case feed
        case activity
        
        static let count = 2
        
        var title: String {
            switch self {
            case .feed:
                return String.trans_titleTopic
            case .activity:
                return String.trans_titleActivity
            }
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension FeedsContainerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController == feedvc {
            return activityvc
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController == activityvc {
            return feedvc
        }
        
        return nil
    }
}

// MARK: - UIPageViewControllerDelegate

extension FeedsContainerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else {
            return
        }
        
        if previousViewControllers.first == feedvc {
            currentOption = .feed
        } else if previousViewControllers.first == activityvc {
            currentOption = .activity
        }
        segmentedControl.selectedSegmentIndex = currentOption.rawValue
    }
}

// MARK: - UIViewControllerPreviewingDelegate

//extension FeedsContainerViewController: UIViewControllerPreviewingDelegate {
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//
//        switch currentOption {
//
//        case .feed:
//
////            let tableView = meetGeniusViewController.interviewsTableView
////
////            let fixedLocation = view.convert(location, to: tableView)
////
////            guard let indexPath = tableView.indexPathForRow(at: fixedLocation), let cell = tableView.cellForRow(at: indexPath) else {
////                return nil
////            }
////
////            previewingContext.sourceRect = cell.frame
//
//            let vc = UIStoryboard.Scene.geniusInterview
////            let geniusInterview = meetGeniusViewController.geniusInterviewAtIndexPath(indexPath)
////            vc.interview = geniusInterview
//
//            return vc
//
//        case .activity:
//
//            let collectionView = discoverViewController.collectionView
//
//            let fixedLocation = view.convert(location, to: collectionView)
//
//            guard let indexPath = collectionView.indexPathForItem(at: fixedLocation), let cell = collectionView.cellForItem(at: indexPath) else {
//                return nil
//            }
//
//            previewingContext.sourceRect = cell.frame
//
//            let vc = UIStoryboard.Scene.profile
//
//            let discoveredUser = discoverViewController.discoveredUserAtIndexPath(indexPath)
//            vc.prepare(with: discoveredUser)
//
//            return vc
//        }
//    }
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//
//        show(viewControllerToCommit, sender: self)
//    }
//}
