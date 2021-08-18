//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class CouponData:InfinityData{
    private(set) var title: String? = nil
    private(set) var expireDate:String? = nil
    private(set) var remain:String? = nil
    private(set) var icon:String? = nil
    private(set) var isExpire:Bool = false
    func setData(data:Coupon, idx:Int = -1) -> CouponData {
        title = data.title
        self.setupExpire(data.expireMessage)
        self.index = idx
        return self
    }
    
    func setData(data:BPoint, idx:Int = -1) -> CouponData {
        title = data.title
        self.setupExpire(data.expireMessage)
        self.setupBalance(data.balance)
        self.index = idx
        return self
    }
    
    func setData(data:BCash, idx:Int = -1) -> CouponData {
        title = data.title
        self.setupExpire(data.expireMessage)
        self.setupBalance(data.totalBalance)
        self.index = idx
        
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> CouponData {
        icon = Asset.icon.expiration
        title = "월정액 구매 리워드 10,000P 월정액 구매 리워드 10,000P 월정액 구매 리워드 10,000P"
        expireDate = "만료일 : 20.04.14"
        remain = "잔여 10,000P"
        return self
    }
    private func setupBalance(_ balance:Double?){
        guard let balance = balance else {
            return
        }
        if balance <= 0 { return }
        self.remain = String.app.remain + " " + balance.formatted(style: .decimal) + String.app.point
    }
    private func setupExpire(_ msg:String?){
        guard let msg = msg else {
            return
        }
        switch msg {
        case "기간만료":
            self.icon = Asset.icon.expiration
            self.isExpire = true
        case "사용완료":
            self.icon = Asset.icon.used
            self.isExpire = true
        case "무제한":
            self.expireDate = msg
        default:
            if msg.count == 8 {
                if let date = msg.toDate(dateFormat:"yyyyMMdd") {
                    let now = Double(Date().timeIntervalSince1970)
                    let expireTime = Double(date.timeIntervalSince1970)
                    if now + (60 * 60 * 24) >= expireTime {
                        self.icon = Asset.icon.imminent
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yy.MM.dd"
                    self.expireDate = String.app.expirePeriodDate + ":" + dateFormatter.string(from: date)
                }
            }
        }
    }
}



struct CouponList: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var couponBlockModel:CouponBlockModel = CouponBlockModel()
    var type:CouponBlock.ListType? = nil
    var title:String? = nil
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[CouponData]
    var useTracking:Bool = false
    var marginBottom:CGFloat = Dimen.margin.regular
    var onBottom: ((_ data:CouponData) -> Void)? = nil
    
    @State var horizontalMargin:CGFloat = Dimen.margin.thin
   
    var body: some View {
        ZStack(alignment: .topLeading){
            
            InfinityScrollView(
                viewModel: self.viewModel,
                axes: .vertical,
                scrollType : .reload(isDragEnd:false),
                header:self.type != nil ?
                    CouponHeader(
                        type: type!,
                        title:self.title,
                        horizontalMargin: self.horizontalMargin)
                    : nil,
                headerSize: Dimen.tab.lightExtra + Dimen.margin.tinyExtra,
                marginTop: Dimen.margin.medium,
                marginBottom: self.marginBottom,
                spacing: 0,
                useTracking: self.useTracking
            ){
                
                if !self.datas.isEmpty {
                    ForEach(self.datas) { data in
                        CouponItem( data:data )
                        .modifier(ListRowInset(marginHorizontal:self.horizontalMargin ,spacing: Dimen.margin.tinyExtra))
                        .onAppear{
                            if data.index == self.datas.last?.index {
                                self.onBottom?(data)
                            }
                        }
                    }
                } else {
                    EmptyMyData(
                        text: self.type?.empty ?? String.alert.dataError)
                        .modifier(PageBody())
                }
            }
        }
       
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            self.horizontalMargin
                = self.sceneObserver.sceneOrientation == .portrait ? Dimen.margin.thin : Dimen.margin.heavy
        }
        .onAppear{
            self.horizontalMargin
                = self.sceneObserver.sceneOrientation == .portrait ? Dimen.margin.thin : Dimen.margin.heavy
        }
        
        
    }//body
}

struct CouponHeader: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var naviLogManager:NaviLogManager
    var type:CouponBlock.ListType
    var title:String?
    var horizontalMargin:CGFloat
    var body: some View {
        HStack(spacing: Dimen.margin.tiny){
            VStack(alignment: .leading, spacing: 0){
                if let title = self.title {
                    HStack(spacing: Dimen.margin.micro){
                        if let leading = self.type.text {
                            Text(leading).modifier(MediumTextStyle(size: Font.size.regular))
                        }
                        Text(title).modifier(BoldTextStyle(size: Font.size.regular))
                    }
                }
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            Button(action: {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.confirmNumber)
                        .addParam(key: .type, value: type)
                )
                self.naviLogManager.actionLog(.clickCouponPointAdd, actionBody: .init(config: "",  category: self.type.text))
                
            }) {
                HStack(alignment:.center, spacing: Dimen.margin.micro){
                    Image(Asset.icon.add)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.micro, height: Dimen.icon.micro)
                    Text(type.regist)
                        .modifier(BoldTextStyle(size: Font.size.light, color: Color.brand.primary))
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.horizontal, self.horizontalMargin )
    }
}


struct CouponItem: PageView {
    var data:CouponData
    
    let textStyle = MediumTextStyle( size: Font.size.thin, color: Color.app.greyMedium)
    var body: some View {
        HStack(spacing:0){
            VStack(alignment: .leading ,spacing:Dimen.margin.thin){
                VStack(alignment: .leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if let icon = self.data.icon {
                        Image(icon)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: Dimen.icon.tiny)
                            .padding(.bottom, Dimen.margin.tiny)
                    }
                   
                    if let title = self.data.title {
                        Text(title)
                            .modifier(BoldTextStyle(size: Font.size.lightExtra, color: self.data.isExpire ? Color.app.grey : Color.app.white))
                            .multilineTextAlignment(.leading)
                    }
                }
                HStack(spacing:Dimen.margin.thin){
                    if let expireDate = self.data.expireDate {
                        Text(expireDate)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: self.data.isExpire ? Color.app.grey :Color.app.greyLight))
                            .lineLimit(1)
                    }
                    if self.data.expireDate != nil && self.data.remain != nil {
                        Text("|").modifier(MediumTextStyle(size: Font.size.thinExtra, color: self.data.isExpire ? Color.app.grey :Color.app.greyLight))
                    }
                    if let remain = self.data.remain {
                        Text(remain)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: self.data.isExpire ? Color.app.grey :Color.app.greyLight))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.all, Dimen.margin.regularExtra)
            .modifier(MatchParent())
            .background(Color.app.blueLight)
            .clipShape( RoundedRectangle(cornerRadius: Dimen.radius.light))
            LineVerticalDotted()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                .modifier(MatchVertical(width:1))
                .foregroundColor(Color.transparent.white15)
                .padding(.vertical, Dimen.radius.light)
                .background(Color.app.blueLight)
            Spacer()
                .modifier(MatchVertical(width:75))
                .background(Color.app.blueLight)
                .clipShape( RoundedRectangle(cornerRadius:Dimen.radius.light))
        }
        .frame(height:ListItem.coupon.height)
        .background(
            HStack{
                Spacer()
                    .modifier(MatchVertical(width:Dimen.radius.light))
                    .background(Color.app.blueLight)
                Spacer()
                Spacer()
                    .modifier(MatchVertical(width:Dimen.radius.light))
                    .background(Color.app.blueLight)
            }
        )
    }
    
}

#if DEBUG
struct CouponList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            CouponList( datas: [
                CouponData().setDummy(),
                CouponData().setDummy(),
                CouponData().setDummy(),
                CouponData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

