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

class KidsGnbModel:Identifiable, ObservableObject{
    private(set) var home: KidsGnbItemData? = nil
    private(set) var datas: [KidsGnbItemData] = []
    @Published var isUpdated:Bool = false  {didSet{ if isUpdated { isUpdated = false} }}
    func setData(data:BlockItem) {
        self.home = KidsGnbItemData().setHomeData(data: data)
        self.datas = data.blocks?.first?.blocks?.map{KidsGnbItemData().setData(data: $0)} ?? []
        self.isUpdated = true
    }
    
    func getGnbDatas() -> [KidsGnbItemData] {
        var gnbs:[KidsGnbItemData] = []
       
        let center = floor(Double(self.datas.count/2)).toInt()
        if datas.count < 2 {
            if let home = self.home { gnbs.append(home) }
            gnbs.append(contentsOf: datas)
            return gnbs
        }
        gnbs.append(contentsOf: datas[0...center-1])
        if let home = self.home { gnbs.append(home) }
        gnbs.append(contentsOf: datas[center...datas.count-1])
        zip(gnbs, 0...gnbs.count-1).forEach{ gnb, idx in gnb.idx = idx}
        return gnbs
        
    }
}

class KidsGnbItemData:InfinityData, ObservableObject{
    private(set) var imageOn: String = Asset.noImg1_1
    private(set) var imageOff: String = Asset.noImg1_1
    private(set) var title: String? = nil
    private(set) var menuId: String? = nil
    private(set) var blocks: [BlockItem]? = nil
    private(set) var isHome:Bool = false
    fileprivate(set) var idx:Int = -1
    func setHomeData(data:BlockItem) -> KidsGnbItemData {
        self.isHome = true
        self.title = data.menu_nm
        self.menuId = data.menu_id
        self.imageOn = AssetKids.gnbTop.homeOn
        self.imageOff = AssetKids.gnbTop.homeOff
        self.blocks = data.blocks?.dropFirst().map{$0}
        return self
    }
    func setData(data:BlockItem) -> KidsGnbItemData {
        self.title = data.menu_nm
        self.menuId = data.menu_id
        
        self.blocks = data.blocks?.map{$0}
        let size = CGSize(width: DimenKids.icon.heavy, height: DimenKids.icon.heavy)
        
        self.imageOff = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: size, convType: .alpha) ?? self.imageOn
        self.imageOn = ImagePath.thumbImagePath(filePath: data.bnr_on_img_path, size: size, convType: .alpha) ?? self.imageOff
        return self
    }
   
}


struct KidsGnb: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var datas:[KidsGnbItemData] = []
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing:0){
                ForEach(self.datas) { data in
                    if data.idx != 0 {
                        Spacer()
                    }
                    KidsGnbItem( data:data )
                    .onTapGesture {
                        
                    }
                }
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
            marginHorizontal: Dimen.margin.thin ,
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

struct KidsGnbItem: PageView {
    @EnvironmentObject var pairing:Pairing
    var data:KidsGnbItemData
    @State var isSelected:Bool = true
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
                    }.padding(.all, DimenKids.margin.tinyExtra)
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
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
                    
                KFImage(URL(string: self.data.imageOn))
                    .resizable()
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
                    .opacity(self.isSelected ? 1.0 : 0.0)
            }
            
        }
        .frame(
            width: SystemEnvironment.isTablet ? DimenKids.icon.heavy : DimenKids.icon.heavyExtra,
            height: SystemEnvironment.isTablet ? DimenKids.icon.heavy : DimenKids.icon.heavyExtra)
        .onReceive(self.pairing.$kid) { kid in
            if !self.data.isHome {return}
            if let kid = kid {
                self.profileImg = AssetKids.characterGnbList[kid.characterIdx]
                self.title = kid.nickName
                if let age = kid.age {
                    self.subTitle = age.description + String.app.ageCount
                }
            } else {
                self.profileImg = Asset.gnbTop.zemkids
                self.title = nil
            }
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
