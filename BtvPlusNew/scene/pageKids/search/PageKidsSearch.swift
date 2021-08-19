//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import Combine

struct PageKidsSearch: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var viewModel:PageKidsSearchModel = PageKidsSearchModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    
    @ObservedObject var resultScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var isKeyboardOn:Bool = false
    @State var isVoiceSearch:Bool = false
    @State var isInputSearch:Bool = false
    
    @State var marginTop:CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .top){
                    ZStack(){
                        if self.isVoiceSearch {
                            VoiceRecorderKids(
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
                            .modifier(MatchParent())
                        } else {
                            if let searchDatas = self.searchDatas {
                                if !searchDatas.isEmpty {
                                    SearchResultKids(
                                        infinityScrollModel: self.resultScrollModel,
                                        pageObservable: self.pageObservable,
                                        pageDragingModel: self.pageDragingModel,
                                        datas: searchDatas,
                                        useTracking:true
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
                                } else {
                                    EmptySearchResultKids(
                                        image: AssetKids.image.searchNodata,
                                        text: String.kidsText.kidsSearchNoData)
                                }
                            } else {
                                EmptySearchResultKids(
                                    image: AssetKids.image.searchInfo,
                                    text: String.kidsText.kidsSearchText)
                            }
                        }
                        
                    }
                    .padding(.top, self.marginTop + DimenKids.tab.medium)
                    .modifier(MatchParent())
                    
                    SearchTabKids(
                        isFocus:self.isInputSearch,
                        isVoiceSearch: self.isVoiceSearch,
                        keyword: self.$keyword,
                        datas:self.datas,
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
                        inputVoice: {
                            self.sendLog(action: .clickSearchVoiceInput) 
                            self.voiceSearch()
                        },
                        search: { keyword in
                            self.search(keyword: keyword)
                        },
                        goBack: {
                            self.sendLog(action: .clickSearchBack)
                            if self.isVoiceSearch {
                                self.voiceSearchEnd()
                                return
                            }
    
                            if self.searchDatas != nil {
                                self.searchDatas = nil
                                self.updatedLogPage()
                                return
                            }
                            self.pagePresenter.goBack()
                        }
                    )
                    .modifier(ContentHorizontalEdgesKids())
                    .padding(.top, self.marginTop)
                }// vstack
                .background(
                    Image(AssetKids.image.homeBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        
                )
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//PageDragingBody
            .onReceive(self.keyboardObserver.$isOn){ on in
                if self.pageObservable.layer != .top { return }
                if self.isKeyboardOn == on { return }
                self.isKeyboardOn = on
                if self.isInputSearch != on { self.isInputSearch = on}
                
            }
            .onReceive(self.viewModel.$searchDatas){ datas in
                self.datas = datas
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                switch res.type {
                case .getCompleteKeywords : self.viewModel.updateCompleteKeywords(res.data as? CompleteKeyword, searchKeyword: self.keyword)
                case .getSeachVod : self.searchRespond(res: res, geometry: geometry)
                default : break
                }
            }
            .onReceive(dataProvider.$error) { err in
                if err?.id != self.tag { return }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isInputSearch = true
                    self.dataProvider.requestData(q: .init(id: self.tag, type: .getSearchKeywords, isOptional: true))
                }
            }
            
            .onReceive(self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ bottom in
                self.marginTop = self.sceneObserver.safeAreaTop + DimenKids.margin.light
            }
            .onAppear{
                
            }
            
        }//geo
    }//body
    
    @State var keyword:String = ""
    @State var datas:[SearchData] = []
    @State var searchDatas:[BlockData]? = nil
    
    func resetSearchData() {
        self.searchDatas = nil
        self.updatedLogPage()
        self.viewModel.updateSearchKeyword()
    }
    
    func voiceSearch(){
        withAnimation{ self.isVoiceSearch = true }
        AppUtil.hideKeyboard()
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
        self.keyword = keyword
        self.dataProvider.requestData(q: .init(id: self.tag, type: .getSeachVod(keyword, .kids), isOptional: false))
    }
    
    func searchRespond(res:ApiResultResponds, geometry:GeometryProxy){
        let searchDatas = self.viewModel.updateSearchCategory(res.data as? SearchCategory, keyword: self.keyword)
        self.searchDatas = searchDatas
        self.updatedLogPage()
        let total = searchDatas.reduce(0, { $0 + $1.allResultCount })
        if !searchDatas.isEmpty{
            self.sendLog(action: .pageShow,
                         actionBody: MenuNaviActionBodyItem(
                            search_keyword: self.keyword,
                            result: total.description)
            )
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
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getCompleteKeywords(word, .kids), isOptional: true))
        }
    }
    
    private func updatedLogPage() {
        self.naviLogManager.setupPageId(self.searchDatas?.isEmpty == false ? .zemSearchResult : nil)
    }
    
    private func sendLog(action:NaviLog.Action, actionBody:MenuNaviActionBodyItem? = nil) {
        self.naviLogManager.actionLog(action, actionBody: actionBody)
    }
    
}


