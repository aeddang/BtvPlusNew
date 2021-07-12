//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class SerisData:InfinityData{
    private(set) var image: String = Asset.noImg16_9
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var isAdult:Bool = false
    private(set) var epsdId:String? = nil
    private(set) var brcastTseqNm:Int = -1
    private(set) var price: String? = nil
    private(set) var isFree: Bool? = nil
    private(set) var type: SerisType = .big
    func setData(data:SeriesInfoItem, title:String? = nil, idx:Int = -1) -> SerisData {
       
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.video.size) ?? image
        }
        self.title = title
        if let count = data.brcast_tseq_nm {
            self.title = (self.title ?? "") + " " + count + String.app.broCount
            self.brcastTseqNm = count.toInt()
        }
        if let prc = data.sale_prc_vat {
            if prc == 0 { isFree = true }
            price = prc.formatted(style: .decimal) + String.app.cash
        }
        subTitle = data.brcast_exps_dy
        index = idx
        contentID = data.epsd_id ?? ""
        epsdId = data.epsd_id
        return self
    }
    
    func setListType(_ type: SerisType) -> SerisData {
        self.type = type
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> SerisData {
        title = "12회 결방"
        subTitle = "19.08.25"
        return self
    }
}

enum SerisType {
    case small, big, kids
    var size:CGSize {
        get{
            switch self {
            case .small: return ListItem.seris.type01
            case .big: return ListItem.seris.type02
            case .kids: return ListItemKids.seris.type01
            }
        }
    }
}


struct SerisList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[SerisData]
    var contentID:String? = nil
    var useTracking:Bool = false
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginVertical: 0,
            marginHorizontal: 0,
            spacing: Dimen.margin.regular,
            useTracking: self.useTracking
        ){
            ForEach(self.datas) { data in
                SerisItem( data:data, isSelected: self.contentID == data.contentID )
                .onTapGesture {
                    
                }
            }
        }
    }//body
}

struct SerisItem: PageView {
    var data:SerisData
    var isSelected:Bool = false
    var body: some View {
        HStack(spacing:Dimen.margin.thin){
            ZStack(alignment:.bottomTrailing){
                ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                    .modifier(MatchParent())
                if self.isSelected  {
                    ZStack(){
                        Image(Asset.icon.thumbPlay)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                    }
                    .modifier(MatchParent())
                }
                if data.isFree == true {
                    Text(String.app.free)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra))
                        .lineLimit(1)
                        .padding(.all, Dimen.margin.tiny)
                }
            }
            .overlay(
               Rectangle()
                .stroke(
                    self.isSelected ? Color.app.white : Color.transparent.clear,
                    lineWidth: Dimen.stroke.regular)
            )
            .frame(
                width: self.data.type.size.width,
                height: self.data.type.size.height)
            .clipped()
            VStack(alignment: .leading, spacing:Dimen.margin.thinExtra){
                Spacer().modifier(MatchHorizontal(height: 0))
                if self.data.title != nil {
                    Text(self.data.title!)
                        .modifier(MediumTextStyle(size: Font.size.light))
                        .multilineTextAlignment(.leading)
                }
                if self.data.subTitle != nil {
                    Text(self.data.subTitle!)
                        .modifier(MediumTextStyle(size: Font.size.thinExtra))
                        .opacity(0.6)
                }
            }
        }
        .frame(height: self.data.type.size.height)
    }
    
}


struct SerisItemKids: PageView {
    var data:SerisData
    var isSelected:Bool = false
    var body: some View {
        VStack(alignment: .center, spacing:DimenKids.margin.tiny){
            ZStack(alignment:.bottomTrailing){
                
                ImageView(url: self.data.image, contentMode: .fill, noImg: AssetKids.noImg16_9)
                    .modifier(MatchParent())
                
                if self.isSelected  {
                    ZStack(){
                        Image(AssetKids.icon.thumbPlay)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.thin, height: DimenKids.icon.thin)
                    }
                    .modifier(MatchParent())
                }
                if data.isFree == true {
                    Text(String.app.free)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra))
                        .lineLimit(1)
                        .padding(.all, Dimen.margin.tiny)
                }
            }
            .frame(
                width: self.data.type.size.width,
                height: self.data.type.size.height)
            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
            .overlay(
                RoundedRectangle(cornerRadius: DimenKids.radius.light)
                .stroke(
                    self.isSelected ? Color.kids.primary : Color.transparent.clear,
                    lineWidth:  DimenKids.stroke.medium )
            )
            if self.data.title != nil {
                Text(self.data.title!)
                    .modifier(BoldTextStyleKids(
                                size: SystemEnvironment.isTablet ?  Font.sizeKids.tiny : Font.sizeKids.thinExtra,
                                color: Color.app.brownDeep))
                    .lineLimit(1)
                    .frame(width: self.data.type.size.width)
            }
        }
        .frame(height: self.data.type.size.height + ListItemKids.seris.bottomHeight)
    }
    
}


#if DEBUG
struct SerisList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SerisList( datas: [
                SerisData().setDummy(0),
                SerisData().setDummy(),
                SerisData().setDummy(),
                SerisData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif
