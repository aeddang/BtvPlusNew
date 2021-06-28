//
//  TopTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct KidsTopTab: PageComponent{
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    
    var body: some View {
        HStack(alignment: .center ,spacing:DimenKids.margin.light){
            KidProfile()
            Spacer()
            Button(action: {
                self.pagePresenter.changePage(PageKidsProvider.getPageObject(.kidsIntro))
            }) {
                Image(AssetKids.gnbTop.monthly)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: DimenKids.icon.regular,
                           height: DimenKids.icon.regular)
            }
            Button(action: {
                
                self.pagePresenter.openPopup(
                    PageKidsProvider.getPageObject(.tabInfo)
                        .addParam(key: .datas, value: [
                            TabInfoData(
                                title:"결과 해석",
                                text:"우리 아이의 창의적인 사고와 특성을 꾸준히 유지해 나가기 위해 아이가 가진 생각을 존중해주고,  자유롭게 표현할 수 있는 환경 조성을 해주는 것이 매우 중요합니다. 사람 몸에 바퀴가 생긴다면? 바퀴가 필요한 또 다른 물건은? 이렇게 사물의 특성을 다른 사물에 응용하고 상상하는 대화를 우리 아이의 창의적인 사고와 특성을 꾸준히 유지해 나가기 위해 아이가 가진 생각을 존중해주고,  자유롭게 표현할 수 있는 환경 조성을 해주는 것이 매우 중요합니다. 사람 몸에 바퀴가 생긴다면? 바퀴가 필요한 또 다른 물건은? 이렇게 사물의 특성을 다른 사물에 응용하고 상상하는 대화를"
                            ),
                            TabInfoData(
                                title:"콘텐츠 추천",
                                text:"우리 아이의 창의적인 사고와 특성을 꾸준히 유지해 나가기 위해 아이가 가진 생각을 존중해주고,  자유롭게 표현할 수 있는 환경 조성을 해주는 것이 매우 중요합니다. 사람 몸에 바퀴가 생긴다면? 바퀴가 필요한 또 다른 물건은? 이렇게 사물의 특성을 다른 사물에 응용하고 상상하는 대화를"
                            )
                        ])
                        .addParam(key: .selected, value: 1)
                )
                
            }) {
                Image(AssetKids.gnbTop.search)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            Button(action: {
                if let home  = self.dataProvider.bands.getHome() {
                    let move = PageProvider.getPageObject(.home).addParam(key: .id, value: home.menuId)
                    
                    /*
                    self.pagePresenter.openPopup(
                        PageKidsProvider.getPageObject(.kidsConfirmNumber)
                            .addParam(key: .type, value: PageKidsConfirmType.exit)
                            .addParam(key: .data, value: move)
                    )
                    */
                    self.pagePresenter.changePage(move)
                }
            }) {
                Image(AssetKids.gnbTop.exit)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
        }
       
        .onAppear(){
        }
        
    }
}

#if DEBUG
struct KidsTopTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidsTopTab()
                .environmentObject(PagePresenter())
                .environmentObject(DataProvider())
                .frame(width:320,height:100)
        }
    }
}
#endif
