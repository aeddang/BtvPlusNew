//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
import AVKit


struct PlayerOptionSelectListKids: PageComponent{
    var viewModel: BtvPlayerModel = BtvPlayerModel()
    var isFullScreen:Bool = false
    var btns:[PlayerOptionSelectBox.BtnData] = []
    var selectedIdx:Int = -1
    var body: some View {
        HStack(spacing: self.isFullScreen ? KidsPlayerUI.fullScreenSpacing : KidsPlayerUI.spacing ){
            ForEach(self.btns) { btn in
                RectButtonKids(
                    text: btn.title,
                    isSelected: self.selectedIdx == btn.index,
                    textModifier: TextModifierKids (
                        family:Font.familyKids.bold,
                        size: self.isFullScreen ? Font.sizeKids.regularExtra : Font.sizeKids.tinyExtra,
                        color: Color.app.brownDeep,
                        activeColor: Color.app.white
                    ),
                    size: self.isFullScreen ? DimenKids.button.regularRect : DimenKids.button.lightRect ){ _ in
                    
                    guard let type = self.viewModel.selectFunctionType else{ return }
                    
                    switch type {
                    case .quality :
                        guard let value = btn.value as? Quality else { return }
                        self.viewModel.initPlay = true
                        self.viewModel.selectQuality = value
                        self.viewModel.btvLogEvent =
                            .clickConfigButton(.clickVodConfigDetail, config: value.name.lowercased())
                    case .rate :
                        guard let value = btn.value as? Float else { return }
                        self.viewModel.event = .rate(value, isUser: true)
                        self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfigDetail, config: "x"+value.description)
                    case .ratio :
                        guard let value = btn.value as? AVLayerVideoGravity else { return }
                        self.viewModel.event = .screenGravity(value)
                        var config:String? = nil
                        switch value {
                        case .resize : config = "full_proportion"
                        case .resizeAspect : config = "original_proportion"
                        case .resizeAspectFill : config = "maintain_proportion"
                        default: break
                        }
                        self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfigDetail, config: config)
                    }
                    self.viewModel.selectFunctionType = nil
                }
                .accessibility(label: Text( btn.accessibility))
            }
        }
    }//body
}


