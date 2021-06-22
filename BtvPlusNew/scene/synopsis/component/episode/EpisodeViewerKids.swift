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
    var episodeViewerData:EpisodeViewerData
    var purchaseViewerData:PurchaseViewerData?
    @State var showInfo:Bool = false
    
    var body: some View { 
        VStack(alignment:.leading , spacing:DimenKids.margin.thinExtra) {
            HStack(alignment: .center, spacing:DimenKids.margin.micro){
                if let restrictAgeIcon = self.episodeViewerData.restrictAgeIconKids {
                    Image( restrictAgeIcon )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.thinExtra, height: DimenKids.icon.thinExtra)
                }
                Text(episodeViewerData.episodeTitleKids)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regularExtra,
                                color: Color.app.brownDeep
                        ))
                    .lineLimit(2)
                  
            }
            if let data = self.purchaseViewerData {
                if let info = data.serviceInfoDesc {
                    Text(info)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                        .lineLimit(1)
                } else {
                    HStack(alignment: .center, spacing:Dimen.margin.tiny){
                        if let duration = self.episodeViewerData.duration {
                            Text(duration)
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                        }
                        
                        if data.isInfo {
                            Text("|")
                                .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                            
                            HStack(spacing:Dimen.margin.thinExtra){
                                if data.infoIcon != nil {
                                    Image( data.infoIcon! )
                                        .renderingMode(.original).resizable()
                                        .scaledToFit()
                                        .frame(width: DimenKids.icon.light)
                                }
                                if data.infoLeading != nil && data.infoTrailing != nil{
                                    Text(data.infoLeading!)
                                        .font(.custom(Font.familyKids.bold, size: Font.sizeKids.thinExtra))
                                        .foregroundColor(Color.app.sepia)
                                    + Text(data.infoTrailing!)
                                        .font(.custom(Font.familyKids.bold, size: Font.sizeKids.thinExtra))
                                        .foregroundColor(Color.app.sepia)
                                }
                                else if data.infoLeading != nil {
                                    Text(data.infoLeading!)
                                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                                        .lineLimit(1)
                                        
                                }
                                else if data.infoTrailing != nil {
                                    Text(data.infoTrailing!)
                                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thinExtra, color: Color.app.sepia))
                                        .lineLimit(1)
                                }
                                if data.infoTip != nil {
                                    HStack(spacing:Dimen.margin.tiny){
                                        Button(action: {
                                            withAnimation { self.showInfo.toggle() }
                                        }){
                                            Image( AssetKids.icon.info )
                                                .renderingMode(.original).resizable()
                                                .scaledToFit()
                                                .frame(width: DimenKids.icon.tinyExtra, height: DimenKids.icon.tinyExtra)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        TooltipKids(
                                            title: data.infoLeading,
                                            text: data.infoTip
                                        )
                                        .opacity( self.showInfo ? 1.0 : 0)
                                    }
                                    .frame(height:DimenKids.icon.tinyExtra)
                                    
                                }
                            }
                        }//info
                    }
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
                episodeViewerData:EpisodeViewerData()
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.blue)
    }
}
#endif
