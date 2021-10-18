//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
//import struct Kingfisher.KFImage

struct BannerDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 1
    var datas:[BannerData] = []
    var isFull = false
    var index:Int = -1
}

extension BannerSet{

    static func listSize(data:BannerDataSet, screenWidth:CGFloat, isFull:Bool = false,
                         padding:CGFloat = SystemEnvironment.currentPageType == .btv
                            ? Dimen.margin.thin
                            : DimenKids.margin.thinUltra) -> CGSize{
        let ratio =  ListItem.banner.type02.height / ListItem.banner.type02.width
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2)
        let cellW = ( w - (padding*(count-1)) ) / count
        let cellH = round(cellW * ratio)
        return CGSize(width: floor(cellW), height: cellH )
    }
    
    static let listPadding:CGFloat = SystemEnvironment.currentPageType == .btv
        ? SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin
        : DimenKids.margin.thinUltra
}

struct BannerSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var data:BannerDataSet
    var screenSize:CGFloat? = nil
    var padding:CGFloat = Self.listPadding
   
    @State var cellDatas:[BannerData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing: self.padding){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    BannerItem( data:data )
                }
                if !self.data.isFull && self.data.count > 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, self.padding)
        .frame(width: self.screenSize ??  self.sceneObserver.screenSize.width)
       
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data, screenWidth: self.screenSize ?? sceneObserver.screenSize.width, padding: self.padding)
            self.cellDatas = self.data.datas.map{
                $0.setBannerSize(width: size.width, height: size.height, padding: self.padding)
            }
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
        }
    }//body
}

extension BannerList{
    static let spacing:CGFloat = Dimen.margin.tiny
}
struct BannerList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[BannerData]
    var useTracking:Bool = false
    var margin:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.thin : DimenKids.margin.regular
    var spacing:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.margin.tiny : DimenKids.margin.thinUltra
   
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin ,
            spacing: self.spacing,
            isRecycle:  true,
            useTracking: self.useTracking
            ){
            ForEach(self.datas) { data in
                BannerItem( data:data ){
                        var actionBody = MenuNaviActionBodyItem()
                        actionBody.menu_id = data.menuId
                        actionBody.menu_name = data.menuNm
                        actionBody.position = data.logPosition
                        actionBody.config = data.logConfig
                        self.naviLogManager.actionLog(.clickBannerBanner, actionBody: actionBody)
                }
            }
        }
    }//body
}



struct BannerItem: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
   
    var data:BannerData
    var action: (() -> Void)? = nil
    var body: some View {
        ZStack{
            switch self.data.type {
            case .cell(let size, _), .cellKids(let size, _):
                ImageView(
                    url: self.data.image,
                    contentMode: .fill,
                    noImg: self.data.type.noImage)
                    .frame(width: size.width, height: size.height)
            case .horizontalList :
                ImageView(
                    url: self.data.image,
                    contentMode: .fill,
                    noImg: self.data.type.noImage)
                    .frame(width: self.data.type.size.width, height: self.data.type.size.height)
            case .kids :
                ImageView(
                    url: self.data.image,
                    contentMode: .fill,
                    noImg: self.data.type.noImage)
                    .frame(width: self.data.type.size.width, height: self.data.type.size.height)
            default :
                ImageView(
                    url: self.data.image,
                    contentMode: SystemEnvironment.isTablet ? .fit : .fill,
                    noImg: self.data.type.noImage)
                    .modifier(MatchHorizontal(height: ListItem.banner.type01.height))
            }
        }
        .background(self.data.bgColor ?? Color.app.blueLight)
        .clipShape(RoundedRectangle(cornerRadius: self.data.type.radius))
        .accessibility(label: Text(data.title ?? ""))
        .onTapGesture {
            action?()
            BannerData.move(pagePresenter: self.pagePresenter, dataProvider: self.dataProvider, data: self.data)
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

