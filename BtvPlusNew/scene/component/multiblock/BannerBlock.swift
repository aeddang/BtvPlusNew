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
    var data: Block
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
            if data.cardType == .banner , let originData = data.originData {
                self.bannerData = BannerData().setData(data: originData)
            }
            self.updateListSize()
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
