//
//  TopTab.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage



struct KidsGnb: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var datas:[KidsGnbItemData] = []
    
    @State var selectedPage:PageObject? = nil
    @State var selectedMenuId:String? = nil
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing:0){
                ForEach(self.datas) { data in
                    KidsGnbItem(
                        data:data,
                        isSelected:self.selectedMenuId == data.menuId
                    )
                    .onTapGesture {
                        self.pagePresenter.changePage(
                            PageKidsProvider
                                .getPageObject(.kidsHome)
                                .addParam(key: .id, value: data.menuId)
                                .addParam(key: UUID().uuidString , value: "")
                        )
                        self.selectedMenuId = data.menuId
                    }
                }
            }
        }
        .onReceive (self.pagePresenter.$currentPage) { page in
            if page?.pageID != .kidsHome {
                self.selectedMenuId = nil
                return
            }
            if let id = page?.getParamValue(key: .id) as? String {
                self.selectedMenuId = id
            } else {
                self.selectedMenuId = self.dataProvider.bands.kidsGnbModel.home?.menuId 
            }
        }
        .onReceive (self.appSceneObserver.$useTop) { use in
            if !use {return}
            if SystemEnvironment.currentPageType == .btv {return}
            self.datas = self.dataProvider.bands.kidsGnbModel.getGnbDatas()
        }
        .onAppear(){
            
        }
        
    }
  
}

struct KidsGnbList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[KidsGnbItemData]
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical:0,
            marginHorizontal: 0,
            spacing: 0,
            isRecycle: false,
            useTracking: false
            ){
            ForEach(self.datas) { data in
                KidsGnbItem( data:data )
                .onTapGesture {
                    
                }
            }
        }
    }//body
}

extension KidsGnbItem{
    static let size:CGFloat = SystemEnvironment.isTablet ? 76 : 48
}

struct KidsGnbItem: PageView {
    @EnvironmentObject var pairing:Pairing
    var data:KidsGnbItemData
    var isSelected:Bool = false
    @State var profileImg:String? = nil
    @State var title:String? = nil
    @State var subTitle:String? = nil
    var body: some View {
        ZStack(){
            if self.data.isHome {
                if let profileImg = self.profileImg {
                    Image(AssetKids.gnbTop.bgOn)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .modifier(MatchParent())
                        .opacity(self.isSelected ? 1.0 : 0.0)
                    
                    VStack(spacing:DimenKids.margin.microExtra){
                        Image(self.isSelected ? profileImg : Asset.gnbTop.zemkids)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.item.profileGnb.width,
                                   height: DimenKids.item.profileGnb.height)
                        HStack(spacing:DimenKids.margin.microExtra){
                            if let title = self.title {
                                Text(title)
                                    .modifier(BoldTextStyleKids(
                                                size: Font.sizeKids.tinyExtra,
                                                color: self.isSelected ? Color.app.white : Color.app.brownDeep))
                            }
                            Text(String.app.home)
                                .modifier(BoldTextStyleKids(
                                            size: Font.sizeKids.tinyExtra,
                                            color: self.isSelected ? Color.app.white : Color.app.brownDeep))
                                .fixedSize(horizontal: true, vertical: true)
                        }
                        if self.isSelected ,let subTitle = self.subTitle {
                            Text(subTitle)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color: Color.app.white))
                                .fixedSize(horizontal: true, vertical: true)
                                .padding(.vertical, DimenKids.margin.micro)
                                .padding(.horizontal, DimenKids.margin.thin)
                                .background(Color.kids.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.lightExtra))
                                
                        } else {
                            Spacer()
                        }
                    }
                    .padding(.all, DimenKids.margin.tinyExtra)
                } else {
                    Image(self.data.imageOff)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .modifier(MatchParent())
                    Image(self.data.imageOn)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .modifier(MatchParent())
                        .opacity(self.isSelected ? 1.0 : 0.0)
                }
            } else {
                KFImage(URL(string: self.data.imageOff))
                    .resizable()
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
                    
                KFImage(URL(string: self.data.imageOn))
                    .resizable()
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
                    .opacity(self.isSelected ? 1.0 : 0.0)
            }
        }
        .frame(height: Self.size)
        /*
        .frame(
            minWidth: SystemEnvironment.isTablet ? DimenKids.icon.medium : DimenKids.icon.medium,
            maxWidth: SystemEnvironment.isTablet ? DimenKids.icon.heavy : DimenKids.icon.heavyExtra,
            minHeight: SystemEnvironment.isTablet ? DimenKids.icon.heavy : DimenKids.icon.heavyExtra,
            maxHeight: SystemEnvironment.isTablet ? DimenKids.icon.heavy : DimenKids.icon.heavyExtra)
        */
        .onReceive(self.pairing.$kid) { kid in
            if !self.data.isHome {return}
            self.update(kid: kid)
        }
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .editedKids :
                self.update(kid: self.pairing.kid)
            default: break
            }
        }
    }
    
    private func update(kid:Kid?) {
        if let kid = kid {
            self.profileImg = AssetKids.characterGnbList[kid.characterIdx]
            self.title = kid.nickName
            if let age = kid.age {
                self.subTitle = age.description + String.app.ageCount
            }
        } else {
            self.profileImg = Asset.gnbTop.zemkids
            self.subTitle = nil
            self.title = nil
        }
    }
}




#if DEBUG
struct KidsGnb_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            KidsTopTab().environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
