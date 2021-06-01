//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI



struct TipTab: PageComponent{
    var leading:String? = nil
    var icon:String? = nil
    var trailing:String? = nil
    var isMore:Bool = false
    var textColor:Color = Color.app.greyLight
    var bgColor:Color = Color.app.blueLight
    
    var body: some View {
        ZStack{
            HStack(alignment:.center, spacing:Dimen.margin.micro){
                if let leading = self.leading {
                    Text(leading)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: self.textColor))
                }
                if let icon = self.icon {
                    Image(icon).resizable()
                        .renderingMode(.original).aspectRatio(contentMode: .fit)
                        .frame(height:Dimen.icon.tinyExtra)
                }
                if let trailing = self.trailing {
                    Text(trailing)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: self.textColor))
                }
                if self.isMore {
                    Image(Asset.icon.more)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
                }
            }
            .padding(.horizontal, Dimen.margin.micro)
        }

        .modifier( MatchHorizontal(height: Dimen.button.regularExtra) )
        .background(self.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.heavy))

    }
}

#if DEBUG
struct TipTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            TipTab(leading: "title")
                .environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif


