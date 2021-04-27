//
//  ImageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import struct Kingfisher.KFImage

extension HeaderBanner{
    static let height:CGFloat = 65
}
struct HeaderBanner: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
  
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var data: BannerData
    var close:(() -> Void)? = nil
    var body: some View {
        HStack(spacing:0){
            if let img = self.data.resourceImage {
                Image(img)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    //.modifier(MatchParent())
                    
                    .background(Color.app.grey)
            } else {
                KFImage(URL(string: self.data.image))
                    .resizable()
                    .placeholder {
                        Image(Asset.noImg16_9)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fit)
                    //.modifier(MatchParent())
                    
            }
            Spacer()
            if let close = self.close {
                Button(action: {
                    close()
                }) {
                    Image(Asset.icon.close)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.light,
                               height: Dimen.icon.light)

                }
            }
        }
        .padding(.trailing, Dimen.margin.thin)
        .background(Color.brand.primary)
        .onTapGesture {
            if let move = data.move {
                switch move {
                case .home, .category:
                    if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                        if let band = dataProvider.bands.getData(gnbTypCd: gnbTypCd) {
                            self.pagePresenter.changePage(
                                PageProvider
                                    .getPageObject(move)
                                    .addParam(params: data.moveData)
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
            else if let link = data.outLink {
                AppUtil.openURL(link)
            }
            else if let link = data.inLink {
                self.pagePresenter.openPopup(
                    PageProvider
                        .getPageObject(.webview)
                        .addParam(key: .data, value: link)
                        .addParam(key: .title , value: data.title)
                )
            }
        }
        .modifier(MatchHorizontal(height: Self.height))

    }
    
    
}


#if DEBUG
struct HeaderBanner_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            HeaderBanner(
             data: BannerData())
            .frame(width:375, height: 65, alignment: .center)
        }
    }
}
#endif
