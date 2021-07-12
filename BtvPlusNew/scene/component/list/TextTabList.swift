//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class TextTabData:InfinityData{
    private(set) var title: String = ""
    private(set) var menuId: String? = nil
    private(set) var blocks:[BlockItem]? = nil
    private(set) var listType:CateBlock.ListType? = nil
    private(set) var isAdult:Bool = false
    func setData(data:BlockItem ,idx:Int) -> TextTabData {
        title = data.menu_nm ?? ""
        menuId = data.menu_id
        
        let blockData = BlockData().setData(data)
        switch blockData.cardType {
        case .smallPoster, .bigPoster, .bookmarkedPoster, .rankingPoster :
            listType = .poster
        case .video, .watchedVideo :
            listType = .video
        case .banner :
            listType = .banner
        default:
            listType = nil
        }
        index = idx
        blocks = data.blocks
        isAdult = data.lim_lvl_yn?.toBool() ?? false
        return self
    }
    
    var useAble:Bool {
        get{
            if self.blocks != nil {return true}
            if self.listType != nil && self.menuId != nil {return true}
            return false
        }
    }
    
    
    func setDummy(_ idx:Int = UUID().hashValue) -> TextTabData {
        title = "외국인남친"
        index = idx
        return self
    }
    
}

extension TextTabList {
    static let height = Dimen.tab.regular
}

struct TextTabList: PageComponent{
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[TextTabData]
    var selectedIdx:Int = -1
    var useTracking:Bool = false
    var margin:CGFloat = Dimen.margin.light
    var action: ((_ data:TextTabData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin,
            spacing: Dimen.margin.medium,
            isRecycle: true,
            useTracking: self.useTracking
            ){
            ForEach(self.datas) { data in
                TextTabItem( data:data , isSelected: self.selectedIdx == data.index)
                    .id(data.index)
                    .onTapGesture {
                        if let action = self.action {
                            action(data)
                        }
                    }
            }
        }
    }//body
}



struct TextTabItem: PageView {
    var data:TextTabData
    var isSelected:Bool = false
    var body: some View {
        ZStack{
            Text(self.data.title)
                .modifier(MediumTextStyle(
                    size: Font.size.light,
                    color: isSelected ? Color.brand.primary : Color.app.white
                    )
                )
        }
        .frame( height:TextTabList.height )
        
    }
    
}

#if DEBUG
struct TextTabList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            TextTabList( datas: [
                TextTabData().setDummy(),
                TextTabData().setDummy(),
                TextTabData().setDummy(),
                TextTabData().setDummy()
            ])
            .environmentObject(PagePresenter()).modifier(MatchParent())
            .background(Color.brand.bg)
        }
    }
}
#endif

