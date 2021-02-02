//
//  ComponentSearchBar.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine

struct CPYTPlayer: PageComponent {
    @ObservedObject var ytPlayerModel:YTPlayerModel
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    var playID:String?
    
    init(
        viewModel:PlayerModel? = nil,
        playID:String? = nil,
        useCustomControl:Bool = true,
        ytPlayerModel:YTPlayerModel? = nil,
        pageObservable:PageObservable? = nil
    )
    {
        self.ytPlayerModel = ytPlayerModel ?? YTPlayerModel(useControl:!useCustomControl)
        self.viewModel = viewModel ?? PlayerModel()
        self.pageObservable = pageObservable ?? PageObservable()
        self.playID = playID ?? viewModel?.path
    }
    
    var body: some View {
        ZStack{
            CustomYTPlayer( viewModel : self.viewModel, ytPlayerModel:self.ytPlayerModel, playID: self.playID)
            
            if !ytPlayerModel.useControl {
                PlayerUI(viewModel : self.viewModel, pageObservable:self.pageObservable)
            }
        }
        .background(Color.black)
    }
}

