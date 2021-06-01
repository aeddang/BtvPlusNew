//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine

class CouponBlockModel: PageDataProviderModel {
    private(set) var key:String? = nil
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
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

extension CouponBlock{
    enum ListType:String {
        case coupon, point, cash
        
        var text: String {
            switch self {
            case .coupon: return String.pageText.myBenefitsCouponText
            case .point: return String.pageText.myBenefitsPointText
            case .cash: return String.pageText.myBenefitsCashText
            }
        }
        
        var regist:String {
            switch self {
            case .coupon: return String.pageText.myBenefitsCouponRegist
            case .point: return String.pageText.myBenefitsPointRegist
            case .cash: return String.pageText.myBenefitsCashRegist
            }
        }
        
        var empty: String {
            switch self {
            case .coupon: return String.pageText.myBenefitsCouponEmpty
            case .point: return String.pageText.myBenefitsPointEmpty
            case .cash: return String.pageText.myBenefitsCashEmpty
            }
        }
    }
}


struct CouponBlock: PageComponent, Identifiable{
    let id:String = UUID().uuidString
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:CouponBlockModel = CouponBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var useTracking:Bool = false
    var type:ListType = .coupon
    @State var reloadDegree:Double = 0
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            
            if self.isError == false {
                ZStack(alignment: .topLeading){
                    ReflashSpinner(
                        progress: self.$reloadDegree)
                        .padding(.top, Dimen.margin.regular)
                    CouponList(
                        couponBlockModel:self.viewModel,
                        type:self.type,
                        title:self.title,
                        viewModel:self.infinityScrollModel,
                        datas: self.datas,
                        useTracking:self.useTracking,
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
                    default : do{}
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
                self.reload()
            }
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                switch res.type {
                case .getCoupons : if self.type == .coupon {  self.loadedCoupon(res) }
                case .getBPoints : if self.type == .point {self.loadedPoint(res) }
                case .getBCashes : if self.type == .cash {self.loadedCash(res) }
                default : break
                }
            case .onError(_,  let err, _):
                switch err.type {
                case .getCoupons : if self.type == .coupon { self.onError() }
                case .getBPoints : if self.type == .point { self.onError() }
                case .getBCashes : if self.type == .cash { self.onError() }
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
                guard let type = evt.data as? CouponBlock.ListType  else { return }
                if type == self.type { self.reload() }
            default : break
            }
        }
        .onAppear(){
           
        }
    }//body
    
    @State var isError:Bool? = nil
    @State var datas:[CouponData] = []
    @State var title:String? = nil
    func initLoad(){
        if !self.datas.isEmpty {return}
        self.reload()
    }
    func reload(){
        if self.pairing.status != .pairing {
            withAnimation{ self.isError = true }
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
        if  !self.infinityScrollModel.isLoadable { return }
        self.infinityScrollModel.onLoad()
        switch type {
        case .coupon:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getCoupons(self.pairing.hostDevice,  self.infinityScrollModel.page + 1 )
            )
        case .point:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getBPoints(self.pairing.hostDevice,  self.infinityScrollModel.page + 1 )
            )
        case .cash:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getBCashes(self.pairing.hostDevice,  self.infinityScrollModel.page + 1 )
            )
        }
        
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loadedCoupon(_ res:ApiResultResponds){
        guard let data = res.data as? Coupons else { return }
        if let count = data.usableCount {
            self.pairing.authority.useAbleCoupon = count
            self.title = count.description + String.app.count
        }
        setDatas(datas: data.coupons?.coupon)
    }
    private func loadedPoint(_ res:ApiResultResponds){
        guard let data = res.data as? BPoints else { return }
        if let point = data.usableNewBpoint {
            self.pairing.authority.useAbleBPoint = point
            self.title = point.formatted(style: .decimal) + String.app.point
        }
        setDatas(datas: data.newBpoints?.newBpoint)
        
    }
    private func loadedCash(_ res:ApiResultResponds){
        guard let data = res.data as? BCashes else { return }
        if let cash = data.usableBcash?.totalBalance {
            self.pairing.authority.useAbleBCash = cash
            self.title = cash.formatted(style: .decimal) + String.app.point
        }
        setDatas(datas: data.bcashList?.bcash)
    }
    
    private func setDatas(datas:[Coupon]?) {
        guard let datas = datas else {
            withAnimation{ self.isError = false }
            return
        }
        let start = self.datas.count
        let end = datas.count
        let loadedDatas:[CouponData] = zip(start...end, datas).map { idx, d in
            return CouponData().setData(data: d, idx: idx)
        }
        self.datas.append(contentsOf: loadedDatas)
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
        withAnimation{ self.isError = false }
    }
    
    private func setDatas(datas:[BPoint]?) {
        guard let datas = datas else {
            withAnimation{ self.isError = false }
            return
        }
        let start = self.datas.count
        let end = datas.count
        let loadedDatas:[CouponData] = zip(start...end, datas).map { idx, d in
            return CouponData().setData(data: d, idx: idx)
        }
        self.datas.append(contentsOf: loadedDatas)
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
        withAnimation{ self.isError = false }
    }
    
    private func setDatas(datas:[BCash]?) {
        guard let datas = datas else {
            withAnimation{ self.isError = false }
            return
        }
        let start = self.datas.count
        let end = datas.count
        let loadedDatas:[CouponData] = zip(start...end, datas).map { idx, d in
            return CouponData().setData(data: d, idx: idx)
        }
        self.datas.append(contentsOf: loadedDatas)
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
        withAnimation{ self.isError = false }
    }
}



