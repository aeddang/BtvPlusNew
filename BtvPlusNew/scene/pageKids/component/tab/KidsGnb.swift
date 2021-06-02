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
    private(set) var blocks: [BlockItem]? = nil
    private(set) var isHome:Bool = false
    fileprivate(set) var idx:Int = -1
    func setHomeData(data:BlockItem) -> KidsGnbItemData {
        self.isHome = true
        self.blocks = data.blocks?.dropFirst().map{$0}
        self.imageOn = AssetKids.characterGnbList.first ?? self.imageOn
        self.imageOff = AssetKids.characterGnbList.first ?? self.imageOff
        return self
    }
    func setData(data:BlockItem) -> KidsGnbItemData {
        self.blocks = data.blocks?.map{$0}
        let size = CGSize(width: DimenKids.icon.heavy, height: DimenKids.icon.heavy)
        
        self.imageOff =  ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size: size, convType: .alpha) ?? self.imageOn
        self.imageOn =  ImagePath.thumbImagePath(filePath: data.bnr_on_img_path, size: size, convType: .alpha) ?? self.imageOff
        return self
    }
   
}


struct KidsGnb: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
 
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
            /*
            KidsGnbList(
                viewModel:self.infinityScrollModel,
                datas: self.datas)
 `          */
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
    var data:KidsGnbItemData
    @State var isSelected:Bool = false
    var body: some View {
        ZStack(){
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
        .frame(width: DimenKids.icon.heavy, height:DimenKids.icon.heavy)
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
