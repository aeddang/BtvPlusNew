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

struct PlayerEffect: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    @State var brightness:CGFloat? = nil
    @State var volume:Float? = nil
    @State var rate:Float? = nil
    @State var message:String? = nil
    @State var toast:String? = nil
    @State var screenRatio:CGFloat? = nil
    @State var screenGravity:AVLayerVideoGravity? = nil
    
    @State var imgBrightness:String = Asset.player.brightnessLv0
    @State var imgVolume:String = Asset.player.volumeOn
    
    @State var textBrightness:String = "0"
    @State var textVolume:String =  "0"
    @State var textSeeking:String =  ""
    @State var textTime:String =  ""
    
    @State var showBrightness:Bool = false
    @State var showVolume:Bool = false
    @State var showSeeking:Bool = false
    @State var isFullScreen:Bool = false
    
    @State var textWillMoveTime:String = ""
    @State var showSeekForward:Bool = false
    @State var showSeekBackward:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom){
                ZStack{
                    Spacer()
                        .modifier(MatchParent())
                        .background(Color.app.black)
                        .opacity(self.showSeeking ? 0.5 : 0)
                    
                    if self.showSeeking {
                        VStack(spacing:Dimen.margin.tiny){
                            Text(self.textSeeking)
                                .modifier(BoldTextStyle(
                                        size: Font.size.bold,
                                        color: Color.app.white)
                                )
                            Text(self.textTime)
                                .modifier(BoldTextStyle(
                                        size: Font.size.regular,
                                        color: Color.app.greyLight)
                                )
                        }
                        
                    }
                    
                    if self.message != nil {
                        Text(self.message!)
                            .modifier(BoldTextStyle(
                                        size: self.isFullScreen ? Font.size.bold : Font.size.regular,
                                    color: Color.app.white)
                            )
                            .padding(.bottom,  self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
                    }
                }
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
                                self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), false)
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
                                            size: Font.size.boldExtra,
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
                                self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), false)
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
                                            size: Font.size.boldExtra,
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
                if self.toast != nil {
                    Text(self.toast!)
                        .modifier(BoldTextStyle(
                                    size: self.isFullScreen ? Font.size.bold : Font.size.regular,
                                color: Color.app.white)
                        )
                        .padding(.bottom,  self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
                }
            }
            .modifier(MatchParent())
            .onReceive(self.viewModel.$brightness){ brightness in
                if self.brightness == nil {
                    self.brightness = brightness
                    return
                }
                if self.brightness == brightness { return }
                self.brightness = brightness
                let value = min(brightness*100.0, 100)
                let lv = Int( ceil( value / 100 * 5 ) )
                self.imgBrightness = Asset.brightnessList[lv]
                self.textBrightness = Double(value).toInt().description
                self.delayBrightnessHidden()
            }
            .onReceive(self.viewModel.$volume){ volume in
                if self.volume == nil {
                    self.volume = volume
                    return
                }
                if self.volume == volume { return }
                self.volume = volume
                let value = min(volume*100.0, 100.0)
                let lv = Int( ceil( value / 100 * 3 ) )
                self.imgVolume = Asset.volumeList[lv]
                self.textVolume = Double(value).toInt().description
                self.delayVolumeHidden()
            }
            .onReceive(self.viewModel.$message){ message in
                guard let message = message else { return }
                if self.toast == message { return }
                withAnimation{ self.toast = message }
                self.delayToastHidden()
            }
            .onReceive(self.viewModel.$rate){ rate in
                if self.rate == nil {
                    self.rate = rate
                    return
                }
                if self.rate == rate { return }
                self.rate = rate
                withAnimation{ self.toast = "x " + rate.description }
                self.delayToastHidden()
            }
            .onReceive(self.viewModel.$screenRatio){ ratio in
                if self.screenRatio == nil {
                    self.screenRatio = ratio
                    return
                }
                if self.screenRatio == ratio { return }
                self.screenRatio = ratio
                self.message = Int(round(ratio * 100)).description + "%" 
                self.delayMessageHidden()
            }
            .onReceive(self.viewModel.$screenGravity){ gravity in
                if self.screenGravity == nil {
                    self.screenGravity = gravity
                    return
                }
                if self.screenGravity == gravity { return }
                self.screenGravity = gravity
                withAnimation{
                    switch gravity {
                    case .resize: self.toast = String.button.ratioFill
                    case .resizeAspect: self.toast = String.button.ratioOrigin
                    case .resizeAspectFill: self.toast = String.button.ratioFit
                    default:do{}
                    }
                }
                self.delayToastHidden()
            }
            .onReceive(self.viewModel.$streamEvent) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .seeked: withAnimation{ self.showSeeking = false }
                default : do{}
                }
            }
            .onReceive(self.viewModel.$seeking){ seeking in
                if seeking == 0 {
                    withAnimation{ self.showSeeking = false }
                }else{
                    if !self.showSeeking {
                        withAnimation{ self.showSeeking = true }
                    }
                    let leading = seeking < 0 ? "- " : ""
                    self.textSeeking = leading + abs(seeking).secToHourString()
                }
            }
            .onReceive(self.viewModel.$time) { tm in
                if !self.showSeeking { return }
                self.textTime = tm.secToHourString()
            }
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .seekForward(let t, _):
                    self.textWillMoveTime = t.toInt().description + String.player.moveSec
                    self.delaySeekForwardHidden()
                case .seekBackword(let t, _):
                    self.textWillMoveTime = t.toInt().description + String.player.moveSec
                    self.delaySeekBackwardHidden()
                default : do{}
                }
            }
            .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
                self.isFullScreen = fullScreen
            }
        }//geo
    }//body
    
    
    @State var effectVolume:AnyCancellable?
    func delayVolumeHidden(){
        if !self.showVolume {
            withAnimation{ self.showVolume = true }
        }
        self.effectVolume?.cancel()
        self.effectVolume = Timer.publish(
            every: 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectVolume?.cancel()
                withAnimation{ self.showVolume = false }
            }
    }
    
    @State var effectBrightness:AnyCancellable?
    func delayBrightnessHidden(){
        if !self.showBrightness {
            withAnimation{ self.showBrightness = true }
        }
        self.effectBrightness?.cancel()
        self.effectBrightness = Timer.publish(
            every: 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectBrightness?.cancel()
                withAnimation{ self.showBrightness = false }
            }
    }
    
    @State var effectSeekForward:AnyCancellable?
    func delaySeekForwardHidden(){
        if !self.showSeekForward {
            withAnimation{ self.showSeekForward = true }
        }
        self.effectSeekForward?.cancel()
        self.effectSeekForward = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectSeekForward?.cancel()
                withAnimation{ self.showSeekForward = false }
            }
    }
    
    @State var effectSeekBackward:AnyCancellable?
    func delaySeekBackwardHidden(){
        if !self.showSeekBackward {
            withAnimation{ self.showSeekBackward = true }
        }
        self.effectSeekBackward?.cancel()
        self.effectSeekBackward = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectSeekBackward?.cancel()
                withAnimation{ self.showSeekBackward = false }
            }
    }
    
    @State var effectToast:AnyCancellable?
    func delayToastHidden(){
        self.effectToast?.cancel()
        self.effectToast = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectToast?.cancel()
                withAnimation{ self.toast = nil }
            }
    }
    
    @State var effectMessage:AnyCancellable?
    func delayMessageHidden(){
        self.effectMessage?.cancel()
        self.effectMessage = Timer.publish(
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectMessage?.cancel()
                withAnimation{ self.message = nil }
            }
    }
    
}


#if DEBUG
struct PlayerEffect_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerEffect()
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
