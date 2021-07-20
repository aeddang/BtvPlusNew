//
//  KidsHeader.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/13.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
class KidsCategoryListData: KidsHomeBlockListData {
    private(set) var title:String = " "
    private(set) var svcPropCd:String? = nil
    
    private(set) var datas:[KidsCategoryListItemData] = []
    private(set) var sets:[KidsCategoryListItemDataSet] = []
   
    func setData(data:BlockItem) -> KidsCategoryListData{
        self.type = .cateList
        self.title = data.menu_nm ?? " "
        let cardType = data.btm_bnr_blk_exps_cd
        
        switch cardType {
        case "05":
            self.title = " "
            self.datas = [KidsCategoryListItemData().setData(data: data, size: KidsCategoryList.size)]
            
        case "08":
            if let blocks = data.blocks {
                var rows:[KidsCategoryListItemDataSet] = []
                var cells:[KidsCategoryListItemData] = []
                blocks
                    .map{KidsCategoryListItemData()
                    .setData(data: $0, size: KidsCategoryList.sizeHalf)}.forEach{ d in
                    if cells.count < 2 {
                        cells.append(d)
                    }else{
                        rows.append(
                            KidsCategoryListItemDataSet(
                                datas: cells,
                                isFull: true)
                        )
                        cells = [d]
                    }
                }
                if !cells.isEmpty {
                    rows.append(
                        KidsCategoryListItemDataSet(
                            datas: cells,
                            isFull: cells.count == 2)
                    )
                }
                self.sets = rows
            }
        
        default:
            self.datas = data.blocks?
                .map{
                    KidsCategoryListItemData()
                        .setData(data: $0, size: KidsCategoryList.sizeLong)
                    
                } ?? []
        }
        return self
    }
}

struct KidsCategoryListItemDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var datas:[KidsCategoryListItemData] = []
    var isFull = false
    var index:Int = -1
}

class KidsCategoryListItemData:Identifiable{
    private(set) var id = UUID().uuidString
    private(set) var image:String? = nil
    private(set) var defaultImage:String = AssetKids.noImgCard
    private(set) var title:String? = nil
   
    private(set) var menuId:String? = nil
    private(set) var blocks:[BlockItem] = []
    private(set) var size:CGSize = KidsCategoryList.size
    func setData(data:BlockItem, size:CGSize) -> KidsCategoryListItemData {
        self.title = data.menu_nm
        self.size = size
        self.blocks = data.blocks ?? [data]
        let img = ImagePath.thumbImagePath(filePath: data.bnr_off_img_path, size:CGSize(width: 0, height: size.height), convType:.alpha)
        self.image = img
        if size.height == KidsCategoryList.sizeHalf.height {
            self.defaultImage = AssetKids.noImgCardHalf
        }
        return self
    }
}

extension KidsCategoryList{
    static let sizeRound:CGSize = SystemEnvironment.isTablet ? CGSize(width: 198, height: 359) : CGSize(width: 103, height: 187)
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 205, height: 344) : CGSize(width: 107, height: 179)
    static let sizeHalf:CGSize = SystemEnvironment.isTablet ? CGSize(width: 227, height: 162) : CGSize(width: 118, height: 84)
    static let sizeLong:CGSize = SystemEnvironment.isTablet ? CGSize(width: 198, height: 359) : CGSize(width: 103, height: 187)
}
struct KidsCategoryList:PageView  {
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:KidsCategoryListData
    
    var body :some View {
        VStack(alignment: .leading , spacing:DimenKids.margin.light){
            Text(self.data.title)
                .modifier(BlockTitleKids())
                .lineLimit(1)
                .fixedSize()
            HStack(alignment: .top, spacing: DimenKids.margin.thinExtra){
                ForEach(self.data.datas) { data in
                    KidsCategoryListItem(data: data)
                       
                }
                
                ForEach(self.data.sets) { sets in
                    VStack(spacing: DimenKids.margin.thinExtra){
                        ForEach(sets.datas) { data in
                            KidsCategoryListItem(data: data)
                                .frame(width: Self.sizeHalf.width, height: Self.sizeHalf.height)
                        }
                    }
                }
            }
        }
    }
}


struct KidsCategoryListItem:PageView  {
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:KidsCategoryListItemData
   
    var body :some View {
        ZStack(){
            if let img = self.data.image {
                KFImage(URL(string: img))
                    .resizable()
                    .placeholder {
                        Image(data.defaultImage)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fit)
                    .modifier(MatchParent())
               
            }
        }
        .frame(width: data.size.width, height: data.size.height)
        .onTapGesture {
            self.pagePresenter.openPopup(
                PageKidsProvider.getPageObject(.kidsMultiBlock)
                    .addParam(key: .datas, value: data.blocks)
                    .addParam(key: .title, value: data.title)
            )
        }
        
    }
}

