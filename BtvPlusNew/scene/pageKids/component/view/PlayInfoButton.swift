
//
//  Banner.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct PlayInfoButton: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    var data:SummaryViewerData
    var body: some View {
        Button(action: {
            self.pagePresenter.openPopup(
                PageKidsProvider.getPageObject(.detailInfo)
                    .addParam(key: .data, value:
                                DetailInfoData(
                                    subTitle: data.seasonTitle,
                                    title: data.episodeTitle,
                                    text: data.summry ?? ""))
                    
            )
        }) {
            Image(  AssetKids.icon.playInfo)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(
                    width: DimenKids.icon.light,
                    height: DimenKids.icon.light)
        }//btn
        
    }//body
}

#if DEBUG
struct PlayInfoButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            PlayInfoButton(data:SummaryViewerData())
            .environmentObject(Pairing())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }
    }
}
#endif

