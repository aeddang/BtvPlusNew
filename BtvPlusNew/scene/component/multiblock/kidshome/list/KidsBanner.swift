//
//  KidsHeader.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation
import SwiftUI

class KidsBannerData: KidsHomeBlockListData {
    fileprivate(set) var banner:BannerData? = nil
    private(set) var menuId:String? = nil
    
    func setData(data:BlockItem) -> KidsHomeBlockListData{
        self.type = .banner
        self.menuId = data.menu_id
        return self
    }
}



struct KidsBanner:PageView  {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var dataProvider:DataProvider
    var data:KidsBannerData
    @State var banner:BannerData? = nil
  
    var body :some View {
        ZStack(alignment: .top){
            if let banner = self.banner {
                BannerItem(data: banner){
                    self.naviLogManager.actionLog(
                        .clickPromotionBanner,
                        actionBody:.init(
                            menu_id: banner.menuId,
                            config: banner.logConfig,
                            result: self.appSceneObserver.kidsGnbMenuTitle),
                        contentBody:.init(
                            title: banner.title
                        )
                    )
                }
            }
        }
        .onReceive(dataProvider.$result) { res in
            if res?.id != self.data.id { return }
            guard let resData = res?.data as? EventBanner else { return }
            guard let banners = resData.banners else { return }
            guard let bannerData = banners.first else { return }
            let banner = BannerData().setDataKids(data: bannerData)
            self.data.banner = banner
            withAnimation{
                self.banner = banner
            }
        }
        .onAppear(){
            if let banner = self.data.banner {
                withAnimation{
                    self.banner = banner
                }
            } else {
                self.dataProvider.requestData(
                    q: .init(id: self.data.id,
                             type: .getEventBanner(self.data.menuId, .list),
                            isOptional: true))
            }
            
        }
    }
}
