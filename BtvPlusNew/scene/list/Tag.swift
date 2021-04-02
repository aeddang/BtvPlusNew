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
    private(set) var isAdult: Bool = false
    private(set) var isLock: Bool = false
    private(set) var restrictAgeIcon: String? = nil
    private(set) var badgeIcon: String? = nil
    private(set) var ppmIcon: String? = nil
    private(set) var price: String? = nil

    func setData(data:ContentItem, isAdult:Bool) -> TagData {
        if let prc = data.sale_prc_vat {
            if prc == 0 { isFree = true }
            self.price = prc.formatted(style: .decimal) + String.app.cash
        }
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.wat_lvl_cd)
        self.ppmIcon = ImagePath.thumbImagePath(filePath: data.ppm_grid_icon_img_path,
                                           size:CGSize(width: 0, height: Dimen.icon.light),
                                           convType: .alpha)
        return self
    }
    
    func setData(data:PackageContentsItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.wat_lvl_cd)
        return self
    }
    
    func setData(data:BookMarkItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    func setData(data:WatchItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    func setData(data:CWBlockItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.wat_lvl_cd)
        if let prc = data.sale_prc_vat?.number {
            if prc == 0 { isFree = true }
            self.price = prc.formatted(style: .decimal) + String.app.cash
        }
        self.ppmIcon = ImagePath.thumbImagePath(filePath: data.ppm_grid_icon_img_path,
                                           size:CGSize(width: 0, height: Dimen.icon.light),
                                           convType: .alpha)
        return self
    }
    
    func setData(data:SearchPopularityVodItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    func setData(data:CategoryVodItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        if let prc = data.price?.toInt() {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        return self
    }
    func setData(data:SeriesInfoItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        if let prc = data.sale_prc_vat {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        return self
    }
    
    func setData(data:CategorySrisItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        if let prc = data.price?.toInt() {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        return self
    }
    
    func setData(data:CategoryCornerItem, isAdult:Bool) -> TagData{
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = Asset.age.getListIcon(age: data.level)
        return self
    }
    
    @discardableResult
    func setRank(_ idx:Int)-> TagData{
        self.rank = idx+1
        return self
    }
    
    fileprivate func updatedImage(){
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
    }
}



struct Tag: PageView {
    @EnvironmentObject var repository:Repository
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
            if self.data.isLock {
                ZStack{
                    VStack(alignment: .center, spacing: Dimen.margin.thin){
                        Image(Asset.icon.itemRock)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                        Text(String.app.lockAdult)
                            .modifier(MediumTextStyle(size: Font.size.tiny))
                            
                    }
                }.modifier(MatchParent())
            } else {
                Spacer().modifier(MatchParent())
            }
            
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
            .onReceive(self.repository.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .updatedWatchLv : self.data.updatedImage()
                default : break
                }
            }
                
                
        }
    }
    
}



