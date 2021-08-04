//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI




struct SerisTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var data:RelationContentsModel
    @Binding var seris:[SerisData]
    let action: (_ idx:SeasonData) -> Void
    
    @State var textSeason:String? = nil
    @State var textSeasonCount:String = ""
    
    @State var sortType:SerisSortType = .latest
    let sortOption:[SerisSortType] = [
        SerisSortType.latest,
        SerisSortType.count
    ]
    
    enum SelectType :String {
        case sort, season
    }
    
    var body: some View {
        HStack(alignment:.center, spacing: Dimen.margin.thin){
            VStack(alignment: .leading, spacing: 0) {
                Spacer().modifier(MatchHorizontal(height: 0))
                HStack(alignment:.center, spacing: Dimen.margin.thin){
                    if self.textSeason != nil {
                        TextButton(
                            defaultText: self.textSeason!,
                            textModifier: TextModifier(
                                family: Font.family.medium,
                                size: Font.size.regular,
                                color: Color.app.white),
                            image: Asset.icon.dropDown,
                            imageSize: Dimen.icon.tinyExtra){_ in
                            
                            self.appSceneObserver.select =
                                .select((self.tag + SelectType.season.rawValue ,
                                         self.data.seasons.map{$0.title ?? ""}),
                                self.data.currentSeasonIdx)
                            
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    Text(self.textSeasonCount)
                        .modifier(BoldTextStyle(
                            size: Font.size.lightExtra,
                            color: Color.app.white)
                        )
                        .opacity(0.5)
                }
            }
            
            TextButton(
                defaultText: self.sortType.name,
                textModifier: TextModifier(
                    family: Font.family.medium,
                    size: Font.size.lightExtra,
                    color: Color.app.white),
                image: Asset.icon.sortList,
                imageSize: Dimen.icon.thinExtra,
                spacing: Dimen.margin.micro
                ){_ in
                let idx = sortOption.firstIndex(where: {$0 == self.sortType})
                self.appSceneObserver.select =
                    .select((self.tag + SelectType.sort.rawValue , self.sortOption.map{$0.name}), idx ?? -1)
                
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .onReceive(self.appSceneObserver.$selectResult){ result in
            guard let result = result else { return }
            switch result {
                case .complete(let type, let idx) : do {
                    if type.check(key: self.tag + SelectType.sort.rawValue){
                        self.sortType = self.sortOption[idx]
                        self.seris = self.data.getSerisDatas(sort: self.sortType)
                    }
                    else if type.check(key: self.tag + SelectType.season.rawValue){
                        self.textSeason = self.data.seasons[idx].title
                        self.action( self.data.seasons[idx] )
                    }
                }
            }
        }
        .onAppear{
            if self.data.currentSeasonIdx != -1 && self.data.seasons.count > 1 {
                self.textSeason = self.data.seasons[data.currentSeasonIdx].title
            }
            self.textSeasonCount = String.app.total + self.data.seris.count.description + String.pageText.synopsisSiris
            self.sortType = self.data.getCurrentSerisSortType()
        }
    }//body
}



#if DEBUG
struct SerisTab_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SerisTab(
                data:RelationContentsModel(),
                seris: .constant([])
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

