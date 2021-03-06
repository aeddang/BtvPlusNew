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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    
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
                self.onClose()
            default : break
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            if !isInit {return}
            switch self.sceneObserver.sceneOrientation {
            case .portrait :
                self.onClose()
            default : break
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                if let obj = self.pageObject  {
                    if let data = obj.getParamValue(key: .data) as? PlayInfo {
                        let type = obj.getParamValue(key: .type) as? BtvPlayType ?? .preview("")
                        let autoPlay = obj.getParamValue(key: .autoPlay) as? Bool
                        let initTime = obj.getParamValue(key: .initTime) as? Double
                        self.playerModel.setData(data: data, type: type, autoPlay: autoPlay, continuousTime: initTime)
                        
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
   
    private func onClose(){
        self.playerModel.event = .pause
        PageLog.d("play time " +  self.playerModel.time.description, tag:self.tag)
        self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .timeChange, data: self.playerModel.time))
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
    
}



