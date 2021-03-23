//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import Combine

struct PageSearch: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var viewModel:PageSearchModel = PageSearchModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var searchScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var resultScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var isKeyboardOn:Bool = false
    @State var isVoiceSearch:Bool = false
    @State var isInputSearch:Bool = false
    @State var useTracking:Bool = false
    @State var marginBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(){
                    VStack(spacing:0){
                        SearchTab(
                            isFocus:self.isInputSearch,
                            isVoiceSearch: self.$isVoiceSearch,
                            keyword: self.$keyword,
                            inputChanged: {text in
                                if text == "" {
                                    self.resetSearchData()
                                } else {
                                    self.changeSearch(word: text)
                                }
                            },
                            inputCopmpleted : { text in
                                self.search(keyword: text)
                            },
                            goBack: {
                                if !self.emptyDatas.isEmpty {
                                    self.emptyDatas = []
                                    return
                                }
                                if !self.searchDatas.isEmpty {
                                    self.searchDatas = []
                                    return
                                }
                                self.pagePresenter.goBack()
                            }
                        )
                        .modifier(ContentHorizontalEdges())
                        .padding(.top, Dimen.margin.thin)
                        
                        ZStack(){
                            if !self.searchDatas.isEmpty {
                                SearchResult(
                                    viewModel: self.resultScrollModel,
                                    pageObservable: self.pageObservable,
                                    pageDragingModel: self.pageDragingModel,
                                    total:self.total,
                                    keyword: self.keyword,
                                    datas: self.searchDatas,
                                    useTracking: self.useTracking
                                    )
                                    .modifier(MatchParent())
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
                                    
                            } else if !self.emptyDatas.isEmpty {
                                EmptySearchResult(keyword: self.keyword, datas: self.emptyDatas)
                                    .modifier(MatchParent())
                                    
                            } else {
                                SearchList(
                                    viewModel:self.searchScrollModel,
                                    datas:self.datas,
                                    delete: { data in
                                        if data.isSection {
                                            self.viewModel.removeAllSearchKeyword()
                                        } else {
                                            self.viewModel.removeSearchKeyword(keyword: data.keyword)
                                        }
                                    },
                                    action: { data in
                                        self.search(keyword: data.keyword)
                                    }
                                )
                                .modifier(MatchParent())
                                .onReceive(self.searchScrollModel.$event){ evt in
                                    guard let evt = evt else { return }
                                    switch evt {
                                    case .down : AppUtil.hideKeyboard()
                                    default : break
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    .padding(.bottom, self.marginBottom)
                    if self.isVoiceSearch {
                        ZStack(){
                            VoiceRecorder(){ keyword in
                                self.search(keyword: keyword)
                            }
                            .modifier(MatchHorizontal(height:VoiceRecorder.height ))
                            VStack(alignment: .trailing){
                                Button(action: {
                                    withAnimation{ self.isVoiceSearch = false }
                                }) {
                                    Image(Asset.icon.close)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.regular,
                                               height: Dimen.icon.regular)
                                }
                                .padding(.all, Dimen.margin.thin)
                                Spacer().modifier(MatchParent())
                            }
                            .padding(.top, self.sceneObserver.safeAreaTop)
                        }
                        .modifier(MatchParent())
                        .background(Color.transparent.black70)
                        
                    }
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//PageDragingBody
            .onReceive(self.keyboardObserver.$isOn){ on in
                if self.pageObservable.layer != .top { return }
                if self.isKeyboardOn == on { return }
                self.isKeyboardOn = on
                if self.isInputSearch != on { self.isInputSearch = on}
                if on {
                    self.emptyDatas = []
                }
                if on {
                    self.appSceneObserver.useBottomImmediately = false
                } else {
                    self.appSceneObserver.useBottom = true
                }
                
            }
            .onReceive(self.viewModel.$searchDatas){ datas in
                self.datas = datas
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                switch res.type {
                case .getSearchKeywords : self.viewModel.updatePopularityKeywords(res.data as? SearchKeyword)
                case .getCompleteKeywords : self.viewModel.updateCompleteKeywords(res.data as? CompleteKeyword)
                case .getSeachVod : self.searchRespond(res: res, geometry: geometry)
                case .getSeachPopularityVod :
                    self.viewModel.updatePopularityVod(res.data as? SearchPopularityVod)
                    self.emptyDatas = self.viewModel.getPosterSets(screenSize: geometry.size.width)
                default : break
                }
            }
            .onReceive(dataProvider.$error) { err in
                if err?.id != self.tag { return }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.isInputSearch = true
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page?.id == self.pageObject?.id {
                    if self.useTracking {return}
                    self.useTracking = true
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
                        DispatchQueue.main.async {
                            self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom + Dimen.app.bottom
                        }
                    }
                } else {
                    if !self.useTracking {return}
                    self.useTracking = false
                    self.marginBottom = 0
                }
            }
            .onAppear{
                self.viewModel.onAppear(apiCoreDataManager:self.repository.apiCoreDataManager)
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getSearchKeywords, isOptional: true))
            }
            
        }//geo
    }//body
    
    
    @State var keyword:String = ""
    @State var datas:[SearchData] = []
    @State var emptyDatas:[PosterDataSet] = []
    @State var searchDatas:[BlockData] = []
    @State var total:Int = 0
    func resetSearchData() {
        if !self.emptyDatas.isEmpty {
            self.emptyDatas = []
        }
        if !self.searchDatas.isEmpty {
            self.searchDatas = []
        }
        self.viewModel.updateSearchKeyword()
    }
    
    func voiceSearch(){
        withAnimation{ self.isVoiceSearch = true }
    }
    
    func search(keyword:String){
        AppUtil.hideKeyboard()
        withAnimation{ self.isVoiceSearch = false }
        if keyword.isEmpty { return }
        self.viewModel.addSearchKeyword(keyword: keyword)
        self.keyword = keyword
        self.dataProvider.requestData(q: .init(id: self.tag, type: .getSeachVod(keyword), isOptional: false))
    }
    
    func searchRespond(res:ApiResultResponds, geometry:GeometryProxy){
        self.searchDatas = self.viewModel.updateSearchCategory(res.data as? SearchCategory)
        if self.searchDatas.isEmpty {
            self.emptyDatas = self.viewModel.getPosterSets(screenSize: geometry.size.width)
            if self.emptyDatas.isEmpty {
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getSeachPopularityVod, isOptional: false))
            }
        } else {
            self.total = self.searchDatas.reduce(0, {$0 + ($1.allPosters?.count ?? 0) + ($1.allVideos?.count ?? 0)})
        }
    }
    
    @State var changeSearchSubscription:AnyCancellable?
    func changeSearch(word:String) {
        self.changeSearchSubscription?.cancel()
        self.changeSearchSubscription = Timer.publish(
            every: 0.1, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.changeSearchSubscription?.cancel()
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getCompleteKeywords(word), isOptional: true))
        }
    }
    
}


