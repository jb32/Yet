//
//  Realm+Yep.swift
//  Yep
//
//  Created by NIX on 15/6/30.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import RealmSwift

public extension Results {

    subscript (safe index: Int) -> Element? {
        return (index >= 0 && index < count) ? self[index] : nil
    }
}

public extension List {

    subscript (safe index: Int) -> Element? {
        return (index >= 0 && index < count) ? self[index] : nil
    }
}

