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
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var data: BlockData
    @State var bannerData:BannerData? = nil
    @State var listHeight:CGFloat = ListItem.banner.type01.height
    @State var isUiview:Bool = true
    var body :some View {
        ZStack() {
            if self.isUiview {
                if self.bannerData != nil {
                    BannerItem(data: self.bannerData!)
                        .modifier(MatchParent())
                } else {
                    Image(Asset.noImgBanner)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .modifier(MatchParent())
                        .clipped()
                        .background(Color.app.black)
                        .opacity(0.5)
                }
            }
        }
        .padding(.horizontal, Dimen.margin.thin)
        .frame( height: self.listHeight)
        
        .onAppear{
            if let datas = data.banners {
                self.bannerData = datas.first
                self.updateListSize()
            }
            if let apiQ = self.getRequestApi(pairing:self.pairing.status) {
                dataProvider.requestData(q: apiQ)
            } else {
                self.data.setRequestFail()
            }
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiview = false
            case .top, .below : self.isUiview = true
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
            self.listHeight = ListItem.banner.type01.height
            onDataBinding()
        }
        else { onBlank() }
    }
    
}
