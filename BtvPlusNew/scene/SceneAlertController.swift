//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import Foundation
import SwiftUI
import Combine

enum SceneAlert:Equatable {
    case recivedApns, apiError(ApiResultError), connectWifi , notFoundDevice
    static func ==(lhs: SceneAlert, rhs: SceneAlert) -> Bool {
        switch (lhs, rhs) {
        case ( .connectWifi, .connectWifi):return true
        case ( .notFoundDevice, .notFoundDevice):return true
        default: return false
        }
    }

}
enum SceneAlertResult {
    case complete(SceneAlert), error(SceneAlert) , cancel(SceneAlert), retry(SceneAlert)
}
struct DeclarationData:Identifiable {
    let id = UUID.init().uuidString
    let key:String
}

struct SceneAlertController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    
    @State var isShow = false
    @State var title:String? = nil
    @State var image:UIImage? = nil
    @State var text:String = ""
    @State var subText:String? = nil
    @State var buttons:[AlertBtnData] = []
    @State var currentAlert:SceneAlert? = nil
    @State var delayReset:AnyCancellable? = nil
    var body: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: self.$isShow,
            title: self.$title,
            image: self.$image,
            text: self.$text,
            subText: self.$subText,
            buttons: self.$buttons
        ){ idx in
            switch self.currentAlert {
            case .apiError(let data): self.selectedApi(idx, data:data)
            case .connectWifi: self.selectedConnectWifi(idx)
            case .notFoundDevice : self.selectedNotFoundDevice(idx)
            case .recivedApns: self.selectedRecivedApns(idx)
            default: do { return }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        
        }
        .onReceive(self.pageSceneObserver.$alert){ alert in
            self.reset()
            self.currentAlert = alert
            switch alert{
            case .apiError(let data): self.setupApi(data:data)
            case .connectWifi: self.setupConnectWifi()
            case .notFoundDevice: self.setupNotFoundDevice()
            case .recivedApns:
                let enable = self.setupRecivedApns()
                if !enable { return }
            default: do { return }
            }
            withAnimation{
                self.isShow = true
            }
        }
    }//body
    
    func reset(){
        if self.isShow { return }
        self.title = nil
        self.image = nil
        self.text = ""
        self.subText = nil
        self.buttons = []
        self.currentAlert = nil
    }

    func setupRecivedApns() -> Bool{
        guard let apns = self.appObserver.apns else { return false }
        guard let alert = apns["alert"] as? [String:String] else { return false }
        self.title = String.alert.apns
        self.text = alert["title"] as String? ?? ""
        self.subText = alert["body"] as String? ?? ""
        if (self.appObserver.page?.page) != nil {
            self.buttons = [
                AlertBtnData(title: String.app.cancel, index: 0), 
                AlertBtnData(title: String.app.corfirm, index: 1)
            ]
        }else{
            self.buttons = [
                AlertBtnData(title: String.app.corfirm, index: 0)
            ]
        }
        return true
    }
    
    func selectedRecivedApns(_ idx:Int) {
        if idx == 1 {
            guard let page = self.appObserver.page?.page else { return }
            if page.isPopup {
                self.pagePresenter.openPopup(page)
            }else{
                self.pagePresenter.changePage(page)
            }
        }
        self.appObserver.reset()
    }
    
    
    func setupApi(data:ApiResultError) {
        self.title = String.alert.api
        if let apiError = data.error as? ApiError {
            self.text = ApiError.getViewMessage(message: apiError.message)
        }else{
            if self.networkObserver.status == .none {
                self.text = String.alert.apiErrorClient
                
            }else{
                self.text = String.alert.apiErrorServer
            }
        }
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0),
        ]
    }
    func selectedApi(_ idx:Int, data:ApiResultError) {}
    
    func setupConnectWifi() {
        self.title = String.alert.connect
        self.text = String.alert.connectWifi
        self.subText = String.alert.connectWifiSub
        self.buttons = [
            AlertBtnData(title: String.app.retry, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedConnectWifi(_ idx:Int){
        if idx == 0 {
            self.pageSceneObserver.alertResult = .retry(.connectWifi)
        }else {
            self.pageSceneObserver.alertResult = .cancel(.connectWifi)
        }
    }
    
    func setupNotFoundDevice() {
        self.title = String.alert.connect
        self.text = String.alert.connectNotFound
        self.subText = String.alert.connectNotFoundSub
        self.buttons = [
            AlertBtnData(title: String.app.retry, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedNotFoundDevice(_ idx:Int) {
        if idx == 0 {
            self.pageSceneObserver.alertResult = .retry(.notFoundDevice)
        }else {
            self.pageSceneObserver.alertResult = .cancel(.notFoundDevice)
        }
    }
}


