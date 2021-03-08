//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PageFullPlayer: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false)
    @State var isInit:Bool = false
    var body: some View {
        BtvPlayer(
            pageObservable:self.pageObservable,
            viewModel:self.playerModel
        )
        
        .modifier(PageFull())
        .onReceive(self.playerModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .fullScreen(let isFullScreen) :
                if isFullScreen { return }
                self.playerModel.event = .pause
                self.pagePresenter.closePopup(self.pageObject?.id)
            default : break
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            if !isInit {return}
            switch self.sceneObserver.sceneOrientation {
            case .portrait : self.pagePresenter.closePopup(self.pageObject?.id)
            default : break
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                if let obj = self.pageObject  {
                    if let data = obj.getParamValue(key: .data) as? PlayInfo {
                        let type = obj.getParamValue(key: .type) as? BtvPlayType ?? .preview("")
                        let autoPlay = obj.getParamValue(key: .autoPlay) as? Bool
                        let initTime = obj.getParamValue(key: .initTime) as? Double ?? 0
                        self.playerModel.setData(data: data, type: type, autoPlay: autoPlay)
                        
                    }
                }
                self.isInit = true
            }
        }
        .onAppear{
           
        }
        .onDisappear{
           
        }
       
    }//body
   
    
}



