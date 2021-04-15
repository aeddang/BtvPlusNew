//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI
struct DiscountView: PageComponent{
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    @ObservedObject var cardModel:CardBlockModel = CardBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var tabs:[NavigationButton] = []
    @State var currentType:CardBlock.ListType = .member
    
    var body: some View {
        VStack (alignment: .center, spacing: 0){
            DivisionTab(
                viewModel: self.viewModel,
                buttons: self.tabs)
                .frame(width: ListItem.card.size.width)
                .padding(.top, Dimen.margin.medium)
            CardBlock(
                viewModel: self.cardModel,
                pageObservable: self.pageObservable,
                useTracking: true
            )
        }
        .background(Color.brand.bg)
        .onReceive(self.viewModel.$index) { idx in
            switch idx {
            case 0 : self.currentType = .member
            case 1 : self.currentType = .okCash
            case 2 : self.currentType = .tvPoint
            default : break
            }
            self.cardModel.update(type:self.currentType)
            self.updateButtons(idx: idx)
            
        }
    }//body
    
    private func updateButtons(idx:Int){
        let titles: [String] = [
            CardBlock.ListType.member.title,
            CardBlock.ListType.okCash.title,
            CardBlock.ListType.tvPoint.title
        ]
        self.tabs = NavigationBuilder(
            index:idx,
            textModifier: TextModifier(
                family:Font.family.medium,
                size: Font.size.lightExtra,
                color: Color.app.grey,
                activeColor: Color.app.white
                )
            )
            .getNavigationButtons(texts:titles)
        
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
