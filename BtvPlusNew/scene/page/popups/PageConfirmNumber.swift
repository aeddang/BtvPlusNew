//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

extension PageConfirmNumber{
    enum InputType:Equatable{
        case password, coupon, nickname,
             okcash(OcbItem?), okcashMaster(RegistCardData)
        
        func keyboardType() -> UIKeyboardType {
            switch self {
            case .nickname : return .default
            default : return .numberPad
            }
        }
        
        var errorMsg:String {
            switch self {
           // case .coupon : return 서버메시지
            case .okcashMaster, .okcash: return String.alert.okCashIncorrecPassword
            default : return String.alert.incorrecPassword
            }
        }
        static func == (lhs: InputType, rhs: InputType) -> Bool {
            switch (lhs, rhs) {
            case ( .password, .password):return true
            case ( .coupon, .coupon):return true
            case ( .nickname, .nickname):return true
            case ( .okcash, .okcash):return true
            case ( .okcashMaster, .okcashMaster):return true
            default: return false
            }
        }
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
    
    @State var type:InputType = .password
    
    @State var movePage:PageObject? = nil
    @State var pwType:ScsNetwork.ConfirmType = ScsNetwork.ConfirmType.adult
    @State var couponType:CouponBlock.ListType = CouponBlock.ListType.coupon
    @State var eventId:String = ""
    @State var title:String = ""
    @State var text:String = ""
    @State var placeHolder:String = ""
    @State var inputSize:Int = 4
    @State var inputSizeMin:Int? = nil
    @State var tip:String? = nil
    @State var msg:String? = nil // String.alert.watchLvInfoError
    @State var safeAreaBottom:CGFloat = Dimen.app.keyboard
    @State var isFocus:Bool = false
    @State var isSecure:Bool = false
    @State var isComplete:Bool = false
    @State var isCancel:Bool = false
    @State var input:String = ""
    var body: some View {
        ZStack{
            InputBox(
                input: self.$input,
                isFocus:self.isFocus,
                isInit:self.isFocus,
                title: self.title,
                text: self.text,
                tip: self.tip,
                msg: self.msg,
                placeHolder: self.placeHolder,
                inputSize: self.inputSize,
                inputSizeMin: self.inputSizeMin,
                isInputNickName: self.type == .nickname,
                isInputDivision: self.type == .coupon,
                keyboardType: self.type.keyboardType(),
                isSecure : self.isSecure,
                changed:{ input, _ in
                    guard let input = input else { return }
                    switch self.type {
                    case .nickname :
                        if !input.isNickNameType() {
                            self.msg = String.app.nickNameInvalidation
                        } else {
                            self.msg = nil
                        }
                    default: break
                    }
                },
                action :{ input, _ in
                    
                    guard let input = input else {
                        self.closePage()
                        return
                    }
                    switch self.type {
                    case .password : self.confirmPassword(input)
                    case .coupon : self.resigistCoupon(input)
                    case .nickname : self.modifyNickName(input)
                    case .okcash(let data) : self.confirmOkCash(input, card:data)
                    case .okcashMaster(let data) : self.confirmOkCashMaster(input, card: data)
                    }
                }
            )
            .padding(.bottom, self.safeAreaBottom)
            .modifier(MatchParent())
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
        .onReceive(self.pagePresenter.$currentTopPage){top in
            if self.pageObject != top {
                self.closePage()
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
            default : break
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) { return }
            switch res.type {
            case .confirmPassword :
                self.confirmPasswordRespond(res)
            case .postCoupon, .getStbInfo, .certificationCoupon, .postBPoint, .postBCash :
                self.resigistCouponRespond(res)
            case .updateUser (let user):
                self.modifyNickNameRespond(res, updateData:user)
            case .getOkCashPoint :
                self.confirmOkCashRespond(res)
            case .updateOkCashPoint :
                self.confirmOkCashMasterRespond(res)
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            if err.id != self.tag { return }
            switch err.type {
            case .confirmPassword, .postCoupon, .updateUser,
                 .postBPoint, .postBCash, .updateOkCashPoint, .getStbInfo:
                self.msg = String.alert.apiErrorClient
                //self.input = ""
            case .certificationCoupon:
                self.msg = String.alert.couponRegistIncorrectFail.replace(self.couponType.name)
                self.input = ""
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
        .onReceive(self.keyboardObserver.$isOn){ on in
            if on {return}
            if !self.isReady {return}
            self.pagePresenter.closePopup(self.pageObject?.id)
        }
        .onAppear{
            guard let obj = self.pageObject  else { return }
            if let data = obj.getParamValue(key: .data) as? PageObject {
                self.movePage = data
            }
            if let eventId = obj.getParamValue(key: .id) as? String {
                self.eventId = eventId
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
                if let input = obj.getParamValue(key: .data) as? String {
                    self.input = input
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
                case .okcashMaster:
                    self.title = String.alert.okCashMaster
                    self.text = String.alert.okCashMasterInput
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
            if let value = obj.getParamValue(key: .value) as? String {
                self.input = value
            }
            if self.placeHolder.isEmpty {
                self.placeHolder = (1...self.inputSize).reduce("", { p, _ in p + "*"})
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
        self.isFocus = true
        self.closePageImmediately()
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.closePageImmediately()
        }*/
    }
    func closePageImmediately(){
        //self.isFocus = false
        AppUtil.hideKeyboard()
        if !self.isComplete && !self.isCancel {
            self.isCancel = true
            self.pagePresenter.onPageEvent(self.pageObject,
                                           event: .init(id: self.eventId, type: .cancel, data:self.pwType))
        }
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
                                           event: .init(id: self.eventId ,type: .completed, data:self.pwType))
            self.isComplete = true
            self.closePage()
        } else{
            self.input = ""
            self.msg = self.type.errorMsg
            
        }
    }
    
    func resigistCoupon(_ number:String){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        
        switch couponType {
        case .coupon:
            self.dataProvider.requestData(q: .init(id:self.tag, type: .getStbInfo(self.pairing.hostDevice) ))
            //self.dataProvider.requestData(q: .init(id:self.tag, type: .postCoupon(self.pairing.hostDevice, number)))
        case .point:
            self.dataProvider.requestData(q: .init(id:self.tag, type: .postBPoint(self.pairing.hostDevice, number)))
        case .cash:
            self.dataProvider.requestData(q: .init(id:self.tag, type: .postBCash(self.pairing.hostDevice, number)))
        }
    }
    func resigistCouponRespond(_ res:ApiResultResponds){
        if let resData = res.data as? RegistEps {
            if resData.result == ApiCode.success {
                self.registCouponSuccess()
            } else{
                self.input = ""
                self.msg = String.alert.couponRegistIncorrectFail.replace(self.couponType.name)
            }
        } else if let  resData = res.data as? StbInfo {
            if resData.result == ApiCode.success {
                self.dataProvider.requestData(
                    q: .init(id:self.tag, type: .certificationCoupon(self.input, resData), isOptional: true ))
                    // 에러메시지가 빈값임..... 옵셔널로 보내고 에러처리는 수동
            } else{
                self.input = ""
                self.msg = String.alert.couponRegistIncorrectFail.replace(self.couponType.name)
            }
        } else if let _ = res.data as? CertificationCoupon {
            self.registCouponSuccess()
            //성공이면 결과값이 들어옴 규격대로 안되있음 내시간..... 108108
            /*
            if resData.result == ApiCode.success2 {
                
            } else{
                self.input = ""
                self.msg = CbsNetwork.getCertificationErrorMeassage(resData.result , reason: resData.reason)
            }*/
        }
    }
    
    private func registCouponSuccess(){
        if let page = self.movePage {
            if page.isPopup {
                self.pagePresenter.openPopup(page)
            } else {
                self.pagePresenter.changePage(page)
            }
        }
        self.appSceneObserver.event = .toast(String.alert.couponRegistSuccess.replace(self.title))
        self.pagePresenter.onPageEvent(self.pageObject,
                                       event: .init(id: self.eventId , type: .completed, data:self.couponType))
        self.isComplete = true
        self.closePage()
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
            self.pagePresenter.onPageEvent(self.pageObject,
                                           event: .init(id : self.eventId, type: .completed, data:self.type))
            if let data = updateData {
                self.repository.updateUser(data)
            }
            self.isComplete = true
            self.closePage()
        } else{
            self.input = ""
            self.msg = resData.header?.reason ?? String.alert.apiErrorServer
        }
    }
   
    func confirmOkCash(_ pw:String, card:OcbItem?){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        
        self.dataProvider.requestData(q: .init(id:self.tag, type: .getOkCashPoint(self.pairing.hostDevice, card, pw)))
    }
    
    func confirmOkCashRespond(_ res:ApiResultResponds){
        guard let resData = res.data as? OkCashPoint else {return}
        if resData.result == ApiCode.success {
            self.pagePresenter.onPageEvent(self.pageObject,
                                           event: .init(id : self.eventId, type: .completed, data:self.type))
            self.isComplete = true
            self.closePage()
            
        } else{
            self.input = ""
            self.msg = self.type.errorMsg
        }
    }
    
    func confirmOkCashMaster(_ pw:String, card:RegistCardData){
        if !self.isReady {
            self.appSceneObserver.event = .toast(String.alert.checkConnectStatus)
            return
        }
        var masterCard = card
        masterCard.password = pw
        self.dataProvider.requestData(q: .init(id:self.tag, type: .updateOkCashPoint(self.pairing.hostDevice, masterCard)))
    }
    
    func confirmOkCashMasterRespond(_ res:ApiResultResponds){
        guard let resData = res.data as? RegistEps else {return}
        if resData.result == ApiCode.success {
            self.closePage()
        } else{
            self.input = ""
            self.msg = self.type.errorMsg
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
