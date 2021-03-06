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
    private(set) var epsdId:String? = nil
    private(set) var brcastTseqNm:Int = -1
    func setData(data:SeriesInfoItem, title:String? = nil, idx:Int = -1) -> SerisData {
       
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.video.size) ?? image
        }
        self.title = title
        if let count = data.brcast_tseq_nm {
            self.title = (self.title ?? "") + " " + count + String.app.broCount
            self.brcastTseqNm = count.toInt()
        }
        subTitle = data.brcast_exps_dy
        index = idx
        contentID = data.epsd_id ?? ""
        epsdId = data.epsd_id
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> SerisData {
        title = "12회 결방"
        subTitle = "19.08.25"
        return self
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
            ZStack{
                ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg16_9)
                    .modifier(MatchParent())
                if self.isSelected  {
                    Image(Asset.icon.thumbPlay)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                }
                
            }
            .frame(
                width: ListItem.seris.size.width,
                height: ListItem.seris.size.height)
            .overlay(
               Rectangle()
                .stroke(
                    self.isSelected ? Color.app.white : Color.transparent.clear,
                    lineWidth: Dimen.stroke.regular)
            )
            
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
        .frame(height: ListItem.seris.size.height)
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

