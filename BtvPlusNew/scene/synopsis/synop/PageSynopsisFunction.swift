//
//  PageSynopsisFunction.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/09.
//

import Foundation

extension PageSynopsis {
    func fullScreenCancel(){
        if !self.isFullScreen {return}
        DispatchQueue.main.async {
            if self.type == .btv && !SystemEnvironment.isTablet {
                self.pagePresenter.requestDeviceOrientation(.portrait)
            } else {
                self.pagePresenter.fullScreenExit()
            }
        }
    }
    
    func onFullScreenViewMode(){
        if self.isFullScreen {return}
        DispatchQueue.main.async {
            self.pagePresenter.fullScreenEnter(isLock: SystemEnvironment.isTablet , changeOrientation: .landscape)
        }
    }
    func onDefaultViewMode(){
        if !self.isFullScreen {return}
        self.fullScreenCancel()
    }
    
}
