//
//  Repository.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class Repository:ObservableObject, PageProtocol{
    let setting = SettingStorage()
    let sceneObserver:PageSceneObserver?
    let pagePresenter:PagePresenter?
    let dataProvider:DataProvider
    private let apiManager:ApiManager
    private var anyCancellable = Set<AnyCancellable>()
    
    init(
        dataProvider:DataProvider? = nil,
        pagePresenter:PagePresenter? = nil,
        sceneObserver:PageSceneObserver? = nil
    ) {
        
        if !setting.initate {
            setting.initate = true
            SystemEnvironment.firstLaunch = true
        }
        
        self.apiManager = ApiManager()
        self.dataProvider = dataProvider ?? DataProvider()
        self.sceneObserver = sceneObserver
        self.pagePresenter = pagePresenter
        self.pagePresenter?.$currentPage.sink(receiveValue: { evt in
            self.apiManager.clear()
            self.sceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            self.retryRegisterPushToken()
        }).store(in: &anyCancellable)
        
        self.dataProvider.$event.sink(receiveValue: { evt in
            guard let apiQ = evt else { return }
            self.apiManager.load(q: apiQ)
            if apiQ.isLock {
                self.pagePresenter?.isLoading = true
            }else{
                self.sceneObserver?.isApiLoading = true
            }
        }).store(in: &anyCancellable)
        
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            switch res.type {
                default: do{}
            }
            
            DispatchQueue.main.async {
                self.dataProvider.result = res
                self.sceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            }
    
        }).store(in: &anyCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            DispatchQueue.main.async {
                self.dataProvider.error = err
                if !err.isOptional {
                    self.sceneObserver?.alert = .apiError(err)
                }
                self.sceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            }
        }).store(in: &anyCancellable)
        
        if self.setting.retryPushToken != "" {
            self.registerPushToken(self.setting.retryPushToken)
        }
        
    }

    func retryRegisterPushToken(){
        if self.setting.retryPushToken != "" {
            self.registerPushToken(self.setting.retryPushToken)
        }
    }
    
    func registerPushToken(_ token:String) {
        self.setting.retryPushToken = token
    }
    
    
    
}
