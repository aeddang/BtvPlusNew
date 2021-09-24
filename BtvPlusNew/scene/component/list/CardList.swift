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
    private(set) var sale:String? = nil
    private(set) var type:CardBlock.ListType = .member
    private(set) var isEmpty:Bool = false
    private(set) var masterSequence:Int = 0
    private(set) var ocb:OcbItem? = nil
    
    func setEmpty(type:CardBlock.ListType, masterSequence:Int? = nil, idx:Int = -1) -> CardData {
        self.type = type
        self.isEmpty = true
        self.masterSequence = masterSequence ?? 1
        return self
    }
    func setData(data:TMembershipItem, idx:Int = -1) -> CardData {
        defaultImage = Asset.image.cardMembership
        type = .member
        if let no = data.cardNo, no.count == 8 {
            memberNo = no.subString(start: 0, len: 4) + "  "
                + no.subString(start: 4, len: 4) + "  ****  ****"
        }
        switch data.grade  {
        case "V":
            grade = String.app.vip
            sale = "20"
        case "G": grade = String.app.gold
            sale = "10"
        case "S": grade = String.app.silver
            sale = "10"
        default: break
        }
        return self
    }
    
    func setData(data:TvPointItem, idx:Int = -1) -> CardData {
        type = .tvPoint
        title = String.pageText.myBenefitsDiscountTvText1
        defaultImage = Asset.image.cardTvpoint
        if let balance = data.balance {
            point = balance.formatted(style: .decimal) + String.app.point
        }
        return self
    }
    
    func setData(data:OcbItem, masterSequence:Int? = nil , idx:Int = -1) -> CardData {
        type = .okCash
        if let master = masterSequence {
            isRepresent = data.sequence == master
            self.masterSequence = master
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
    var spacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.thin : Dimen.margin.regular
   
    var headerSize:Int = 2
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            scrollType: .horizontal(isDragEnd: false),
            marginVertical: 0,
            marginHorizontal: margin ,
            spacing: 0,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            
            ForEach(self.datas) { data in
                CardItem( data:data , cardCount: self.datas.count)
                    .modifier(HolizentalListRowInset(spacing: self.spacing))
            }
        }
    }//body
}

struct CardItem: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    var data:CardData
    var cardCount:Int = 1
    @State var point:String? = nil
    var body: some View {
        VStack(spacing:0){
            if self.data.isEmpty {
                AddCard(type:self.data.type, idx: self.data.masterSequence)
            } else {
                CardItemBody(data: self.data, point:self.point)
                if self.data.type != .tvPoint {
                    HStack(spacing:Dimen.margin.light){
                        if self.data.type == .member {
                            EditButton(
                                icon: Asset.icon.edit,
                                text: String.button.change ){
                                self.sendLog(action: .clickCouponPointOption)
                                self.pagePresenter.openPopup(
                                     PageProvider.getPageObject(.myRegistCard)
                                        .addParam(key: PageParam.type, value: self.data.type)
                                )
                            }
                            Spacer().modifier(MatchVertical(width: 1))
                                .background(Color.app.blueLightExtra)
                                .frame(height: Dimen.line.heavy)
                        } else if self.cardCount > 2 && !self.data.isRepresent{
                            CheckBox(
                                isChecked: (self.data.isRepresent),
                                text: String.pageText.myBenefitsDiscountOkSetup,
                                isStrong : true,
                                isFill: false,
                                action:{ ck in
                                    if ck {
                                        self.sendLog(action: .clickOkPointCheck)
                                        let card = RegistCardData( 
                                            no: self.data.ocb?.cardNo ?? "",
                                            masterSequence: self.data.ocb?.sequence ?? 1,
                                            isMaster: true
                                        )
                                            
                                        self.appSceneObserver.alert = .confirm(
                                            String.pageText.myBenefitsDiscountOkSetup, String.pageText.myBenefitsDiscountOkSetupText) { isOk in
                                                if isOk {
                                                    self.dataProvider.requestData(q: .init(id:self.tag, type: .updateOkCashPoint(self.pairing.hostDevice,card)))
                                                }
                                            }
                                        /*
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.confirmNumber)
                                                .addParam(key: .type, value: PageConfirmNumber.InputType.okcashMaster(card))
                                               
                                        )*/
                                    }
                                }
                            )
                            Spacer().modifier(MatchVertical(width: 1))
                                .background(Color.app.blueLightExtra)
                                .frame(height: Dimen.line.heavy)
                        }
                        
                            
                        EditButton(
                            icon: Asset.icon.delete,
                            text: self.data.type == .member ? String.button.remove :  String.pageText.myBenefitsDiscountOkDelete){
                            self.sendLog(action: .clickCouponPointOption)
                            self.appSceneObserver.alert =
                                .confirm(nil, self.data.type == .member
                                            ? String.pageText.myBenefitsDiscountTDeleteConfirm
                                            : String.pageText.myBenefitsDiscountOkDeleteConfirm,
                                         nil, confirmText: String.button.remove){ isOk in
                                    if isOk {
                                        switch self.data.type {
                                        case .member :
                                            self.dataProvider.requestData(q: .init(id:self.tag, type: .deleteTMembership(self.pairing.hostDevice)))
                                        case .okCash :
                                            self.dataProvider.requestData(q: .init(id:self.tag, type: .deleteOkCashPoint(self.pairing.hostDevice, masterSequence:self.data.masterSequence)))
                                        default : break
                                        }
                                    }
                                }
                            
                        }
                    }
                    .frame(height:ListItem.card.bottom)
                }
            }
        }
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
    private func sendLog(action:NaviLog.Action) {
        let actionBody = MenuNaviActionBodyItem(category: self.data.type.title)
        self.naviLogManager.actionLog(action, actionBody: actionBody)
    }
   
}

struct CardItemBody: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    var data:CardData
    var point:String? = nil
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
                        Text(String.pageText.myBenefitsDiscountTvText2)
                            .modifier(MediumTextStyle(size: Font.size.regular, color:Color.app.blackLight))
                        Button(action: {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.confirmNumber)
                                    .addParam(key: .type, value: PageConfirmNumber.InputType.okcash(self.data.ocb))
                                   
                            )
                        }) {
                            Image(Asset.icon.lookupCard)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(height: Dimen.icon.regularExtra)
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
    }
    
    private func sendLog() {
        let actionBody = MenuNaviActionBodyItem(category: self.data.type.title, target: self.data.masterSequence.description)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
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
