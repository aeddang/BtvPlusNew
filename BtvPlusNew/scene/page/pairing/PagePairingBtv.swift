//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePairingBtv: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var input:String = ""
    @State var safeAreaBottom:CGFloat = 0
    @State var isInput = false
    @State var isFocus = false
    @State var sceneOrientation: SceneOrientation = .portrait
    @State var errorMsg:String? = nil
    
    struct TextBlock:PageComponent {
        var body :some View {
            VStack(alignment:.leading , spacing:0) {
                Text(String.pageText.pairingBtvText1)
                    .modifier(MediumTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.boldExtra : Font.size.bold ))
                    .padding(.top, Dimen.margin.light)
                    .fixedSize(horizontal: false, vertical:true)
                Text(String.pageText.pairingBtvText2)
                    .modifier(MediumTextStyle( size: Font.size.light ))
                    .padding(.top, Dimen.margin.regular)
                Text(String.pageText.pairingBtvText3)
                    .modifier(MediumTextStyle( size: Font.size.thin ))
                    .padding(.top, Dimen.margin.tinyExtra)
                Text(String.pageText.pairingBtvText4)
                    .modifier(MediumTextStyle( size: Font.size.thin ))
                    .padding(.top, Dimen.margin.tinyExtra)
                Text(String.pageText.pairingBtvText5)
                    .modifier(MediumTextStyle( size: Font.size.thin ))
                    .padding(.top, Dimen.margin.tinyExtra)
                
            }
        }
    }
    struct InputBlock:PageComponent {
        @Binding var input:String
        @Binding var isFocus:Bool
        @Binding var msg:String?
        var body :some View {
            VStack(alignment:.center , spacing:Dimen.margin.regularExtra) {
                
                HStack(alignment:.center, spacing:Dimen.margin.light){
                    Text(String.app.certificationNumber)
                        .modifier(BoldTextStyle(size: Font.size.light))
                        //.padding(.top, (Font.size.black - Font.size.light)/2)
                    VStack(alignment: .center, spacing:Dimen.margin.tiny){
                        FocusableTextField(
                            text:self.$input,
                            keyboardType: .numberPad, returnVal: .done,
                            placeholder: String.app.certificationNumberHolder,
                            placeholderColor: Color.app.blackLight,
                            maxLength: 6,
                            kern: 8,
                            textModifier: BoldTextStyle(
                                size: Font.size.black )
                                .textModifier,
                            isfocus: self.isFocus,
                            inputChanged: { _ in
                                if self.msg != nil {
                                    msg = nil
                                }
                            },
                            inputCopmpleted: { text in
                                self.isFocus = false
                            })
                            .frame(height:Font.size.black)
                        Spacer().modifier(MatchHorizontal(height: 1))
                            .background(Color.app.blackLight)
                        /*
                        if let msg = self.msg {
                            Text(msg)
                                .modifier(BoldTextStyle(size: Font.size.microUltra, color:Color.brand.primary))
                        }*/
                    }
                    .frame(width:SystemEnvironment.isTablet ? 250 : 173)
                }
            }
        }
    }
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    if !self.isInput || self.sceneOrientation == .portrait {
                        PageTab(
                            title: String.pageTitle.connectCertificationBtv,
                            isClose: true,
                            style:.dark
                        ){
                            self.appSceneObserver.alert = .confirm(String.alert.connectCancel, String.alert.connectCancelText,  confirmText: String.button.end) { isOk in
                                if isOk { self.pagePresenter.closePopup(self.pageObject?.id) }
                            }
                        }
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    }
                    if self.sceneOrientation == .portrait {
                        VStack(alignment:.leading , spacing:Dimen.margin.regularExtra) {
                            if !self.isInput {
                                TextBlock()
                                    .padding(.vertical, Dimen.margin.regularExtra)
                                    .padding(.horizontal, Dimen.margin.regular)
                            }
                            VStack(alignment:.center , spacing:0) {
                                Image(Asset.image.pairingTutorial)
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height:SystemEnvironment.isTablet ? 336 : 200)
                                
                                InputBlock(input: self.$input, isFocus: self.$isFocus, msg:self.$errorMsg)
                                    .padding(.top, Dimen.margin.regularExtra)
                                
                                if let errorMsg = self.errorMsg {
                                    Text(errorMsg)
                                        .multilineTextAlignment(.leading)
                                        .modifier(MediumTextStyle(
                                            size: Font.size.tiny, color: Color.brand.primary
                                        ))
                                        .padding(.top, Dimen.margin.tiny)
                                }
                                Spacer().modifier(MatchParent())
                            }
                        }
                        .modifier(MatchParent())
                        
                    } else {
                        HStack(alignment:.center , spacing:0) {
                            VStack(alignment:.center , spacing:0) {
                                if !self.isInput {
                                    TextBlock()
                                        .padding(.horizontal, Dimen.margin.regular)
                                        .modifier(MatchParent())
                                } else {
                                    Spacer().modifier(MatchHorizontal(height: 0))
                                }
                                InputBlock(input: self.$input, isFocus: self.$isFocus, msg:self.$errorMsg)
                                    .padding(.vertical, Dimen.margin.medium)
                                if let errorMsg = self.errorMsg {
                                    Text(errorMsg)
                                        .multilineTextAlignment(.leading)
                                        .modifier(MediumTextStyle(
                                            size: Font.size.tiny, color: Color.brand.primary
                                        ))
                                        .padding(.top, Dimen.margin.tiny)
                                }
                            }
                           
                            Image(Asset.image.pairingTutorial)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .modifier(MatchParent())
                                
                        }
                        .padding(.vertical, Dimen.margin.light)
                        
                    }
                    FillButton(
                        text: String.button.connect,
                        isSelected: self.isInputCompleted()
                    ){_ in
                        self.naviLogManager.actionLog(.clickConnectConfirm, pageId:.pairingAuthNumber,
                                                      actionBody: .init(config:PairingType.wifi.logPageConfig))
                        self.inputCompleted()
                    }
                    .padding(.bottom, self.safeAreaBottom)
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                if self.isInput {return}
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                withAnimation{
                    self.safeAreaBottom = self.sceneObserver.safeAreaBottom
                }
            }
            .onReceive(self.keyboardObserver.$isOn){ on in
                PageLog.d("keyboardObserver " + on.description, tag:self.tag)
                self.updatekeyboardStatus(on:on)
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    DispatchQueue.main.async {
                        self.isFocus = true
                        self.updatekeyboardStatus(on:true)
                        
                        self.naviLogManager.actionLog(.pageShow, pageId:.pairingAuthNumber)
                    }
                }
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .connected : 
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .connectError(let header, _) :
                    if header?.result == NpsNetwork.resultCode.pairingLimited.code {
                        self.appSceneObserver.alert = .limitedDevice(nil)
                    } else if header?.result == NpsNetwork.resultCode.authcodeWrong.code {
                        self.errorMsg = NpsNetwork.getConnectErrorMeassage(data: header)
                    }else {
                        self.appSceneObserver.alert = .pairingError(header)
                    }
                case .connectErrorReason(let info) :
                    self.appSceneObserver.alert = .limitedDevice(info)
                default : break
                }
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
    func updatekeyboardStatus(on:Bool) {
        PageLog.d("updatekeyboardStatus " + on.description, tag:self.tag)
        PageLog.d("updatekeyboardStatus isFocus " + isFocus.description, tag:self.tag)
        PageLog.d("updatekeyboardStatus isInput " + isInput.description, tag:self.tag)
        if self.isFocus != on { self.isFocus = on }
        if self.isInput == on { return }
        withAnimation{
            self.isInput = on
        }
        
    }
    
    func isInputCompleted() -> Bool {
        return self.input.isCertificationNumberType()
    }
    
    func inputCompleted() {
        if !self.isInputCompleted() { return }
        self.errorMsg = nil
        self.pairing.requestPairing(.auth(self.input))
    }
}

#if DEBUG
struct PagePairingBtv_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingBtv().contentBody
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
