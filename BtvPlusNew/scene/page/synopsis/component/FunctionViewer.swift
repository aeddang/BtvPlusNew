//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct FunctionViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var synopsisData:SynopsisData? = nil
    var srisId:String?
    var epsdId:String?
    @Binding var isBookmark:Bool?
    @Binding var isLike:LikeStatus?
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            HStack(spacing:Dimen.margin.regular){
                if let synopsisData = self.synopsisData {
                    BookMarkButton(
                        data:synopsisData,
                        isBookmark: self.$isBookmark
                    )
                    .buttonStyle(BorderlessButtonStyle())
                }
                if let srisId = self.srisId{
                    LikeButton(
                        srisId: srisId,
                        isLike: self.$isLike
                    ){ ac in
                       
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                BtvButton(
                    id:""
                )
                .buttonStyle(BorderlessButtonStyle())
                if let srisId = self.srisId{
                    ShareButton(
                        srisId:srisId,
                        epsdId:self.epsdId
                    )
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .modifier(ContentHorizontalEdges())
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct FunctionViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            FunctionViewer(
                synopsisData:SynopsisData(),
                isBookmark: .constant(false),
                isLike: .constant(.unlike)
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.blue)
    }
}
#endif

