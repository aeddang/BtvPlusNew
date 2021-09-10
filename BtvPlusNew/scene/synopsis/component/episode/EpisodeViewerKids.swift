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
            if let seasonTitle = episodeViewerData.seasonTitle {
                Text(seasonTitle)
                    .modifier(BoldTextStyleKids(
                        size: Font.sizeKids.tinyExtra,
                        color: Color.app.sepia.opacity(0.6)))
            }
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
                    .lineLimit(1)
                  
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
                                EpisodeViewerKidsBody(
                                    data: data
                                )
                                if data.infoTip != nil {
                                    EpisodeViewerKidsTip(
                                        data: data,
                                        showInfo: self.$showInfo
                                    )
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

struct EpisodeViewerKidsBody: PageComponent{
    var data:PurchaseViewerData
    
    var body: some View {
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
        if let sub = self.data.infoTrailingSub {
            Text(sub)
                .modifier(MediumTextStyleKids(size: Font.sizeKids.thin, color: Color.app.sepia))
                .lineLimit(1)
        }
    }

}

struct EpisodeViewerKidsTip: PageComponent{
    var data:PurchaseViewerData
    @Binding var showInfo:Bool
    var body: some View {
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

