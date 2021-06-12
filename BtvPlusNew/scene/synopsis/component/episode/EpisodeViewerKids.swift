//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


struct EpisodeViewerKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var data:EpisodeViewerData
    var purchaseViewerData:PurchaseViewerData?
    var body: some View {
        VStack(alignment:.leading , spacing:DimenKids.margin.thinExtra) {
            HStack(alignment: .center, spacing:DimenKids.margin.micro){
                if let restrictAgeIcon = self.data.restrictAgeIconKids {
                    Image( restrictAgeIcon )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.thinExtra, height: DimenKids.icon.thinExtra)
                }
                Text(data.episodeTitleKids)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regularExtra,
                                color: Color.app.brownDeep
                        ))
                    .lineLimit(2)
                  
            }
            HStack(alignment: .center, spacing:Dimen.margin.tiny){
                if let duration = self.data.duration {
                    Text(duration)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                    }
                if let info = self.purchaseViewerData?.serviceInfo {
                    Text(" | " + info)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                    }
            }
           
        }
        .modifier(ContentHorizontalEdges())
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct EpisodeViewerKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            EpisodeViewerKids(
                data:EpisodeViewerData()
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.blue)
    }
}
#endif

