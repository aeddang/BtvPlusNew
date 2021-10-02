//
//  PlayerEffectAnimation.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
//

import Foundation
import SwiftUI
import AVKit

struct PlayerEffectAnimation: PageComponent{
    var viewModel: BtvPlayerModel = BtvPlayerModel()
    var isFullScreen:Bool = false
    
    var brightness:CGFloat? = nil
    var volume:Float? = nil
     
    var imgBrightness:String = Asset.player.brightnessLv0
    var imgVolume:String = Asset.player.volumeOn
    
    var textBrightness:String = "0"
    var textVolume:String =  "0"
   
    var showBrightness:Bool = false
    var showVolume:Bool = false
     
    var textWillMoveTime:String = ""
    var showSeekForward:Bool = false
    var showSeekBackward:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing:0){
                ZStack{
                    if self.showSeekBackward {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( Asset.player.seekBackward )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(
                                            height: self.isFullScreen ? Dimen.icon.light : Dimen.icon.tiny))
                            Text(self.textWillMoveTime)
                                .modifier(BoldTextStyle(
                                        size: self.isFullScreen ? Font.size.lightExtra :Font.size.tinyExtra,
                                        color: Color.app.white)
                                )
                        }
                        .modifier(MatchParent())
                        .background(
                            LinearGradient(
                                gradient:Gradient(colors: [Color.transparent.white45, Color.transparent.clear]), startPoint: .leading, endPoint: .trailing))
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                        })
                    }
                    if self.showBrightness {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( self.imgBrightness )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(height:Dimen.icon.regular))
                            Text(self.textBrightness)
                                .modifier(BoldTextStyle(
                                        size: Font.size.mediumExtra,
                                        color: Color.app.greyLight)
                                )
                        }
                        VStack(spacing:0){
                            Spacer()
                                .modifier(MatchParent())
                                .background(Color.transparent.clearUi)
                            Spacer()
                                .modifier(
                                    MatchHorizontal(height: geometry.size.height * (self.brightness ?? 0) ))
                                .background(Color.app.white)
                                .opacity( 0.2 )
                        }
                        .modifier(MatchParent())
                    }
                    Spacer().modifier(MatchParent())
                }
                ZStack{
                    if self.showSeekForward {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( Asset.player.seekForward )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(
                                            height: self.isFullScreen ? Dimen.icon.light : Dimen.icon.tiny))
                            Text(self.textWillMoveTime)
                                .modifier(BoldTextStyle(
                                        size: self.isFullScreen ? Font.size.lightExtra :Font.size.tinyExtra,
                                        color: Color.app.white)
                                )
                        }
                        .modifier(MatchParent())
                        .background(
                            LinearGradient(gradient:Gradient(colors: [Color.transparent.white45, Color.transparent.clear]), startPoint: .trailing, endPoint: .leading))
                        .onTapGesture(count: 2, perform: {
                            if self.viewModel.isLock { return }
                            self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                        })
                    }
                    if self.showVolume {
                        VStack(spacing:Dimen.margin.thinExtra){
                            Image( self.imgVolume )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .modifier(MatchHorizontal(height:Dimen.icon.regular))
                            Text(self.textVolume)
                                .modifier(BoldTextStyle(
                                        size: Font.size.mediumExtra,
                                        color: Color.app.greyLight)
                                )
                        }
                        VStack(spacing:0){
                            Spacer()
                                .modifier(MatchParent())
                                .background(Color.transparent.clearUi)
                            Spacer()
                                .modifier(
                                    MatchHorizontal(height: geometry.size.height * CGFloat(self.volume ?? 0) ))
                                .background(Color.app.white)
                                .opacity( 0.2 )
                        }
                        .modifier(MatchParent())
                    }
                    Spacer().modifier(MatchParent())
                }
            }
        }
    }
}
