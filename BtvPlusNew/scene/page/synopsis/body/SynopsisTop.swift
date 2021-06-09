//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct SynopsisTop: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel()
    var playerListViewModel: InfinityScrollModel = InfinityScrollModel()
    var prerollModel = PrerollModel()
    var playGradeData: PlayGradeData? = nil;
    var title:String? = nil
    var imgBg:String? = nil
    var imgContentMode:ContentMode = .fit
    var textInfo:String? = nil
    var epsdId:String? = nil
    var playListData:PlayListData = PlayListData()
    var isPlayAble:Bool = false
    var isPlayViewActive = false
  
    var body: some View {
        ZStack {
            KidsPlayer(
                pageObservable:self.pageObservable,
                viewModel:self.playerModel,
                prerollModel:self.prerollModel,
                listViewModel: self.playerListViewModel,
                playGradeData: self.playGradeData,
                title: self.title,
                thumbImage: self.imgBg,
                thumbContentMode: self.imgContentMode,
                contentID:self.epsdId,
                listData: self.playListData
            )
            if !self.isPlayAble {
                PlayViewer(
                    pageObservable:self.pageObservable,
                    title: self.title,
                    textInfo: self.textInfo,
                    imgBg: self.isPlayViewActive ? self.imgBg : nil,
                    contentMode: self.imgContentMode,
                    isActive: self.isPlayViewActive
                )
                
            }
        }
    }//body
}



#if DEBUG
struct SynopsisTop_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SynopsisTop(
                
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

