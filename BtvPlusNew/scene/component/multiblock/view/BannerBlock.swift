//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct BannerBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var data: BlockData
    @State var bannerData:BannerData? = nil
    @State var listHeight:CGFloat = 0
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if self.bannerData != nil {
                BannerItem(data: self.bannerData!)
                    .modifier(MatchHorizontal(height: self.listHeight))
            }
        }
        .padding(.horizontal, Dimen.margin.thin)
        .onAppear{
            if let datas = data.banners {
                self.bannerData = datas.first
                self.updateListSize()
            }
            if let apiQ = self.getRequestApi() {
                dataProvider.requestData(q: apiQ)
            }
        }
        .onReceive(dataProvider.$result) { res in
            if res?.id != data.id { return }
            var allDatas:[BannerData] = []
            switch data.dataType {
            case .banner:
                guard let resData = res?.data as? EventBanner else {return onBlank()}
                guard let banners = resData.banners else {return onBlank()}
                if banners.isEmpty {return onBlank()}
                let addDatas = banners.map{ d in
                    BannerData().setData(data: d)
                }
                allDatas.append(contentsOf: addDatas)
            default: do {}
            }
            self.bannerData = allDatas.first
            self.updateListSize()
            self.data.banners = allDatas
            ComponentLog.d(allDatas.count.description, tag: self.tag)
            
        }
        .onReceive(dataProvider.$error) { err in
            if err?.id != data.id { return }
            onError(err)
            ComponentLog.d(err.debugDescription, tag: self.tag)
        }
    }
    
    func updateListSize(){
        if self.bannerData != nil {
            self.listHeight = ListItem.banner.size.height
            onDataBinding()
        }
        else { onBlank() }
    }
    
}
