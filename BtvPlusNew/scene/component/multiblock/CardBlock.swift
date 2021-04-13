//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine

class CardBlockModel: PageDataProviderModel {
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

extension CardBlock{
    enum ListType:String {
        case member, okCash, tvPoint
        
        var title: String {
            switch self {
            case .member: return String.pageText.myBenefitsDiscountT
            case .okCash: return String.pageText.myBenefitsDiscountOk
            case .tvPoint: return String.pageText.myBenefitsDiscountTv
            }
        }
        var empty: String {
            switch self {
            case .member: return String.pageText.myBenefitsCardEmpty
            case .okCash: return String.pageText.myBenefitsCardEmpty
            case .tvPoint: return String.pageText.myBenefitsDiscountTvEmpty
            }
        }
        var emptyTip: String? {
            switch self {
            case .member: return nil
            case .okCash: return nil
            case .tvPoint: return String.pageText.myBenefitsDiscountTvEmptyTip
            }
        }
        var tips: [String] {
            switch self {
            case .member: return [
                String.pageText.myBenefitsDiscountTInfo1,
                String.pageText.myBenefitsDiscountTInfo2]
            case .okCash: return [
                String.pageText.myBenefitsDiscountOkInfo1,
                String.pageText.myBenefitsDiscountOkInfo2,
                String.pageText.myBenefitsDiscountOkInfo3]
            case .tvPoint: return [
                String.pageText.myBenefitsDiscountTvInfo1]
            }
        }
    }
}


struct CardBlock: PageComponent, Identifiable{
    let id:String = UUID().uuidString
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:CardBlockModel = CardBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
     
    var useTracking:Bool = false
    var type:CardBlock.ListType = .member
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.isError == false {
                VStack(alignment: .center, spacing:Dimen.margin.regular){
                    if self.datas.isEmpty {
                        EmptyCard(text: self.type.empty, tip: self.type.emptyTip)
                    } else if self.datas.count == 1 {
                        CardItem(data: self.datas.first!)
                    } else {
                        CardList(
                            viewModel:self.infinityScrollModel,
                            datas: self.datas,
                            useTracking:self.useTracking,
                            margin: self.sceneObserver.screenSize.width - ListItem.card.size.width
                        )
                    }
                    VStack(alignment: .leading, spacing:Dimen.margin.micro){
                        ForEach(self.type.tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 0){
                                Text("• ")
                                    .modifier(MediumTextStyle(
                                        size: Font.size.thinExtra,
                                        color: Color.app.grey
                                    ))
                                Text(tip)
                                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.grey))
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(width: ListItem.card.size.width)
                    Spacer()
                }
                .padding(.top, Dimen.margin.medium)
                .modifier(MatchParent())
                .background(Color.brand.bg)
                
                
                
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
                case .getTMembership : if self.type == .member { self.loadedTMembership(res) }
                case .getTotalPoint : if self.type == .okCash { self.loadedOkCash(res) }
                case .getTvPoint : if self.type == .tvPoint { self.loadedTvpoint(res) }
                default : break
                }
            case .onError(_,  let err, _):
                switch err.type {
                case .getTMembership : if self.type == .member { self.onError() }
                case .getTotalPoint : if self.type == .okCash { self.onError() }
                case .getTvPoint : if self.type == .tvPoint { self.onError() }
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
        .onAppear(){
           
        }
    }//body
    
    @State var isError:Bool? = nil
    @State var datas:[CardData] = []
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
        case .member:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getTMembership(self.pairing.hostDevice)
            )
        case .okCash:
            self.viewModel.request = .init(
                    id: self.tag,
                    type: .getTotalPoint(self.pairing.hostDevice)
                )

        case .tvPoint:
            self.viewModel.request = .init(
                id: self.tag,
                type: .getTvPoint(self.pairing.hostDevice)
            )
        }
        
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    private func onEmpty(){
        withAnimation{ self.isError = false }
    }

    private func loadedTMembership(_ res:ApiResultResponds){
        guard let data = res.data as? TMembership else { return }
        guard let tmembership = data.tmembership else { return self.onEmpty() }
        
        self.datas.append(CardData().setData(data: tmembership))
        self.infinityScrollModel.onComplete(itemCount: 1)
        withAnimation{ self.isError = false }
    }
    
    private func loadedOkCash(_ res:ApiResultResponds){
        guard let data = res.data as? TotalPoint else { return }
        guard let ocbList = data.ocbList?.ocb else { return self.onEmpty() }
        let datas:[CardData] = ocbList.map{
            CardData().setData(data: $0)
        }
        self.datas.append(contentsOf: datas)
        self.infinityScrollModel.onComplete(itemCount: datas.count)
        withAnimation{ self.isError = false }
    }
    
    private func loadedTvpoint(_ res:ApiResultResponds){
        guard let data = res.data as? TvPoint else { return }
        guard let tvpoint = data.tvpoint else { return self.onEmpty() }
        if tvpoint.useTvpoint == true {
            self.datas.append(CardData().setData(data: tvpoint))
            self.infinityScrollModel.onComplete(itemCount: 1)
        }
        withAnimation{ self.isError = false }
    }
}



