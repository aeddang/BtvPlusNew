//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
class PurchaseData:InfinityData,ObservableObject{
    private(set) var originImage: String? = nil
    private(set) var image: String? = nil
    private(set) var originTitle: String? = nil
    private(set) var title: String? = nil
    private(set) var price: String? = nil
    private(set) var date:String? = nil
    private(set) var period:String? = nil
    private(set) var isImminent:Bool? = nil
    private(set) var isUseable:Bool = true
    private(set) var srisId:String? = nil
    private(set) var epsdId:String? = nil
    private(set) var purchaseId:String? = nil
    private(set) var isAdult:Bool = false
    private(set) var isLock:Bool = false
    private(set) var isOksusu:Bool = false
    private(set) var isPosson:Bool = false
    private(set) var watchLv:Int = 0
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var synopsisType:SynopsisType = .title
    
    private(set) var originData:PurchaseListItem? = nil
    @Published fileprivate(set) var isEdit:Bool = false
    @Published fileprivate(set) var isSelected:Bool = false
    
    func setData(data:PurchaseListItem, idx:Int = -1, type:PurchaseBlock.ListType, anotherStb:String) -> PurchaseData {
        originData = data
        watchLv = data.level?.toInt() ?? 0
        isAdult = data.adult?.toBool() ?? false
        isPosson = type == .possession
        isLock = !SystemEnvironment.isImageLock ? false : isAdult
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster, size: ListItem.purchase.size, isAdult:isAdult)
        originTitle = data.title
        title = data.title
        
        if data.omni_use_flag?.toBool() == true {
            price = String.app.purchasePrice + " : 0" + String.app.cash + " (" + String.app.useOmnipack + ")"
        } else if let prc = data.selling_price {
            price = String.app.purchasePrice + " : " + prc + " (" + String.app.vat + ")"
        } else {
            price = String.app.purchasePrice + " : "
        }
        
        if let dat = data.reg_date {
            date = String.app.purchaseDate + " : " + dat
        }
        if !self.isPosson {
            if data.period == "-1" {
                period = String.app.purchasePeriod + " : " + String.app.expirePeriod
                isUseable = false
            } else if let prd = data.period_detail {
                period = String.app.purchasePeriod + " : " + prd
            }
            isImminent = data.period == "0"
        }
        
        index = idx
        purchaseId = data.purchase_idx
        srisId = data.sris_id
        epsdId = data.epsd_id
        synopsisType = SynopsisType(value: data.prod_type_cd)
        synopsisData = .init(
            srisId: data.sris_id,
            searchType: synopsisType == .package ? .sris : EuxpNetwork.SearchType.prd,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil,
            isPosson:self.isPosson, anotherStbId: self.isPosson ? anotherStb : nil)
        return self
    }
    
    func setDummy(_ idx:Int = -1) -> PurchaseData {
        isImminent = true
        title = "12회 결방"
        price = "구매 금액 : 10,000원 (부가세 포함)"
        date = "구매 일자 : 20.03.17"
        period = "이용 기간 : B tv 해지 전까지"
        return self
    }
    
    fileprivate func updatedImage(){
        title = (SystemEnvironment.isImageLock && self.isAdult) ? String.app.lockAdult : self.originTitle
        image = ImagePath.thumbImagePath(filePath: self.originImage, size: ListItem.purchase.size, isAdult: self.isAdult)
    }
}



struct PurchaseList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var purchaseBlockModel:PurchaseBlockModel = PurchaseBlockModel()
    @EnvironmentObject var naviLogManager:NaviLogManager
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    
    var datas:[PurchaseData]
    var useTracking:Bool = false
    var marginBottom:CGFloat = Dimen.margin.regular
    var type:PurchaseBlock.ListType? = nil
    var onBottom: ((_ data:PurchaseData) -> Void)? = nil
    @State var isEdit:Bool = false
   
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            scrollType : .reload(isDragEnd:false),
            marginTop: Dimen.margin.regularExtra,
            marginBottom: self.marginBottom,
            spacing: 0,
            useTracking: self.useTracking
        ){
            if type == .possession {
                InfoAlert(text: String.pageText.myTerminatePurchaseInfo)
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.thin))
            }
            if !self.datas.isEmpty {
                ForEach(self.datas) { data in
                    PurchaseItem(
                        purchaseBlockModel:self.purchaseBlockModel,
                        data:data )
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.tinyExtra))
                    .onTapGesture {
                        self.sendLog(data: data)
                        if let synopsisData = data.synopsisData {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject( data.synopsisType == .package ? .synopsisPackage : .synopsis)
                                    .addParam(key: .data, value: synopsisData)
                                    .addParam(key: .watchLv, value: data.watchLv)
                            )
                        }
                    }
                    .onAppear{
                        if data.index == self.datas.last?.index {
                            self.onBottom?(data)
                        }
                    }
                }
            } else {
                EmptyMyData(text: String.pageText.myPurchaseEmpty)
                    .modifier(PageBody())
                
            }
        }
        .onReceive(self.purchaseBlockModel.$isEditmode) { isEdit in
            self.datas.forEach{$0.isEdit = isEdit}
            withAnimation{ self.isEdit = isEdit }
        }
        .onReceive(self.purchaseBlockModel.$isSelectAll) { isSelect in
            self.datas.forEach{$0.isSelected = isSelect}
        }
    }//body
    
    private func sendLog (data:PurchaseData){
        switch self.type { 
        case .normal:
            self.sendLogData( data )
        case .collection:
            self.sendLogData( data )
        case .possession:
            break
        case .oksusu:
            self.sendLogDataOksusu( data )
        default : break
        }
        
    }
    
    private func sendLogData(_ data:PurchaseData){
        let content = MenuNaviContentsBodyItem(
            type: "vod",
            title: data.title,
            genre_text: nil,
            genre_code: nil,
            paid: data.originData?.price == "0",
            purchase: true,
            episode_id: data.epsdId,
            episode_resolution_id: data.originData?.epsd_rslu_id,
        
            product_id: data.originData?.prod_id,
            purchase_type: data.originData?.prod_type_cd,
            monthly_pay: nil,
            running_time: nil,
            list_price: data.originData?.selling_price,
            payment_price: data.originData?.price)
        
        let action = MenuNaviActionBodyItem(category : data.isOksusu ? "옥수수소장" : "")
        self.naviLogManager.actionLog(.clickPurchaseListList ,actionBody: action, contentBody: content)
    }
    
    private func sendLogDataOksusu(_ data:PurchaseData){
        let content = MenuNaviContentsBodyItem(
            title: data.title,
            genre_code: nil,
            paid: data.originData?.price == "0",
            purchase: true,
            episode_id: data.epsdId,
            episode_resolution_id: data.originData?.epsd_rslu_id,
            series_id: data.originData?.sris_id
        )
        self.naviLogManager.actionLog(.clickContentsList ,contentBody: content)
    }
    
}

struct PurchaseItem: PageView {
    @EnvironmentObject var repository:Repository
    var purchaseBlockModel:PurchaseBlockModel
    @ObservedObject var data:PurchaseData
    
    @State var isEdit:Bool = false
    @State var isSelected:Bool = false
    
    var body: some View {
        VStack(spacing:Dimen.margin.tinyExtra){
            HStack(spacing:0){
                if self.isEdit {
                    CheckBox(
                        isChecked: self.isSelected,
                        isSimple:true,
                        action:{ ck in
                            self.isSelected = ck
                            self.data.isSelected = ck
                            self.purchaseBlockModel.isSelectChanged = isSelected
                        }
                    )
                    .padding(.trailing, Dimen.margin.thin)
                }
                ZStack{
                    KFImage(URL(string: self.data.image ?? ""))
                        .resizable()
                        .placeholder {
                            Image(Asset.noImg16_9)
                                .resizable()
                        }
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                    
                    if !self.data.isUseable {
                        Spacer().modifier(MatchParent()).background(Color.transparent.black50)
                    }
                    if self.data.isLock {
                        VStack(alignment: .center, spacing: Dimen.margin.thin){
                            Image(Asset.icon.itemRock)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:Dimen.icon.light, height: Dimen.icon.light)
                            Text(String.app.lockAdult)
                                .modifier(MediumTextStyle(size: Font.size.tiny))
                        }
                    }
                }
                .frame( width: ListItem.purchase.size.width, height: ListItem.purchase.size.height)
                .background(Color.app.blueDeep)
                .clipped()
                
                VStack(alignment: .leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if self.data.isImminent == true {
                        Image(Asset.icon.imminent)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: Dimen.icon.tiny)
                            .padding(.bottom, Dimen.margin.tinyExtra)
                    }
                    VStack(alignment: .leading, spacing:Dimen.margin.tinyExtra){
                        if let title = self.data.title {
                            Text(title)
                                .modifier(BoldTextStyle(size: Font.size.light, color: self.data.isUseable ? Color.app.white :Color.app.greyMedium))
                                .multilineTextAlignment(.leading)
                        }
                        if let price = self.data.price {
                            Text(price)
                                .modifier(MediumTextStyle(size: Font.size.thin,
                                                          color: self.data.isUseable ? Color.app.greyLightExtra : Color.app.greyMedium))
                            
                        }
                    }
                    VStack(alignment: .leading, spacing:Dimen.margin.tinyExtra) {
                        if let date = self.data.date {
                            Text(date)
                                .modifier(MediumTextStyle(size: Font.size.tiny,
                                                          color: self.data.isUseable ? Color.app.greyLightExtra : Color.app.greyMedium))
                        }
                        if let period = self.data.period {
                            Text(period)
                                .modifier(MediumTextStyle(size: Font.size.tiny,
                                                          color: self.data.isUseable ? Color.app.greyLightExtra : Color.app.greyMedium))
                        }
                    }
                    .padding(.top, Dimen.margin.thin)
                }
                .padding(.leading, Dimen.margin.regular)
            }
            Spacer().modifier(LineHorizontal())
        }
        .onReceive(self.data.$isEdit) { isEdit in
            withAnimation{self.isEdit = isEdit}
        }
        .onReceive(self.data.$isSelected) { isSelected in
            self.isSelected = isSelected
            
        }
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv : self.data.updatedImage()
            default : break
            }
        }
        
        
    }
    
}

#if DEBUG
struct PurchaseList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PurchaseList( datas: [
                PurchaseData().setDummy(),
                PurchaseData().setDummy(),
                PurchaseData().setDummy(),
                PurchaseData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
            .background(Color.brand.bg)
        }
    }
}
#endif

