//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct BlockHeader:PageComponent, BlockProtocol {
    @EnvironmentObject var pagePresenter:PagePresenter
    
    var data: BlockData
    var type: CateBlock.ListType
   
    var body :some View {
        HStack( spacing:Dimen.margin.thin){
            VStack(alignment: .leading, spacing:0){
                Text(data.name).modifier(BlockTitle())
                    .lineLimit(1)
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            TextButton(
                defaultText: String.button.all,
                textModifier: MediumTextStyle(size: Font.size.thin, color: Color.app.white).textModifier
            ){_ in
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.categoryList)
                        .addParam(key: .data, value: data)
                        .addParam(key: .type, value: data.uiType)
                )
            }
        }
        .modifier(ContentHorizontalEdges())
        .frame( height: 170)
        
    }
}
