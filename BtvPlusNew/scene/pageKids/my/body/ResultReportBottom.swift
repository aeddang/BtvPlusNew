//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI
extension ResultReportBottom {
    static let textSize:CGFloat = SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.thin
}

struct ResultReportBottom: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var date:String
   
    var type:DiagnosticReportType
    var retryCount:String
    
    var body: some View {
        HStack(spacing:DimenKids.margin.tiny){
            Text(String.kidsText.kidsMyDiagnosticReportDate)
                .modifier(BoldTextStyleKids(
                            size: Self.textSize,
                            color: Color.app.brownDeep))
            Text(self.date)
                .modifier(BoldTextStyleKids(
                            size: Self.textSize,
                            color: Color.kids.primaryLight))
            if !self.retryCount.isEmpty {
                Spacer().modifier(LineVertical(width: 1, color: Color.app.brownDeep, opacity: 0.6))
                    .frame(height:Font.sizeKids.thin)
            
                Text(String.kidsText.kidsMyResultRetryCount)
                    .modifier(BoldTextStyleKids(
                                size: Self.textSize,
                                color: Color.app.brownDeep))
                Text(self.retryCount)
                    .modifier(BoldTextStyleKids(
                                size: Self.textSize,
                                color: Color.kids.primaryLight))
            }
            Spacer()
            RectButtonKids(
                text: String.kidsText.kidsMyResultRecommandView,
                icon: AssetKids.icon.medal,
                isSelected: false,
                textModifier: BoldTextStyleKids(
                    size: SystemEnvironment.isTablet ? Font.sizeKids.thinExtra : Font.sizeKids.lightExtra,
                    color: Color.app.sepia).textModifier,
                size: CGSize(width: 0,
                             height: SystemEnvironment.isTablet ? DimenKids.button.regularExtra : DimenKids.button.regular),
                isFixSize: false){_ in
                
                guard let datas = self.dataProvider.bands.kidsGnbModel.home?.blocks else {return}
                let blocks = datas.map{ block in
                    BlockData(pageType: .kids).setDataKids(block)
                }
                guard let home = blocks.first(where: {$0.uiType == .kidsHome})  else {return}
                let homeData = KidsHomeBlockData().setData(data: home)
                guard let playList = homeData.datas.first(where: {$0.type == .playList}) as? KidsPlayListData else {return}
                guard let find = playList.datas.first(where: {$0.playType == self.type.playType})  else {return}
                
                self.pagePresenter.openPopup(
                    PageKidsProvider.getPageObject(.kidsMultiBlock)
                        .addParam(key: .datas, value: find.blocks)
                        .addParam(key: .title, value: find.title)
                        .addParam(key: .type, value: find.playType)
                )
            }
        }
        .modifier(MatchHorizontal(height: DimenKids.button.regular))
    }
}
