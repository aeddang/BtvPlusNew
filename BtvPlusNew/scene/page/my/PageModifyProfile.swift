//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageModifyProfile: PageView {
    enum EditType {
        case nickName, none
    }
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
   
    @State var editType:EditType = .none
    
    @State var nickName:String = ""
    @State var characterIdx:Int = 0
  
    @State var safeAreaBottom:CGFloat = 0
     
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.modifyProfile,
                        isClose: true
                    )
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
                                if self.editType != .nickName {
                                    Text(String.pageText.modifyProfileText1)
                                        .modifier(MediumTextStyle( size: Font.size.bold ))
                                        .padding(.top, Dimen.margin.light)
                                    
                                    Text(String.pageText.modifyProfileText2)
                                        .modifier(MediumTextStyle( size: Font.size.light, color: Color.app.whiteDeep))
                                        .padding(.top, Dimen.margin.light)
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
                    default : do{}
                    }
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
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
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                switch res.type {
                case .updateUser : self.onUpdatedData(res)
                default: do{}
                }
            }
            .onReceive(self.dataProvider.$error){ err in
                guard let err = err else { return }
                switch err.type {
                case .updateUser : self.onErrorData()
                default: do{}
                }
            }
            .onAppear{
                if let user = self.pairing.user {
                    self.nickName = user.nickName
                    self.characterIdx = user.characterIdx
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
        if self.nickName.isNickNameType() { complete = true }
        return complete
    }
    
    func inputCompleted() {
        if !self.isInputCompleted() { return }
        guard let user = self.pairing.user else { return }
        if self.nickName != user.nickName{
            let modifyData = ModifyUserData(nickName: self.nickName, characterIdx: self.characterIdx)
            self.dataProvider.requestData(q: .init(type: .updateUser(modifyData), isOptional: false))
        }else{
            self.modifyCompleted()
        }
    }
   
    func onUpdatedData(_ res:ApiResultResponds){
        guard let data = res.data as? NpsResult  else { return errorResult() }
        guard let resultCode = data.header?.result else { return errorResult() }
        if resultCode == NpsNetwork.resultCode.success.code {
            modifyCompleted()
        } else {
            errorResult()
        }
    }
    func onErrorData(){
        AppUtil.hideKeyboard()
    }
    
    private func errorResult(){
        AppUtil.hideKeyboard()
        self.appSceneObserver.alert = .alert(String.alert.connect, String.alert.needConnectStatus)
    }
    
    private func modifyCompleted() {
        AppUtil.hideKeyboard()
        let modifyData = ModifyUserData(nickName: self.nickName, characterIdx: self.characterIdx)
        self.repository.updateUser(modifyData)
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
    
    private func onCharacterSelected(){
        AppUtil.hideKeyboard()
        withAnimation{
            self.editType = .none
        }
    }
    
}

#if DEBUG
struct PageModifyProfile_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageModifyProfile().contentBody
                .environmentObject(Repository())
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
