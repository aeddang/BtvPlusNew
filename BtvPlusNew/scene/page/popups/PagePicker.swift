//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI



struct PagePicker: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
   
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
      
    @State var title:String? = nil
    @State var datas:[PickerData] = []
    @State var pickerId:String? = nil
    @State var selectedIdx:Int = -1
    @State var marginBottom:CGFloat = Dimen.app.bottom
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    if self.title != nil {
                        PageTab(
                            title: self.title,
                            isClose: true,
                            style:.dark
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    }
                    ZStack(alignment: .bottomLeading){
                        /*
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                          */
                        PickerList(
                            viewModel: self.infinityScrollModel,
                            datas: self.datas,
                            selectedIdx: self.selectedIdx,
                            bgColor: PageStyle.dark.bgColor){ select in
                            
                            self.pagePresenter.onPageEvent(
                                self.pageObject,
                                event: .init(id :self.pickerId ?? "", type: .selected, data:select))
                            
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
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
                        
                        Button(action: {
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }) {
                            Image(Asset.icon.closeCircle)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimen.icon.medium,
                                       height: Dimen.icon.medium)
                        }
                        .padding(.bottom, Dimen.margin.regular)
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop + Dimen.margin.regular)
                    .padding(.bottom, self.marginBottom)
                    .padding(.horizontal, Dimen.margin.heavy)
                }
                .modifier(PageFull(style: .dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation{ self.marginBottom = bottom }
                }
            }
            .onAppear{
                self.marginBottom = self.appSceneObserver.safeBottomLayerHeight
                guard let obj = self.pageObject  else { return }
                self.title = obj.getParamValue(key: .title) as? String
                self.pickerId = obj.getParamValue(key: .id) as? String
                self.selectedIdx = obj.getParamValue(key: .index) as? Int ?? -1
                if let pickers = obj.getParamValue(key: .datas) as? [String]{
                    self.datas = zip(0...pickers.count, pickers).map{ idx , pic in
                        PickerData().setData(title: pic, idx: idx) 
                    }
                }
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
   
}

#if DEBUG
struct PagePicker_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePicker().contentBody
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
