//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine
extension MonthlyBlock{
    static let height:CGFloat = ListItem.monthly.size.height + Font.size.regular
        + Dimen.button.regularExtra + (Dimen.margin.thinExtra * 3) + Dimen.margin.lightExtra
}


struct MonthlyBlock: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var monthlyDatas:[MonthlyData]? = nil
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
                TextButton(
                    defaultText: String.monthly.more,
                    textModifier: MediumTextStyle(size: Font.size.thin, color: Color.app.white).textModifier
                ){_ in
                    /*
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.cate)
                            .addParam(key: .data, value: data)
                            .addParam(key: .type, value: CateBlock.ListType.video)
                        
                    )
                     */
                }
            }
            .modifier(ContentHorizontalEdges())
            if self.monthlyDatas != nil {
                MonthlyList(
                    viewModel:self.viewModel,
                    datas: self.monthlyDatas!,
                    useTracking:self.useTracking
                ){ data in
                    if let action = self.action {
                        action(data)
                    }
                    self.selectedData(data: data)
                }
                .modifier(MatchHorizontal(height: ListItem.monthly.size.height))
                
                .onReceive(self.viewModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCancel : self.pageDragingModel.updateNestedScroll(evt: .pulled)
                    default : do{}
                    }
                }
                .onReceive(self.viewModel.$pullPosition){ pos in
                    self.pageDragingModel.updateNestedScroll(evt: .pull(pos))
                }
            }
            ZStack{
                HStack(spacing:Dimen.margin.tinyExtra){
                    Text(self.hasAuth ? String.monthly.textEnjoy : String.monthly.textRecommand)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: self.hasAuth ? Color.app.white : Color.app.greyLight))
                    if !self.hasAuth{
                        Image(Asset.icon.more)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
                    }
                }
            }
            .padding(.horizontal, Dimen.margin.thin)
            .modifier( MatchHorizontal(height: Dimen.button.regularExtra) )
            .background(self.hasAuth ? Color.brand.primary : Color.app.blueLight)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
            .modifier( ContentHorizontalEdges() )
            .padding(.top, Dimen.margin.lightExtra)
            .onTapGesture {
                if self.hasAuth {return}
                
                let model = PurchaseWebviewModel()
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.purchase)
                        .addParam(key: .data, value: model)
                )
            }
        }
        
        .onAppear(){
            if let data = self.monthlyDatas?.first(where: { $0.isSelected }) {
                self.selectedData(data: data)
            }
            self.initSubscription()
            if let data = self.currentData {
                let idx  = data.index - 1
                if idx > 0 { self.viewModel.uiEvent = .scrollTo(idx) }
            }
        }
        .onDisappear(){
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
    }
    
    @State var anyCancellable = Set<AnyCancellable>()
    
    @State var currentData:MonthlyData? = nil
    @State var hasAuth:Bool = false
    
    private func initSubscription(){
        self.monthlyDatas?.forEach{ data in
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
