//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine
import struct Kingfisher.KFImage
class PurchaseBlockModel: PageDataProviderModel {
    private(set) var key:String? = nil
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    @Published var isEditmode = false
    @Published var isSelectAll = false
    @Published var isSelectChanged:Bool? = nil  {
        didSet{ if self.isSelectChanged != nil { self.isSelectChanged = nil} }
    }
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
        case normal, collection, possession, oksusu
    }
}


struct PurchaseBlock: PageComponent, Identifiable{
    let id:String = UUID().uuidString
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PurchaseBlockModel = PurchaseBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var useTracking:Bool = false
    var marginBottom : CGFloat = 0
    var type:ListType = .normal
    @State var isEdit:Bool = false
    @State var isSelectAll:Bool = false
    @State var isDeletAble:Bool = false
    @State var reloadDegree:Double = 0
    @State var userName:String? = nil
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            VStack(spacing:0){
                if self.isError == false {
                    if self.type == .normal && !self.datas.isEmpty  {
                        HStack(spacing: 0){
                            Spacer()
                            EditButton(
                                icon: self.viewModel.isEditmode ? "" : Asset.icon.edit,
                                text: self.viewModel.isEditmode ? String.app.cancel : String.button.purchaseEdit){
                                    
                                if !self.viewModel.isEditmode {
                                    self.sendLogEdit()
                                }
                                self.viewModel.isEditmode.toggle()
                                self.viewModel.isSelectAll = false
                            }
                        }
                        .padding(.horizontal, Dimen.margin.thin)
                        .frame(height:Dimen.tab.lightExtra)
                        .padding(.vertical, Dimen.margin.thin)
                    }
                    ZStack(alignment: .topLeading){
                        ReflashSpinner(
                            progress: self.$reloadDegree)
                            .padding(.top, Dimen.margin.regular)
                        
                        PurchaseList(
                            purchaseBlockModel:self.viewModel,
                            viewModel:self.infinityScrollModel,
                            datas: self.datas,
                            userName: self.userName,
                            useTracking:self.useTracking,
                            marginBottom: self.marginBottom,
                            type: self.type,
                            onBottom: { _ in
                                if self.type == .oksusu {return} // okssusu 페이징 처리안됨...
                                self.load()
                            }
                        )
                       // Text("QA 확인용 놀라지마세요 " + self.datas.count.description).modifier(BoldTextStyle(color:Color.app.white))
                        
                    }
                    .modifier(MatchParent())
                    .background(Color.brand.bg)
                    .onReceive(self.infinityScrollModel.$event){evt in
                        guard let evt = evt else {return}
                        if self.type == .possession || self.type == .oksusu {return}
                        switch evt {
                        case .pullCompleted :
                            if !self.infinityScrollModel.isLoading { self.reload() }
                            withAnimation{ self.reloadDegree = 0 }
                        case .pullCancel :
                            withAnimation{ self.reloadDegree = 0 }
                        default : do{}
                        }
                        
                    }
                    .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                        if self.type == .possession || self.type == .oksusu {return}
                        if pos < InfinityScrollModel.PULL_RANGE { return }
                        self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
                    }
                    
                } else if self.isError == true {
                    EmptyAlert().modifier(MatchParent())
                } else {
                    Spacer().modifier(MatchParent())
                }
                if self.isEdit && !self.datas.isEmpty {
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
                        EditButton(
                            icon: Asset.icon.delete,
                            text: String.button.remove){
                                if !self.isDeletAble {return}
                                self.delete()
                            }
                            .opacity(self.isDeletAble ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, Dimen.margin.regular)
                    .modifier(MatchHorizontal(height: Dimen.tab.medium))
                    .background(Color.app.blueLightExtra)
                    .padding(.bottom, self.sceneObserver.safeAreaIgnoreKeyboardBottom)
                    
                }
            }
            .background(Color.brand.bg)
        }
        .onReceive(self.viewModel.$isEditmode) { isEdit in
            withAnimation{ self.isEdit = isEdit }
        }
        .onReceive(self.viewModel.$isSelectAll) { isSelect in
            self.isSelectAll = isSelect
            if isSelect {
                self.isDeletAble = isSelect
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    if self.datas.first(where: {$0.isSelected}) == nil {
                        self.isDeletAble = false
                    } else {
                        self.isDeletAble = true
                    }
                }
            }
        }
        .onReceive(self.viewModel.$isSelectChanged) { isSelect in
            guard let change = isSelect else { return }
            if !self.isEdit {return}
            if !change && self.isSelectAll {
                DispatchQueue.main.async {
                    self.isSelectAll = false
                    if self.datas.count == 1 {
                        self.isDeletAble = false
                    }
                }
                return
                
            }else if !self.isSelectAll && change {
                if self.datas.first(where: {!$0.isSelected}) == nil {
                    DispatchQueue.main.async {
                        self.isSelectAll = true
                        if self.datas.count == 1 {
                            self.isDeletAble = true
                        }
                    }
                    return
                }
            }
            if change {
                self.isDeletAble = true
            } else {
                if self.datas.first(where: {$0.isSelected}) == nil {
                    self.isDeletAble = false
                } else {
                    self.isDeletAble = true
                }
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
                case .getPurchase : if self.type == .normal { self.loaded(res) }
                case .getCollectiblePurchase : if self.type == .collection { self.loaded(res) }
                case .getPossessionPurchase : if self.type == .possession { self.loaded(res) }
                case .getOksusuPurchase : if self.type == .oksusu { self.loaded(res) }
                case .deletePurchase : if self.type == .normal { self.deleted(res) }
                default : break
                }
            case .onError(_,  let err, _):
                switch err.type {
                case .getPurchase, .getCollectiblePurchase, .getPossessionPurchase, .getOksusuPurchase : self.onError()
                case .deletePurchase :
                    PageLog.d("delete error", tag:self.tag)
                    
                default : break
                }
                
            default : break
            }
        }
        .onReceive(self.pairing.$event){evt in
            if self.type == .possession {return}
            guard let _ = evt else {return}
            switch evt {
            case .pairingCompleted : self.initLoad()
            case .disConnected : self.initLoad()
            case .pairingCheckCompleted(let isSuccess, _) :
                if isSuccess { self.initLoad() }
                else { self.appSceneObserver.alert = .pairingCheckFail }
            default : break
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
    
    @State var isError:Bool? = nil
    @State var datas:[PurchaseData] = []
    @State var currentDeleteId:String? = nil
    @State var deleteList:[String]? = nil
    func initLoad(){
        if !self.datas.isEmpty {return}
        self.reload()
    }
    func reload(){
        switch type {
        case .possession:
            if self.setup.possession.isEmpty {
                withAnimation{ self.isError = true}
                return
            }
        case .oksusu:
            if self.repository.namedStorage?.oksusu.isEmpty != false {
                withAnimation{ self.isError = true}
                return
            }
        default :
            if self.pairing.status != .pairing {
                withAnimation{ self.isError = true}
                return
            }
        }
        
        withAnimation{
            self.isError = nil
            self.datas = []
        }
        self.infinityScrollModel.reload()
        self.viewModel.isEditmode = false
        self.viewModel.isSelectAll = false
        self.load()
    }
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
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
        case .possession:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getPossessionPurchase( anotherStbId:self.setup.possession , self.infinityScrollModel.page + 1 )
            )
        case .oksusu:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getOksusuPurchase( anotherStbId:self.repository.namedStorage?.oksusu ?? "" , self.infinityScrollModel.page + 1 )
            )
        }

        
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? Purchase else { return }
        self.userName = data.oksusu_user_nm
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
        self.sendLogDelete(num: dels.count)
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
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
        self.appSceneObserver.event = .toast(String.pageText.myPurchaseDeleted)
       
        ComponentLog.d("deleted count " + (result.result_infos?.count.description ?? "0"), tag: self.tag)
        self.reload()
    }
    
    private func setDatas(datas:[PurchaseListItem]?) {
        
        guard let datas = datas else {
            withAnimation{ self.isError = false }
            return
        }
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            
            let anotherStb = self.type == .oksusu
            ? self.repository.namedStorage?.oksusu ?? ""
            : self.type == .possession ? self.setup.possession : ""
            
            let loadedDatas:[PurchaseData] = zip(start...end, datas).map { idx, d in
                return PurchaseData().setData(data: d, idx: idx, type: self.type, anotherStb:anotherStb)
            }
            self.datas.append(contentsOf: loadedDatas)
        }
        self.infinityScrollModel.onComplete(itemCount: datas.count)
        withAnimation{ self.isError = false }
    }
    
    private func sendLogEdit (){
        self.naviLogManager.actionLog(.clickPurchaseListEdit)
    }
    private func sendLogDelete (num:Int){
        let action = MenuNaviActionBodyItem(config:num.description)
        self.naviLogManager.actionLog(.clickPurchaseListDelete ,actionBody: action)
    }
}



