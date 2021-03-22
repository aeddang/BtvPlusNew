//
//  BottomTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI
import Combine
struct PageSelecterble : SelecterbleProtocol{
    let key = UUID().uuidString
    var id:PageID = PageID.home
    var on:String = ""
    var off:String = ""
    var text:String = ""
    var menuId:PageID = ""
}

struct BottomTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @State var pages:[PageSelecterble] = []
    @State var selectedPage:PageObject? = nil
    @State var selectedMenuId:String? = nil
    var body: some View {
        ZStack{
            HStack( alignment: .center, spacing:0 ){
                ForEach(self.pages, id: \.key) {band in
                    ImageViewButton(
                        isSelected:self.checkCategory(pageID: band.id, menuId: band.menuId),
                        defaultImage: band.off,
                        activeImage:band.on,
                        text: band.text
                    ){
                        self.pagePresenter.changePage(
                            PageProvider
                                .getPageObject(band.id)
                                .addParam(key: .id, value: band.menuId)
                                .addParam(key: UUID().uuidString , value: "")
                        )
                        self.selectedMenuId = band.menuId
                    }
                    .modifier(MatchParent())
                }
            }
            .padding(.bottom, self.sceneObserver.safeAreaBottom)
        }
        .modifier(MatchParent())
        .background(Color.brand.bg)
        
        .onReceive (self.pagePresenter.$currentPage) { page in
            if let id = page?.getParamValue(key: .id) as? String {
                self.selectedMenuId = id
            }
            self.selectedPage = page
            
        }
        .onReceive(self.dataProvider.bands.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
                case .updated :
                    self.pages = self.dataProvider.bands.datas.map{ band in
                        let page:PageID = (band.gnbTypCd == EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue) ? .category : .home
                        return PageSelecterble(
                            id: page,
                            on: band.activeIcon, off: band.defaultIcon,
                            text: band.name, menuId: band.menuId)
                    }
                default : do{}
            }
        }
        .onAppear(){
        
        }
    }
    
    func checkCategory(pageID:PageID, menuId:String) -> Bool {
        if pageID == .home {
            return self.selectedMenuId == menuId
        } else {
            return self.selectedPage?.pageID == pageID
        }
    }
}

#if DEBUG
struct ComponentBottomTab_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            BottomTab().environmentObject(PagePresenter()).frame(width:370,height:200)
        }
    }
}
#endif
