//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


struct EpisodeViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var data:EpisodeViewerData 
    
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            
            HStack(alignment: .center, spacing:Dimen.margin.tiny){
                if let ratingPct = self.data.ratingPct {
                    RatingInfo(
                        rating: ratingPct
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
                if let ratingPoint = self.data.ratingPoint {
                    RatingPoint(
                        rating: ratingPoint, ratingMax: self.data.ratingMax!
                    )
                }
                
                if let date = self.data.date {
                    Text( date )
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    }
                if let restrictAgeIcon = self.data.restrictAgeIcon {
                    Image( restrictAgeIcon )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                    }
                if let duration = self.data.duration {
                    Text(duration)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    }
                if let provider = self.data.provider {
                    Text( provider )
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    }
                if let onair = self.data.onAir {
                    Image( onair )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(height: Dimen.icon.thin)
                }
            }
            if self.data.award != nil {
                Button(action: {
                    self.appSceneObserver.alert = .alert(nil, self.data.awardDetail)
                }) {
                    HStack(spacing:Dimen.margin.tinyExtra){
                        Image( Asset.icon.trophy )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                        Text(self.data.award!)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                        
                    }
                    .padding(.top, Dimen.margin.lightExtra)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .modifier(ContentHorizontalEdges())
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct EpisodeViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            EpisodeViewer(
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

