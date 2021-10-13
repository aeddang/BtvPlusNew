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
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var viewModel:PageSearchModel = PageSearchModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var searchScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var resultScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var emptyScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var isKeyboardOn:Bool = false
    @State var isVoiceSearch:Bool = false
    @State var isInputSearch:Bool = false
    @State var marginBottom:CGFloat = 0
    
    let scrollPos = UUID().hashValue
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(){
                    VStack(spacing:0){
                        SearchTab(
                            isFocus:self.$isInputSearch,
                            scrollPos: scrollPos,
                            keyword: self.$keyword,
                            inputChanged: {text in
                                if text == "" {
                                    self.resetSearchData()
                                } else {
                                    self.changeSearch(word: text)
                                }
                            },
                            inputCopmpleted : { text in
                                if self.keyword.isEmpty {
                                    self.appSceneObserver.alert = .alert(String.alert.apns, String.kidsText.kidsSearchInput)
                                    return
                                }
                                self.search(keyword: text)
                            },
                            inputVoice: {
                                self.sendLog(action: .clickSearchVoiceInput)
                                self.voiceSearch()
                            },
                            goBack: {
                                AppUtil.hideKeyboard()
                                self.sendLog(action: .clickSearchBack) 
                                if !self.emptyDatas.isEmpty {
                                    self.emptyDatas = []
                                    if !self.keyword.isEmpty {
                                        self.isInputSearch = true
                                    }
                                    //self.keyword = ""
                                    return
                                }
                                if !self.searchDatas.isEmpty {
                                    self.searchDatas = []
                                    self.updatedLogPage()
                                    return
                                }
                                self.pagePresenter.goBack()
                            }
                        )
                        .modifier(ContentHorizontalEdges())
                        .padding(.top, Dimen.margin.thin)
                        .padding(.bottom, Dimen.margin.micro)
                        
                        ZStack(){
                            if self.isInputSearch {
                                Spacer().modifier(MatchParent()).background(Color.transparent.clearUi)
                                .onTapGesture {
                                    AppUtil.hideKeyboard()
                                }
                            }
                            if !self.searchDatas.isEmpty {
                                SearchResult(
                                    infinityScrollModel: self.resultScrollModel,
                                    pageObservable: self.pageObservable,
                                    pageDragingModel: self.pageDragingModel,
                                    total:self.total,
                                    keyword: self.resultKeyword,
                                    datas: self.searchDatas,
                                    useTracking: true
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
                                    .onTapGesture {
                                        AppUtil.hideKeyboard()
                                    }
                                    
                            } else if !self.emptyDatas.isEmpty {
                                EmptySearchResult(
                                    viewModel:self.emptyScrollModel,
                                    keyword: self.keyword,
                                    datas: self.emptyDatas)
                                    .modifier(MatchParent())
                                    .onTapGesture {
                                        AppUtil.hideKeyboard()
                                    }
            
                            } else {
                                SearchList(
                                    viewModel:self.searchScrollModel,
                                    datas:self.datas,
                                    delete: { data in
                                        AppUtil.hideKeyboard()
                                        self.sendLog(action: .clickSearchRecentKeyword,
                                                     actionBody: .init(
                                                        menu_id: "",
                                                        menu_name: data.isDeleteAble ? "최근검색어"  : "인기검색어",
                                                        config: data.isSection ? "all" : "",
                                                        search_keyword: data.isSection ? "" : data.keyword
                                                     ))
                                        
                                        if data.isSection {
                                            self.appSceneObserver.alert =
                                                .confirm(String.button.remove, String.pageText.searchDeleteAllConfirm, confirmText: String.button.remove) { isOk in
                                                if isOk {
                                                    self.viewModel.removeAllSearchKeyword()
                                                }
                                            }
                                            
                                        } else {
                                            self.viewModel.removeSearchKeyword(keyword: data.keyword)
                                        }
                                    },
                                    action: { data in
                                        AppUtil.hideKeyboard()
                                        self.sendLog(action: .clickSearchRecentKeyword,
                                                     actionBody: .init(
                                                        menu_id: "",
                                                        menu_name: data.isDeleteAble ? "최근검색어"  : "인기검색어",
                                                        search_keyword: data.keyword
                                                     ))
                                        self.search(keyword: data.keyword)
                                    }
                                    
                                )
                                .modifier(MatchParent())
                                .onReceive(self.searchScrollModel.$event){ evt in
                                    guard let evt = evt else { return }
                                    switch evt {
                                    case .down, .up : AppUtil.hideKeyboard()
                                    default : break
                                    }
                                    
                                }
                                .onTapGesture {
                                    AppUtil.hideKeyboard()
                                }
                            }
                        }
                        
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    .padding(.bottom, self.marginBottom)
                    if self.isVoiceSearch {
                        ZStack(){
                            VoiceRecorder(
                                cancle: {
                                    self.voiceSearchEnd()
                                },
                                action: { keyword in
                                    guard let keyword = keyword else {
                                        self.voiceSearchEnd()
                                        return
                                    }
                                    self.search(keyword: keyword)
                                }
                            )
                            .modifier(MatchHorizontal(height:VoiceRecorder.height ))
                            VStack(alignment: .trailing){
                                Button(action: {
                                    self.voiceSearchEnd()
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
                        .background(Color.transparent.black80)
                        
                    }
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//PageDragingBody
            .onReceive(self.keyboardObserver.$isOn){ on in
                if self.pageObservable.layer != .top { return }
                if self.isKeyboardOn == on { return }
                self.isKeyboardOn = on
                if !on {
                    self.isInputSearch = false
                }
                if self.isInputSearch != on {
                    self.isInputSearch = on
                }
                if on {
                    self.clearSearchData()
                }
                if !self.isVoiceSearch {
                    if on {
                        self.appSceneObserver.useBottomImmediately = false
                    } else {
                        self.appSceneObserver.useBottom = true
                    }
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
                case .getCompleteKeywords(let word, _):
                    if self.keyword != word {return} 
                    self.viewModel.updateCompleteKeywords(res.data as? CompleteKeyword)
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
                if ani {
                    if self.isInit {return}
                    DispatchQueue.main.async {
                        self.isInputSearch = true
                        self.viewModel.onAppear()
                        self.dataProvider.requestData(q: .init(id: self.tag, type: .getSearchKeywords, isOptional: true))
                    }
                }
            }
            .onReceive(self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ bottom in
                self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom
            }
            .onAppear{
                
            }
            .onDisappear{
               
            }
        }//geo
    }//body
    @State var isInit:Bool = false
    @State var keyword:String = ""
    @State var resultKeyword:String = ""
    @State var datas:[SearchData] = []
    @State var emptyDatas:[PosterDataSet] = []
    @State var searchDatas:[BlockData] = []
    @State var total:Int = 0
    
    
    func clearSearchData() {
        if !self.emptyDatas.isEmpty {
            self.emptyDatas = []
        }
        if !self.searchDatas.isEmpty {
            self.searchDatas = []
        }
    }
    func resetSearchData() {
        self.clearSearchData()
        self.viewModel.updateSearchKeyword()
        self.updatedLogPage()
    }
    
    func voiceSearch(){
        AppUtil.hideKeyboard()
        withAnimation{ self.isVoiceSearch = true }
        self.appSceneObserver.useBottom = false
    }
    func voiceSearchEnd(){
        withAnimation{ self.isVoiceSearch = false }
        self.appSceneObserver.useBottom = true
    }
    
    func search(keyword:String){
        AppUtil.hideKeyboard()
        self.voiceSearchEnd()
        if keyword.isEmpty { return }
        self.viewModel.addSearchKeyword(keyword: keyword)
        self.keyword = keyword
        self.dataProvider.requestData(q: .init(id: self.tag, type: .getSeachVod(keyword), isOptional: false))
    }
    
    func searchRespond(res:ApiResultResponds, geometry:GeometryProxy){
        self.searchDatas = self.viewModel.updateSearchCategory(res.data as? SearchCategory, keyword: self.keyword)
        if self.searchDatas.isEmpty {
            self.emptyDatas = self.viewModel.getPosterSets(screenSize: geometry.size.width)
            if self.emptyDatas.isEmpty {
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getSeachPopularityVod, isOptional: false))
            }
        } else {
            self.resultKeyword = self.keyword
            self.total = self.searchDatas.reduce(0, { $0 + $1.allResultCount })
        }
        self.updatedLogPage()
        if !self.searchDatas.isEmpty {
            self.sendLog(action: .pageShow,
                         actionBody: MenuNaviActionBodyItem(
                            search_keyword: self.keyword,
                            result: self.total.description)
            )
        }
        
    }
    
    @State var changeSearchSubscription:AnyCancellable?
    func changeSearch(word:String) {
        self.searchDatas = []
        self.changeSearchSubscription?.cancel()
        self.changeSearchSubscription = Timer.publish(
            every: 0.1, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.changeSearchSubscription?.cancel()
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getCompleteKeywords(word), isOptional: true))
        }
    }
    
    private func updatedLogPage() {
        self.naviLogManager.setupPageId(self.searchDatas.isEmpty == false ? .searchResult : .searchNoResult)
    }
    
    private func sendLog(action:NaviLog.Action, actionBody:MenuNaviActionBodyItem? = nil) {
        self.naviLogManager.actionLog(action, actionBody: actionBody)
    }
    
}


