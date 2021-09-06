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
    @EnvironmentObject var pairing:Pairing
    var componentViewModel:PageSynopsis.ComponentViewModel
    var synopsisData:SynopsisData? = nil
    var funtionLayout:Axis = .vertical
    
    //var srisId:String?
    //var epsdId:String?
    @Binding var isBookmark:Bool?
    @Binding var isLike:LikeStatus?
    var isRecommandAble:Bool
    var isRecommand:Bool?
    
    @State var isPairing:Bool = false
    var body: some View {
        VStack(alignment:.trailing , spacing:0) {
            if self.isPairing && self.isRecommand == true && self.funtionLayout == .horizontal {
                RecommandTip(funtionLayout: self.funtionLayout)
            }
            HStack(alignment: .center, spacing:SystemEnvironment.isTablet ?  Dimen.margin.thinExtra : Dimen.margin.regularUltra){
                if let synopsisData = self.synopsisData {
                    BookMarkButton(
                        data:synopsisData,
                        isBookmark: self.$isBookmark
                    )
                    .buttonStyle(BorderlessButtonStyle())
                    .fixedSize()
                }
                if let srisId = self.synopsisData?.srisId{
                    LikeButton(
                        srisId: srisId,
                        isLike: self.$isLike
                    ){ ac in
                       
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                BtvButton(){
                    self.componentViewModel.uiEvent = .watchBtv
                }
                .buttonStyle(BorderlessButtonStyle())
                .fixedSize()
                if self.isRecommandAble, let srisId = self.synopsisData?.srisId{
                    HStack(alignment: .top, spacing:0){
                        ShareButton(
                            srisId:srisId,
                            epsdId:self.synopsisData?.epsdId,
                            isRecommand: self.isPairing ? self.isRecommand : false
                        )
                        .buttonStyle(BorderlessButtonStyle())
                        .fixedSize()
                        if self.isPairing && self.isRecommand == true && self.funtionLayout == .vertical  {
                            RecommandTip(funtionLayout: self.funtionLayout)
                        }
                    }
                }
            }
        }
        .onReceive(self.pairing.$status) { status in
            self.isPairing = status == .pairing
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
                componentViewModel: .init(),
                synopsisData:SynopsisData(),
                isBookmark: .constant(false),
                isLike: .constant(.unlike), isRecommandAble: true
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.blue)
    }
}
#endif

