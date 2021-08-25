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
    private(set) var pageType:PageType = .btv
    
    private(set) var isQuiz:Bool = false
    private(set) var studyIcon:String? = nil
    private(set) var translation:String? = nil
    
    init(pageType:PageType = .btv) {
        self.pageType = pageType
    }
    
    func setData(data:ContentItem, isAdult:Bool) -> TagData {
        if let prc = data.sale_prc_vat {
            if prc == 0 { isFree = true }
            self.price = prc.formatted(style: .decimal) + String.app.cash
        }
        self.isQuiz = data.quiz_yn?.toBool() ?? false
        self.setTranslation(code: data.epsd_lag_capt_typ_cd)
        self.studyIcon = AssetKids.study.getIcon(watchingProgress: data.kes?.watching_progress)
        self.isAdult = isAdult
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
        self.restrictAgeIcon = self.pageType == .btv ? Asset.age.getListIcon(age: data.wat_lvl_cd) : AssetKids.age.getIcon(age: data.wat_lvl_cd)
        self.ppmIcon = ImagePath.thumbImagePath(filePath: data.ppm_grid_icon_img_path,
                                           size:CGSize(width: 0, height: Dimen.icon.light),
                                           convType: .alpha)
        return self
    }
    
    func setData(data:PackageContentsItem, isAdult:Bool) -> TagData {
        self.isAdult = isAdult
        self.setTranslation(code: data.lag_capt_typ_cd)
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
    
    private func setTranslation(code:String?){
        switch code {
        case "01" : translation = String.sort.dubbingKor
        case "02" : translation = String.sort.subtitleKor
        default : break
        }
    }
    
    fileprivate func updatedImage(){
        self.isLock = !SystemEnvironment.isImageLock ? false : isAdult
    }
}




struct Tag: PageView {
    @EnvironmentObject var repository:Repository
    var data:TagData
    var isBig:Bool = false
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
                        .modifier(BoldTextStyle(size: self.isBig ? Font.size.thinExtra : Font.size.tiny, color:Color.brand.primary))
                        .lineLimit(1)
                        .fixedSize()
                }else if let price = data.price {
                    Text(price)
                        .modifier(BoldTextStyle(size:  self.isBig ? Font.size.thinExtra : Font.size.tiny, color:Color.app.whiteDeep))
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
                        .frame(height: self.isBig ? Dimen.icon.light : Dimen.icon.tinyUltra, alignment: .trailing)
                        .padding(.bottom, Dimen.margin.microExtra)
                    
                }
            }
            .padding(.all, self.isBig ? Dimen.margin.thinExtra : Dimen.margin.tiny)
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


extension TagKids{
    public static let studyIconSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 104, height: 50) :   CGSize(width: 54, height: 26)
}

struct TagKids: PageView {
    
    var data:TagData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(alignment: .top, spacing: 0){
                /*
                if !data.isQuiz ,let icon = data.studyIcon  {
                    Image(icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width:Self.studyIconSize.width,
                            height: Self.studyIconSize.height)
                }*/
                Spacer()
                if let translation = data.translation {
                    Text(translation)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color:Color.app.white))
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, DimenKids.margin.tiny)
                        .padding(.vertical, DimenKids.margin.micro)
                        .background(Color.app.brownDeep.opacity(0.7)) 
                        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.lightExtra))
                        .overlay(
                            RoundedRectangle(cornerRadius: DimenKids.radius.lightExtra)
                                .stroke( Color.app.white ,lineWidth:  DimenKids.stroke.light )
                        )
                }
                
            }
            .padding(.top, DimenKids.margin.tiny)
            .padding(.trailing, DimenKids.margin.tiny)
            
            Spacer().modifier(MatchParent())
            
            HStack(alignment: .bottom, spacing: 0){
                if data.isFree == true {
                    Text(String.app.free)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color:Color.app.white))
                        .lineLimit(1)
                        .fixedSize()
                }else if let price = data.price {
                    Text(price)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color:Color.app.whiteDeep))
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
                        .frame(height: DimenKids.icon.tiny, alignment: .trailing)
                }
            }
            .padding(.all, DimenKids.margin.tiny)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.transparent.clear, Color.transparent.black70]), startPoint: .top, endPoint: .bottom)
                
            )
        }
    }
    
}




