//
//  PageDataProtocol.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

enum PageDataProviderEvent {
    case willRequest(Int),
         onResult(Int,ApiResultResponds, Int),
         onError(Int,ApiResultError, Int)
}
open class PageDataProviderModel:ObservableObject{
    
    @Published private(set) var event:PageDataProviderEvent? = nil
    @Published var request:ApiQ? = nil
    
    @Published fileprivate var requests:Array<ApiQ>? = nil
    private(set) var progress = 0
    private var isProgress = false
    private var completedCount = 0
    func initate(){
        self.progress = 0
        self.event = .willRequest(progress)
    }
    private func next(){
        if self.completedCount != self.requests?.count { return }
        self.progress += 1
        self.requests = nil
        self.isProgress = false
        self.completedCount = 0
        self.event = .willRequest(progress)
    }
    func requestProgress(q:ApiQ){
        if isProgress { return }
        var copy = q.copy()
        copy.isProcess = true
        self.requests = [copy]
    }
    func requestProgress(qs:Array<ApiQ>){
        if isProgress { return }
        let copys:Array<ApiQ> = qs.map { q in
            var copy = q.copy()
            copy.isProcess = true
            return copy
        }
        self.requests = copys
    }
    
    fileprivate func onResult(_ result:ApiResultResponds) {
        
        if result.id == request?.id {
            self.event = .onResult(-1, result, -1)
        }
        guard let apis = self.requests else { return }
        guard let count = apis.firstIndex(where: { $0.id == result.id }) else { return }
        self.completedCount += 1
        self.event = .onResult(progress, result, count)
        self.next()
    }
    
    fileprivate func onError(_ err:ApiResultError) {
        if err.id == request?.id {
            self.event = .onError(-1, err, -1)
        }
        guard let apis = self.requests else { return }
        guard let count = apis.firstIndex(where: { $0.id == err.id }) else { return }
        self.completedCount += 1
        self.event = .onError(progress, err, count)
        self.next()
    }
}


struct PageDataProviderContent<Content>: PageComponent  where Content: View{
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel
    let content: Content
    
    init(
        pageObservable : PageObservable? = nil,
        viewModel: PageDataProviderModel,
        @ViewBuilder content: () -> Content){
        
        if let pageObservable = pageObservable { self.pageObservable = pageObservable }
        self.viewModel = viewModel
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top){
            self.content.modifier(MatchParent())
        }//z
    
        .onReceive(self.viewModel.$request){ apiQ in
            guard let apiQ = apiQ else { return }
            //apiQ.copy(newId: self.tag)
            self.dataProvider.requestData(q:apiQ)
        }
        .onReceive(self.viewModel.$requests){ apiQs in
            guard let apiQs = apiQs else { return }
            apiQs.forEach{ apiQ in
                self.dataProvider.requestData(q: apiQ)
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            //if !res.id.hasPrefix(self.tag) { return }
            self.viewModel.onResult(res)
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            //if !err.id.hasPrefix(self.tag) { return }
            self.viewModel.onError(err)
        }
    }//body
}
