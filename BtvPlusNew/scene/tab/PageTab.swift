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
    var body: some View {
        HStack(alignment: .center ,spacing:0){
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
            if self.title != nil {
                Spacer()
                Text(self.title!)
                    .modifier(BoldTextStyle(size: Font.size.mediumExtra, color: Color.app.white))
                    .modifier(ContentHorizontalEdges())
            }
            Spacer()
            
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
