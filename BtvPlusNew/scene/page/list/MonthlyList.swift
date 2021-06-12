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
    private(set) var subTitle: String? = nil
    private(set) var count: String = "0"
    private(set) var menuId: String? = nil
    private(set) var prdPrcId: String = ""
    private(set) var prodTypeCd: String? = nil
    private(set) var isJoin: Bool = false
    private(set) var isSubJoin: Bool = false
    private(set) var isSelected: Bool = false
    private(set) var blocks:[BlockItem]? = nil
    
    private(set) var sortIdx:Int = 0
  
    @Published private(set) var isUpdated: Bool = false
        {didSet{ if isUpdated { isUpdated = false} }}
    
    func setData(data:BlockItem, idx:Int = -1) -> MonthlyData {
        
        title = data.menu_nm
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
        prodTypeCd = data.prd_typ_cd
        menuId = data.menu_id
        blocks = data.blocks
        isUpdated = true
        return self
    }
    
    @discardableResult
    func setData(data:MonthlyInfoItem, isLow:Bool) -> MonthlyData {
        if isLow {
            self.isSubJoin = true
            self.sortIdx += 10
        }else{
            self.isJoin = true
            self.sortIdx += 100
        }
        self.isUpdated = true
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
        self.isSubJoin = false
        self.isJoin = false
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
                if data.index == -1 {
                    MonthlyItem( data:data )
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }
                    }
                }else{
                    MonthlyItem( data:data )
                        .id(data.index)
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }
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
                .loadImmediately()
                .aspectRatio(contentMode: .fill)
                .modifier(MatchParent())
        }
        .overlay(
           Rectangle()
            .stroke(
                self.isSelected ? Color.brand.primary : Color.transparent.clear,
                lineWidth: Dimen.stroke.heavy)
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
