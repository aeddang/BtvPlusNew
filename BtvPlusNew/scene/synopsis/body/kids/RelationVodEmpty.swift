//
//  RelationVodEmpty.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/25.
//

import Foundation
import SwiftUI
struct RelationVodEmpty: PageView{
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Image(AssetKids.image.emptyRelationVod)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height:SystemEnvironment.isTablet ? 288 : 150)

            VStack(alignment: .center, spacing: 0){
                Text(String.kidsText.synopsisRelationVod)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.regularExtra, color: Color.app.brownDeep))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.mediumExtra)
                    .fixedSize()
                Spacer()
                Text(String.kidsText.synopsisNoRelationVod)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.mediumExtra)
                    .fixedSize()
                Spacer()
            }
            .padding(.vertical, DimenKids.margin.medium)
            .modifier(MatchParent())
        }
    }
}

#if DEBUG
struct RelationVodEmpty_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            RelationVodEmpty(
            )
        }
        .frame(width: 200)
        .background(Color.kids.bg)
    }
}
#endif
