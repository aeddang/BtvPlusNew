//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMyWatchedList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @ObservedObject var mobileScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var mobileWatchedBlockModel:WatchedBlockModel = WatchedBlockModel()
    
    @ObservedObject var btvScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var btvWatchedBlockModel:WatchedBlockModel = WatchedBlockModel()
    
    @ObservedObject var kidsScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var kidsWatchedBlockModel:WatchedBlockModel = WatchedBlockModel()
   
    @State var pages: [PageViewProtocol] = []
    @State var marginBottom:CGFloat = 0
    let titles: [String] = [
        String.pageTitle.mobileBtv,
        String.pageTitle.btv,
        String.kidsTitle.kids
    ]
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.watched,
                        isBack: true,
                        style: .dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    if !self.pages.isEmpty {
                        CPPageViewPager(
                            pageObservable: self.pageObservable,
                            viewModel: self.viewPagerModel,
                            pages: self.pages,
                            titles: self.titles,
                            usePull: .horizontal)
                            { idx in
                                switch idx {
                                case 0 :
                                    self.sendLogTabMenu(0)
                                    self.mobileWatchedBlockModel.updateMobile()
                                case 1 :
                                    self.sendLogTabMenu(1)
                                    self.btvWatchedBlockModel.updateBtv()
                                case 2 :
                                    self.sendLogTabMenu(2)
                                    self.kidsWatchedBlockModel.updateKids()
                                default : break
                                }
                            }
                    } else {
                        Spacer()
                    }
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .clipped()
            }
            
            .onReceive(self.mobileScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.btvScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.kidsScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.viewPagerModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                case .pull(let pos) :
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.pages = [
                        WatchedBlock(
                            infinityScrollModel:self.mobileScrollModel,
                            viewModel:self.mobileWatchedBlockModel,
                            pageObservable:self.pageObservable,
                            deleteAble: true,
                            useTracking:true,
                            marginBottom: self.marginBottom
                        ),
                        WatchedBlock(
                            infinityScrollModel:self.btvScrollModel,
                            viewModel:self.btvWatchedBlockModel,
                            pageObservable:self.pageObservable,
                            deleteAble: false,
                            useTracking:true,
                            marginBottom: self.marginBottom
                        ),
                        WatchedBlock(
                            infinityScrollModel:self.kidsScrollModel,
                            viewModel:self.kidsWatchedBlockModel,
                            pageObservable:self.pageObservable,
                            deleteAble: false,
                            useTracking:true, 
                            marginBottom: self.marginBottom
                        )
                    ]
                }
            }
            
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onAppear{
                self.naviLogManager.actionLog(.pageShow, pageId: .recentContents ,
                                              actionBody: .init(category:WatchedBlockType.mobile.category))
            }
            .onDisappear{
               
            }
        }//geo
    }//body
    
    @State var isInitLog:Bool = true
    private func sendLogTabMenu(_ idx:Int){
        if self.isInitLog {
            self.isInitLog = false
            return
        }
        var action = MenuNaviActionBodyItem()
        switch idx {
        case 0 :
            action.category = WatchedBlockType.mobile.category
        case 1 :
            action.category = WatchedBlockType.btv.category
        case 2 :
            action.category = WatchedBlockType.kids.category
        default : break
        }
        self.naviLogManager.actionLog(.clickRecentContentsTab, pageId: .recentContents ,actionBody: action)
    }
   
}

#if DEBUG
struct PageMyWatchedList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyWatchedList().contentBody
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
