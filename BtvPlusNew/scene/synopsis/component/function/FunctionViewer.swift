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
    var componentViewModel:SynopsisViewModel?
    var synopsisData:SynopsisData? = nil
    var synopsisModel:SynopsisModel? = nil
    var purchaseViewerData:PurchaseViewerData? = nil
    var funtionLayout:Axis = .vertical
   
    //var srisId:String?
    //var epsdId:String?
    @Binding var isBookmark:Bool?
    @Binding var isLike:LikeStatus?
     
    @State var isPairing:Bool = false
    var body: some View {
        VStack(alignment:.trailing , spacing:0) {
            if self.isPairing && self.synopsisModel?.isRecommand == true && self.funtionLayout == .horizontal {
                RecommandTip(funtionLayout: self.funtionLayout)
            }
            HStack(alignment: .center, spacing:SystemEnvironment.isTablet ?  Dimen.margin.thinExtra : Dimen.margin.regularUltra){
                if let synopsisData = self.synopsisData {
                    BookMarkButton(
                        componentViewModel: self.componentViewModel,
                        data:synopsisData,
                        isBookmark: self.$isBookmark,
                        isActive: self.synopsisData?.isPosson != true
                    )
                    .buttonStyle(BorderlessButtonStyle())
                    .fixedSize()
                }
                if let srisId = self.synopsisData?.srisId{
                    LikeButton(
                        componentViewModel: self.componentViewModel,
                        srisId: srisId,
                        isLike: self.$isLike
                    ){ ac in
                       
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                BtvButton(isActive: self.synopsisData?.isPosson != true){
                    self.componentViewModel?.uiEvent = .watchBtv
                }
                .buttonStyle(BorderlessButtonStyle())
                .fixedSize()
                if  self.synopsisModel?.isRecommandAble == true , let srisId = self.synopsisData?.srisId {
                    HStack(alignment: .top, spacing:0){
                        ShareButton(
                            componentViewModel: self.componentViewModel,
                            srisId:srisId,
                            epsdId:self.synopsisData?.epsdId,
                            isRecommand: self.isPairing ? self.synopsisModel?.isRecommand : false,
                            isActive: self.synopsisData?.isPosson != true
                        )
                        .buttonStyle(BorderlessButtonStyle())
                        .fixedSize()
                        if self.isPairing &&  self.synopsisModel?.isRecommand == true && self.funtionLayout == .vertical  {
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
                synopsisData:SynopsisData(synopType: .none),
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

