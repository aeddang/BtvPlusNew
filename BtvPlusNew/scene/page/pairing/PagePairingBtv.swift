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
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
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
                            textModifier: BoldTextStyle( size: Font.size.black ).textModifier,
                            isfocusAble: self.$isFocus,
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
            PageDataProviderContent(
                pageObservable: self.pageObservable,
                viewModel: self.pageDataProviderModel) {
                PageDragingBody(
                    viewModel:self.pageDragingModel,
                    axis:.vertical
                ) {
                    VStack(spacing:0){
                        if !self.isInput || self.sceneOrientation == .portrait {
                            PageTab(
                                title: .constant(String.pageTitle.connectCertificationBtv),
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
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 20, coordinateSpace: .local)
                            .onChanged({ value in
                                self.pageDragingModel.uiEvent = .drag(geometry, value)
                            })
                            .onEnded({ _ in
                                self.pageDragingModel.uiEvent = .draged(geometry)
                            })
                    )
                    .onReceive(self.infinityScrollModel.$event){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .down, .up :
                            self.pageDragingModel.uiEvent = .dragCancel(geometry)
                        case .pullCancel :
                            self.pageDragingModel.uiEvent = .pulled(geometry)
                        default : do{}
                        }
                    }
                    .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    }
                }//draging
            }//data
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
            .onReceive(self.pageDataProviderModel.$event){ evt in
                guard let evt = evt else { return }
                self.pairingProsess(evt: evt)
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
    
    func isInputCompleted() -> Binding<Bool> {
        return  Binding<Bool>(
            get: {
                self.input.isCertificationNumberType()
            },
            set: { _ in }
        )
    }
    
    func inputCompleted() {
        if !self.isInputCompleted().wrappedValue { return }
        self.isPairingProsessError = false
        self.pageDataProviderModel.initate()
    }
    
    @State var isPairingProsessError = false
    private func pairingProsess(evt:PageDataProviderEvent){
        if  self.isPairingProsessError { return }
        switch evt {
        case .willRequest(let progress):
            switch progress {
            case 0 : self.pageDataProviderModel.requestProgress(
                q:.init(id: self.tag, type: .postAuthPairing(self.pairing.user, self.input), isOptional: true))
            default : do{}
            }
        case .onResult(let progress, let res, _):
            self.isPairingProsessError = true
            var resHeader:NpsCommonHeader? = nil
            switch progress {
            case 0 :
                guard let resData = res.data as? DevicePairing else { return }
                resHeader = resData.header
            case 1 :
                guard let resData = res.data as? HostDeviceInfo else { return }
                resHeader = resData.header
            default : do{}
            }
            
            if resHeader?.result != NpsNetwork.resultCode.success.code {
                self.pageSceneObserver.alert = .pairingError(resHeader)
                return
            }
            self.isPairingProsessError = false
        
        case .onError(_ , _ , _ ):
            self.isPairingProsessError = true
        }
    }
}

#if DEBUG
struct PagePairingBtv_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingBtv().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
