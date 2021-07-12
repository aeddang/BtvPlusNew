//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage

class PurchaseTicketData:InfinityData{
    
    private(set) var isMonthly : Bool = false
    private(set) var joinImage: String? = nil
    private(set) var title: String? = nil
    private(set) var price: String? = nil
    private(set) var period:String? = nil
    private(set) var originPrice: String? = nil
    private(set) var joinDate:String? = nil
    private(set) var payment : String? = nil
    private(set) var contractInfo : String? = nil
    private(set) var contractPeriod: String? = nil
    private(set) var prodId: String? = nil
    private(set) var type:PurchaseTicketType = .list
    func setData(data:PurchaseFixedChargeItem, idx:Int = -1) -> PurchaseTicketData {
        isMonthly = true
        title = data.title
        price = data.selling_price
        prodId = data.prod_id
        joinDate = data.reg_date?.subString(start: 2, len: 8)
        period = data.period
        payment = data.method_pay_nm
        if let p = data.price {
            originPrice = String.app.month + p
        }
        
        if let agreeYn = data.agmt_yn {
            if agreeYn.toBool() {
                if let contract = data.agmt_term {
                    if let discount = data.agmt_rt_dsc {
                        contractInfo = contract + String.app.contractDiscount.replace(discount)
                    } else {
                        contractInfo = contract
                    }
                }
                if let startDate = data.agmt_dd_start, let endDate = data.agmt_dd_end {
                    let convertStartDate = startDate.count == 10 ? startDate.subString(2) : startDate
                    let convertEndDate = endDate.count == 10 ? endDate.subString(2) : endDate
                    contractPeriod =  convertStartDate + "~" + convertEndDate
                }
            }
        }
        index = idx
        return self
    }
    
    func setData(data:PurchaseFixedChargePeriodItem, idx:Int = -1) -> PurchaseTicketData {
        isMonthly = false
        title = data.title
        price = data.selling_price
        prodId = data.prod_id
        joinDate = data.reg_date?.subString(start: 2, len: 8)
        period = data.period
        payment = data.method_pay_nm
        if let p = data.price {
            originPrice = String.app.month + p
        }
        index = idx
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> PurchaseTicketData {
        title = "프리미어"
        price = "19,000원"
        joinDate = "20.03.10"
        period = "해지 전까지(20.03.10~)"
        payment = "청구서"
        originPrice = "월 20,000원"
        contractInfo = "3개월 약정(5% 할인)"
        contractPeriod = "20.03.10~20.06.10"
        return self
    }
    
    @discardableResult
    func setTicketSize(width:CGFloat, height:CGFloat, padding:CGFloat) -> PurchaseTicketData {
        self.type = .cell(CGSize(width: width, height: height), padding)
        return self
    }
}

enum PurchaseTicketType {
    case list, cell(CGSize, CGFloat)
    var size:CGSize {
        get{
            switch self {
            case .list: return ListItem.purchaseTicket.size
            case .cell(let size, _ ): return size
            }
        }
    }
}

struct PurchaseTicketDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 1
    var datas:[PurchaseTicketData] = []
    var isFull = false
    var index:Int = -1
}

extension PurchaseTicketSet{
    static let padding:CGFloat = Dimen.margin.thin
    static let spacing:CGFloat = Dimen.margin.tinyExtra
    static func listSize(data:PurchaseTicketDataSet, screenWidth:CGFloat, isFull:Bool = false) -> CGSize{
        let count = CGFloat(data.count)
        let w = screenWidth - ( padding * 2)
        let cellW = ( w - (spacing*(count-1)) ) / count
        let cellH = ListItem.purchaseTicket.size.height
        return CGSize(width: cellW, height: cellH )
    }
}

struct PurchaseTicketSet: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var data:PurchaseTicketDataSet
    
    @State var cellDatas:[PurchaseTicketData] = []
    @State var isUiActive:Bool = true
    var body: some View {
        HStack(spacing: Self.spacing){
            if self.isUiActive {
                ForEach(self.cellDatas) { data in
                    PurchaseTicketItem( data:data )
                        .frame(width:data.type.size.width)
                }
                if !self.data.isFull && self.data.count > 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, Self.padding)
        .frame(width: self.sceneObserver.screenSize.width)
        .onAppear {
            if self.data.datas.isEmpty { return }
            let size = Self.listSize(data: self.data, screenWidth: sceneObserver.screenSize.width)
            self.cellDatas = self.data.datas.map{
                $0.setTicketSize(width: size.width, height: size.height, padding: Self.padding)
            }
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
        }
    }//body
}



struct PurchaseTicketList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
  
   
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PurchaseTicketData] = []
    var dataSets:[PurchaseTicketDataSet] = []
    var useTracking:Bool = false
    var spacing:CGFloat = PurchaseTicketSet.padding
    var marginBottom:CGFloat = Dimen.margin.tinyExtra
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginTop: Dimen.margin.regular,
            marginBottom: self.marginBottom,
            spacing:0,
            isRecycle: false,
            useTracking: self.useTracking
        ){
            
            InfoAlert(text: String.pageText.myTicketInfo)
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: self.spacing))
            ForEach(self.dataSets) { data in
                PurchaseTicketSet( data:data )
                    .modifier(ListRowInset(marginHorizontal:0 ,spacing: self.spacing))
            }
            
            /*
            ForEach(self.datas) { data in
                PurchaseTicketItem( data:data )
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.thin))
                    .onTapGesture {
                        
                    }
            }
            */
            
        }
        
        
    }//body
}

struct PurchaseTicketItem: PageView {
   
    var data:PurchaseTicketData
    var body: some View {
        VStack(alignment: .leading , spacing:
                SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.regularExtra){
            Image(self.data.isMonthly ? Asset.icon.ticketMonthly :Asset.icon.ticketPeriod)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: SystemEnvironment.isTablet ? Dimen.icon.tiny : Dimen.icon.light)
                .padding(.horizontal,
                         SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.regularExtra)
            
            if let title = self.data.title {
                Text(title)
                    .modifier(BoldTextStyle(
                                size: SystemEnvironment.isTablet ? Font.size.lightExtra : Font.size.medium,
                                color: Color.app.black))
                    .padding(.horizontal,
                             SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.regularExtra)
            }
            
            if let price = self.data.price {
                HStack(alignment:.bottom , spacing: Dimen.margin.micro){
                    Text(String.app.purchasePrice)
                        .modifier(MediumTextStyle(
                                    size: SystemEnvironment.isTablet ? Font.size.tiny : Font.size.regular,
                                    color: Color.app.black))
                    Text(price)
                        .modifier(MediumTextStyle(
                                    size: SystemEnvironment.isTablet ? Font.size.tiny : Font.size.regular,
                                    color: Color.app.black))
                    Text("(" + String.app.vat + ")")
                        .modifier(MediumTextStyle(
                                    size: SystemEnvironment.isTablet ? Font.size.micro : Font.size.thinExtra,
                                    color: Color.app.grey))
                }
                .padding(.horizontal,
                         SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.regularExtra)
            }
            Spacer().modifier(LineHorizontal(color:Color.app.black))
                .padding(.horizontal,
                         SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.regularExtra)
            HStack(alignment:.top ,
                   spacing: SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.thin){
                VStack(alignment: .leading ,
                       spacing: SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.tiny){
                    if let value = self.data.originPrice {
                        PurchaseTicketValue(title: String.app.ticketPrice, value: value)
                    }
                    if let value = self.data.payment {
                        PurchaseTicketValue(title: String.app.paymentMethod, value: value)
                    }
                    if let value = self.data.joinDate {
                        PurchaseTicketValue(title: String.app.joinDate, value: value)
                    }
                }
                .frame(width: 130)
                VStack(alignment: .leading ,
                       spacing: SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.tiny){
                    if let value = self.data.period {
                        PurchaseTicketValue(title: String.app.purchasePeriod, value: value)
                    }
                    if let value = self.data.contractInfo {
                        PurchaseTicketValue(title: String.app.contractInfo, value: value)
                    }
                    if let value = self.data.contractPeriod {
                        PurchaseTicketValue(title: String.app.contractPeriod, value: value)
                    }
                }
               
            }
            .padding(.horizontal, SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.thin)
        }
        .padding(.vertical, SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.regularExtra)
        
        .background(Color.app.white)
    }
}

struct PurchaseTicketValue: View{
    var title:String
    var value:String
    var body: some View {
        HStack(alignment: .top, spacing: Dimen.margin.micro){
            Text("・ " + title + " ")
                .kerning(Font.kern.thin)
                .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.micro : Font.size.thinExtra,
                            color: Color.app.grey))
            Text(value)
                .kerning(Font.kern.thin)
                .modifier(MediumTextStyle(
                            size: SystemEnvironment.isTablet ? Font.size.micro : Font.size.thinExtra,
                            color: Color.app.black))
                .lineLimit(1)
        }
    }//body
}

#if DEBUG
struct PurchaseTicketList_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            PurchaseTicketList( datas: [
                PurchaseTicketData().setDummy(0),
                PurchaseTicketData().setDummy(),
                PurchaseTicketData().setDummy(),
                PurchaseTicketData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:400,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif