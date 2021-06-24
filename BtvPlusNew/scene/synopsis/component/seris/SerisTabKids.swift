//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI




struct SerisTabKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var data:RelationContentsModel
    @Binding var seris:[SerisData]
    let action: (_ idx:SeasonData) -> Void
    
    @State var textSeason:String? = nil
    @State var textSeasonCount:String = ""
    
    @State var sortIdx:Int = 0
    let sortOption:[SerisSortType] = [
        SerisSortType.latest,
        SerisSortType.count
    ]
    
    var body: some View {
        VStack(alignment:.center, spacing: 0){
            Text(self.textSeasonCount)
                .modifier(BoldTextStyleKids(
                    size: Font.sizeKids.lightExtra,
                    color: Color.app.sepia)
                )
            if let textSeason = self.textSeason {
                SortButtonKids(text: textSeason){
                    self.appSceneObserver.select =
                        .select((self.tag  ,
                                 self.data.seasons.map{$0.title ?? ""}),
                                self.data.currentSeasonIdx){ idx in
                            
                            self.textSeason = self.data.seasons[idx].title
                            self.action( self.data.seasons[idx] )
                        }
                }
            }
            TabSwitch(
                tabs: self.sortOption.map{$0.nameKids},
                selectedIdx: self.sortIdx,
                fontSize: Font.sizeKids.tinyExtra,
                bgColor: Color.kids.bg,
                useCheck: false
            ){ idx in
                
                self.sortIdx = idx
                self.seris = self.data.getSerisDatas(sort: self.sortOption[idx])
            }
            .frame(width: SystemEnvironment.isTablet ? 194 : 130)
            .padding(.top, SystemEnvironment.isTablet ? DimenKids.margin.thinUltra : DimenKids.margin.light)
            
        }
        .onAppear{
            if self.data.currentSeasonIdx != -1 && self.data.seasons.count > 1 {
                self.textSeason = self.data.seasons[data.currentSeasonIdx].title
            }
            self.textSeasonCount = String.app.total + self.data.seris.count.description + String.pageText.synopsisSiris
            self.sortIdx = self.sortOption.firstIndex(of: self.data.serisSortType) ?? 0
        }
    }//body
}



#if DEBUG
struct SerisTabKids_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SerisTabKids(
                data:RelationContentsModel(),
                seris: .constant([])
            ){ _ in
                
            }
            .environmentObject(PagePresenter())
        }
    }
}
#endif

