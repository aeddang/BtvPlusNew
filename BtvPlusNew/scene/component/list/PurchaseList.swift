//
//  VideoList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class PurchaseData:InfinityData,ObservableObject{
    private(set) var originImage: String? = nil
    private(set) var image: String? = nil
    private(set) var originTitle: String? = nil
    private(set) var title: String? = nil
    private(set) var price: String? = nil
    private(set) var date:String? = nil
    private(set) var period:String? = nil
    private(set) var isImminent:Bool? = nil
    private(set) var srisId:String? = nil
    private(set) var epsdId:String? = nil
    private(set) var purchaseId:String? = nil
    private(set) var isAdult:Bool = false
    private(set) var isLock:Bool = false
    private(set) var watchLv:Int = 0
    private(set) var synopsisData:SynopsisData? = nil
    private(set) var synopsisType:SynopsisType = .title
    @Published fileprivate(set) var isEdit:Bool = false
    @Published fileprivate(set) var isSelected:Bool = false
    
    func setData(data:PurchaseListItem, idx:Int = -1) -> PurchaseData {
        watchLv = data.level?.toInt() ?? 0
        isAdult = data.adult?.toBool() ?? false
        isLock = !SystemEnvironment.isImageLock ? false : isAdult
        originImage = data.poster
        image = ImagePath.thumbImagePath(filePath: data.poster, size: ListItem.purchase.size, isAdult:isAdult)
        originTitle = data.title
        title = data.title
        
        if let prc = data.selling_price {
            
            price = String.app.purchasePrice + " : "
                + max(prc.toInt(),0).formatted(style: .decimal) + String.app.cash + " (" + String.app.vat + ")"
        }
        
        if let dat = data.reg_date {
            date = String.app.purchaseDate + " : " + dat
        }
        if data.period == "-1" {
            period = String.app.purchasePeriod + " : " + String.app.expirePeriod
        } else if let prd = data.period_detail {
            period = String.app.purchasePeriod + " : " + prd
        }
        isImminent = data.period == "0"
        
        index = idx
        purchaseId = data.purchase_idx
        srisId = data.sris_id
        epsdId = data.epsd_id
        synopsisType = SynopsisType(value: data.prod_type_cd)
        synopsisData = .init(
            srisId: data.sris_id, searchType: EuxpNetwork.SearchType.sris.rawValue,
            epsdId: data.epsd_id, epsdRsluId: data.epsd_rslu_id, prdPrcId: "",  kidZone:nil)
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
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[PurchaseData]
    var useTracking:Bool = false
    var marginBottom:CGFloat = Dimen.margin.tinyExtra
    var onBottom: ((_ data:PurchaseData) -> Void)? = nil
    @State var isEdit:Bool = false
   
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .vertical,
            marginTop: Dimen.margin.regularExtra,
            marginBottom: self.marginBottom,
            spacing: 0,
            useTracking: self.useTracking
        ){
            
            
            ForEach(self.datas) { data in
                PurchaseItem( data:data )
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.tinyExtra))
                .onTapGesture {
                    if let synopsisData = data.synopsisData {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject( data.synopsisType == .package ? .synopsisPackage : .synopsis)
                                .addParam(key: .data, value: synopsisData)
                                .addParam(key: .watchLv, value: data.watchLv)
                        )
                    } 
                }
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
}

struct PurchaseItem: PageView {
    @EnvironmentObject var repository:Repository
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
                        }
                    )
                    .padding(.trailing, Dimen.margin.thin)
                }
                ZStack{
                    ImageView(url: self.data.image, contentMode: .fill, noImg: Asset.noImg9_16)
                        .modifier(MatchParent())
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
                                .modifier(BoldTextStyle(size: Font.size.light))
                                .multilineTextAlignment(.leading)
                        }
                        if let price = self.data.price {
                            Text(price)
                                .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.greyLight))
                            
                        }
                    }
                    VStack(alignment: .leading, spacing:Dimen.margin.tinyExtra) {
                        if let date = self.data.date {
                            Text(date)
                                .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.greyLight))
                        }
                        if let period = self.data.period {
                            Text(period)
                                .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.app.greyLight))
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

