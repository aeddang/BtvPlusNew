//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct BannerItem: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var data:BannerData
    var body: some View {
        ZStack{
            ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                .modifier(MatchParent())
        }
        .modifier(MatchHorizontal(height: ListItem.banner.size.height))
        .background(Color.app.blueLight)
        .clipped()
        .onTapGesture {
            if let move = data.move {
                switch move {
                case .home :
                    if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                        if let band = dataProvider.bands.getData(gnbTypCd: gnbTypCd) {
                            self.pagePresenter.changePage(
                                PageProvider
                                    .getPageObject(move)
                                    .addParam(key: .id, value: band.menuId)
                                    .addParam(key: UUID().uuidString , value: "")
                            )
                        }
                    }
                    
                default :
                    let pageObj = PageProvider.getPageObject(move)
                    pageObj.params = data.moveData
                    self.pagePresenter.openPopup(pageObj)
                }
            }
            
        }
    }
}

#if DEBUG
struct BannerItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            BannerItem( data:
                BannerData())
            .environmentObject(PagePresenter()).modifier(MatchParent())
        }
    }
}
#endif

