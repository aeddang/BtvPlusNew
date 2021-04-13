//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage

class CardData:InfinityData{
    private(set) var defaultImage: String = Asset.image.cardMembership
    private(set) var image: String? = nil
    private(set) var title: String? = nil
    private(set) var point: String? = nil
    private(set) var memberNo: String? = nil
    private(set) var cardPoint: String? = nil
    private(set) var cardNo: String? = nil
    private(set) var isVip:Bool = false
    private(set) var isRepresent:Bool = false
    
   
    func setData(data:TMembershipItem,  idx:Int = -1) -> CardData {
        
        return self
    }
    
    func setData(data:TvPointItem,  idx:Int = -1) -> CardData {
        
        return self
    }
    
    func setData(data:OcbItem,  idx:Int = -1) -> CardData {
        
        return self
    }
    
    
    func setDummy(_ idx:Int = -1) -> CardData{
        memberNo = "2444  2444  ****  ****"
        isVip = true
        isRepresent = true
        return self
    }
    func setDummy2(_ idx:Int = -1) -> CardData{
        cardNo = "2444  2444  ****  ****"
        defaultImage = Asset.image.cardOkcashbag
        isRepresent = true
        point = "20,300P"
        return self
    }
    func setDummy3(_ idx:Int = -1) -> CardData{
        cardNo = "2444  2444  ****  ****"
        title = String.pageText.myBenefitsDiscountTvText1
        defaultImage = Asset.image.cardTvpoint
        point = "20,300P"
        isRepresent = true
        return self
    }
}


struct CardList: PageComponent{
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[CardData]
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    var spacing:CGFloat = Dimen.margin.tiny
   
    var headerSize:Int = 2
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: margin ,
            spacing: 0,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            
            ForEach(self.datas) { data in
                CardItem( data:data )
                .modifier(HolizentalListRowInset(spacing: self.spacing))
            }
        }
    }//body
}

struct CardItem: PageView {
    var data:CardData
    var body: some View {
        ZStack{
            if let image = self.data.image {
                KFImage(URL(string: image))
                    .resizable()
                    .placeholder {
                        Image(Asset.noImg1_1)
                            .resizable()
                    }
                    .cancelOnDisappear(true)
                    .loadImmediately()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
            } else {
                Image(self.data.defaultImage)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
            }
            VStack( alignment:.center , spacing:0){
                HStack( alignment:.center , spacing:Dimen.margin.tiny){
                    if let title = self.data.title {
                        Text(title)
                            .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.black))
                    }
                    Spacer()
                    if self.data.isRepresent {
                        Image(Asset.icon.represent)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 20)
                    }
                    if self.data.isVip {
                        Text(String.app.vip)
                            .modifier(BoldTextStyle(size: Font.size.thin))
                    }
                }
                
                Spacer()
                VStack( alignment:.center , spacing:Dimen.margin.tiny){
                    if let no = self.data.memberNo  {
                        Text(no)
                            .modifier(MediumTextStyle(size: Font.size.large))
                            .padding(.top, Dimen.margin.heavy)
                    }
                    if let point = self.data.point  {
                        Text(String.pageText.myBenefitsDiscountTvText2)
                            .modifier(MediumTextStyle(size: Font.size.regular, color:Color.app.blackLight))
                        Text(point)
                            .modifier(BoldTextStyle(size: Font.size.black, color:Color.app.blackDeep))
                            
                    }
                }
                Spacer()
                if let no = self.data.cardNo  {
                    Text(no)
                        .modifier(MediumTextStyle(size: Font.size.regular, color:Color.app.blackLight))
                }
            }
            .padding(.all, Dimen.margin.thin)
        }
        .frame(
            width: ListItem.card.size.width,
            height:  ListItem.card.size.height)
    }
}

#if DEBUG
struct CardList_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            CardList( datas: [
                CardData().setDummy(0),
                CardData().setDummy2(),
                CardData().setDummy3(),
                CardData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:620,height:600)
        }
    }
}
#endif
