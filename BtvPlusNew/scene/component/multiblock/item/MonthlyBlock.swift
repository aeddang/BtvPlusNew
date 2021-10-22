//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine

class MonthlyBlockModel: InfinityScrollModel {
    @Published var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
}

extension MonthlyBlock{
    static let height:CGFloat = ListItem.monthly.size.height + Font.size.regular
        + Dimen.button.regularExtra + (Dimen.margin.thinExtra * 3) + Dimen.margin.lightExtra
}

struct MonthlyBlock: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel: MonthlyBlockModel = MonthlyBlockModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var monthlyDatas:[MonthlyData] = []
    var allData:BlockItem? = nil
    var useTracking:Bool = false
    var action: ((_ data:MonthlyData) -> Void)? = nil
    
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            HStack( spacing:Dimen.margin.thin){
                VStack(alignment: .leading, spacing:0){
                    Text(String.monthly.title).modifier(BlockTitle())
                        .lineLimit(1)
                    Spacer().modifier(MatchHorizontal(height: 0))
                }
                if let allData = self.allData, !SystemEnvironment.isEvaluation {
                    TextButton(
                        defaultText: String.monthly.more,
                        textModifier: MediumTextStyle(size: Font.size.thin, color: Color.app.white).textModifier
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.monthlyTicket)
                                .addParam(key: .id, value: allData.menu_id)
                                .addParam(key: .title, value: allData.menu_nm)
                                .addParam(key: .data, value: allData.blocks)
                                .addParam(key: .type, value: BlockData.ThemaType.ticket)
                        )
                    }
                } else{
                    Spacer()
                }
            }
            .modifier(ContentHorizontalEdges())
           
            if let list = self.list {
                list.modifier(MatchHorizontal(height: ListItem.monthly.size.height))
            }
            TipTab(
                leadingIcon: self.tipIconLeading,
                leading: self.tipLeading,
                strong: self.tipStrong,
                icon: self.tipIcon,
                trailing: self.tipTrailing,
                isMore: !self.hasAuth || self.isKids,
                textColor: self.hasAuth ? Color.app.white : Color.app.greyLight,
                textStrongColor: self.hasAuth ? Color.app.white : Color.brand.primary,
                bgColor: self.hasAuth ? Color.brand.primary : Color.app.blueLight)
            .modifier( ContentHorizontalEdges() )
            .padding(.top, Dimen.margin.lightExtra)
            .onTapGesture {
                if self.isKids {
                    self.moveKids()
                    return
                }
                if self.hasAuth {return}
                
                let status = self.pairing.status
                if status != .pairing {
                    self.appSceneObserver.alert = .needPairing()
                    return 
                }
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.purchase)
                        .addParam(key: .data, value: currentData)
                )
            }
        }
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.viewModel,
                pageDragingModel: self.pageDragingModel)
        )
        .onAppear(){
            if self.monthlyDatas.isEmpty {return}
            self.list = self.getList()
            self.initSubscription()
            if self.currentData == nil {
                if let data = self.monthlyDatas.first(where: { $0.isSelected }) {
                    self.selectedData(data: data)
                }
            }
            self.setupTipTab()
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            self.list = self.getList()
        }
        .onReceive(self.dataProvider.$result) { res in
            guard let res = res else {return}
            switch res.type {
            case .getMonthlyData(let prcPrdId, _) :
                guard let data = res.data as? MonthlyInfoData else { return }
                if let monthly = self.monthlyDatas.first(where: {$0.prdPrcId == prcPrdId}) {
                    monthly.setData(data: data)
                    if self.isInitFocus {
                        self.isInitFocus = false
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            self.viewModel.uiEvent = .scrollTo(monthly.hashId, .center)
                        }
                    }
                }
            default : break
            }
        }
        
        .onDisappear(){
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
    }
    @State var isInitFocus:Bool = true
    @State var list: MonthlyList?
    @State var listId:String = ""
    
    @discardableResult
    private func getList() -> MonthlyList {
        let key = self.monthlyDatas.reduce("", {$0 + "|" + $1.prdPrcId + $1.sortIdx.description})
        ComponentLog.d("key " + key , tag: self.tag)
        if  self.listId == key, let list = self.list {
            ComponentLog.d("Recycle List" , tag: self.tag)
            return list
        }
        let newList = MonthlyList(
            viewModel:self.viewModel,
            datas: self.monthlyDatas,
            useTracking:self.useTracking
        ){ data in
            
            self.selectedData(data: data)
            if let action = self.action {
                action(data)
            }
           
        }
        ComponentLog.d("New List" , tag: self.tag)
        self.listId = key
        return newList
    }
    
    private func moveKids(){
        guard let current = self.currentData else { return }
        self.pagePresenter.changePage(
            PageKidsProvider.getPageObject(.kidsHome)
                .addParam(key: .title, value: current.title)
        )
    }
    
    
    @State var anyCancellable = Set<AnyCancellable>()
    @State var currentData:MonthlyData? = nil
    @State var hasAuth:Bool = false
    @State var isKids:Bool = false
    private func initSubscription(){
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        
        self.monthlyDatas.forEach{ data in
            data.$isUpdated.sink(receiveValue: { update in
                if !update {return}
                if data.prdPrcId == self.currentData?.prdPrcId {
                    self.hasAuth = data.hasAuth
                    self.setupTipTab()
                }
            }).store(in: &anyCancellable)
            
            data.$isPurchaseUpdated.sink(receiveValue: { update in
                if !update {return}
                if data.prdPrcId == self.currentData?.prdPrcId {
                    self.setupTipTab()
                }
            }).store(in: &anyCancellable)
        }
    }
    
    private func selectedData(data:MonthlyData){
        self.currentData = data
        self.hasAuth = data.hasAuth
    }
    @State var tipIconLeading:String? = nil
    @State var tipLeading:String? = nil
    @State var tipStrong:String? = nil
    @State var tipIcon:String? = nil
    @State var tipTrailing:String? = nil
    private func setupTipTab(){
        guard let currentData = self.currentData else {return}
        self.tipIconLeading = nil
        self.tipLeading = nil
        self.tipStrong = nil
        self.tipIcon = nil
        self.tipTrailing = nil
        if self.hasAuth {
            self.isKids = self.currentData?.isKidszone ?? false
            if self.isKids {
                self.tipLeading = String.monthly.textKidsLeading
                self.tipIcon = Asset.icon.logoZem
                self.tipTrailing = String.monthly.textKidsTrailing
            } else {
                if currentData.isPeriod {
                    if let titlePeriod = currentData.titlePeriod {
                        self.tipStrong = titlePeriod
                        self.tipTrailing = String.monthly.textEnjoyPeriod
                    } else {
                        self.tipLeading = String.monthly.textEnjoyPeriod
                    }
                } else {
                    self.tipLeading = currentData.prodTypeCd == .omnipack
                        ? String.monthly.textEnjoyOmnipack
                        : String.monthly.textEnjoy

                    if currentData.isFirstFree == nil && self.pairing.status == .pairing {
                        self.dataProvider.requestData(q: .init(type: .getMonthlyData(currentData.prdPrcId, isDetail: false), isOptional:true))
                    }
                }
            }
            
        } else{
            self.isKids = false
            if currentData.isFirstFree == true {
                self.tipIconLeading = Asset.icon.firstFree
                self.tipStrong = String.monthly.textFirstFreeStrong
                self.tipTrailing = String.monthly.textFirstFreeTrailing
            } else {
                self.tipLeading = currentData.prodTypeCd == .omnipack
                    ? String.monthly.textRecommandOmnipack : String.monthly.textRecommand
                
                if currentData.isFirstFree == nil && self.pairing.status == .pairing {
                    self.dataProvider.requestData(q: .init(type: .getMonthlyData(currentData.prdPrcId, isDetail: false), isOptional:true))
                }
            }
            
        }
    }
    
}
