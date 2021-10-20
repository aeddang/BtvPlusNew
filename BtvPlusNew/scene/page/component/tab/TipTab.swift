//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI



struct TipTab: PageComponent{
    var leadingIcon:String? = nil
    var leading:String? = nil
    var strong:String? = nil
   
    var icon:String? = nil
    var strongTrailing:String? = nil
    var trailing:String? = nil
    var isMore:Bool = false
    var textColor:Color = Color.app.white
    var textStrongColor:Color = Color.brand.primary
    var bgColor:Color = Color.app.blueLight
    
    var body: some View {
        ZStack{
            HStack(alignment:.center, spacing:Dimen.margin.micro){
                if let icon = self.leadingIcon {
                    Image(icon).resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: Dimen.icon.regularExtra,
                            height: Dimen.icon.regularExtra)
                }
                if let leading = self.leading {
                    Text(leading)
                        .kerning(Font.kern.medium)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: self.textColor))
                        
                }
                if let strong = self.strong {
                    Text(strong)
                        .kerning(Font.kern.medium)
                        .modifier(BoldTextStyle(size: Font.size.thin, color: self.textStrongColor))
                }
                if let icon = self.icon {
                    if icon == Asset.icon.logoZem {
                        Image(icon).resizable()
                            .renderingMode(.original)
                            .frame(
                                width: Dimen.icon.regular,
                                height: Dimen.icon.regular
                            )
                    } else {
                        Image(icon).resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            /*
                            .frame(
                                minWidth: SystemEnvironment.isTablet ? Dimen.icon.heavy : Dimen.icon.regularExtra,
                                maxWidth: SystemEnvironment.isTablet ? Dimen.icon.heavy : Dimen.icon.heavyExtra,
                                minHeight: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.tinyExtra,
                                maxHeight: SystemEnvironment.isTablet ? Dimen.icon.regular : Dimen.icon.regularExtra
                            )*/
                            .padding(.vertical,  SystemEnvironment.isTablet ?  Dimen.margin.tiny : Dimen.margin.lightExtra)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                }
                if let strong = self.strongTrailing {
                    Text(strong)
                        .kerning(Font.kern.medium)
                        .modifier(BoldTextStyle(size: Font.size.thin, color: self.textStrongColor))
                }
                if let trailing = self.trailing {
                    Text(trailing)
                        .kerning(Font.kern.medium)
                        .modifier(MediumTextStyle(size: Font.size.thin, color: self.textColor))
                }
                if self.isMore {
                    Image(Asset.icon.moreSmall)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.microExtraUltra, height: Dimen.icon.thinExtra)
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


