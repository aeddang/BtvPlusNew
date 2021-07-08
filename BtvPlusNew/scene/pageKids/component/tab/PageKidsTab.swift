//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI



struct PageKidsTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var title:String? = nil
    var isBack:Bool = false
    var isClose:Bool = false
    var isSetting:Bool = false
    var style:PageStyle = .kidsWhite
    var close: (() -> Void)? = nil
    var body: some View {
        ZStack(alignment: .leading){
            if self.title != nil {
                Text(self.title!)
                    .modifier(BoldTextStyleKids(
                                size: SystemEnvironment.isTablet ?  Font.sizeKids.light : Font.sizeKids.regular,
                                color: self.style.textColor))
                    .lineLimit(1)
                    .padding(.horizontal, DimenKids.icon.mediumExtra)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 1)
                    
            }
            HStack{
                if self.isBack {
                    Button(action: {
                        self.pagePresenter.goBack()
                    }) {
                        Image(AssetKids.icon.backTop)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.mediumExtra,
                                   height: DimenKids.icon.mediumExtra)
                    }
                }
                Spacer()
                
                if self.isSetting {
                    Button(action: {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.setup)
                        )
                    }) {
                        Image(AssetKids.icon.setting)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .colorMultiply(self.style.textColor)
                            .frame(width: DimenKids.icon.mediumExtra,
                                   height: DimenKids.icon.mediumExtra)
                    }
                }
                if self.isClose {
                    Button(action: {
                        if let close = self.close{
                            close()
                        } else {
                            self.pagePresenter.goBack()
                        }
                    }) {
                        Image(AssetKids.icon.close)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.regularUltra,
                                   height: DimenKids.icon.regularUltra)
                    }
                }
            }
        }
        .modifier(ContentHorizontalEdgesKids())
        .modifier(MatchHorizontal(height: DimenKids.app.pageTop))
        .background(self.style.bgColor)
    }
}

#if DEBUG
struct PageKidsTab_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            PageKidsTab(
                title: "title",
                isBack: true
                )
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
        }
        .background(Color.kids.bg)
    }
}
#endif
