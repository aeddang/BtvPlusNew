//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI





struct TopSynopsisViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
   
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            Text(String.pageText.pairingText1)
                .modifier(BoldTextStyle( size: Font.size.boldExtra ))
                .lineLimit(2)
                .padding(.top, Dimen.margin.regularExtra)
            HStack(spacing:Dimen.margin.tiny){
                RatingInfo(
                    rating: 32.123
                )
                .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: false)
                RatingPoint(
                    rating: 3.123
                )
                Text("19.08.29")
                    .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                Image( Asset.icon.age19 )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                Text("132분")
                    .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                Text("tvN")
                    .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
            }
            .padding(.top, Dimen.margin.lightExtra)
            
            HStack(spacing:Dimen.margin.tinyExtra){
                Image( Asset.icon.trophy )
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                Text("제 72회 칸영화제 황금종료상 수상 ")
                    .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                
            }
            .padding(.top, Dimen.margin.lightExtra)
            
            HStack(spacing:Dimen.margin.regular){
                HeartButton(
                    id:"",
                    isHeart:.constant(true)
                ){ ac in
                    
                }
                LikeButton(
                    id:"",
                    isLike:.constant(true)
                ){ ac in
                    
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
            
        }.modifier(ContentHorizontalEdges())
    }//body
}



#if DEBUG
struct TopSynopsisViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            TopSynopsisViewer()
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter()).modifier(MatchParent())
            .environmentObject(PageSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.blue)
    }
}
#endif

