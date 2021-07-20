//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageKidsMonthly: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var viewModel:MultiBlockModel = MultiBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var useTracking:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageKidsTab(
                        title: String.kidsTitle.kidsMonthly,
                        isBack : true,
                        style: .kidsWhite
                    )
                    MultiBlockBody (
                        pageObservable: self.pageObservable,
                        viewModel: self.viewModel,
                        infinityScrollModel: self.infinityScrollModel,
                        pageDragingModel: self.pageDragingModel,
                        useBodyTracking:self.useTracking,
                        useTracking:self.useTracking,
                        marginTop: DimenKids.margin.medium,
                        marginBottom: self.sceneObserver.safeAreaIgnoreKeyboardBottom
                        )
                    .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .pullCompleted :
                            self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                        case .pullCancel :
                            self.pageDragingModel.uiEvent = .pullCancel(geometry)
                        case .pull(let pos) :
                            self.pageDragingModel.uiEvent = .pull(geometry, pos)
                        default: break
                        }
                    }
                }
                
                .background(
                    Image(AssetKids.image.homeBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        
                )
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }
            .onReceive(self.pairing.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pairingCompleted : self.reload()
                default : break
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page?.id == self.pageObject?.id {
                    if self.useTracking {return}
                    self.useTracking = true
                } else {
                    if !self.useTracking {return}
                    self.useTracking = false
                   
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.reload()
                }
            }
            .onAppear{
                if let obj = self.pageObject {
                    self.openId = obj.getParamValue(key: .subId) as? String
                }
            }
            .onDisappear{
                //self.appSceneObserver.useGnb = true
            }
        }//geo
    }//body
    
    @State var menuId:String = ""
    @State var openId:String? = nil
    private func reload(){
        guard let blockData = self.dataProvider.bands.kidsGnbModel.monthly else { return }
        self.viewModel.updateKids(data: blockData , openId: self.openId)
    }

    //Block init
    
}


#if DEBUG
struct PageKidsMonthly_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsMonthly().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

