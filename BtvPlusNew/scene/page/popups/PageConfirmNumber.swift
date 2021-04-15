//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

extension PageConfirmNumber{
    enum InputType:String {
        case password, coupon, nickname, okcash
    }
}


struct PageConfirmNumber: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    @State var type:InputType = .password
    
    @State var movePage:PageObject? = nil
    @State var pwType:ScsNetwork.ConfirmType = ScsNetwork.ConfirmType.adult
    @State var couponType:CouponBlock.ListType = CouponBlock.ListType.coupon
    @State var title:String = ""
    @State var text:String = ""
    @State var placeHolder:String = ""
    @State var inputSize:Int = 0
    @State var inputSizeMin:Int? = nil
    @State var tip:String? = nil
    @State var msg:String? = nil // String.alert.watchLvInfoError
    @State var safeAreaBottom:CGFloat = 0
    @State var isFocus:Bool = false
    @State var isSecure:Bool = false
    @State var requestData:Any? = nil
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
                inputSizeMin: self.inputSizeMin,
                keyboardType: self.type == .nickname ? .default : .numberPad,
                isSecure : self.isSecure
            ){ input, _ in
                guard let input = input else {
                    self.closePage()
                    return
                }
                switch self.type {
                case .password : self.confirmPassword(input)
                case .coupon : self.resigistCoupon(input)
                case .nickname : self.modifyNickName(input)
                case .okcash : self.confirmOkCash(input)
                }
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
                self.confirmPasswordRespond(res)
            case .postCoupon :
                self.resigistCouponRespond(res)
            case .updateUser (let user):
                self.modifyNickNameRespond(res, updateData:user)
            case .getOkCashPoint :
                self.confirmOkCashRespond(res)
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            if err.id != self.tag { return }
            switch err.type {
            case .confirmPassword, .postCoupon, .updateUser:
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
            }else if let data = obj.getParamValue(key: .data) {
                self.requestData = data
            }
          
            if let type = obj.getParamValue(key: .type) as? ScsNetwork.ConfirmType {
                self.pwType = type
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
                self.type = .password
                self.isSecure = true
                
            } else if let type = obj.getParamValue(key: .type) as? CouponBlock.ListType  {
                self.couponType = type
                switch type {
                case .coupon:
                    self.title = String.pageText.myBenefitsCouponRegist
                    self.text = String.pageText.myBenefitsCouponInput
                case .point:
                    self.title = String.pageText.myBenefitsPointRegist
                    self.text = String.pageText.myBenefitsPointInput
                case .cash:
                    self.title = String.pageText.myBenefitsCashRegist
                    self.text = String.pageText.myBenefitsCashInput
                }
                self.inputSize = 16
                self.placeHolder = String.pageText.myBenefitsNumberTip
                self.type = .coupon
                self.isSecure = false
            } else if let type = obj.getParamValue(key: .type) as? Self.InputType  {
                self.type = type
                switch type {
                case .nickname:
                    self.title = String.pageText.myModifyNickname
                    self.text = String.pageText.myModifyNicknameText
                    self.tip = String.pageText.myModifyNicknameTip
                    self.placeHolder = String.app.nickNameHolder
                    self.inputSizeMin = 0
                    self.inputSize = 8
                    self.isSecure = false
                case .okcash:
                    self.title = String.alert.okCashDiscount
                    self.text = String.alert.okCashDiscountInput
                    self.inputSize = 4
                    self.isSecure = true
                
                default : break
                }
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
            if self.placeHolder.isEmpty {
                self.placeHolder = (1...self.inputSize).reduce("", { p, _ in p + "*"})
            }
            
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
        self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .cancel, data:self.pwType))
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
            self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .completed, data:self.pwType))
            self.closePage()
        } else{
            self.msg = String.alert.incorrecPassword
        }
    }
    
    func resigistCoupon(_ number:String){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        
        switch couponType {
        case .coupon:
            self.dataProvider.requestData(q: .init(id:self.tag, type: .postCoupon(self.pairing.hostDevice, number)))
        case .point:
            self.dataProvider.requestData(q: .init(id:self.tag, type: .postBPoint(self.pairing.hostDevice, number)))
        case .cash:
            self.dataProvider.requestData(q: .init(id:self.tag, type: .postBCash(self.pairing.hostDevice, number)))
        }
    }
    func resigistCouponRespond(_ res:ApiResultResponds){
        guard let resData = res.data as? RegistEps else {return}
        
        if resData.result == ApiCode.success {
            if let page = self.movePage {
                if page.isPopup {
                    self.pagePresenter.openPopup(page)
                } else {
                    self.pagePresenter.changePage(page)
                }
            }
            self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .completed, data:self.couponType))
            self.closePage()
        } else{
            self.msg = resData.reason
        }
    }
    
    func modifyNickName(_ name:String){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        let modifyData = ModifyUserData(nickName: name, characterIdx: self.pairing.user?.characterIdx)
        self.dataProvider.requestData(q: .init(id:self.tag, type: .updateUser(modifyData)))
        
    }
    
    func modifyNickNameRespond(_ res:ApiResultResponds, updateData:ModifyUserData?){
        guard let resData = res.data as? NpsResult else {return}
        if resData.header?.result == ApiCode.success {
            self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .completed, data:self.type))
            if let data = updateData {
                self.repository.updateUser(data)
            }
            self.closePage()
        } else{
            self.msg = resData.header?.reason ?? String.alert.apiErrorServer
        }
    }
   
    func confirmOkCash(_ pw:String){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        let item = self.requestData as? OcbItem
        self.dataProvider.requestData(q: .init(id:self.tag, type: .getOkCashPoint(self.pairing.hostDevice, item, pw)))
    }
    
    func confirmOkCashRespond(_ res:ApiResultResponds){
        guard let resData = res.data as? OkCashPoint else {return}
        if resData.result == ApiCode.success {
            self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .completed, data:self.type))
            self.closePage()
            
        } else{
            self.msg = String.alert.incorrecPassword
        }
    }
}

#if DEBUG
struct PageConfirmPassword_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageConfirmNumber().contentBody
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
