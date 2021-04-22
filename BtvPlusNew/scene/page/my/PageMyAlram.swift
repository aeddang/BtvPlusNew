//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMyAlram: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @ObservedObject var alramScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var datas:[AlramData]? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.myAlram,
                        isBack: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    if let datas = self.datas {
                        AlramList(
                            viewModel: self.alramScrollModel,
                            datas: datas,
                            marginBottom: self.sceneObserver.safeAreaBottom
                        )
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                }
                .modifier(PageFull())
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    let historys = NotificationCoreData().getAllNotices()
                    self.datas = historys.map{AlramData().setData(data: $0)}
                    self.appSceneObserver.isApiLoading = false
                }
            }
            .onAppear{
                self.appSceneObserver.isApiLoading = true
            }
            .onDisappear{
               
            }
        }//geo
    }//body
    
   
}

#if DEBUG
struct PageMyAlram_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyAlram().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
