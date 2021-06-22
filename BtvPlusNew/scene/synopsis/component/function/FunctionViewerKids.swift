//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct FunctionViewerKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var componentViewModel:PageSynopsis.ComponentViewModel
    var synopsisData:SynopsisData? = nil
    var summaryViewerData:SummaryViewerData? = nil
    @Binding var isBookmark:Bool?
   
    var body: some View {
        ZStack{
            if SystemEnvironment.isTablet {
                HStack(alignment:.center , spacing:DimenKids.margin.regularExtra) {
                    FunctionViewerKidsBody(
                        componentViewModel: self.componentViewModel,
                        synopsisData: self.synopsisData,
                        summaryViewerData:self.summaryViewerData,
                        isBookmark: self.$isBookmark)
                }
            } else {
                VStack(alignment:.center , spacing:DimenKids.margin.regularExtra) {
                    FunctionViewerKidsBody(
                        componentViewModel: self.componentViewModel,
                        synopsisData: self.synopsisData,
                        summaryViewerData:self.summaryViewerData,
                        isBookmark: self.$isBookmark)
                }
            }
        }
        .onAppear{
            
        }
    }//body
}

struct FunctionViewerKidsBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var componentViewModel:PageSynopsis.ComponentViewModel
    var synopsisData:SynopsisData? = nil
    var summaryViewerData:SummaryViewerData? = nil
    @Binding var isBookmark:Bool?
   
    var body: some View {
        if let data = summaryViewerData {
            PlayInfoButton(data: data)
            .buttonStyle(BorderlessButtonStyle())
        }
        BtvButton(type: .kids){
            self.componentViewModel.uiEvent = .watchBtv
        }
        .buttonStyle(BorderlessButtonStyle())
        if let synopsisData = self.synopsisData {
            BookMarkButton(
                type: .kids,
                data:synopsisData,
                isBookmark: self.$isBookmark
            )
            .buttonStyle(BorderlessButtonStyle())
        }
        
        
        if let srisId = self.synopsisData?.srisId{
            ShareButton(
                type: .kids,
                srisId:srisId,
                epsdId:self.synopsisData?.epsdId
            )
            .buttonStyle(BorderlessButtonStyle())
        }
    }//body
}


#if DEBUG
struct FunctionViewerKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            FunctionViewerKids(
                componentViewModel: .init(),
                synopsisData:SynopsisData(),
                isBookmark: .constant(false)
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.blue)
    }
}
#endif

