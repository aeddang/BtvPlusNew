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
    @Binding var title:String?
    var isBack:Bool = false
    var isClose:Bool = false
        
    var body: some View {
        ZStack(alignment: .leading){
            if self.title != nil {
                Text(self.title!)
                    .modifier(BoldTextStyle(size: Font.size.mediumExtra, color: Color.app.white))
                    .modifier(ContentHorizontalEdges())
                    .frame(maxWidth: .infinity)
            }
            HStack{
                if self.isBack {
                    Button(action: {
                        self.pagePresenter.goBack()
                        
                    }) {
                        Image(Asset.icon.back)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                }
                Spacer()
                if self.isClose {
                    Button(action: {
                        self.pagePresenter.goBack()
                        
                    }) {
                        Image(Asset.icon.close)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                }
            }
            .padding(.horizontal, Dimen.margin.tiny)
            
        }
        .modifier(MatchHorizontal(height: Dimen.app.pageTop))
    }
}

#if DEBUG
struct PageTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            PageTab(title:.constant("title")).environmentObject(PagePresenter()).frame(width:320,height:100)
                .background(Color.app.blue)
        }
    }
}
#endif
