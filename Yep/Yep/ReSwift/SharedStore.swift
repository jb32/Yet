//
//  SharedStore.swift
//  Yep
//
//  Created by NIX on 16/8/31.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import ReSwift

final private class SharedStore {

    static let shared = SharedStore()

    lazy var store: Store<AppState> = {
        return Store<AppState>(
            reducer: mobilePhoneReducer,
            state: nil
        )
    }()

    fileprivate init() {}
}

func sharedStore() -> Store<AppState> {
    return SharedStore.shared.store
}

func mobilePhoneReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    switch action {
    case let x as MobilePhoneUpdateAction:
        state.mobilePhone = x.mobilePhone
        
    default:
        break
    }
    return state
}
