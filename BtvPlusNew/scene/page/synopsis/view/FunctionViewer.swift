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
    @Binding var isBookmark:Bool?
    @Binding var isLike:LikeStatus?
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            HStack(spacing:Dimen.margin.regular){
                if self.synopsisData != nil{
                    BookMarkButton(
                        data:self.synopsisData!,
                        isBookmark: self.$isBookmark
                    ){ ac in
                       
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                if self.srisId != nil{
                    LikeButton(
                        srisId: self.srisId!,
                        isLike: self.$isLike
                    ){ ac in
                       
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                BtvButton(
                    id:""
                )
                .buttonStyle(BorderlessButtonStyle())
                ShareButton(
                    id:""
                )
                .buttonStyle(BorderlessButtonStyle())
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

