//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage

class MonthlyData:InfinityData,ObservableObject{
    private(set) var image: String = Asset.noImg16_9
    private(set) var selectedImage: String? = nil
    private(set) var selectedJoinImage: String? = nil
    private(set) var joinImage: String? = nil
    private(set) var title: String? = nil
    private(set) var titlePeriod: String? = nil
    private(set) var text: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var count: String = "0"
    private(set) var menuId: String? = nil
    private(set) var prdPrcId: String = ""
    
    private(set) var prodTypeCd: PrdTypCd = .none
    private(set) var isJoin: Bool = false
    private(set) var subJoinId:String? = nil
    private(set) var isPeriod: Bool = false
    private(set) var isSubJoin: Bool = false
    private(set) var isSelected: Bool = false
    private(set) var isKidszone: Bool = false
    private(set) var isFirstFree: Bool? = nil
    private(set) var blocks:[BlockItem]? = nil
    private(set) var price:String? = nil
    private(set) var sortIdx:Int = 0
    var posIdx:Int = UUID.init().hashValue
  
    @Published private(set) var isUpdated: Bool = false
        {didSet{ if isUpdated { isUpdated = false} }}
    
    @Published private(set) var isPurchaseUpdated: Bool = false
        {didSet{ if isPurchaseUpdated { isPurchaseUpdated = false} }}
    
    func setData(data:BlockItem, idx:Int = -1) -> MonthlyData {
        title = data.menu_nm
        text = data.menu_expl
        if let prc = data.prd_prc_vat {
            self.price = String.app.month + " " + prc.formatted(style: .decimal) + String.app.cash
        }
        if let thumb = data.bnr_off_img_path {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.monthly.size) ?? image
        }
        if let thumb = data.bnr_selected_img_path {
            selectedImage = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.monthly.size)
        }
        if let thumb = data.ppm_join_off_img_path {
            joinImage = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.monthly.size)
        }
        if let thumb = data.ppm_join_on_img_path {
            selectedJoinImage = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.monthly.size)
        }
        index = idx
        prdPrcId = data.prd_prc_id ?? ""
        prodTypeCd = PrdTypCd.init(rawValue: data.prd_typ_cd ?? "") ?? .none
        menuId = data.menu_id
        blocks = data.blocks
        isUpdated = true
        return self
    }
    
    func setData(band:Band, prdPrcId:String?, blocks:[BlockItem], idx:Int = -1) -> MonthlyData {
        self.title = band.name
        self.index = idx
        self.prdPrcId = prdPrcId ?? ""
        self.prodTypeCd = .none
        self.menuId = band.menuId
        self.blocks = blocks
        //isUpdated = true
        return self
    }
    
    @discardableResult
    func setData(data:MonthlyInfoItem, isLow:Bool, isPeriod: Bool) -> MonthlyData {
        isKidszone = data.kzone_yn?.toBool() ?? false
        
        if isPeriod {
            if self.isPeriod && isLow {return self}
            self.isPeriod = true
            self.titlePeriod = data.title
        }else{
            if self.isPeriod {return self}
            self.isPeriod = false
        }
        
        if isLow && !self.isJoin {
            self.isSubJoin = true
            self.isJoin = false
            self.sortIdx = 100
        } else {
            self.isJoin = true
            self.isSubJoin = false
            self.sortIdx = 1000
        }
        self.subJoinId = data.subs_id
        self.isUpdated = true
        return self
    }
        
    @discardableResult
    func setData(data:MonthlyInfoData) -> MonthlyData {
        guard let item  = data.purchaseList?.first else { return self}
        //self.isPeriod = item.owned_prd_typ_cd == "32"
        self.isFirstFree = item.free_ppm_use_yn?.toBool() ?? false
        self.isPurchaseUpdated = true
        return self
    }
    
    func resetJoin(){
        self.isSubJoin = false
        self.isJoin = false
        self.isUpdated = true
        self.sortIdx = 0
    }
    
    func setDummy(_ idx:Int = -1) -> MonthlyData {
        title = "THEMA"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    
    var hasAuth :Bool {
        get{
            return isJoin || isSubJoin
        }
    }
    
    func reset() {
        self.isSelected = false
        //self.isSubJoin = false
        //self.isJoin = false
        //self.sortIdx = 0
        self.isUpdated = true
        
    }
    func setSelected(_ isSelected:Bool) {
        self.isSelected = isSelected
        self.isUpdated = true
    }
    
    func getImage() -> String? {
        if self.hasAuth {
            return isSelected ? (selectedJoinImage ?? joinImage) : joinImage
        } else {
            return isSelected ? (selectedImage ?? image) : image
        }
    }
   
}


struct MonthlyList: PageComponent{
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[MonthlyData]
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.thin
    var action: ((_ data:MonthlyData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin ,
            spacing: Dimen.margin.tiny,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            ForEach(self.datas) { data in
                MonthlyItem( data:data )
                .id(data.hashId)
                .accessibility(label: Text(data.title ?? ""))
                .onTapGesture {
                    if let action = self.action {
                        action(data)
                    }
                }
            }
        }
        
    }//body
}

struct MonthlyItem: PageView {
    //@ObservedObject var imageLoader: ImageLoader = ImageLoader()
    @ObservedObject var data:MonthlyData
    @State var image:String? = nil
    @State var isSelected:Bool = false
    var body: some View {
        ZStack{
            KFImage(URL(string: self.image ?? ""))
                .resizable()
                .placeholder {
                    Image(Asset.noImg4_3)
                        .resizable()
                }
                .cancelOnDisappear(true)
                .aspectRatio(contentMode: .fill)
                .modifier(MatchParent())
        }
        .overlay(
           Rectangle()
            .strokeBorder(
                self.isSelected ? Color.brand.primary : Color.transparent.clear,
                lineWidth: Dimen.stroke.medium)
        )
        .frame(
            width: ListItem.monthly.size.width,
            height: ListItem.monthly.size.height)
        .clipped()
        .onReceive(self.data.$isUpdated){ update in
            if !update {return}
            let willImage = data.getImage() ?? data.image
            self.isSelected = data.isSelected
            if willImage != self.image {
                self.image = willImage
            }
           
        }
        .onAppear{
            self.image = data.getImage() ?? data.image
            self.isSelected = data.isSelected
    
        }
        
    }
}

#if DEBUG
struct MonttlyList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            
            MonthlyList(
                viewModel:InfinityScrollModel(),
                datas: [
                MonthlyData().setDummy(0),
                MonthlyData().setDummy(),
                MonthlyData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif
