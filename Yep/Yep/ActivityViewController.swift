//
//  ActivityViewController.swift
//  Yep
//
//  Created by zzzl on 2018/9/29.
//  Copyright © 2018年 Sinbane Inc. All rights reserved.
//

import UIKit

class ActivityViewController: BaseViewController, CanScrollsToTop {    
    // PullToRefreshViewDelegate
    // CanScrollsToTop
    var scrollView: UIScrollView? {
        return tableView
    }
    
    @IBOutlet fileprivate weak var tableView: UITableView!  {
        didSet {
            tableView.backgroundColor = UIColor.white
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

extension ActivityViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
        
        
        
        return cell;
    }
    
    
}
