//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageRemotecon: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()

    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: SystemEnvironment.isTablet ?.center : .top){
                    if let isPairing = self.isPairing {
                        if isPairing  {
                            if SystemEnvironment.isTablet {
                                ZStack{
                                    Image(Asset.remote.bg)
                                        .renderingMode(.original).resizable()
                                        .modifier(MatchParent())
                                    RemoteCon(){ evt in
                                        self.action(evt: evt)
                                    }
                                }
                                .frame(
                                    width:  RemoteStyle.ui.size.width,
                                    height:  RemoteStyle.ui.size.height)
                                
                            } else {
                                VStack( spacing: 0 ){
                                    Spacer()
                                        .modifier(MatchHorizontal(height: self.sceneObserver.safeAreaTop))
                                        .background(Color.app.blackExtra)
                                    Image(Asset.remote.bg)
                                        .renderingMode(.original).resizable()
                                        .modifier(MatchHorizontal(height: RemoteStyle.ui.size.height))
                                    Spacer()
                                        .modifier(MatchParent())
                                        .background(Color.app.blackExtra)
                                }
                                .modifier(MatchParent())
                                RemoteCon(){ evt in
                                    self.action(evt: evt)
                                }
                                .padding(.top, self.sceneObserver.safeAreaTop)
                            }
                        } else {
                            EmptyAlert(text: String.alert.pairingError){
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                        }
                        
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                    if self.isInputText {
                        InputRemoteBox(
                            isInit: true,
                            title: String.remote.inputText,
                            placeHolder:String.remote.inputTextHolder,
                            inputSize: 8,
                            inputSizeMin: 1
                        ){ input in
                            withAnimation{
                                self.isInputText = false
                            }
                        }
                    }
                    if self.isInputChannel {
                        InputRemoteBox(
                            isInit: true,
                            title: String.remote.inputChannel,
                            placeHolder:String.remote.inputChannelHolder,
                            inputSize: 3,
                            inputSizeMin: 1,
                            keyboardType: .numberPad
                        ){ input in
                            withAnimation{
                                self.isInputChannel = false
                            }
                        }
                    }
                }
                .modifier(MatchParent())
                .background(Color.transparent.black70)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
                switch evt {
                case .pairingCompleted : self.isPairing = true
                case .disConnected : self.isPairing = false
                case .pairingCheckCompleted(let isSuccess) :
                    if isSuccess { self.isPairing = true }
                    else { self.isPairing = false }
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
               
            }
            .onAppear{
                self.isPairing = true
               // self.pairing.requestPairing(.check)
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
    
    @State var isPairing:Bool? = nil
    @State var isInputText:Bool = false
    @State var isInputChannel:Bool = false
    
    
    private func action(evt:RemoteConEvent) {
        switch evt {
        case .close:
            self.pagePresenter.closePopup(self.pageObject?.id)
        case .inputMessage:
            withAnimation{ self.isInputText = true }
        case .inputChannel:
            withAnimation{ self.isInputChannel = true }
        default:
            break
        }
        
        
    }
    
   
}

#if DEBUG
struct PageRemotecon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageRemotecon().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
