//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageWatchHabit: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    @State var marginBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.watchHabit,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    BtvWebView( viewModel: self.webViewModel )
                        .modifier(MatchParent())
                    
                    
                   
                }
                .padding(.bottom, self.marginBottom)
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, _, _) :
                    switch method {
                    case WebviewMethod.bpn_closeWebView.rawValue :
                        self.pagePresenter.goBack()
                        break
                    case WebviewMethod.requestSTBViewInfo.rawValue :
                        self.checkHostDeviceStatus()
                        break
                    
                    default : break
                    }
                    
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    let path = ApiPath.getRestApiPath(.WEB) + BtvWebView.watchHabit
                    self.webViewModel.request = .link(path)
                }
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                switch res.type {
                case .sendMessage :
                    guard let result = res.data as? ResultMessage else { return }
                    if result.header?.result != ApiCode.success { return }
                    guard let message =  result.body?.message else { return }
                    guard let type = message.SvcType else { return }
                    self.message = result
                    switch type {
                    case BroadcastingType.VOD.rawValue:
                        self.dataProvider.broadcasting.requestBroadcast(.updateCurrentVod(message.CurCID))
                    case BroadcastingType.IPTV.rawValue:
                        if message.CurChNum == "0" {
                            self.dataProvider.broadcasting.reset()
                            return
                        }
                        self.dataProvider.broadcasting.requestBroadcast(.updateCurrentBroadcast)
                        self.dataProvider.broadcasting.updateChannelNo(message.CurChNum)

                    default: self.dataProvider.broadcasting.reset()
                    }
                default: break
                }
            }
            .onReceive(self.dataProvider.broadcasting.$currentProgram){program in

                guard let message = self.message else { return }
                let dic = self.repository.webBridge.getSTBPlayInfo(result: message, broadcastProgram: program)
                let js = BtvWebView.callJsPrefix + WebviewRespond.responseSTBViewInfo.rawValue
                self.webViewModel.request = .evaluateJavaScriptMethod(js, dic)
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                self.marginBottom = bottom
            }
           
            .onAppear{
                
                
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    

    @State var message:ResultMessage? = nil
    func checkHostDeviceStatus(){
        self.message = nil
        self.dataProvider.requestData(
            q: .init(id: self.tag, type: .sendMessage(NpsMessage().setMessage(type: .Refresh)), isOptional: true)
        )
    }
    
}

#if DEBUG
struct PageWatchHabit_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWatchHabit().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
