//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageSynopsis: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                viewModel: self.pageDataProviderModel
            ){
                PageDragingBody(
                    viewModel:self.pageDragingModel,
                    axis:.horizontal
                ) {
                    VStack(spacing:0){
                        Image(Asset.noImg16_9)
                            .modifier(Ratio16_9(geometry:geometry))
                        InfinityScrollView( viewModel: self.infinityScrollModel ){
                            VStack(alignment:.leading , spacing:0) {
                                TopSynopsisViewer()
                            }
                        }
                        .modifier(MatchParent())
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
                    .modifier(PageFull())
                }//PageDragingBody
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let _ = evt else {return}
                    self.pageDragingModel.uiEvent = .draged(geometry)
                    
                }
            }//PageDataProviderContent
            
            .onAppear{
               
            }
            
        }//geo
    }//body
    
    

}

#if DEBUG
struct PageSynopsis_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSynopsis().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
