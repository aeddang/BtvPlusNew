//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
struct DiscountView: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    @EnvironmentObject var naviLogManager:NaviLogManager
    var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var cardModel:CardBlockModel = CardBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var tabs:[NavigationButton] = []
    @State var currentType:CardBlock.ListType? = nil
    
    var body: some View {
        VStack (alignment: .center, spacing: 0){
            DivisionTab(
                viewModel: self.viewModel,
                buttons: self.tabs
                )
                .frame(width: self.pairing.pairingStbType == .btv ? ListItem.card.size.width
                       : ListItem.card.size.width*0.66)
                .padding(.top, Dimen.margin.medium)
            CardBlock(
                infinityScrollModel:self.infinityScrollModel,
                viewModel: self.cardModel,
                pageObservable: self.pageObservable,
                useTracking: true
            )
        }
        .background(Color.brand.bg)
        .onReceive(self.viewModel.$index) { idx in
            var willType:CardBlock.ListType? = nil
            switch idx {
            case 0 :
                self.sendLog(action: .clickCouponPointTabMenu, category: "다른할인수단-T맴버십")
                willType = .member
            case 1 :
                self.sendLog(action: .clickCouponPointTabMenu, category: "다른할인수단-OK캐쉬백")
                willType = .okCash
            case 2 :
                self.sendLog(action: .clickCouponPointTabMenu, category: "다른할인수단-TV포인트")
                willType = .tvPoint
            default : break
            }
            if willType != self.currentType {
                self.currentType = willType ?? .member
                self.cardModel.update(type:self.currentType!)
                DispatchQueue.main.async {
                    self.updateButtons(idx: idx)
                }
            }
        }
        .onReceive(self.infinityScrollModel.$scrollPosition) { pos in
            self.viewPagerModel.request = .reset
            
        }
    }//body
    
    private func updateButtons(idx:Int){
        
        let titles: [String] = self.pairing.pairingStbType == .btv
        ? [
            CardBlock.ListType.member.title,
            CardBlock.ListType.okCash.title,
            CardBlock.ListType.tvPoint.title
        ]
        : [
            CardBlock.ListType.member.title,
            CardBlock.ListType.okCash.title
        ]
        self.tabs = NavigationBuilder(
            index:idx,
            textModifier: TextModifier(
                family:Font.family.medium,
                size: SystemEnvironment.isTablet ?  Font.size.tiny : Font.size.lightExtra,
                color: Color.app.grey,
                activeColor: Color.app.white)
            )
            .getNavigationButtons(texts:titles,  bgColor:Color.app.blueLight)
        
    }
    
    private func sendLog(action:NaviLog.Action,
                         category:String?) {
        
        let actionBody = MenuNaviActionBodyItem(category: category)
        self.naviLogManager.actionLog(action, actionBody: actionBody)
    }
}


#if DEBUG
struct DiscountView_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            DiscountView()
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .frame(width:320,height:600)
                .background(Color.brand.bg)
        }
    }
}
#endif
