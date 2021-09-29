//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine

enum WatchedBlockType{
    case mobile, btv, kids
}

class WatchedBlockModel: PageDataProviderModel {
    private(set) var dataType:BlockData.DataType = .watched
    private(set) var watchedType:WatchedBlockType = .btv
    private(set) var key:String? = nil
    private(set) var menuId:String? = nil
    private var isInit = true
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    func update(menuId:String?, key:String? = nil) {
        self.menuId = menuId
        self.key = key
        self.isUpdate = true
    }
    
    func updateMobile() {
        if !self.isInit {return}
        self.isInit = false
        self.watchedType = .mobile
        self.isUpdate = true
    }
    
    func updateBtv() {
        if !self.isInit {return}
        self.isInit = false
        self.watchedType = .btv
        self.isUpdate = true
    }
    
    func updateKids() {
        if !self.isInit {return}
        self.isInit = false
        self.watchedType = .kids
        self.isUpdate = true
    }
}


struct WatchedBlock: PageComponent, Identifiable{
    let id:String = UUID().uuidString
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:WatchedBlockModel = WatchedBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var useTracking:Bool = false
    var marginBottom : CGFloat = 0
    @State var reloadDegree:Double = 0
    @State var watchedType:WatchedBlockType = .btv
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.isError == false {
                ZStack(alignment: .center){
                    ReflashSpinner(
                        progress: self.$reloadDegree)
                        .padding(.top, Dimen.margin.regular)
                    
                    WatchedList(
                        viewModel: self.infinityScrollModel,
                        datas: self.datas,
                        watchedType:self.watchedType,
                        useTracking:self.useTracking,
                        marginBottom:self.marginBottom,
                        delete: { data in
                            self.delete(data:data)
                        },
                        onBottom: { _ in
                            self.load()
                        }
                    )
                }
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted :
                        if !self.infinityScrollModel.isLoading { self.reload() }
                        withAnimation{ self.reloadDegree = 0 }
                    case .pullCancel :
                        withAnimation{ self.reloadDegree = 0 }
                    default : break
                    }
                    
                }
                .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                    if pos < InfinityScrollModel.PULL_RANGE { return }
                    self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
                }
            } else if self.isError == true {
                EmptyAlert().modifier(MatchParent())
            } else {
                Spacer().modifier(MatchParent())
            }
            
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.watchedType = self.viewModel.watchedType
                self.reload()
            }
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                switch res.type {
                case .getWatch : if self.watchedType == .btv { self.loaded(res) }
                case .getWatchMobile : if self.watchedType == .mobile { self.loaded(res) }
                case .deleteWatch:
                    if res.id == self.currentDeleteId && self.watchedType == .btv{
                        self.deleted(res)
                    }
                case .deleteWatchMobile :
                    if res.id == self.currentDeleteId && self.watchedType == .mobile {
                        self.deleted(res)
                    }
                default : break
                }
            case .onError(_,  let err, _):
                switch err.type {
                case .getWatch : if self.watchedType == .btv {self.onError()}
                case .getWatchMobile : if self.watchedType == .mobile {self.onError()}
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
            default : break
            }
        }
        .onAppear(){
           
        }
    }//body
    
    @State var isError:Bool? = nil
    @State var datas:[WatchedData] = []
    @State var currentDeleteId:String? = nil
     
    func reload(){
        if self.pairing.status != .pairing {
            withAnimation{ self.isError = true}
            return
        }
        withAnimation{
            self.isError = nil
            self.datas = []
        }
        self.infinityScrollModel.reload()
        self.load()
    }
    
    
    func load(){
        if self.watchedType == .kids {
            self.datas = []
            self.setDatas(datas: [])
            return
        }
        
        if  !self.infinityScrollModel.isLoadable { return }
        self.infinityScrollModel.onLoad()
        switch self.watchedType {
        case .mobile :
            self.viewModel.request = .init(
                id: self.tag,
                type: .getWatchMobile(self.infinityScrollModel.page + 1)
            )
        case .btv :
            self.viewModel.request = .init(
                id: self.tag,
                type: .getWatch(self.infinityScrollModel.page + 1)
            )
        default:break
        }
        
    }
    
    func delete(data:WatchedData){
        
        guard  let sridId = data.srisId else { return }
        self.appSceneObserver.alert = .confirm(nil,  String.alert.deleteWatch){ isOk in
            if !isOk {return}
            self.currentDeleteId = sridId
            switch self.watchedType {
            case .mobile :
                self.viewModel.request = .init(
                    id: sridId ,
                    type: .deleteWatchMobile([sridId], isAll: false)
                )
            case .btv :
                self.viewModel.request = .init(
                    id: sridId ,
                    type: .deleteWatch([sridId], isAll: false)
                )
            default:break
            }
            
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
            withAnimation{ self.isError = false }
            return
        }
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            let loadedDatas:[WatchedData] = zip(start...end, datas).map { idx, d in
                return WatchedData().setData(data: d, idx: idx, isAll:true)
            }
            .filter{$0.isContinueWatch}
            self.datas.append(contentsOf: loadedDatas)
            
           //let total = loadedDatas.count //resData.watch_tot?.toInt()
            /*
            if  total > MetvNetwork.maxWatchedCount {
                self.datas.append(contentsOf: loadedDatas[ 0...30 ].map{$0})
            } else {
                self.datas.append(contentsOf: loadedDatas)
            }*/
            
        }
        self.infinityScrollModel.onComplete(itemCount: datas.count)
        withAnimation{ self.isError = false }
    }
}



