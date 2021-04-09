//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageWatchHabit: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    @State var useTracking:Bool = false
    @State var webViewHeight:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.watchHabit,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            scrollType : .web(isDragEnd: true),
                            isRecycle:false,
                            useTracking:self.useTracking ){
                            BtvWebView( viewModel: self.webViewModel )
                                .modifier(MatchHorizontal(height: self.webViewHeight))
                                .onReceive(self.webViewModel.$screenHeight){height in
                                    let min = geometry.size.height - self.sceneObserver.safeAreaTop - Dimen.app.top
                                    self.webViewHeight = min //max( height, min)
                                    ComponentLog.d("webViewHeight " + webViewHeight.description)
                                }
                        }
                        .padding(.bottom, self.sceneObserver.safeAreaBottom)
                        .modifier(MatchParent())
    
                        .onReceive(self.infinityScrollModel.$event){evt in
                            guard let evt = evt else {return}
                            switch evt {
                            case .pullCompleted :
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
                   
                }
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
                    
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
            }
            .onAppear{
                let path = ApiPath.getRestApiPath(.WEB) + BtvWebView.watchHabit
                self.webViewModel.request = .link(path)
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
    func checkHostDeviceStatus(){
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