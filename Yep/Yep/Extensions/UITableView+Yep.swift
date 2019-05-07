//
//  UITableView+Yep.swift
//  Yep
//
//  Created by nixzhu on 15/12/11.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import UIKit
import YepKit

extension UITableView {

    enum WayToUpdate {

        case none
        case reloadData
        case reloadIndexPaths([IndexPath])
        case insert([IndexPath])

        var needsLabor: Bool {

            switch self {
            case .none:
                return false
            case .reloadData:
                return true
            case .reloadIndexPaths:
                return true
            case .insert:
                return true
            }
        }

        func performWithTableView(_ tableView: UITableView) {

            switch self {

            case .none:
                println("tableView WayToUpdate: None")
                break

            case .reloadData:
                println("tableView WayToUpdate: ReloadData")
                SafeDispatch.async {
                    tableView.reloadData()
                }

            case .reloadIndexPaths(let indexPaths):
                println("tableView WayToUpdate: ReloadIndexPaths")
                SafeDispatch.async {
                    tableView.reloadRows(at: indexPaths, with: .none)
                }

            case .insert(let indexPaths):
                println("tableView WayToUpdate: Insert")
                SafeDispatch.async {
                    tableView.insertRows(at: indexPaths, with: .none)
                }
            }
        }
    }
}

extension UITableView {

    func registerClassOf<T>(_: T.Type) where T: UITableViewCell {

        register(T.self, forCellReuseIdentifier: T.yep_reuseIdentifier)
    }

    func registerNibOf<T>(_: T.Type) where T: UITableViewCell {

        let nib = UINib(nibName: T.yep_nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.yep_reuseIdentifier)
    }

    func registerHeaderFooterClassOf<T: UITableViewHeaderFooterView>(_: T.Type) {

        register(T.self, forHeaderFooterViewReuseIdentifier: T.yep_reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>() -> T {

        guard let cell = self.dequeueReusableCell(withIdentifier: T.yep_reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.yep_reuseIdentifier)")
        }
        
        return cell
    }

    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T {

        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.yep_reuseIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooter with identifier: \(T.yep_reuseIdentifier)")
        }

        return view
    }
}

