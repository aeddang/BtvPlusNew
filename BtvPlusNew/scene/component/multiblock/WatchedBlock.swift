//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine

class WatchedBlockModel: PageDataProviderModel {
    private(set) var dataType:BlockData.DataType = .watched
    private(set) var key:String? = nil
    private(set) var menuId:String? = nil
     
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    func update(menuId:String?, key:String? = nil) {
        self.menuId = menuId
        self.key = key
        self.isUpdate = true
    }
}


struct WatchedBlock: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:WatchedBlockModel = WatchedBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var key:String? = nil
    var useTracking:Bool = false
    var spacing: CGFloat = Dimen.margin.medium
   
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if !self.isError {
                WatchedList(
                    datas: self.datas,
                    useTracking:self.useTracking,
                    delete: { data in
                        self.delete(data:data)
                    },
                    onBottom: { _ in
                        self.load()
                    }
                )
                .modifier(MatchParent())
                .background(Color.brand.bg)
            } else {
                EmptyAlert()
                .modifier(MatchParent())
            }
            
            
        }
        
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.reload()
            }
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                switch res.type {
                case .getWatch : self.loaded(res)
                case .deleteWatch :
                    if res.id == self.currentDeleteId {
                        self.deleted(res)
                    }
                default : break
                }
            case .onError(_,  let err, _):
                switch err.type {
                case .getWatch : self.onError()
                case .deleteWatch :
                    if err.id == self.currentDeleteId {
                        PageLog.d("delete error", tag:self.tag)
                    }
                default : break
                }
                
            default : break
            }
        }
        .onReceive(self.pairing.$event){evt in
            guard let _ = evt else {return}
            switch evt {
            case .pairingCompleted : self.reload()
            case .disConnected : self.reload()
            case .pairingCheckCompleted(let isSuccess) :
                if isSuccess { self.reload() }
                else { self.appSceneObserver.alert = .pairingCheckFail }
            default : do{}
            }
        }
        .onAppear(){
           
        }
    }//body
    
    @State var isError:Bool = false
    @State var datas:[WatchedData] = []
    @State var currentDeleteId:String? = nil
     
    func reload(){
        self.datas = []
        self.infinityScrollModel.reload()
        self.load()
    }
    
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        self.viewModel.request = .init(
            id: self.tag,
            type: .getWatch(
                false,
                self.infinityScrollModel.page + 1)
        )
    }
    
    func delete(data:WatchedData){
        guard  let sridId = data.srisId else {
            return
        }
        self.appSceneObserver.alert = .confirm(nil,  String.alert.deleteWatch){ isOk in
            if !isOk {return}
            self.currentDeleteId = sridId
            self.viewModel.request = .init(
                id: sridId ,
                type: .deleteWatch([sridId], false)
            )
        }
    }
    
    func deleted(_ res:ApiResultResponds){
        guard let result = res.data as? UpdateMetv else {
            self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
            return
        }
        if result.result != ApiCode.success {
            self.appSceneObserver.event = .toast(result.reason ?? String.alert.apiErrorServer)
            return
        }
        if let find = self.datas.firstIndex(where: {$0.srisId == self.currentDeleteId}) {
            self.datas.remove(at: find)
        }
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? Watch else { return }
        setDatas(datas: data.watchList)
    }
    
    private func setDatas(datas:[WatchItem]?) {
        guard let datas = datas else {
            if self.datas.isEmpty { self.onError() }
            return
        }
        let start = self.datas.count
        let end = datas.count
        let loadedDatas:[WatchedData] = zip(start...end, datas).map { idx, d in
            return WatchedData().setData(data: d, idx: idx)
        }
        self.datas.append(contentsOf: loadedDatas)
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
}



