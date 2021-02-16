//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct PlayerListTab: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var listTitle:String? = nil
    var title:String? = nil
    var listOffset:CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottom){
            Spacer().modifier(MatchParent())
            VStack(alignment :.leading, spacing:Dimen.margin.thinExtra){
                Spacer().modifier(MatchHorizontal(height: 0))
                if self.listTitle != nil {
                    Text(self.listTitle!)
                        .modifier(BoldTextStyle(size: Font.size.mediumExtra, color: Color.app.white))
                }
                if self.title != nil {
                    Text(self.title!)
                        .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                }
            }
            .padding(.horizontal, PlayerUI.paddingFullScreen + Dimen.margin.regular)
            .padding(.bottom, self.listOffset + Dimen.margin.thin)
        }
        .modifier(MatchParent())
        .background(Color.transparent.black50)
        
    }//body
}


#if DEBUG
struct PlayerListTab_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerListTab(
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
