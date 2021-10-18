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
        SimplePlayer(
            pageObservable:self.pageObservable,
            viewModel:self.playerModel
        )
        .modifier(PageFullScreen(style: .dark))
        .onReceive(self.playerModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .fullScreen(let isFullScreen, _) :
                if isFullScreen { return }
                self.onClose()
            default : break
            }
        }
        .onReceive(self.playerModel.$btvPlayerEvent){evt in
            guard let evt = evt else { return }
            switch evt {
            case .close : self.onClose()
            default : break
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            if !isInit {return}
            if SystemEnvironment.isTablet {return}
            switch self.sceneObserver.sceneOrientation {
            case .portrait :
                self.onClose()
            default : break
            }
        }
        .onReceive(self.playerModel.$streamEvent){evt in
            guard let evt = evt else { return }
            switch evt {
            case .completed:self.onClose()
            default: break
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                if self.isInit {return}
                DispatchQueue.main.async {
                    if let obj = self.pageObject  {
                        if let data = obj.getParamValue(key: .data) as? PlayInfo {
                            let type = obj.getParamValue(key: .type) as? BtvPlayType ?? .preview("")
                            let autoPlay = obj.getParamValue(key: .autoPlay) as? Bool
                            let initTime = obj.getParamValue(key: .initTime) as? Double
                            var changeType = type
                            switch type {
                            case .preview(let value,_):
                                changeType = .preview(value,isList:false)
                            default: break
                            }
                            self.playerModel.setData(data: data, type: changeType, autoPlay: autoPlay, continuousTime: initTime)
                            
                        }
                    }
                    self.isInit = true
                }
            }
        }
        .onAppear{
            if !self.pagePresenter.isFullScreen {
                self.pagePresenter.fullScreenEnter(changeOrientation: nil)
            }
        }
    }//body
    private func onClose(){
        if self.pagePresenter.isFullScreen {
            self.pagePresenter.fullScreenExit()
        }
        self.pagePresenter.onPageEvent(self.pageObject, event: .init(type: .timeChange, data: self.playerModel.time))
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
    
}



