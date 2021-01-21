//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct SrisViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    var synopsisData:SynopsisData? = nil
    var srisId:String?
    @Binding var isHeart:Bool?
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            HStack(spacing:Dimen.margin.regular){
                if self.synopsisData != nil{
                    BookMarkButton(
                        data:self.synopsisData!,
                        isHeart: self.$isHeart
                    ){ ac in
                       
                    }
                }
                if self.srisId != nil{
                    LikeButton(
                        srisId: self.srisId!
                    ){ ac in
                       
                    }
                }
                BtvButton(
                    id:""
                )
                ShareButton(
                    id:""
                )
            }
            .padding(.vertical, Dimen.margin.regular)
            Spacer().modifier(LineHorizontal())
            
        }
        .modifier(ContentHorizontalEdges())
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct SrisViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SrisViewer(
                synopsisData:SynopsisData(),
                isHeart: .constant(false)
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.blue)
    }
}
#endif

