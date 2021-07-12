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
                            PageProvider.getPageObject(.multiBlock)
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
                .onReceive(self.viewModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted : self.pageDragingModel.updateNestedScroll(evt: .pullCompleted)
                    case .pullCancel : self.pageDragingModel.updateNestedScroll(evt: .pullCancel)
                    default : do{}
                    }
                }
                .onReceive(self.viewModel.$pullPosition){ pos in
                    self.pageDragingModel.updateNestedScroll(evt: .pull(pos))
                }
            }
            TipTab(
                leading: self.hasAuth ? String.monthly.textEnjoy : String.monthly.textRecommand,
                isMore: !self.hasAuth,
                textColor: self.hasAuth ? Color.app.white : Color.app.greyLight,
                bgColor: self.hasAuth ? Color.brand.primary : Color.app.blueLight)
            .modifier( ContentHorizontalEdges() )
            .padding(.top, Dimen.margin.lightExtra)
            .onTapGesture {
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
        .onAppear(){
            if self.monthlyDatas.isEmpty {return}
            self.getList()
            self.initSubscription()
            if self.currentData == nil {
                if let data = self.monthlyDatas.first(where: { $0.isSelected }) {
                    self.selectedData(data: data)
                }
            } else {
                self.moveScroll()
            }
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            self.getList()
        }
        .onDisappear(){
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
    }
    
    
   
    private func moveScroll(){
        if let data = self.currentData {
            let idx  = self.monthlyDatas.firstIndex(of: data) ?? 0
            ComponentLog.d("idx " + idx.description, tag: self.tag)
            if idx > 0 {
                self.viewModel.uiEvent = .scrollTo(max(0,idx), .center)
            }
        }
    }
    
    @State var list: MonthlyList?
    @State var listId:String = ""
    
    @discardableResult
    private func getList() -> some View {
        let key = self.monthlyDatas.reduce("", {$0 + "|" + $1.sortIdx.description})
        if  self.listId == key, let list = self.list {
            ComponentLog.d("Recycle List" , tag: self.tag)
            return list
        }
        
        
        let newList = MonthlyList(
            viewModel:self.viewModel,
            datas: self.monthlyDatas,
            useTracking:self.useTracking
        ){ data in
            
            if let action = self.action {
                action(data)
            }
            self.selectedData(data: data)
        }
        ComponentLog.d("New List" , tag: self.tag)
        DispatchQueue.main.async {
            self.listId = key
            self.list = newList
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            self.moveScroll()
        }
        return newList
    }
    
    @State var anyCancellable = Set<AnyCancellable>()
    @State var currentData:MonthlyData? = nil
    @State var hasAuth:Bool = false
    private func initSubscription(){
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        
        self.monthlyDatas.forEach{ data in
            data.$isUpdated.sink(receiveValue: { update in
                if !update {return}
                if data.prdPrcId == self.currentData?.prdPrcId {
                    self.hasAuth = data.hasAuth
                }
            }).store(in: &anyCancellable)
        }
    }
    
    private func selectedData(data:MonthlyData){
        self.currentData = data
        self.hasAuth = data.hasAuth
    }
}