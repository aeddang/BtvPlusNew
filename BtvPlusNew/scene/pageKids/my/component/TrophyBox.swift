//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

struct TrophyBox: PageComponent{
    var trophyText:String? = nil
    var title:String? = nil
    var subTitle:String? = nil
    
    var body: some View {
        VStack(spacing: DimenKids.margin.tinyExtra){
            ZStack{
                Image(AssetKids.icon.trophy)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                    .frame(height: SystemEnvironment.isTablet ? 145 : 81)
                if let trophyText = self.trophyText {
                    Text(trophyText)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.regular,
                                    color:  Color.app.white))
                }
            }
            if let title = self.title {
                Text(title)
                    .modifier(BoldTextStyleKids(
                        size: SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.thin,
                                color:  Color.app.brownDeep))
            }
            
            if let subTitle = self.subTitle {
                Text(subTitle)
                    .modifier(BoldTextStyleKids(
                                size:  SystemEnvironment.isTablet ? Font.sizeKids.tiny : Font.sizeKids.thin,
                                color:  Color.app.sepia))
            }
            
        }
    }
}

#if DEBUG
struct TrophyBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            TrophyBox()
        }
    }
}
#endif
