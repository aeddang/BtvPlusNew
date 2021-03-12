//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
struct BannerDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 1
    var datas:[BannerData] = []
    var isFull = false
    var index:Int = -1
}

extension BannerSet{
    static let padding:CGFloat = Dimen.margin.thin
    static func listSize(data:BannerDataSet, screenWidth:CGFloat, isFull:Bool = false) -> CGSize{
        let ratio =  ListItem.banner.type02.height / ListItem.banner.type02.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2)
        let cellW = ( w - (padding*(count-1)) ) / count
        let cellH = cellW * ratio
        return CGSize(width: cellW, height: cellH )
    }
}

struct BannerSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    var data:BannerDataSet
    
    @State var cellDatas:[BannerData] = []
    var body: some View {
        HStack(spacing: Self.padding){
            ForEach(self.cellDatas) { data in
                BannerItem( data:data )
            }
            if !self.data.isFull {
                Spacer()
            }
        }
        .padding(.horizontal, Self.padding)
        .frame(width: self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data, screenWidth: sceneObserver.screenSize.width)
            self.cellDatas = self.data.datas.map{
                $0.setBannerSize(width: size.width, height: size.height, padding: Self.padding)
            }
        }
    }//body
}



struct BannerItem: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var data:BannerData
    var body: some View {
        ZStack{
            switch self.data.type {
            case .cell(let size, _) :
                ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                    .frame(width: size.width, height: size.height)
            default :
                ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                    .modifier(MatchHorizontal(height: ListItem.banner.type01.height))
            }
        }
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
            } else if let link = data.outLink {
                AppUtil.openURL(link)
            } else if let link = data.inLink {
                self.pagePresenter.openPopup(
                    PageProvider
                        .getPageObject(.webview)
                        .addParam(key: .data, value: link)
                        .addParam(key: .title , value: data.title)
                )
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

