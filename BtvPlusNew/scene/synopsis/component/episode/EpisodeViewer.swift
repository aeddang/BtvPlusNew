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
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    var data:EpisodeViewerData 
    var isSimple:Bool = false
    
    @State var ratingPct:Double? = nil
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            Spacer().modifier(MatchHorizontal(height: 0))
            HStack(alignment: .center, spacing: SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin){
                if let ratingPct = self.ratingPct {
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
                if !self.isSimple {
                    if self.data.date?.isEmpty == false, let date = self.data.date {
                        Text( date )
                            .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                            .opacity(0.8)
                    }else if self.data.serviceYear?.isEmpty == false, let serviceYear = self.data.serviceYear {
                        Text( serviceYear )
                            .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                            .opacity(0.8)
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
                            .opacity(0.8)
                        }
                    if let provider = self.data.provider {
                        Text( provider )
                            .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                            .opacity(0.8)
                        }
                    if let onair = self.data.onAir {
                        Image( onair )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(height: Dimen.icon.thin)
                    }
                }
                
            }
            if self.data.award != nil {
                Button(action: {
                    self.appSceneObserver.alert = .alert(String.pageText.synopsisAward, self.data.awardDetail)
                }) {
                    HStack(spacing:Dimen.margin.tinyExtra){
                        Image( Asset.icon.trophy )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                        Text(self.data.award!)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyMedium))
                        
                    }
                    .padding(.top, Dimen.margin.thinExtra)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
        }
        .modifier(ContentHorizontalEdges())
        .onReceive(self.dataProvider.$result){ res in
            guard let srisId = self.data.srisId else { return }
            guard let res = res else { return }
            if !res.id.hasPrefix(srisId) { return }
            switch res.type {
            case .getLike:
                guard let data = res.data as? Like else { return }
                guard let like = data.like_total?.toDouble() else { return }
                guard let dislike = data.dislike_total?.toDouble() else { return }
                self.data.likeCountTotal = like
                self.data.disLikeCountTotal = dislike
                self.updateRate(changeLike: 0, changeDislike: 0)

            case .registLike(_, _ , _, let changeLike, let changeDislike):
                self.updateRate(changeLike: changeLike, changeDislike: changeDislike)
        
               
            default: break
            }
            
        }
        .onAppear{
            self.ratingPct = self.data.ratingPct
        }
    }//body
    
    private func updateRate(changeLike:Int, changeDislike:Int){
        guard let like = self.data.likeCountTotal else { return }
        guard let dislike = self.data.disLikeCountTotal else { return }
        let total = like + dislike + Double(changeLike + changeDislike)
        if total == 0 {
            self.ratingPct = nil
            return
        }
        self.data.likeCountTotal! += Double(changeLike)
        self.data.disLikeCountTotal! += Double(changeDislike)
        let clike = like + Double(changeLike)
        self.ratingPct = clike / total * 100
    }
    
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

