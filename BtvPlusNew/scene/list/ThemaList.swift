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
    
    func setData(data:ContentItem, cardType:Block.CardType = .squareThema, idx:Int = -1) -> ThemaData {
        
        switch cardType {
        case .circleTheme: type = .small
        case .bigTheme: type = .big
        default: type = .square
        }
        
        title = data.title
        if let thumb = data.poster_filename_h {
            image = ImagePath.thumbImagePath(filePath: thumb, size: ListItem.thumb.size)
        }
        index = idx
        return self
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
    @Binding var datas:[ThemaData]
    var body: some View {
        InfinityScrollView(
            viewModel: self.viewModel,
            axes: .horizontal,
            marginVertical: 0,
            marginHorizontal: Dimen.margin.thin){
            ForEach(self.datas) { data in
                ThemaItem( data:data )
                .onTapGesture {
                   
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
                ImageView(url: self.data.image, contentMode: .fill)
                    .modifier(MatchParent())
                    .clipShape(Circle())
            }else{
                ImageView(url: self.data.image, contentMode: .fill)
                    .modifier(MatchParent())
                    .clipShape(Rectangle())
            }
            
            if self.data.title != nil {
                Text(self.data.title!)
                    .modifier(MediumTextStyle(size: Font.size.medium))
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, Dimen.margin.thin)
                    .frame(width: self.data.type.size.width)
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
            ThemaList( datas: .constant([
                ThemaData().setDummy(0),
                ThemaData().setDummyCircle(),
                ThemaData().setDummy(),
                ThemaData().setDummy()
            ]))
            .environmentObject(PagePresenter()).frame(width:320,height:600)
        }
    }
}
#endif
