//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

extension PlayerListTabKids {
    static let padding = DimenKids.margin.medium
}

struct PlayerListTabKids: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var listTitle:String? = nil
    var title:String? = nil
    var listOffset:CGFloat = 0
    var body: some View {
        VStack(alignment: .trailing){
            Button(action: {
                self.viewModel.btvUiEvent = .closeList
                
            }) {
                Image(AssetKids.player.close)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: KidsPlayerUI.iconFullScreen.width ,
                        height: KidsPlayerUI.iconFullScreen.height )
            }
            .padding(.all, KidsPlayerUI.paddingFullScreen)
            Spacer().modifier(MatchParent())
            VStack(alignment :.leading, spacing:DimenKids.margin.tiny){
                Spacer().modifier(MatchHorizontal(height: 0))
                if self.listTitle != nil {
                    Text(self.listTitle!)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.white))
                }
                if self.title != nil {
                    Text(self.title!)
                        .modifier(MediumTextStyleKids(size: Font.sizeKids.regular, color: Color.app.white))
                }
            }
            .padding(.horizontal, KidsPlayerUI.paddingFullScreen + Self.padding)
            .padding(.bottom, self.listOffset + DimenKids.margin.tiny)
        }
        .modifier(MatchParent())
        .background(Color.transparent.black50)
        
    }//body
}


#if DEBUG
struct PlayerListTabKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerListTabKids(
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
