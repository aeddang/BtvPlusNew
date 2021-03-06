//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PagePairingSetupUser: PageView {
    enum EditType {
        case nickName, birth, none
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var title:String? = nil
    @State var pairingType:PairingRequest = .wifi
    @State var editType:EditType = .none
    
    @State var nickName:String = ""
    @State var characterIdx:Int = 0
    @State var gender:Gender = .mail
    @State var birth:String = ""
    
    @State var isAgree1:Bool = true
    @State var isAgree2:Bool = true
    @State var isAgree3:Bool = true
    @State var safeAreaBottom:CGFloat = 0
    @State var useTracking:Bool = false
    @State var reloadDegree:Double = 0
    let birthList = AppUtil.getYearRange(len: 100, offset:0).map{
        $0.description + String.app.year
    }
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
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
                            isRecycle:false,
                            useTracking: self.useTracking
                            ){
                            VStack(alignment:.leading , spacing:0) {
                                if self.editType != .nickName {
                                    Text(String.pageText.pairingSetupUserText1)
                                        .modifier(MediumTextStyle( size: Font.size.bold ))
                                        .padding(.top, Dimen.margin.light)
                                    
                                    Text(String.pageText.pairingSetupUserText2)
                                        .modifier(
                                            MediumTextStyle( size: Font.size.light, color: Color.app.whiteDeep))
                                        .padding(.top, Dimen.margin.light)
                                        .fixedSize(horizontal: false, vertical:true)
                                }
                                InputCell(
                                    title: String.app.nickName,
                                    input: self.$nickName,
                                    isFocus: self.editType == .nickName,
                                    placeHolder: String.app.nickNameHolder
                                )
                                .padding(.top, Dimen.margin.heavy)
                                
                                Text(self.nickName.isNickNameType()
                                    ? String.app.nickNameValidation
                                    : String.app.nickNameInvalidation)
                                    .modifier(MediumTextStyle(
                                        size: Font.size.tiny, color: Color.brand.primary
                                    ))
                                    .padding(.leading, Dimen.tab.titleWidth)
                                    .padding(.top, Dimen.margin.tiny)
                                
                                HStack(alignment:.center, spacing:0){
                                    Text(String.app.birth)
                                        .modifier(MediumTextStyle(size: Font.size.light))
                                        .frame(width:Dimen.tab.titleWidth, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    SortButton(
                                        text: self.birth,
                                        isFocus: self.editType == .birth){
                                        self.doBirthSelect()
                                    }
                                    Text(String.app.gender)
                                        .modifier(MediumTextStyle(size: Font.size.light))
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
                            .padding(.horizontal, Dimen.margin.regular)
                    
                            CharacterSelectBox(
                                data:CharacterRowData(),
                                selectIdx: self.$characterIdx )
                                .padding(.vertical, Dimen.margin.medium)
                            
                        }//scroll
                    }
                    .modifier(MatchParent())
                    .background(Color.brand.bg)
                    VStack{
                        CheckBox(
                            isChecked: .constant(
                                self.isAgree1 &&  self.isAgree2 && self.isAgree3
                            ),
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
                            isChecked: self.$isAgree1,
                            text:String.pageText.pairingSetupUserAgreement1,
                            more:{
                                
                            }
                        )
                        
                        CheckBox(
                            isChecked: self.$isAgree2,
                            text:String.pageText.pairingSetupUserAgreement2,
                            more:{
                                
                            }
                        )
                        CheckBox(
                            isChecked: self.$isAgree3,
                            text:String.pageText.pairingSetupUserAgreement3
                        )
                    }
                    .padding(.all, Dimen.margin.regular)
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
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.pageDragingModel.uiEvent = .draged(geometry, value)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in
                            self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in
                            self.pageDragingModel.uiEvent = .dragCancel})
                )
                
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted:
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    default : do{}
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
                
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
            }
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                //if self.editType == .nickName {return}
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .onReceive(self.keyboardObserver.$isOn){ on in
                self.updatekeyboardStatus(on:on)
            }
            .onReceive(self.appSceneObserver.$selectResult){ result in
                guard let result = result else { return }
                switch result {
                    case .complete(let type, let idx) : do {
                        if type.check(key: self.tag){
                            self.onBirthSelected(idx:idx)
                        }
                    }
                }
            }
            .onTapGesture {
                AppUtil.hideKeyboard()
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.birth = self.birthList[20]
                let type = obj.getParamValue(key: .type)
                self.pairingType = type as? PairingRequest ?? self.pairingType
                
                switch self.pairingType {
                case .btv : self.title = String.pageTitle.connectCertificationBtv
                case .user : self.title = String.pageTitle.connectCertificationUser
                default : self.title = String.pageTitle.connectWifi
                }
                
                if let user = self.pairing.user {
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
            self.safeAreaBottom = on
                ? self.keyboardObserver.keyboardHeight : self.sceneObserver.safeAreaBottom
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
        if !self.isInputCompleted() { return }
        self.pairing.user = User(
            nickName: self.nickName, characterIdx: self.characterIdx, gender: self.gender, birth: self.birth,
            isAgree1: self.isAgree1, isAgree2: self.isAgree2, isAgree3: self.isAgree3
        )
        //self.pagePresenter.goBack()
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
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingUser)
            )
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
        self.appSceneObserver.select = .picker((self.tag, self.birthList), pic)
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
