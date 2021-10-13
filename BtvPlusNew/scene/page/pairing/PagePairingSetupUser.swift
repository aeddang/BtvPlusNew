//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PagePairingSetupUser {
    static private(set) var pairingInType:String? = nil
}

struct PagePairingSetupUser: PageView {
    enum EditType {
        case nickName, birth, none
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var title:String? = nil
    @State var pairingType:PairingRequest = .wifi()
   
    @State var editType:EditType = .none
    @State var nickName:String = ""
    @State var characterIdx:Int = 0
    @State var gender:Gender = .mail
    @State var birth:String = ""
    
    @State var isAgree1:Bool = true
    @State var isAgree2:Bool = true
    @State var isAgree3:Bool = true
    @State var safeAreaBottom:CGFloat = 0
   
    let birthList = AppUtil.getYearRange(len: 100, offset:0).map{
        $0.description + String.app.year
    }
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.title,
                        isClose: true
                    ){
                        self.appSceneObserver.alert = .confirm(String.alert.connectCancel, String.alert.connectCancelText,  confirmText: String.button.end) { isOk in
                            if isOk { self.pagePresenter.closePopup(self.pageObject?.id) }
                        }
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                            
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            isRecycle:false,
                            useTracking: true
                            ){
                            VStack(alignment:.leading , spacing:0) {
                                //if self.editType != .nickName {
                                Text(String.pageText.pairingSetupUserText1)
                                    .modifier(MediumTextStyle( size: Font.size.bold ))
                                    .padding(.top, Dimen.margin.light)
                                
                                Text(SystemEnvironment.isTablet
                                        ? String.pageText.pairingSetupUserText2Tablet : String.pageText.pairingSetupUserText2)
                                    .modifier(
                                        MediumTextStyle( size: Font.size.light, color: Color.app.greyLight))
                                    .padding(.top, Dimen.margin.regular)
                                    .fixedSize(horizontal: false, vertical:true)
                                //}
                                InputCell(
                                    title: String.app.nickName,
                                    input: self.$nickName,
                                    isFocus: self.editType == .nickName,
                                    placeHolder: String.app.nickNameHolder,
                                    message: self.nickName.isEmpty
                                        ? " "
                                        : self.nickName.isNickNameType()
                                            ? String.app.nickNameValidation
                                            : String.app.nickNameInvalidation
                                )
                                .padding(.top, Dimen.margin.heavy)
                                
                                HStack(alignment:.center, spacing:0){
                                    Text(String.app.birth)
                                        .modifier(BoldTextStyle(size: Font.size.light))
                                        .frame(width:Dimen.tab.titleWidth, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    SortButton(
                                        text: self.birth,
                                        isFocus: self.editType == .birth){
                                        self.doBirthSelect()
                                    }
                                    Text(String.app.gender)
                                        .modifier(BoldTextStyle(size: Font.size.light))
                                        .padding(.horizontal, Dimen.margin.thin)
                        
                                    HStack(spacing:Dimen.margin.thin){
                                        RadioButton(
                                            isChecked: self.gender == .mail,
                                            text: String.app.mail
                                        ){idx in
                                            self.onGenderSelected(.mail)
                                        }
                                        RadioButton(
                                            isChecked: self.gender == .femail,
                                            text: String.app.femail
                                        ){idx in
                                            self.onGenderSelected(.femail)
                                        }
                                    }
                                    .padding(.horizontal, Dimen.margin.thin)
                                    .modifier(MatchHorizontal(height: Dimen.tab.regular))
                                    .background(Color.app.blueLight)
                                }
                                .padding(.top, Dimen.margin.thin)
                                
                            }
                            .padding(.horizontal, SystemEnvironment.isTablet ? Dimen.margin.heavy : Dimen.margin.regular)
                    
                            CharacterSelectBox(
                                data:CharacterRowData(),
                                selectIdx: self.$characterIdx )
                                .padding(.vertical, Dimen.margin.medium)
                            
                        }//scroll
                    }
                    .modifier(MatchParent())
                    .background(Color.brand.bg)
                    VStack(spacing: Dimen.margin.thin){
                        CheckBox(
                            isChecked: self.isAgree1 &&  self.isAgree2 && self.isAgree3,
                            text:String.pageText.pairingSetupUserAgreementAll,
                            isStrong:true,
                            action:{ ck in
                                let isAll = self.isAgree1 &&  self.isAgree2 && self.isAgree3
                                self.isAgree1 = !isAll
                                self.isAgree2 = !isAll
                                self.isAgree3 = !isAll
                            }
                        )
                        
                        CheckBox(
                            isChecked: self.isAgree1,
                            text:String.pageText.pairingSetupUserAgreement1,
                            more:{
                                self.pagePresenter.openPopup(
                                    PageProvider
                                        .getPageObject(.webview)
                                        .addParam(key: .data, value: BtvWebView.serviceTerms)
                                        .addParam(key: .title , value: String.pageTitle.serviceTerms)
                                )
                            },
                            action:{ ck in
                                self.isAgree1 = ck
                            }
                        )
                        
                        CheckBox(
                            isChecked: self.isAgree2,
                            text:String.pageText.pairingSetupUserAgreement2,
                            more:{
                                self.pagePresenter.openPopup(
                                    PageProvider
                                        .getPageObject(.privacyAndAgree)
                                )
                            },
                            action:{ ck in
                                self.isAgree2 = ck
                            }
                        )
                        .onReceive(self.pagePresenter.$event){ evt in
                            if evt?.id != "PagePrivacyAndAgree" {return}
                            guard let evt = evt else {return}
                            switch evt.type {
                            case .completed :
                                self.isAgree2 = true
                            case .cancel :
                                self.isAgree2 = false
                            default : break
                            }
                        }
                        
                        CheckBox(
                            isChecked: self.isAgree3,
                            text:String.pageText.pairingSetupUserAgreement3,
                            action:{ ck in
                                self.isAgree3 = ck
                            }
                        )
                    }
                    .padding(.horizontal, SystemEnvironment.isTablet ? Dimen.margin.heavy : Dimen.margin.regular)
                    .padding(.vertical, Dimen.margin.regular)
                    .background(Color.app.blueLight)
                    FillButton(
                        text: String.button.next,
                        isSelected: self.isInputCompleted()
                    ){_ in
                        
                        self.inputCompleted()
                    }
                    .padding(.bottom, self.safeAreaBottom)
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .down, .up :
                        if self.keyboardObserver.isOn { AppUtil.hideKeyboard() }
                    case .pullCompleted:
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    default : break
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
                
            }
            .onReceive(self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ pos in
                //if self.editType == .nickName {return}
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .onReceive(self.keyboardObserver.$isOn){ on in
                if self.pageObservable.layer != .top { return }
                self.updatekeyboardStatus(on:on)
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.birth = self.birthList[30]
                let type = obj.getParamValue(key: .type)
                Self.pairingInType = obj.getParamValue(key: .subType) as? String ?? "mob-my"
                self.pairingType = type as? PairingRequest ?? self.pairingType
                
                switch self.pairingType {
                case .btv : self.title = String.pageTitle.connectCertificationBtv
                case .user : self.title = String.pageTitle.connectCertificationUser
                default : self.title = String.pageTitle.connectWifi
                }
                
                if self.pairing.status == .pairing ,let user = self.pairing.user {
                    self.nickName = user.nickName
                    self.characterIdx = user.characterIdx
                    self.birth = user.birth
                    self.gender = user.gender
                    self.isAgree1 = user.isAgree1
                    self.isAgree2 = user.isAgree2
                    self.isAgree3 = user.isAgree3
                }
                self.updatekeyboardStatus(on:self.keyboardObserver.isOn)

            }
            .onDisappear{
            
            }
        }//geo
    }//body
    
    func updatekeyboardStatus(on:Bool) {
        withAnimation{
            self.editType = on
                ? .nickName
                : self.editType == .nickName ? .none : self.editType
        
        }
    }

    func isInputCompleted() -> Bool {
        var complete = false
        if self.nickName.isNickNameType() && self.isAgree1 && self.isAgree2 {
            complete = true
        }
        return complete
    }
    
    func inputCompleted() {
        if self.nickName.isEmpty {
            self.appSceneObserver.event = .toast(String.alert.needNickName)
            return
        }
        if !self.isAgree1 {
            self.appSceneObserver.event = .toast(String.alert.needAgreeTermsOfService)
            return
        }
        if !self.isAgree2 {
            self.appSceneObserver.event = .toast(String.alert.needAgreePrivacy)
            return
        }
        
        if !self.isInputCompleted() { return }
        self.pairing.user = User(
            nickName: self.nickName, pairingDate: nil, characterIdx: self.characterIdx, gender: self.gender, birth: self.birth,
            isAgree1: self.isAgree1, isAgree2: self.isAgree2, isAgree3: self.isAgree3
        )
        //self.pagePresenter.goBack()
        
        self.naviLogManager.actionLog(.clickProfileConfirm,
                                      actionBody: .init(
                                        menu_id: self.characterIdx.description,
                                        menu_name: Asset.characterList[self.characterIdx]),
                                       memberBody: .init(
                                        gender: self.gender.logValue(),
                                        birthyear: self.birth,
                                        nickname: self.nickName))
        
        
        
        self.pagePresenter.closePopup(self.pageObject?.id)
        switch self.pairingType {
        case .btv :
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingBtv)
            )
        case .wifi :
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingDevice)
                    .addParam(key: .type, value: self.pairingType)
            )
        case .user :
            self.appSceneObserver.alert = .alert(String.alert.userCertification, String.alert.userCertificationPairing){
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.pairingUser)
                )
            }
            
        case .recovery :
            self.pairing.requestPairing(.recovery)
        default : do{}
        }
        
        
    }
    
    private func onGenderSelected(_ gen:Gender){
        AppUtil.hideKeyboard()
        self.gender = gen
        withAnimation{
            self.editType = .none
        }
    }
    
    private func onCharacterSelected(){
        AppUtil.hideKeyboard()
        withAnimation{
            self.editType = .none
        }
    }
    
    private func doBirthSelect(){
        AppUtil.hideKeyboard()
        withAnimation{
            self.editType = .birth
        }
        let pic = self.birthList.firstIndex(of: self.birth) ?? 0
        self.appSceneObserver.select = .picker((self.tag, self.birthList), pic){ idx in
            self.onBirthSelected(idx:idx)
        }
    }
    
    private func onBirthSelected(idx:Int){
        self.birth = self.birthList[idx]
        withAnimation{
            self.editType = .none
        }
    }

}

#if DEBUG
struct PagePairingSetupUser_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingSetupUser().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 565, height: 640, alignment: .center)
        }
    }
}
#endif
