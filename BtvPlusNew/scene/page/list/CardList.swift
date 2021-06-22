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
    private(set) var grade:String? = nil
    private(set) var isRepresent:Bool = false
    private(set) var requestPoint:Bool = false
   
    private(set) var ocb:OcbItem? = nil
    func setData(data:TMembershipItem,  idx:Int = -1) -> CardData {
        defaultImage = Asset.image.cardMembership
        if let no = data.cardNo, no.count == 8 {
            memberNo = no.subString(start: 0, len: 4) + "  "
                + no.subString(start: 4, len: 4) + "  ****  ****"
        }
        switch data.grade  {
        case "V": grade = String.app.vip
        case "G": grade = String.app.gold
        case "S": grade = String.app.silver
        default: break
        }
        return self
    }
    
    func setData(data:TvPointItem,  idx:Int = -1) -> CardData {
        title = String.pageText.myBenefitsDiscountTvText1
        defaultImage = Asset.image.cardTvpoint
        if let balance = data.balance {
            point = balance.formatted(style: .decimal) + String.app.point
        }
        return self
    }
    
    func setData(data:OcbItem, masterSequence:Int? = nil , idx:Int = -1) -> CardData {
        if let master = masterSequence {
            isRepresent = data.sequence == master
        }
   
        requestPoint = true
        ocb = data
        defaultImage = Asset.image.cardOkcashbag
        if let no = data.cardNo, no.count == 8 {
            cardNo = no.subString(start: 0, len: 4) + "  "
                + no.subString(start: 4, len: 4) + "  ****  ****"
        }
        return self
    }
    
    func updatePoint(_ point:Double) {
        self.requestPoint = false
        self.point = point.formatted(style: .decimal) + String.app.point
    }
    func setDummy(_ idx:Int = -1) -> CardData{
        memberNo = "2444  2444  ****  ****"
       
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
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var data:CardData
    @State var point:String? = nil
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
                    if let grade = self.data.grade {
                        Text(grade)
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
                    if let point = (self.data.point ?? self.point) {
                        Text(String.pageText.myBenefitsDiscountTvText2)
                            .modifier(MediumTextStyle(size: Font.size.regular, color:Color.app.blackLight))
                        Text(point)
                            .modifier(BoldTextStyle(size: Font.size.black, color:Color.app.blackRegular))
                            
                    } else if self.data.requestPoint {
                        RectButton(
                            text: String.button.lookup,
                            padding: Dimen.margin.regular
                            ){_ in
                            
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.confirmNumber)
                                    .addParam(key: .type, value: PageConfirmNumber.InputType.okcash)
                                    .addParam(key: .data, value: self.data.ocb)
                            )
                        }
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
        .onReceive(self.dataProvider.$result) { res in
            guard let res = res else { return }
            guard let ocb = self.data.ocb else { return }
            switch res.type {
            case .getOkCashPoint(_ , let card , _) :
                guard let resData = res.data as? OkCashPoint else {return}
                if resData.result == ApiCode.success {
                    if card?.sequence == ocb.sequence {
                        if let p = resData.ocb?.balance {
                            self.data.updatePoint(p)
                            self.point = self.data.point
                        }
                    }
                }
            default: break
            }
        }
        .onAppear{
            self.point = self.data.point
        }
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