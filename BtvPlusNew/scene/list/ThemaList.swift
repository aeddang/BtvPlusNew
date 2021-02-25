//
//  ThemaList.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

class ThemaData:InfinityData{
    private(set) var image: String = Asset.noImg16_9
    private(set) var title: String? = nil
    private(set) var subTitle: String? = nil
    private(set) var count: String = "0"
    private(set) var type:ThemaType = .square
    private(set) var menuId: String? = nil
    private(set) var blocks:[BlockItem]? = nil
    
    func setData(data:ContentItem, cardType:BlockData.CardType = .squareThema, idx:Int = -1) -> ThemaData {
        setCardType(cardType)
        title = data.title
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: type.size, convType: type == .small ? .alpha : .none)
        }
        index = idx
        return self
    }
    
    func setData(data:BlockItem, cardType:BlockData.CardType = .squareThema, idx:Int = -1) -> ThemaData {
        setCardType(cardType)
        title = data.menu_nm
        if let thumb = data.bnr_off_img_path {
            image = ImagePath.thumbImagePath(filePath: thumb, size: type.size, convType: type == .small ? .alpha : .none)
        }
        index = idx
        blocks = data.blocks
        menuId = data.menu_id
        return self
    }
    
    private func setCardType(_ cardType:BlockData.CardType){
        switch cardType {
        case .circleTheme: type = .small
        case .bigTheme: type = .big
        default: type = .square
        }
    }
    
    func setDummy(_ idx:Int = -1) -> ThemaData {
        title = "THEMA"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        return self
    }
    func setDummyCircle(_ idx:Int = -1) -> ThemaData {
        title = "THEMA"
        subTitle = "subTitlesubTitlesubTitle"
        index = idx
        type = .small
        return self
    }
}

enum ThemaType {
    case square, small, big
    var size:CGSize {
        get{
            switch self {
            case .small: return ListItem.thema.type01
            case .big: return ListItem.thema.type02
            case .square: return ListItem.thema.type03
            }
        }
    }
    var spacing:CGFloat {
        get{
            switch self {
            case .small: return Dimen.margin.thinExtra
            case .big: return Dimen.margin.lightExtra
            case .square: return Dimen.margin.tiny
            }
        }
    }
    var isCircle:Bool {
        get{
            switch self {
            case .small: return true
            case .big: return true
            case .square: return false
            }
        }
    }
}

struct ThemaList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var datas:[ThemaData]
    var margin:CGFloat = Dimen.margin.thin
    var action: ((_ data:ThemaData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: self.margin ,
            spacing: datas.isEmpty ? 0 : datas[0].type.spacing,
            isRecycle: true,
            useTracking: true
            ){
            ForEach(self.datas) { data in
                ThemaItem( data:data )
                .onTapGesture {
                    if let action = self.action {
                        action(data)
                    }else{
                        if data.blocks != nil && data.blocks?.isEmpty == false {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.thema)
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .data, value: data.blocks)
                            )
                        }else{
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.cate)
                                    .addParam(key: .title, value: data.title)
                                    .addParam(key: .id, value: data.menuId)
                                    .addParam(key: .type, value: CateBlock.ListType.poster)
                            )
                        }
                        
                        
                        
                    }
                }
            }
        }
    }//body
}

struct ThemaItem: PageView {
    var data:ThemaData
    var body: some View {
        ZStack{
            if self.data.type.isCircle {
                ImageView(url: self.data.image, contentMode: .fit, noImg: Asset.noImg1_1)
                    .modifier(MatchParent())
                
            }else{
                ImageView(url: self.data.image, contentMode: .fit, noImg: Asset.noImg1_1)
                    .modifier(MatchParent())
            }
        }
        .frame(
            width: self.data.type.size.width,
            height: self.data.type.size.height)
        .clipped()
        
    }
}

#if DEBUG
struct ThemaList_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ThemaList( datas: [
                ThemaData().setDummy(0),
                ThemaData().setDummyCircle(),
                ThemaData().setDummy(),
                ThemaData().setDummy()
            ])
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif
