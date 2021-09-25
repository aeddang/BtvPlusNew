//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

enum PageKidsConfirmType:String {
    case exit, exitSetup, deleteKid, watchLv
}
struct PageKidsConfirmNumber: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State var type:PageKidsConfirmType = .exit
    
    @State var movePage:PageObject? = nil
    @State var pwType:ScsNetwork.ConfirmType = ScsNetwork.ConfirmType.adult
    @State var title:String = ""
    @State var text:String = ""
    @State var eventId:String = ""
    @State var tip:String? = nil
    @State var msg:String? = nil
    @State var isInit:Bool = true
    @State var isFocus:Bool = true
    
    var body: some View {
        ZStack{
            InputNumberField(
                isInit:self.isInit,
                isFocus: self.isFocus,
                title: self.title,
                text: self.text,
                tip: self.tip,
                msg: self.msg
            ){ input in
                guard let input = input else {
                    self.closePage()
                    return
                }
                switch self.type {
                default : self.confirmPassword(input)
                }
            }
            .modifier(MatchParent())
            .onTapGesture {
                AppUtil.hideKeyboard()
            }
            /*
            InputNumberBox(
                isInit:self.isFocus,
                title: self.title,
                text: self.text,
                tip: self.tip,
                msg: self.msg
              
            ){ input in
                guard let input = input else {
                    self.closePage()
                    return
                }
                switch self.type {
                default : self.confirmPassword(input)
                }
            }
            .modifier(MatchParent())
            */
        }
        .modifier(MatchParent())
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .connected :
                self.initPage()
            case .connectError :
                self.closePage()
            default : break
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
            default :break
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            if res.id != self.tag { return }
            switch res.type {
            case .confirmPassword :
                self.confirmPasswordRespond(res)
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            if err.id != self.tag { return }
            switch err.type {
            case .confirmPassword:
                self.msg = String.alert.apiErrorClient
            default: break
            }
        }
        .onReceive(self.keyboardObserver.$isOn){ on in
            if self.pageObservable.layer != .top { return }
            
            PageLog.d("updatekeyboardStatus " + on.description, tag:self.tag)
            PageLog.d("updatekeyboardStatus isFocus " + isFocus.description, tag:self.tag)
            if self.isFocus != on { self.isFocus = on }
            
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            self.isFocus = true
            if ani { self.isInit = true }
        }
       
        .onAppear{
            guard let obj = self.pageObject  else { return }
            if let data = obj.getParamValue(key: .data) as? PageObject {
                self.movePage = data
            }
            if let eventId = obj.getParamValue(key: .id) as? String {
                self.eventId = eventId
            }
          
            if let type = obj.getParamValue(key: .type) as? PageKidsConfirmType {
                self.type = type
                switch type {
                case .exit:
                    self.pwType = .adult
                    self.title = String.alert.kidsExit
                    self.text = String.alert.kidsExitText
                case .exitSetup:
                    self.pwType = .adult
                    self.title = String.alert.KidsExitSetup
                    self.text = String.alert.KidsExitSetupText
                case .deleteKid:
                    self.pwType = .adult
                    self.title = String.alert.kidsDelete
                    self.text = String.alert.kidsDeleteText
                case .watchLv:
                    self.pwType = .adult
                    self.title = String.alert.watchLv
                    self.text = String.alert.watchLvInput
                    
                }
                self.tip = String.alert.passwordInitateInfo
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
        }
        .onDisappear{
            
        }
    }//body
    
    @State var isReady:Bool = false
    func initPage(){
        self.isReady = true
    }
    
    func closePage(){
        self.pagePresenter.onPageEvent(self.pageObject,
                                       event: .init( id: self.eventId, type: .cancel, data:self.type))
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
    
    func confirmPassword(_ pw:String){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        self.dataProvider.requestData(q: .init(id:self.tag, type: .confirmPassword(pw, self.pairing.hostDevice, self.pwType)))
    }
    
    func confirmPasswordRespond(_ res:ApiResultResponds){
        guard let resData = res.data as? ConfirmPassword else {return}
        if resData.result == ApiCode.success {
            switch self.pwType {
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
            self.pagePresenter.onPageEvent(self.pageObject,
                                           event: .init(id: self.eventId ,type: .completed, data:self.type))
            self.pagePresenter.closePopup(self.pageObject?.id)
        } else{
            self.msg = String.alert.incorrecPassword
        }
    }
}

#if DEBUG
struct PageKidsConfirmNumber_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsConfirmNumber().contentBody
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
