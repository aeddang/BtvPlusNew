//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePerson: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var title:String? = nil
    @State var webViewHeight:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    if self.title != nil {
                        PageTab(
                            title: self.title,
                            isBack: true
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    }
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        isRecycle:false,
                        useTracking:false ){
                        
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

                }
                .modifier(PageFull())
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.pageDragingModel.uiEvent = .draged(geometry,value)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
                )
            }//draging
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, _, _) :
                    switch method {
                    case WebviewMethod.bpn_closeWebView.rawValue :
                        self.pagePresenter.goBack()
                        break
                    default : break
                    }
                    
                default : do{}
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let people = obj.getParamValue(key: .data) as? PeopleData{
                    self.title = people.name ?? ""
                    let epsdId = people.epsdId ?? ""
                    let prsId = people.prsId ?? ""
                    let path = ApiPath.getRestApiPath(.WEB) + BtvWebView.person + "?epsd_id=" + epsdId + "&prs_id=" + prsId
                    self.webViewModel.request = .link(path)
                }
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
   
}

#if DEBUG
struct PagePerson_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePerson().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(KeyboardObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
