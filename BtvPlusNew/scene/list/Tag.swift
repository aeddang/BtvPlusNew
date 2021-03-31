//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
class TagData{
    private(set) var rank: Int? = nil
    private(set) var isFree: Bool? = nil
    private(set) var restrictAgeIcon: String? = nil
    private(set) var badgeIcon: String? = nil
    private(set) var ppmIcon: String? = nil
    private(set) var price: String? = nil

    func setData(data:ContentItem) -> TagData {
        if let prc = data.sale_prc_vat {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        restrictAgeIcon = Asset.age.getListIcon(age: data.wat_lvl_cd)
        ppmIcon = ImagePath.thumbImagePath(filePath: data.ppm_grid_icon_img_path,
                                           size:CGSize(width: 0, height: Dimen.icon.light),
                                           convType: .alpha)
        return self
    }
    
    func setData(data:PackageContentsItem) -> TagData {
        restrictAgeIcon = Asset.age.getListIcon(age: data.wat_lvl_cd)
        return self
    }
    
    func setData(data:BookMarkItem) -> TagData {
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    func setData(data:WatchItem) -> TagData {
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    func setData(data:CWBlockItem) -> TagData {
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.wat_lvl_cd)
        if let prc = data.sale_prc_vat?.number {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        ppmIcon = ImagePath.thumbImagePath(filePath: data.ppm_grid_icon_img_path,
                                           size:CGSize(width: 0, height: Dimen.icon.light),
                                           convType: .alpha)
        return self
    }
    
    func setData(data:SearchPopularityVodItem, idx:Int = -1) -> TagData {
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    func setData(data:CategoryVodItem) -> TagData {
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        if let prc = data.price?.toInt() {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        return self
    }
    func setData(data:SeriesInfoItem) -> TagData {
        //self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        if let prc = data.sale_prc_vat {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        return self
    }
    
    func setData(data:CategorySrisItem) -> TagData {
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        if let prc = data.price?.toInt() {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        return self
    }
    
    func setData(data:CategoryCornerItem) -> TagData{
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    @discardableResult
    func setRank(_ idx:Int)-> TagData{
        self.rank = idx+1
        return self
    }
}



struct Tag: PageView {
    var data:TagData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(alignment: .top, spacing: 0){
                if let rank = data.rank {
                    Text(rank.description)
                        .modifier(BoldTextStyle(size: Font.size.tiny))
                        .frame(width:Dimen.icon.thinExtra, height: Dimen.icon.lightExtra)
                        .background(
                            Image(Asset.icon.itemRangking)
                                .renderingMode(.original)
                                .resizable()
                        )
                }
                if let icon = data.badgeIcon {
                    Image(icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                }
                Spacer()
                if let icon = data.restrictAgeIcon {
                    Image(icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                }
            }
            Spacer().modifier(MatchParent())
            HStack(alignment: .bottom, spacing: 0){
                if data.isFree == true {
                    Text(String.app.free)
                        .modifier(BoldTextStyle(size: Font.size.tiny, color:Color.brand.primary))
                        .lineLimit(1)
                        .fixedSize()
                }else if let price = data.price {
                    Text(price)
                        .modifier(BoldTextStyle(size: Font.size.tiny, color:Color.app.whiteDeep))
                        .lineLimit(1)
                        .fixedSize()
                }
                Spacer()
                if let icon = data.ppmIcon {
                    KFImage(URL(string: icon))
                        .resizable()
                        .cancelOnDisappear(true)
                        .loadImmediately()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:53, height: Dimen.icon.lightExtra)
                        
                }
            }
            .padding(.all, Dimen.margin.tiny)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.transparent.clear, Color.transparent.black70]), startPoint: .top, endPoint: .bottom)
                
            )
           
                
                
        }
    }
    
}



