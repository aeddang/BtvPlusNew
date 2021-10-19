//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI



struct PageTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var title:String? = nil
    var isBack:Bool = false
    var isClose:Bool = false
    var isSetting:Bool = false
    var style:PageStyle = .normal
    var close: (() -> Void)? = nil
    var body: some View {
        ZStack(alignment: .leading){
            if let title = self.title {
                Text(title)
                    .modifier(BoldTextStyle(
                                size: SystemEnvironment.isTablet ?  Font.size.light : Font.size.mediumExtra,
                                color: self.style.textColor))
                    .lineLimit(1)
                    .modifier(ContentHorizontalEdges())
                    .frame(maxWidth: .infinity)
                    .padding(.top, 1)
                    .padding(.horizontal, Dimen.icon.regular)
            }
            HStack{
                if self.isBack {
                    Button(action: {
                        if let close = self.close{
                            close()
                        } else {
                            self.pagePresenter.goBack()
                        }
                    }) {
                        Image(Asset.icon.back)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .colorMultiply(self.style.textColor)
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                    .accessibility(label: Text( String.app.back))
                }
                Spacer()
                if self.isClose {
                    Button(action: {
                        if let close = self.close{
                            close()
                        } else {
                            self.pagePresenter.goBack()
                        }
                    }) {
                        Image(Asset.icon.close)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .colorMultiply(self.style.textColor)
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                    .accessibility(label: Text( String.app.close))
                }
                if self.isSetting {
                    Button(action: {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.setup)
                        )
                    }) {
                        Image(Asset.icon.setting)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .colorMultiply(self.style.textColor)
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                    .accessibility(label: Text( String.app.setup))
                }
            }
            .padding(.horizontal, Dimen.margin.tiny)
            
        }
        .modifier(MatchHorizontal(height: Dimen.app.pageTop))
        .background(self.style.bgColor)
    }
}

#if DEBUG
struct PageTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            PageTab(title: "title")
                .environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
