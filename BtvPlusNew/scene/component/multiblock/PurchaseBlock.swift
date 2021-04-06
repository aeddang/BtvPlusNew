//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine

class PurchaseBlockModel: PageDataProviderModel {
    private(set) var key:String? = nil
    private(set) var menuId:String? = nil
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    @Published var isEditmode = false
    @Published var isSelectAll = false
    
    func update(menuId:String?, key:String? = nil) {
        self.menuId = menuId
        self.key = key
        self.isUpdate = true
    }
}


struct PurchaseBlock: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PurchaseBlockModel = PurchaseBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var useTracking:Bool = false
    @State var isEdit:Bool = false
    @State var isSelectAll:Bool = false
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            VStack(spacing:0){
                if !self.isError {
                    PurchaseList(
                        purchaseBlockModel:self.viewModel,
                        viewModel:self.infinityScrollModel,
                        datas: self.datas,
                        useTracking:self.useTracking,
                        onBottom: { _ in
                            self.load()
                        }
                    )
                    .modifier(MatchParent())
                    .background(Color.brand.bg)
                } else {
                    EmptyMyData(
                        text:String.pageText.myWatchedEmpty)
                    .modifier(MatchParent())
                }
                if self.isEdit {
                    HStack(spacing: 0){
                        CheckBox(
                            isChecked: self.isSelectAll,
                            text: String.button.selectAll,
                            isStrong : true,
                            action:{ ck in
                                self.viewModel.isSelectAll = ck
                            }
                        )
                        Spacer()
                        Button(action: {
                            
                        }) {
                            HStack(alignment:.center, spacing: Dimen.margin.tinyExtra){
                                Image(Asset.icon.delete)
                                    .renderingMode(.original).resizable()
                                    .scaledToFit()
                                    .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                Text(String.button.delete)
                                    .modifier(BoldTextStyle(size: Font.size.light))
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.horizontal, Dimen.margin.regular)
                    .modifier(MatchHorizontal(height: Dimen.tab.medium))
                    .background(Color.app.blueLightExtra)
                    .padding(.bottom, self.sceneObserver.safeAreaBottom)
                }
            }
        }
        .onReceive(self.viewModel.$isEditmode) { isEdit in
            withAnimation{ self.isEdit = isEdit }
        }
        .onReceive(self.viewModel.$isSelectAll) { isSelect in
            self.isSelectAll = isSelect
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
                case .getPurchase : self.loaded(res)
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
    @State var datas:[PurchaseData] = []
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
            type: .getPurchase( self.infinityScrollModel.page + 1 )
        )
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? Purchase else { return }
        setDatas(datas: data.purchaseList)
    }
    
    func delete(data:PurchaseData){
        /*
        guard  let sridId = data.srisId else {
            return
        }
        self.appSceneObserver.alert = .confirm(nil,  String.alert.deleteWatch){ isOk in
            if !isOk {return}
            self.currentDeleteId = sridId
            self.viewModel.request = .init(
                id: sridId ,
                type: .deleteWatch([sridId], isAll: false)
            )
        }
        */
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
        if let find = self.datas.firstIndex(where: {$0.epsdId == self.currentDeleteId}) {
            self.datas.remove(at: find)
        }
    }
    
    private func setDatas(datas:[PurchaseListItem]?) {
        guard let datas = datas else {
            if self.datas.isEmpty { self.onError() }
            return
        }
        let start = self.datas.count
        let end = datas.count
        let loadedDatas:[PurchaseData] = zip(start...end, datas).map { idx, d in
            return PurchaseData().setData(data: d, idx: idx)
        }
        self.datas.append(contentsOf: loadedDatas)
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
}



