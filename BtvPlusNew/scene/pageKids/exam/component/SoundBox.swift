//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

extension SoundBox {
    static let size:CGSize = SystemEnvironment.isTablet ? CGSize(width: 218, height: 100) : CGSize(width: 124, height: 60)

}

struct SoundBox: PageComponent{
    var isPlay:Bool = false
    var body: some View {
        ZStack(alignment: .leading){
            Image( AssetKids.exam.listenBg)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .modifier(MatchParent())
            HStack( spacing: DimenKids.margin.tiny ){
                Image( AssetKids.exam.sound)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: DimenKids.icon.regular,
                        height: DimenKids.icon.regular)
                    .opacity(self.isPlay ? 1.0 : 0.7)
                Text(self.isPlay
                        ? String.kidsText.kidsExamListen
                        : String.kidsText.kidsExamRepeat)
                    .kerning(Font.kern.thin)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.thin,
                            color:  Color.app.brownDeep))
            }
            .padding(.leading, DimenKids.margin.tiny)
            .padding(.bottom, DimenKids.margin.thin)
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }
}

#if DEBUG
struct SoundBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SoundBox(
               isPlay: true
            )
        }
    }
}
#endif
