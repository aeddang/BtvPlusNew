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
    @EnvironmentObject var naviLogManager:NaviLogManager
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
                    if !data.isMonthly {
                        KidsGnbItem(
                            data:data,
                            isSelected:self.selectedMenuId == data.menuId
                        )
                        .accessibility(label: Text(data.title ?? ""))
                        .onTapGesture {
                            
                            self.naviLogManager.actionLog(
                                .clickGnbMenu,
                                actionBody: .init(menu_id: data.menuId, menu_name:data.title))
                            
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
        }
        .onReceive(self.appSceneObserver.$kidsGnbMenuId) { id in
            self.selectedMenuId = id
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
    static let size:CGFloat = SystemEnvironment.isTablet ? 110 : 70
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
                    
                    VStack(spacing:DimenKids.margin.micro){
                        Image(self.isSelected ? profileImg : Asset.gnbTop.zemkids)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.item.profileGnb.width)
                            .padding(.top, DimenKids.margin.micro)
                        HStack(spacing:DimenKids.margin.microExtra){
                            if let title = self.title {
                                Text(title)
                                    .modifier(BoldTextStyleKids(
                                                size: SystemEnvironment.isTablet
                                                ? Font.sizeKids.tinyExtraExtra
                                                : Font.sizeKids.tinyExtra,
                                                color: self.isSelected ? Color.app.white : Color.app.brownDeep))
                            }
                            Text(String.app.home)
                                .modifier(BoldTextStyleKids(
                                            size: SystemEnvironment.isTablet
                                            ? Font.sizeKids.tinyExtraExtra
                                            : Font.sizeKids.tinyExtra ,
                                            color: self.isSelected ? Color.app.white : Color.app.brownDeep))
                                .fixedSize(horizontal: true, vertical: true)
                        }
                        .padding(.top, SystemEnvironment.isTablet ? 1 : 3)
                        if self.isSelected ,let subTitle = self.subTitle {
                            Text(subTitle)
                                .modifier(BoldTextStyleKids(
                                            size: Font.sizeKids.micro ,
                                            color: Color.app.white))
                                .fixedSize(horizontal: true, vertical: true)
                                .padding(.vertical, DimenKids.margin.microExtra)
                                .padding(.horizontal, DimenKids.margin.thin)
                                .background(Color.kids.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.lightExtra))
                                
                        } else {
                           Spacer()
                        }
                    }
                    
                } else {
                    
                    Image(self.data.imageOff)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                    Image(self.data.imageOn)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                        .opacity(self.isSelected ? 1.0 : 0.0)
                    
                }
            } else {
                KFImage(URL(string: self.data.imageOff))
                    .resizable()
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
                    
                KFImage(URL(string: self.data.imageOn))
                    .resizable()
                    .cancelOnDisappear(true)
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
                    .opacity(self.isSelected ? 1.0 : 0.0)
            }
        }
        .frame(width:Self.size,  height: Self.size)
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
            self.profileImg = nil
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
