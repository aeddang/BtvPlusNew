//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

extension PageMyRegistCard{
    static let spacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.mediumExtra : Dimen.margin.medium
    static let titleSpacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin
}

struct PageMyRegistCard: PageView {
    
    enum EditType {
        case card, birth, gender, pw, foreigner, none
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var dataProvider:DataProvider 
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var title:String? = nil
    @State var editType:EditType = .none
    
    @State var cardType:CardBlock.ListType = .member
    @State var cardMasterSequence:Int = 1
    @State var cardNoFocus:Int = -1
    @State var cardNo:String? = nil
    @State var password:String = ""
    @State var gender:Gender = .mail
    @State var birthDate:Date? = nil
    @State var birth:String = ""
    @State var isForeigner:Bool = false
    @State var safeAreaBottom:CGFloat = 0
    @State var useEdit:[EditType] = []
        
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
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                            
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            marginBottom:self.safeAreaBottom,
                            isRecycle:false,
                            useTracking: true
                            ){
                            VStack(alignment:.leading ,
                                   spacing:Self.spacing) {
                                VStack(alignment:.leading, spacing:Self.titleSpacing){
                                    Text(String.app.cardno)
                                        .modifier(BoldTextStyle(size: Font.size.light))
                                    InputNumberGroupBox(
                                        isInit:true,
                                        focusIdx: self.$cardNoFocus,
                                        completed : {
                                            withAnimation{
                                                self.editType = .pw
                                            }
                                        }
                                    ){ no in
                                        self.cardNo = no
                                        withAnimation{
                                            self.editType = .card
                                        }
                                        
                                    }
                                }
                                if self.useEdit.firstIndex(of: .pw) != nil {
                                    VStack(alignment:.leading, spacing:0){
                                        Text(String.app.password)
                                            .modifier(BoldTextStyle(size: Font.size.light))
                                        Text(String.pageText.myRegistCardPasswordTip)
                                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                                            .multilineTextAlignment(.leading)
                                            .padding(.top, Dimen.margin.tiny)
                                        
                                        InputNumberGroupItem(
                                            idx: 0,
                                            input: self.$password,
                                            focusIdx: (self.cardNoFocus == -1)
                                                ? (self.editType == .pw ? 0  : -1)
                                                : -1,
                                            placeholder: String.pageText.myRegistCardPasswordPlaceHolder,
                                            isSecure: true,
                                            prev: {
                                                self.cardNoFocus = 3
                                            })
                                        .onTapGesture {
                                            self.cardNoFocus = -1
                                            withAnimation{
                                                self.editType = .pw
                                            }
                                        }
                                        .frame(height:Dimen.tab.regular)
                                        .padding(.top, Self.titleSpacing)
                                       
                                    }
                                }
                                
                                if self.useEdit.firstIndex(of: .foreigner) != nil {
                                    VStack(alignment:.leading, spacing:Self.titleSpacing){
                                        Text(String.app.local + "/" + String.app.foreigner)
                                            .modifier(BoldTextStyle(size: Font.size.light))
                                    
                                        HStack(spacing:Dimen.margin.thin){
                                            RadioButton(
                                                isChecked: !self.isForeigner,
                                                text: String.app.local
                                            ){idx in
                                                self.onForeignerSelected(isForeigner: false)
                                            }
                                            RadioButton(
                                                isChecked: self.isForeigner,
                                                text: String.app.foreigner
                                            ){idx in
                                                self.onForeignerSelected(isForeigner: true)
                                            }
                                        }
                                        .padding(.horizontal, Dimen.margin.thin)
                                        .frame(height:Dimen.tab.regular)
                                        .background(Color.app.blueLight)
                                    }
                                }
                                
                                if self.useEdit.firstIndex(of: .gender) != nil {
                                    VStack(alignment:.leading, spacing:Self.titleSpacing){
                                        Text(String.app.gender)
                                            .modifier(BoldTextStyle(size: Font.size.light))
                                         
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
                                        .frame(height:Dimen.tab.regular)
                                        .background(Color.app.blueLight)
                                    }
                                }
                                
                                if self.useEdit.firstIndex(of: .birth) != nil {
                                    VStack(alignment:.leading, spacing:Self.titleSpacing){
                                        Text(String.app.birthDay)
                                            .modifier(BoldTextStyle(size: Font.size.light))
                                           
                                        SortButton(
                                            text: self.birth,
                                            isFocus: self.editType == .birth,
                                            isFill:true,
                                            strokeColor: Color.app.blueLight
                                            )
                                        {
                                            self.doBirthSelect()
                                        }
                                        .opacity(self.birthDate == nil ? 0.5 : 1.0)
                                    }
                                }
                            }
                            .padding(.horizontal, SystemEnvironment.isTablet ? Dimen.margin.heavy : Dimen.margin.regular)
                        }//scroll
                        VStack(spacing:0){
                            Spacer()
                            FillButton(
                                text: String.button.regist2,
                                isSelected: self.isInputCompleted()
                            ){_ in
                                
                                self.inputCompleted()
                            }
                        }
                        .padding(.bottom, self.safeAreaBottom)
                    }
                    .modifier(MatchParent())
                    .background(Color.brand.bg)
                    
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
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.cardNoFocus = 0
                }
            }
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .onReceive(self.keyboardObserver.$isOn){ on in
                if self.pageObservable.layer != .top { return }
                self.updatekeyboardStatus(on:on)
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                switch res.type {
                case .postTMembership , .postOkCashPoint:
                    if !res.id.hasPrefix(self.tag) { return }
                    guard let result = res.data as? RegistEps else { return }
                    if result.result == ApiCode.success {
                        self.appSceneObserver.event = .toast(self.cardType == .member
                            ? String.pageText.myBenefitsRegistT
                            : String.pageText.myBenefitsRegistOk)
                        
                        self.appSceneObserver.event =
                            .update(.registCard(type: self.cardType))
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    } else {
                        let msg = result.reason?.replace("\\n", with: "\n") ?? String.alert.apiErrorServer
                        self.appSceneObserver.event = .toast(msg)
                    }
                    
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                switch err.type {
                case .postTMembership , .postOkCashPoint:
                    if !err.id.hasPrefix(self.tag) { return }
                    //on error
                default: break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let type = obj.getParamValue(key: .type) as? CardBlock.ListType {
                    self.cardType = type
                    switch type {
                    case .member :
                        self.title = String.pageTitle.myRegistCardMember
                        self.useEdit = [
                            .birth, .foreigner, .gender
                        ]
                    case .okCash :
                        self.title = String.pageTitle.myRegistCardOk
                        self.useEdit = [
                            .pw
                        ]
                        self.cardMasterSequence = obj.getParamValue(key: .index) as? Int ?? 1
                    default : break
                    }
                }
                self.birth = Date().toDateFormatter(dateFormat: "yyyy-MM-dd")
                self.updatekeyboardStatus(on:self.keyboardObserver.isOn)

            }
            .onDisappear{
        
            }
        }//geo
    }//body
    
    func updatekeyboardStatus(on:Bool) {
        withAnimation{
            self.safeAreaBottom = on
                ? self.keyboardObserver.keyboardHeight : self.sceneObserver.safeAreaBottom
        }
    }

    func isInputCompleted() -> Bool {
        if self.cardNo?.isEmpty != false{
            return false
        }
        
        let find = self.useEdit.first(where:{ edit in
            switch edit {
            case .pw :
                if self.password.count != 4{
                    return true
                }
            case .birth :
                if self.birthDate == nil{
                    return true
                }
            default : break
            }
            return false
        })
        return find == nil
    }
    
    func inputCompleted() {
        if self.cardNo?.isEmpty != false{
            self.appSceneObserver.event = .toast(String.pageText.myRegistCardEmptyCardNo)
            return
        }
        
        self.useEdit.forEach{ edit in
            switch edit {
            case .pw :
                if self.password.count != 4{
                    self.appSceneObserver.event = .toast(String.pageText.myRegistCardEmptyPassword)
                }
            case .birth :
                if self.birthDate == nil {
                    self.appSceneObserver.event = .toast(String.pageText.myRegistCardEmptyBirth)
                }
            default : break
            }
        }
        if !self.isInputCompleted() { return }
        let card = RegistCardData(
            no: self.cardNo ?? "",
            masterSequence: self.cardMasterSequence,
            isMaster: self.cardMasterSequence == 1,
            isForeigner: self.isForeigner,
            gender: self.gender,
            birth: self.birth,
            password: self.password)
        
        switch self.cardType {
        case .member :
            self.dataProvider.requestData(q: .init(id:self.tag, type: .postTMembership(self.pairing.hostDevice, card)))
        case .okCash :
            self.dataProvider.requestData(q: .init(id:self.tag, type: .postOkCashPoint(self.pairing.hostDevice, card)))
        default : break
        }
        self.sendLog()
    }
    
    private func sendLog() {
        let actionBody = MenuNaviActionBodyItem( category: self.cardType.title, target: self.cardMasterSequence.description)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
    }
    
    private func onGenderSelected(_ gen:Gender){
        self.gender = gen
        self.cardNoFocus = -1
        withAnimation{
            self.editType = .none
        }
        AppUtil.hideKeyboard()
        self.updatekeyboardStatus(on: false)
    }
    
    private func onForeignerSelected(isForeigner:Bool){
        self.isForeigner = isForeigner
        self.cardNoFocus = -1
        withAnimation{
            self.editType = .none
        }
        AppUtil.hideKeyboard()
    }
    
    private func doBirthSelect(){
        
        self.cardNoFocus = -1
        withAnimation{
            self.editType = .birth
        }
        self.appSceneObserver.select = .datePicker((self.tag, 100), self.birthDate ?? Date()){ date in
            if let date = date {
                self.birthDate = date
                self.birth = self.birthDate?.toDateFormatter(dateFormat: "yyyy-MM-dd") ?? ""
            }
            withAnimation{
                self.editType = .none
            }
        }
        AppUtil.hideKeyboard()
    }
}

#if DEBUG
struct PageMyRegistCard_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyRegistCard().contentBody
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
