//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageSearchWebview: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var viewModel:PageSearchModel = PageSearchModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var isKeyboardOn:Bool = false
    @State var isVoiceSearch:Bool = false
    @State var isInputSearch:Bool = false
    @State var keyword:String = ""
    @State var webViewHeight:CGFloat = 0
    @State var transactionId:String = ""
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(){
                    BtvWebView( viewModel: self.webViewModel, useNativeScroll:false )
                    .modifier(MatchHorizontal(height: self.webViewHeight))
                    .onReceive(self.webViewModel.$screenHeight){height in
                        self.webViewHeight = geometry.size.height
                            - self.sceneObserver.safeAreaTop
                    }
                    .onReceive(self.webViewModel.$status){stat in
                        switch stat {
                        case .complete: break
                            
                        default : break
                        }
                    }
                    .onReceive(self.webViewModel.$event){ evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .callFuncion(let method, let json, _) :
                            switch method {
                            case WebviewMethod.requestVoiceSearch.rawValue :
                                if let jsonData = json?.parseJson() {
                                    if let tid = jsonData["transactionId"] as? Int {
                                        self.requestVoiceSearch(id: tid.description)
                                    }
                                }
                            case WebviewMethod.bpn_closeWebView.rawValue :
                                self.pagePresenter.goBack()
                                break
                            default : break
                            }
            
                        default : break
                        }
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    
                    if self.isVoiceSearch {
                        ZStack(){
                            VoiceRecorder(cancle: {
                                
                            }
                            ){ keyword in
                                guard keyword != nil else {
                                    withAnimation{ self.isVoiceSearch = false }
                                    return
                                }
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
                .modifier(PageFull())
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                           self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.pageDragingModel.uiEvent = .draged(geometry, value)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
                )
            }//PageDragingBody
            .onReceive(self.keyboardObserver.$isOn){ on in
                PageLog.d("keyboardObserver " + on.description, tag: self.tag)
                PageLog.d("self.isKeyboardOn " + self.isKeyboardOn.description, tag: self.tag)
                if self.isKeyboardOn == on { return }
                self.isKeyboardOn = on
                if self.isInputSearch != on {
                    PageLog.d("keyboardObserver isInputSearch " + isInputSearch.description, tag: self.tag)
                    self.isInputSearch = on
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                self.webViewHeight = geometry.size.height
                    - self.sceneObserver.safeAreaTop
            }
            .onReceive(self.dataProvider.$result){ result in
                
            }
            .onAppear{
                self.viewModel.onAppear()
                let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.search
                self.webViewModel.request = .link(linkUrl)
                self.dataProvider.requestData(q: .init(id: self.tag, type: .getSearchKeywords, isOptional: true))
            }
            
        }//geo
    }//body
    
    func requestVoiceSearch(id:String){
        withAnimation{ self.isVoiceSearch = true }
        self.transactionId = id
    }
     
    func requestSearch(keyword:String){
        withAnimation{ self.isVoiceSearch = false }
        self.keyword = keyword
        var info = [String: Any]()
        info["transactionId"] = self.transactionId
        info["result"] = "0"
        info["resultValue"] = [keyword]
        let js = BtvWebView.callJsPrefix + WebviewRespond.responseVoiceSearch.rawValue
        self.webViewModel.request = .evaluateJavaScriptMethod(js, info)
    }

    
}

