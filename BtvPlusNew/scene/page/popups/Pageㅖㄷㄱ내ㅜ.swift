//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct Pageㅖㄷㄱ내ㅜ: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var title:String? = nil

    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
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
                        isRecycle:true,
                        useTracking:false ){
                        
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

            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.title = obj.getParamValue(key: .title) as? String
                
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
   
}

#if DEBUG
struct PageCharacter_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            Pageㅖㄷㄱ내ㅜ().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(KeyboardObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
