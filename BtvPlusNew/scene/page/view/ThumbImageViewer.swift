//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct ThumbImageViewer: PageView{
    var imgBg:String? = nil
    var contentMode:ContentMode = .fit
    var body: some View {
        ZStack{
            if self.contentMode == .fit {
                if let bg = self.imgBg  {
                    ImageView(url:ImagePath.thumbImagePath(filePath: bg, size: CGSize(width: 240, height: 0), convType: .blur) ?? "",
                              contentMode: .fill, noImg: Asset.noImg16_9)
                        .modifier(MatchParent())
                        .blur(radius: 4)
                        
                }
                Spacer().modifier(MatchParent()).background(Color.transparent.black45)
                if let bg = self.imgBg {
                    ImageView(url:ImagePath.thumbImagePath(filePath: bg, size: CGSize(width: 90, height: 0), convType: .none) ?? "",
                                        contentMode: .fit, noImg: Asset.noImg9_16)
                        .modifier(MatchParent())
                        .padding(.all, Dimen.margin.heavyExtra)
                }
            }else{
                if let bg = self.imgBg {
                    ImageView(url:ImagePath.thumbImagePath(filePath: bg, size: CGSize(width: 240, height: 0), convType: .none) ?? "",
                              contentMode: .fill, noImg: Asset.noImg16_9)
                        .modifier(MatchParent())
                        
                }
                Spacer().modifier(MatchParent()).background(Color.transparent.black45)
            }
        }
        .modifier(MatchParent())
        .clipped()
       
    }//body
}



#if DEBUG
struct ThumbImageViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ThumbImageViewer(
               
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif
