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
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    @Published var isEditmode = false
    @Published var isSelectAll = false
    private var isInit = true
    func initUpdate(key:String? = nil) {
        if !self.isInit {return}
        self.update(key: key)
    }
    
    func update(key:String? = nil) {
        self.key = key
        self.isUpdate = true
        self.isInit = false
    }
}

extension PurchaseBlock{
    enum ListType:String {
        case normal, collection
    }
}


struct PurchaseBlock: PageComponent, Identifiable{
    let id:String = UUID().uuidString
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PurchaseBlockModel = PurchaseBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var useTracking:Bool = false
    var type:ListType = .normal
    @State var isEdit:Bool = false
    @State var isSelectAll:Bool = false
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            VStack(spacing:0){
                if !self.isError {
                    if self.type == .normal {
                        HStack(spacing: 0){
                            Spacer()
                            Button(action: {
                                self.viewModel.isEditmode.toggle()
                            }) {
                                if !self.isEdit {
                                    HStack(alignment:.center, spacing: Dimen.margin.tinyExtra){
                                        Image(Asset.icon.edit)
                                            .renderingMode(.original).resizable()
                                            .scaledToFit()
                                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                        Text(String.button.purchaseEdit)
                                            .modifier(BoldTextStyle(size: Font.size.light))
                                    }
                                } else {
                                    Text(String.app.cancel)
                                        .modifier(BoldTextStyle(size: Font.size.light))
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.horizontal, Dimen.margin.thin)
                        .frame(height:Dimen.tab.lightExtra)
                        .padding(.vertical, Dimen.margin.thin)
                    }
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
                        text: String.pageText.myPurchaseEmpty)
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
                            self.delete()
                        }) {
                            HStack(alignment:.center, spacing: Dimen.margin.tinyExtra){
                                Image(Asset.icon.delete)
                                    .renderingMode(.original).resizable()
                                    .scaledToFit()
                                    .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                Text(String.button.remove)
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
            .background(Color.brand.bg)
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
                case .getPurchase, .getCollectiblePurchase : self.loaded(res)
                case .deletePurchase : self.deleted(res)
                default : break
                }
            case .onError(_,  let err, _):
                switch err.type {
                case .getPurchase, .getCollectiblePurchase : self.onError()
                case .deletePurchase :
                    PageLog.d("delete error", tag:self.tag)
                    
                default : break
                }
                
            default : break
            }
        }
        .onReceive(self.pairing.$event){evt in
            guard let _ = evt else {return}
            switch evt {
            case .pairingCompleted : self.initLoad()
            case .disConnected : self.initLoad()
            case .pairingCheckCompleted(let isSuccess) :
                if isSuccess { self.initLoad() }
                else { self.appSceneObserver.alert = .pairingCheckFail }
            default : do{}
            }
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            
            switch evt.type {
            case .completed :
                guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                switch type {
                case .purchase:
                    guard let list = self.deleteList   else { return }
                    self.onPurchaseDelete(list:list)
                    self.deleteList = nil
                default: break
                }
            case .cancel :
                guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                switch type {
                case .purchase: self.deleteList = nil
                default: break
                }
                
            default : break
            }
        }
        .onAppear(){
           
        }
    }//body
    
    @State var isError:Bool = false
    @State var datas:[PurchaseData] = []
    @State var currentDeleteId:String? = nil
    @State var deleteList:[String]? = nil
    func initLoad(){
        if !self.datas.isEmpty {return}
        self.reload()
    }
    func reload(){
        if self.pairing.status != .pairing {
            withAnimation{ self.isError = true }
            return
        }
        self.datas = []
        self.infinityScrollModel.reload()
        self.viewModel.isEditmode = false
        self.viewModel.isSelectAll = false
        self.load()
    }
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        switch type {
        case .normal:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getPurchase( self.infinityScrollModel.page + 1 )
            )
        case .collection:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getCollectiblePurchase( self.infinityScrollModel.page + 1 )
            )
        }
        
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? Purchase else { return }
        setDatas(datas: data.purchaseList)
    }

    func delete(){
        let dels = self.datas
            .filter{$0.isSelected}
            .filter{$0.purchaseId != nil}
            .map{$0.purchaseId!}
        
        if dels.count > 100 {
            self.appSceneObserver.alert = .alert(String.alert.purchaseHiddenLimit, String.alert.purchaseHiddenLimitText)
            return
        }
        self.deleteList = dels
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmPassword)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.purchase)
                .addParam(key: .title, value: String.alert.purchaseHidden)
                .addParam(key: .text, value: String.alert.purchaseHiddenText)
                .addParam(key: .subText, value: String.alert.purchaseHiddenInfo)
        )
    }
    
    func onPurchaseDelete(list:[String]){
        self.viewModel.request = .init( type: .deletePurchase(list) )
    }
    
    func deleted(_ res:ApiResultResponds){
        guard let result = res.data as? PurchaseDeleted else {
            self.appSceneObserver.event = .toast(String.alert.apiErrorServer)
            return
        }
        ComponentLog.d("deleted count " + (result.result_infos?.count.description ?? "0"), tag: self.tag)
        self.reload()
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



