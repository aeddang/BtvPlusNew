//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

extension PlayerListTab {
    static let padding = Dimen.margin.regular
}

struct PlayerListTab: PageView{
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
                Image(Asset.icon.close)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            .padding(.all, PlayerUI.paddingFullScreen)
            Spacer().modifier(MatchParent())
            VStack(alignment :.leading, spacing:Dimen.margin.regular){
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
            .padding(.horizontal, PlayerUI.paddingFullScreen + Self.padding)
            .padding(.bottom, self.listOffset + Dimen.margin.tiny)
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
