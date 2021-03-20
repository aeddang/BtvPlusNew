//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageSearch: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var useTracking:Bool = false
    @State var isKeyboardOn:Bool = false
    @State var isVoiceSearch:Bool = false
    @State var isInputSearch:Bool = true
    @State var keyword:String = ""
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                viewModel: self.pageDataProviderModel
            ){
                PageDragingBody(
                    viewModel:self.pageDragingModel,
                    axis:.horizontal
                ) {
                    ZStack(){
                        VStack{
                            SearchTab(
                                isFocus:self.isInputSearch,
                                isVoiceSearch: self.$isVoiceSearch,
                                keyword: self.$keyword,
                                inputChanged: {text in
                                    PageLog.d("inputChanged "  + text)
                                },
                                inputCopmpleted : { text in
                                    PageLog.d("nputCopmpleted "  + text)
                                    AppUtil.hideKeyboard()
                                }
                            )
                            .modifier(ContentHorizontalEdges())
                            .padding(.top, self.sceneObserver.safeAreaTop)
                            Spacer()
                            
                        }
                        if self.isVoiceSearch {
                            VoiceRecorder(){ keyword in
                                self.isVoiceSearch = false
                                self.keyword = keyword
                            }
                            .modifier(MatchHorizontal(height:VoiceRecorder.height ))
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
                
            }//PageDataProviderContent
           
            .onReceive(self.keyboardObserver.$isOn){ on in
                if self.isKeyboardOn == on { return }
                self.isKeyboardOn = on
                if self.isInputSearch != on {
                    withAnimation{ self.isInputSearch = on }
                }
            }
            .onReceive(self.pageDataProviderModel.$event){evt in
                guard let evt = evt else { return }
                switch evt {
                case .willRequest(let progress): self.requestProgress(progress)
                case .onResult(let progress, let res, let count):
                    self.respondProgress(progress: progress, res: res, count: count)
                case .onError(let progress,  let err, let count):
                    self.errorProgress(progress: progress, err: err, count: count)
                }
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.initPage()
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
            }
            .onAppear{
                
            }
            
            
        }//geo
        
        
    }//body

    /*
     Data process
     */
   
    @State var progressError = false
    @State var progressCompleted = false

      
    func initPage(){
        self.pageDataProviderModel.initate()
    }
    

    private func requestProgress(_ progress:Int){
        PageLog.d("requestProgress " + progress.description, tag: self.tag)
        if self.progressError {
            self.errorProgress()
            return
        }
        if self.progressCompleted{
            self.completedProgress()
            return
        }
        /*
        switch progress {
        case 0 :
            guard let data = self.synopsisData else {
                PageLog.d("requestProgress synopsisData nil", tag: self.tag)
                self.errorProgress()
                return
            }
            self.pageDataProviderModel.requestProgress( q:.init(type: .getGatewaySynopsis(data)))
        
        case 1 :
            guard let model = self.synopsisPackageModel else {return}
            if self.isPairing == true {
                self.pageDataProviderModel.requestProgress(q: .init(type: .getPackageDirectView(model, false)))
                self.progressCompleted = true
            } else {
                self.completedProgress()
            }
            
            
        default : do{}
        }
        */
    }
    
    private func respondProgress(progress:Int, res:ApiResultResponds, count:Int){
        PageLog.d("respondProgress " + progress.description + " " + count.description, tag: self.tag)
        self.progressError = false
        /*
        switch progress {
        case 0 :
            guard let data = res.data as? GatewaySynopsis else {
                self.progressError = true
                return
            }
            self.setupGatewaySynopsis(data)
            
        case 1 :
            guard let data = res.data as? DirectPackageView else {
                PageLog.d("DirectPackageView", tag: self.tag)
                self.progressError = true
                return
            }
            self.setupDirectPackageView(data)
        
    
        default :
            switch res.type {
            case .getSynopsis :
                guard let data = res.data as? Synopsis else {
                    PageLog.d("getSynopsis error", tag: self.tag)
                    return
                }
                self.setupSynopsis(data)
            default: break
            }
            
        }
         */
    }
    
    private func errorProgress(progress:Int, err:ApiResultError, count:Int){
        switch progress {
        case 0 : self.progressError = true
        case 1 : self.progressError = true
        default : break
        }
    }
    
    private func completedProgress(){
        PageLog.d("completedProgress", tag: self.tag)
        
        self.onAllProgressCompleted()
        
    }
    private func errorProgress(){
        PageLog.d("errorProgress", tag: self.tag)
        
        self.onAllProgressCompleted()
    }
    
    private func onAllProgressCompleted(){
        PageLog.d("onAllProgressCompleted(", tag: self.tag)
        
    }
}






