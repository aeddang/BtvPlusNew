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
    @ObservedObject var viewModel:MultiBlockModel = MultiBlockModel(logType: .list)
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel(limitedScrollIndex: 1)
     
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
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
                        useBodyTracking:true,
                        useTracking:true,
                        marginTop: DimenKids.margin.medium ,
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
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isUiInit {return}
                    DispatchQueue.main.async {
                        self.isUiInit = true
                        self.reload()
                    }
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
    @State var isUiInit:Bool = false
    @State var menuId:String = ""
    @State var openId:String? = nil
    private func reload(){
        guard let blockData = self.dataProvider.bands.kidsGnbModel.monthly else { return }
        self.viewModel.updateKids(data: blockData , openId: self.openId, isTicket: true)
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

