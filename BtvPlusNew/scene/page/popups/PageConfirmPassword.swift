//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageConfirmPassword: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    @State var movePage:PageObject? = nil
    
    @State var type:ScsNetwork.ConfirmType = ScsNetwork.ConfirmType.adult
    @State var title:String = ""
    @State var text:String = ""
    @State var placeHolder:String = ""
    @State var inputSize:Int = 0
    @State var tip:String? = nil
    @State var msg:String? = nil // String.alert.watchLvInfoError
    @State var safeAreaBottom:CGFloat = 0
    @State var isFocus:Bool = false
    
    var body: some View {
        ZStack{
            InputBox(
                isFocus:self.isFocus,
                isInit:self.isFocus,
                title: self.title,
                text: self.text,
                tip: self.tip,
                msg: self.msg,
                placeHolder: self.placeHolder,
                inputSize: self.inputSize,
                keyboardType: .numberPad,
                isSecure : true
            ){ input, _ in
                guard let input = input else {
                    self.closePage()
                    return
                }
                self.confirmPassword(input)
            }
            .padding(.bottom, self.safeAreaBottom)
            .modifier(MatchParent())
        }
        .modifier(MatchParent())
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .connected :
                self.initPage()
            case .connectError(let header) :
                self.appSceneObserver.alert = .pairingError(header)
            default : do{}
            }
        }
        .onReceive(self.pairing.$event){evt in
            guard let _ = evt else {return}
            switch evt {
            case .pairingCompleted :  self.initPage()
            case .disConnected : self.closePage()
            case .pairingCheckCompleted(let isSuccess) :
                if isSuccess { self.initPage() }
                else { self.appSceneObserver.alert = .pairingCheckFail }
            default : do{}
            }
        }
        .onReceive(self.pageObservable.$status){status in
            switch status {
            case .appear:
                DispatchQueue.main.async {
                    switch self.pairing.status {
                    case .pairing : self.pairing.requestPairing(.check)
                    case .unstablePairing : self.appSceneObserver.alert = .pairingRecovery
                    default :
                        self.appSceneObserver.alert = .needPairing(nil)
                        self.closePage()
                    }
                }
            default : do{}
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            if res.id != self.tag { return }
            switch res.type {
            case .confirmPassword :
                guard let resData = res.data as? ConfirmPassword else {return}
                if resData.result == ApiCode.success {
                    switch self.type {
                    case .adult: SystemEnvironment.isWatchAuth = true
                    case .purchase: SystemEnvironment.isPurchaseAuth = true
                    }
                    if let page = self.movePage {
                        if page.isPopup {
                            self.pagePresenter.openPopup(page)
                        } else {
                            self.pagePresenter.changePage(page)
                        }
                    }
                    self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .completed, data:self.type))
                    self.closePage()
                } else{
                    self.msg = String.alert.incorrecPassword
                }
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            if err.id != self.tag { return }
            switch err.type {
            case .confirmPassword :
                self.msg = String.alert.apiErrorClient
            default: break
            }
        }
        
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani { self.isFocus = true }
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
        .onAppear{
            guard let obj = self.pageObject  else { return }
            if let data = obj.getParamValue(key: .data) as? PageObject {
                self.movePage = data
            }
            if let type = obj.getParamValue(key: .type) as? ScsNetwork.ConfirmType {
                self.type = type
                switch type {
                case .adult:
                    self.inputSize = 4
                    self.title = String.alert.watchLv
                    self.text = String.alert.watchLvInput
                case .purchase:
                    self.inputSize = 4
                    self.title = String.alert.purchaseAuth
                    self.text = String.alert.purchaseAuthInput
                }
                self.tip = String.alert.passwordInitateInfo
            } else {
                self.inputSize = 4
            }
            
            if let title = obj.getParamValue(key: .title) as? String {
                self.title = title
            }
            if let text = obj.getParamValue(key: .text) as? String {
                self.text = text
            }
            if let tip = obj.getParamValue(key: .subText) as? String {
                self.tip  = tip 
            }
            self.placeHolder = (1...self.inputSize).reduce("", { p, _ in p + "*"})
        }
        .onReceive(self.keyboardObserver.$isOn){ on in
            if on {return}
            if !self.isReady {return}
            self.pagePresenter.closePopup(self.pageObject?.id)
        }
        .onDisappear{
            
        }
    }//body
    
    @State var isReady:Bool = false
    func initPage(){
        self.isReady = true
    }
    
    func closePage(){
        self.isFocus = false
        self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .cancel, data:self.type))
    }
    
    func confirmPassword(_ pw:String){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        self.dataProvider.requestData(q: .init(id:self.tag, type: .confirmPassword(pw, self.pairing.hostDevice, .adult)))
    }
    
}

#if DEBUG
struct PageConfirmPassword_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageConfirmPassword().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
