//
//  PlayerUI.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct PlayerUI: PageComponent {
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    @State var time:String = ""
    @State var duration:String = ""
    @State var progress: Float = 0
    @State var isLoading = false
    @State var toggleString = "Pause"
    @State var isError = false
    @State var errorMessage = ""

    var body: some View {
        ZStack{
            ActivityIndicator( isAnimating: self.$isLoading,
                               style: .large,
                               color: Color.app.white )
            
            Button<Text>(action: {
                self.viewModel.event = .togglePlay
            }){
                Text(self.toggleString)
            }
            
            VStack{
                HStack{
                    Spacer()
                    CPAirPlayButton().frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                }
                Spacer()
                ProgressSlider(progress: self.$progress, onEditingChanged:{
                    pct in
                    ComponentLog.d("ProgressSlider " + pct.description, tag: self.tag)
                    self.viewModel.event = .seekProgress(pct)
                })
                .accentColor(.red)
                .frame(height: 5)
                
                
                HStack{
                    Text(self.time)
                        .font(Font.customFont.light)
                        .foregroundColor(Color.app.white)
                        .padding(Dimen.margin.regular)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                    Spacer()
                    Text(self.duration)
                        .font(Font.customFont.light)
                        .foregroundColor(Color.app.white)
                        .padding(Dimen.margin.regular)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                    
                }
                
            }
        }
        .toast(isShowing: self.$isError, text: self.errorMessage)

        .onReceive(self.viewModel.$time) { tm in
            self.time = tm.description
            if self.viewModel.duration <= 0.0 {return}
            self.progress = Float(self.viewModel.time / self.viewModel.duration)
        }
        .onReceive(self.viewModel.$duration) { tm in
            self.duration = tm.description
        }
        .onReceive(self.viewModel.$isPlay) { play in
            ComponentLog.d("isPlay " + play.description, tag: self.tag)
            self.toggleString = play ? "PLAY" : "PAUSE"
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            //guard let event = evt else { return }

        }
        .onReceive(self.viewModel.$playerStatus) { st in
            //guard let status = st else { return }
        }
        .onReceive(self.viewModel.$streamStatus) { st in
            guard let status = st else { return }
            switch status {
            case .buffering(_) : self.isLoading = true
            default : self.isLoading = false
            }
        }
        .onReceive(self.viewModel.$error) { err in
            guard let error = err else { return }
            ComponentLog.d("error " + err.debugDescription, tag: self.tag)
            self.isError = true
            switch error{
            case .connect(_) : self.errorMessage = "connect error"
            case .illegalState(_) : self.errorMessage = "illegalState"
            case .stream(let e) :
                switch e {
                case .pip(let msg): self.errorMessage = msg
                case .playback(let msg): self.errorMessage = msg
                case .unknown(let msg): self.errorMessage = msg
                case .certification(let msg): self.errorMessage = msg
                }
            }
           
        }
    }
    
}

