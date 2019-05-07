//
//  SegueViewController.swift
//  Yep
//
//  Created by nixzhu on 16/1/4.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import UIKit

protocol SegueProtocol {
    func performSegue(withIdentifier identifier: String, sender: Any?)
}


class SegueViewController: UIViewController, SegueProtocol {
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if let navigationController = navigationController {
            guard navigationController.topViewController == self else {
                return
            }
        }
        
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
}

class SegueTableController: UITableViewController, SegueProtocol {
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if let navigationController = navigationController {
            guard navigationController.topViewController == self else {
                return
            }
        }
        
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
}
