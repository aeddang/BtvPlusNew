//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
enum AlramType:String {
    case none, notification, popup, notificationNPopup
    static func getType(_ value:String)->AlramType{
        switch value {
        case "ALL": return .notification
        case "APNS": return .popup
        case "FCM": return .notificationNPopup
        default: return .none
        }
    }
}
enum AlramMsgType: Int {
    case none = -1
    case event
    case contentUpdate
    static func getType(_ value:String)->AlramMsgType{
        switch value {
        case "market": return .event
        case "content": return .contentUpdate
        case "reservation": return .event
        case "service": return .event
        case "inform": return .event
        default: return .event
        }
    }
    /*
    case "market" : config = "A1.market"
    case "content" : config = "A2.content"
    case "reservation" : config = "A3.reservation"
    case "service" : config = "A4.service"
    case "inform" : config = "A5.inform"
    */
}
enum AlramImageType:String {
    case none, local, poster
    static func getType(_ value:String)->AlramImageType{
        switch value {
        case "icon": return .local
        case "poster" : return .poster
        default: return .none
        }
    }
}
enum AlramLandingType:String {
    case none, notice ,eventWeb, vodDetail, webInApp, browser, home, trailer, menu, synop
    case season, monthly, reserve
    case coupon ,point, newpoint
    case recentVOD, reservation, remindReservation
    
    static func getType(_ value:String)->AlramLandingType{
        switch value {
        case "WEBINAPP" : return .webInApp
        case "SYNOP" : return .synop
        case "WEB" : return .browser
        case "MENU" : return .menu
        case "CONTENT" : return .trailer
        case "SEASON" : return .season
        case "MONTH" : return .monthly
        case "RESERVATION" : return .reservation
        case "POINT" : return .point
        case "COUPON" : return .coupon
        case "NEWBPOINT" : return .newpoint
        default: return .none
        }
    }
    
    func getCategoryTitle() -> String {
        switch self {
        case .notice: return String.alert.apnsNotice
        case .eventWeb: return String.alert.apnsEventWeb
        case .vodDetail: return String.alert.apnsVodDetail
        case .webInApp: return String.alert.apnsWebInApp
        case .browser: return String.alert.apnsBrowser
        case .home: return String.alert.apnsHome
        case .trailer: return String.alert.apnsTrailer
        case .menu: return String.alert.apnsMenu
        case .synop: return String.alert.apnsSynop
        case .season: return String.alert.apnsSeason
        case .monthly: return String.alert.apnsMonthly
        case .reserve: return String.alert.apnsReserve
        case .coupon: return ""
        case .point: return ""
        case .newpoint: return ""
        default: return ""
        }
    }
    
   func getIcon() -> String {
        switch self {
        case .trailer: return Asset.icon.noticeRelease
        case .reserve, .reservation: return Asset.icon.noticeReserve
        case .coupon: return Asset.icon.noticeCoupon
        case .point: return Asset.icon.noticePoint
        default: return Asset.icon.noticeAd
        }
    }
    
   func getLogValue() -> String {
        switch self {
        case .notice: return ""
        case .eventWeb: return ""
        case .vodDetail: return ""
        case .webInApp: return "B1.WEBINAPP"
        case .browser: return "B3.WEB"
        case .home: return ""
        case .trailer: return "B5.CONTENT"
        case .menu: return "B4.MENU"
        case .synop: return "B2.SYNOP"
        case .season: return "B6.SEASON"
        case .monthly: return "B7.MONTH"
        case .reserve: return "B8.RESERVATION"
        case .coupon: return "B9.POINT"
        case .point: return "B10.COUPON"
        case .newpoint: return "B11.NEWBPOINT"
        default: return ""
        }
    }
}


class AlramData:InfinityData{
    private(set) var type:AlramType = .none
    private(set) var imageType:AlramImageType = .none
    private(set) var msgType:AlramMsgType = .none
    private(set) var landingType:AlramLandingType = .none
    private(set) var title: String? = nil
    private(set) var text: String? = nil
    private(set) var date:String? = nil
    private(set) var remain:String? = nil
    private(set) var image: String? = nil
    private(set) var location: String? = nil
    private(set) var limitTime: String? = nil
    private(set) var isCoreData: Bool = false
    fileprivate(set) var isExpand:Bool = false
    fileprivate(set) var isRead:Bool = false
    
    func setData(data:NotificationEntity, idx:Int = -1) -> AlramData{
        self.isCoreData = true
        if let userData = data.userInfo as? [String: Any] {
            if let value = userData["notiType"] as? String {
                self.type = AlramType.getType(value.uppercased())
            }
           
            if let value = userData["msgType"] as? String {
                self.msgType = AlramMsgType.getType(value)
            }
            
            if let value = userData["landingPath"] as? String {
                self.landingType = AlramLandingType.getType(value.uppercased())
            }
            
            if let value = userData["imgType"] as? String {
                self.imageType = AlramImageType.getType(value)
            }
            
            if let value = userData["posterUrl "] as? String {
                self.image = value
            } else if let value = userData["iconUrl"] as? String {
                self.image = value
            }
            
            if let value = userData["limitTime"] as? String {
                self.limitTime = value
            }
            
            if let location = userData["destPos"] as? String {
                self.location = location.replace("\n", with: "")
                if let components = URLComponents(string: self.location!) {
                    // Coupon 만료 알림|0|0|0|4|http://58.123.205.55/mybtvCouponPoint.do?type=coupon&state=E
                    // Bpoint 만료 알림|0|0|0|4|http://10.41.10.25:8080/mybtvCouponPoint.do?type=point&state=E
                    if let query = components.queryItems {
                        for item in query where item.name == "type" {
                            if item.value == "coupon" {
                                self.landingType = .coupon
                            } else if item.value == "point" {
                                self.landingType = .point
                            }
                        }
                    }
                }
            }
        }
        
        title = data.title
        text = data.body
        isRead = data.isRead
        if let regDate = data.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd hh:mm"
            date = dateFormatter.string(from: regDate)
        }
        self.index = idx
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> AlramData {
        title = "오늘만 무료! 반도"
        text = "(광고) 좀비는 무섭고 사람은 더 무섭다!! 부산행 이후 돌아온 K-좀비 무비. 강동원 주연의 <반도>! 오늘 하루만 모바일 B tv 로 무료로 감상해 보세요."
        date = "2020.08.31 18:30"
        return self
    }

}



struct AlramList: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[AlramData]
    var useTracking:Bool = false
    var marginBottom:CGFloat = Dimen.margin.tinyExtra
    
    @State var isPush:Bool = false
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            scrollType : .reload(isDragEnd:false),
            marginTop: Dimen.margin.regular,
            marginBottom: self.marginBottom,
            spacing: 0,
            useTracking: self.useTracking
        ){
            InfoAlert(text: String.pageText.myAlramInfo)
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.thin))
            if !self.datas.isEmpty {
                ForEach(self.datas) { data in
                    AlramItem( data:data )
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.tinyExtra))
                }
            } else {
                VStack{
                    EmptyMyData(
                        text: String.pageText.myAlramEmpty,
                        tip : String.pageText.myAlramEmptyTip)
                    if !self.isPush {
                        FillButton(
                            text: String.button.alramOn,
                            size: Dimen.button.regular
                        ){ _ in
                            if self.pairing.status != .pairing {
                                self.appSceneObserver.alert = .needPairing()
                                return
                            }
                            self.dataProvider.requestData(q: .init(type: .updateAgreement(true)))
                        }
                    }
                }
                .padding(.horizontal, Dimen.margin.heavy)
                .modifier(PageBody())
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAgreement(let isAgree) : self.onUpdatedPush(res, isAgree: isAgree)
            default: do{}
            }
        }
        
        .onAppear(){
            self.isPush = self.pairing.user?.isAgree3 ?? false
        }
       
    }//body
    private func onUpdatedPush(_ res:ApiResultResponds, isAgree:Bool){
        guard let data = res.data as? NpsResult  else { return onUpdatePushError() }
        guard let resultCode = data.header?.result else { return onUpdatePushError() }
        if resultCode == NpsNetwork.resultCode.success.code {
            self.repository.updatePush(isAgree)
            self.isPush = isAgree
            self.appSceneObserver.event = .toast(
                isAgree ? String.alert.pushOn : String.alert.pushOff
            )
        } else {
            onUpdatePushError()
        }
    }
    private func onUpdatePushError(){
        self.appSceneObserver.event = .toast( String.alert.pushError )
    }
}

struct AlramItem: PageView {
    var data:AlramData
    @State var isExpand = false
    @State var isRead = false
    var body: some View {
        HStack(spacing:0){
            Circle()
                .fill(self.isRead ? Color.app.blueLight : Color.brand.primary )
                .frame(width: Dimen.icon.microExtra, height:Dimen.icon.microExtra)
                .padding(.horizontal, Dimen.margin.tiny)
            
            if let icon = self.data.landingType.getIcon() {
                Image(icon)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: Dimen.icon.tiny)
                    .padding(.trailing, Dimen.margin.mediumExtra)
                    .opacity(self.isRead ? 0.5 : 1.0)
            }
            VStack(alignment: .leading ,spacing:Dimen.margin.thin){
                VStack(alignment: .leading ,spacing:Dimen.margin.micro){
                    if let title = self.data.title {
                        Text(title)
                            .modifier(BoldTextStyle(
                                        size: Font.size.light,
                                        color: self.isRead ? Color.app.grey : Color.app.white))
                            .lineLimit(self.isExpand ? 999 : 3)
                    }
                    if let text = self.data.text {
                        Text(text)
                            .modifier(MediumTextStyle(
                                        size: Font.size.thin,
                                        color: self.isRead ? Color.app.grey : Color.app.white))
                            .lineLimit(self.isExpand ? 999 : 1)
                    }
                }
                if self.isExpand , let image = self.data.image  {
                    KFImage(URL(string: image))
                        .resizable()
                        .placeholder {
                            Image(Asset.noImg9_16).resizable()
                        }
                        .cancelOnDisappear(true)
                        .loadImmediately()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: ListItem.alram.height, alignment:.topLeading)
                }
                if let date = self.data.date {
                    Text(date)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.grey))
                }
                
            }
            Spacer()
            Button(action: {
                withAnimation{ self.isExpand.toggle() }
                self.data.isExpand = self.isExpand
                if !self.isRead { self.read() }
            }) {
                Image(Asset.icon.down)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                    .rotationEffect(.degrees(self.isExpand ? 180 : 0))
                    .padding(.horizontal, Dimen.margin.light)
            }
        }
        .padding(.vertical, Dimen.margin.thin)
        .background(Color.app.blueLight)
        .onTapGesture {
            if !self.isRead { self.read() }
        }
        .onAppear{
            self.isRead = self.data.isRead
            self.isExpand = self.data.isExpand
        }
    }
    
    private func read(){
        self.isRead = true
        self.data.isRead = true
        if !self.data.isCoreData { return }
        NotificationCoreData().readNotice(title: data.title ?? "", body: data.text ?? "")
    }
}

#if DEBUG
struct AlramList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            AlramList( datas: [
                AlramData().setDummy(),
                AlramData().setDummy(),
                AlramData().setDummy(),
                AlramData().setDummy()
            ])
            .environmentObject(Repository())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(DataProvider())
            .environmentObject(Pairing())
            .frame(width:320,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

