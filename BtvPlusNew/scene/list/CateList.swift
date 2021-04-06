//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
enum CateSubType {
    case prevList, list, event, tip, webview
     
    static func getType(id:String?) -> CateSubType{
        switch id {
        case "BP_03_11" : return .tip
        case "BP_03_09" : return .event
        case "BP_03_04" : return .webview
        case "BP_03_10" : return .prevList
        default : return .list
        }
    }
        
}



class CateData:InfinityData{
    private(set) var image: String = Asset.noImg1_1
    private(set) var title: String? = nil
    private(set) var isAdult:Bool = false
    private(set) var subType: CateSubType = .list
    private(set) var subTitle: String? = nil
    private(set) var menuId: String? = nil
    private(set) var blocks:[BlockItem]? = nil
    
    func setData(data:BlockItem ,idx:Int = -1) -> CateData {
        title = data.menu_nm
        index = idx
        menuId = data.menu_id
        blocks = data.blocks
        isAdult = data.lim_lvl_yn?.toBool() ?? false
        subType = CateSubType.getType(id:data.gnb_sub_typ_cd) 
        if let path = data.menu_off_img_path {
            image = ImagePath.thumbImagePath(filePath: path, size:CGSize(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra) , convType: .alpha) ?? image
        }
        return self
    }

    func setDummy(_ idx:Int = -1) -> CateData {
        title = "title"
        return self
    }
    
}

extension CateList{
    static let magin:CGFloat = Dimen.margin.regularExtra
    static let cellCount = 2
 }


struct CateList: PageComponent{
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[CateDataSet]
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginTop: margin,
            marginHorizontal: 0,
            spacing: 0,
            isRecycle: true,
            useTracking: false
            ){
            if self.datas.isEmpty {
                Spacer()
            } else {
                ForEach(self.datas) { data in
                    CateSet( data:data )
                        .modifier(ListRowInset(spacing:CateList.magin))
                }
            }
        }
    }//body
}


struct CateDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = CateList.cellCount
    var datas:[CateData] = []
    var isFull:Bool = false
    var index:Int = -1
}

struct CateSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:CateDataSet
    var body: some View {
        HStack(spacing: CateList.magin){
            ForEach(self.data.datas) { data in
                CateItem( data:data )
                .onTapGesture {
                    switch data.subType {
                    case .prevList :
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.previewList)
                                .addParam(key: .title, value: data.title)
                                .addParam(key: .id, value: data.menuId)
                                .addParam(key: .data, value: data)
                                .addParam(key: .needAdult, value: data.isAdult)
                        )
        
                    default :
                        if data.blocks != nil && data.blocks?.isEmpty == false {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.multiBlock)
                                    .addParam(key: .data, value: data)
                                    .addParam(key: .needAdult, value: data.isAdult)
                            )
                        }else{
                            
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.categoryList)
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .id, value: data.menuId)
                                    .addParam(key: .type, value: CateBlock.ListType.poster)
                                    .addParam(key: .needAdult, value: data.isAdult)
                            )
                        }
                    }
                    
                    
                }
            }
            if !self.data.isFull {
                Spacer().frame(width: ListItem.cate.size.width, height: ListItem.cate.size.height)
            }
        }
    }
}//body


struct CateItem: PageView {
    var data:CateData
    var body: some View {
        ZStack{
            VStack(spacing:Dimen.margin.tinyExtra){
                KFImage(URL(string: self.data.image))
                    .resizable()
                    .placeholder { Image(Asset.noImg1_1).resizable() }
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                
                Text(self.data.title!)
                    .modifier(BoldTextStyle(size: Font.size.lightExtra))
            }
        }
        .frame(
            width: ListItem.cate.size.width,
            height: ListItem.cate.size.height)
        .background(Color.app.blueLightExtra.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius:Dimen.radius.regular))
        .overlay(
            RoundedRectangle(cornerRadius:Dimen.radius.regular)
                .stroke(Color.app.blueLightExtra.opacity(0.5), lineWidth: 1)
        )
        
    }
    
}

#if DEBUG
struct CateList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            CateList( datas: [
                CateDataSet( datas:[CateData().setDummy(), CateData().setDummy()]),
                CateDataSet( datas:[CateData().setDummy(), CateData().setDummy()]),
                CateDataSet( datas:[CateData().setDummy(), CateData().setDummy()]),
                CateDataSet( datas:[CateData().setDummy()])
            ])
            .environmentObject(PagePresenter()).modifier(MatchParent())
        }
        .frame(width: 320, height: 540)
    }
}
#endif

