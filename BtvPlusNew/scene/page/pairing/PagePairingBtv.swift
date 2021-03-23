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
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var input:String = ""
    @State var safeAreaBottom:CGFloat = 0
    @State var isInput = false
    @State var isFocus = false
    @State var useTracking:Bool = false
    @State var sceneOrientation: SceneOrientation = .portrait
    
    struct TextBlock:PageComponent {
        var body :some View {
            VStack(alignment:.leading , spacing:0) {
                Text(String.pageText.pairingBtvText1)
                    .modifier(MediumTextStyle( size: Font.size.bold ))
                    .padding(.top, Dimen.margin.light)
                    .fixedSize(horizontal: false, vertical:true)
                Text(String.pageText.pairingBtvText2)
                    .modifier(MediumTextStyle( size: Font.size.light ))
                    .padding(.top, Dimen.margin.regular)
                Text(String.pageText.pairingBtvText3)
                    .modifier(MediumTextStyle( size: Font.size.thin ))
                Text(String.pageText.pairingBtvText4)
                    .modifier(MediumTextStyle( size: Font.size.thin ))
                Text(String.pageText.pairingBtvText5)
                    .modifier(MediumTextStyle( size: Font.size.thin ))
                
            }
        }
    }
    struct InputBlock:PageComponent {
        @Binding var input:String
        @Binding var isFocus:Bool
        var isImageView:Bool = true
        var body :some View {
            VStack(alignment:.center , spacing:Dimen.margin.regularExtra) {
                if self.isImageView {
                    Image(Asset.source.pairingTutorial)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .modifier(MatchParent())
                        .padding(.all, Dimen.margin.thin)
                }
                HStack(alignment:.center, spacing:Dimen.margin.light){
                    Text(String.app.certificationNumber)
                        .modifier(BoldTextStyle(size: Font.size.light))
                    VStack(alignment: .center, spacing:0){
                        FocusableTextField(
                            keyboardType: .numberPad, returnVal: .done,
                            placeholder: String.app.certificationNumberHolder,
                            maxLength: 6,
                            kern: 10,
                            textModifier: BoldTextStyle( size: Font.size.black ).textModifier,
                            isfocus: self.isFocus,
                            inputChanged: { text in
                                self.input = text
                            },
                            inputCopmpleted: { text in
                                self.isFocus = false
                            })
                            .frame(height:Font.size.black)
                        Spacer().modifier(MatchHorizontal(height: 1))
                            .background(Color.app.white)
                    }
                    .frame(width:173)
                }
            }
        }
    }
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    if !self.isInput || self.sceneOrientation == .portrait {
                        PageTab(
                            title: String.pageTitle.connectCertificationBtv,
                            isClose: true
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    }
                    if self.sceneOrientation == .portrait {
                        VStack(alignment:.leading , spacing:0) {
                            if !self.isInput {
                                TextBlock()
                                    .padding(.vertical, Dimen.margin.regularExtra)
                                    .padding(.horizontal, Dimen.margin.regular)
                            }else{
                                Spacer().frame(height:Dimen.margin.regularExtra)
                            }
                            InputBlock(input: self.$input, isFocus: self.$isFocus)
                                .frame(height:250)
                            Spacer().modifier(MatchParent())
                        }
                        .modifier(MatchParent())
                        
                    } else {
                        HStack(alignment:.top , spacing:0) {
                            TextBlock()
                                .modifier(MatchParent())
                            InputBlock(input: self.$input, isFocus: self.$isFocus, isImageView: !self.isInput)
                                .modifier(MatchParent())
                        }
                        .padding(.vertical, Dimen.margin.light)
                        
                    }
                    FillButton(
                        text: String.button.connect,
                        isSelected: self.isInputCompleted()
                    ){_ in
                        
                        self.inputCompleted()
                    }
                    .padding(.bottom, self.safeAreaBottom)
                }
                .modifier(PageFull())
                .onTapGesture {
                    self.isFocus = false
                }
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
            }
            .onReceive(self.keyboardObserver.$isOn){ on in
                self.updatekeyboardStatus(on:on)
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani { self.isFocus = true }
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .connected :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .connectError(let header) :
                    self.appSceneObserver.alert = .pairingError(header)
                default : do{}
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
        if self.isFocus != on { self.isFocus = on }
        if self.isInput == on { return }
        withAnimation{
            self.isInput = on
            self.safeAreaBottom = on
                ? self.keyboardObserver.keyboardHeight : self.sceneObserver.safeAreaBottom
        }
        
    }
    
    func isInputCompleted() -> Bool {
        return self.input.isCertificationNumberType()
    }
    
    func inputCompleted() {
        if !self.isInputCompleted() { return }
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
