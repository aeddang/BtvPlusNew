//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
enum RemoteConEvent{
    case toggleOn, multiview, chlist, earphone, reflash,
         fastForward, rewind, exit, previous,
         home, volumeMove(Int), mute(Bool),
         channelMove(Int),
         inputChannel, inputMessage, close,
         control(ControlBox.Event), playControl(PlayControlBox.Event)
}

struct RemotePlayData{
    var progress:Float? = nil
    var title:String? = nil
    var subTitle:String? = nil
    var subText:String? = nil
    var restrictAgeIcon: String? = nil
    var isOnAir:Bool = false
    var isEmpty:Bool = false
    var isError:Bool = false
}


struct RemoteCon: PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    var data:RemotePlayData? = nil
    var action: (RemoteConEvent) -> Void
    var body: some View {
        ZStack(alignment: .top){
            Spacer().modifier(MatchVertical(width: 0))
            VStack(alignment: .center, spacing: 0){
                HStack(alignment: .center, spacing: RemoteStyle.margin.light){
                    EffectButton(defaultImage: Asset.remote.on, effectImage: Asset.remote.onOn)
                    { _ in
                        self.action(.toggleOn)
                    }
                    .frame(width: RemoteStyle.button.regular, height: RemoteStyle.button.regular)
                    EffectButton(defaultImage: Asset.remote.multiview, effectImage: Asset.remote.multiviewOn)
                    { _ in
                        self.action(.multiview)
                    }
                    .frame(width: RemoteStyle.button.thin, height: RemoteStyle.button.thin)
                    Spacer().modifier(MatchVertical(width: 1))
                        .background(Color.app.grey)
                        .padding(.vertical , Dimen.margin.tiny)
                    EffectButton(defaultImage: Asset.remote.chlist, effectImage: Asset.remote.chlistOn)
                    { _ in
                        self.action(.chlist)
                    }
                    .frame(width: RemoteStyle.button.thin, height: RemoteStyle.button.thin)
                    Spacer().modifier(MatchVertical(width: 1))
                        .background(Color.app.grey)
                        .padding(.vertical , Dimen.margin.tiny)
                    EffectButton(defaultImage: Asset.remote.earphone, effectImage: Asset.remote.earphoneOn)
                    { _ in
                        self.action(.earphone)
                    }
                    .frame(width: RemoteStyle.button.thin, height: RemoteStyle.button.thin)
                    Spacer()
                    EffectButton(defaultImage: Asset.remote.close, effectImage: Asset.remote.close)
                    { _ in
                        self.action(.close)
                    }
                    .frame(width: RemoteStyle.button.regular, height: RemoteStyle.button.regular)
                }
                .modifier(MatchHorizontal(height: RemoteStyle.ui.topBoxHeight))
                .padding(.top, RemoteStyle.margin.light)
                CurrentPlayBox( data: self.data ) {
                    self.action(.reflash)
                }
                .modifier(MatchHorizontal(height: RemoteStyle.ui.playBoxHeight))
                HStack(alignment: .center, spacing: 0){
                    VStack(spacing: 0){
                        EffectButton(defaultImage: Asset.remote.fastForward, effectImage: Asset.remote.fastForwardOn)
                        { _ in
                            self.action(.fastForward)
                        }
                        .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                        Spacer()
                        EffectButton(defaultImage: Asset.remote.exit, effectImage: Asset.remote.exitOn)
                        { _ in
                            self.action(.exit)
                        }
                        .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                    }
                    .frame(height: RemoteStyle.ui.verticalButton.height)
                    Spacer()
                    if self.data?.isOnAir == false {
                        PlayControlBox(){ evt in self.action(.playControl(evt))}
                    } else {
                        ControlBox(){ evt in self.action(.control(evt))}
                    }
                    Spacer()
                    VStack(spacing: 0){
                        EffectButton(defaultImage: Asset.remote.rewind, effectImage: Asset.remote.rewindOn)
                        { _ in
                            self.action(.rewind)
                        }
                        .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                        Spacer()
                        EffectButton(defaultImage: Asset.remote.previous, effectImage: Asset.remote.previousOn)
                        { _ in
                            self.action(.previous)
                        }
                        .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                    }
                    .frame(height: RemoteStyle.ui.verticalButton.height)
                }
                .frame(height: RemoteStyle.ui.uiBoxHeight)
                .padding(.top, RemoteStyle.margin.light)
                
                HStack(alignment: .center, spacing: 0){
                    VerticalButtonBox(
                        defaultImage:Asset.remote.volume,
                        upImage:Asset.remote.volumeUp,
                        downImage:Asset.remote.volumeDown
                    ){ evt in
                        self.action(.volumeMove( evt == .up ? 1 : -1 ))
                    }
                    .frame(width: RemoteStyle.ui.verticalButton.width,
                           height: RemoteStyle.ui.verticalButton.height)
                    Spacer()
                    EffectButton(defaultImage: Asset.remote.home, effectImage: Asset.remote.homeOn)
                    { _ in
                        self.action(.home)
                    }
                    .frame(width: RemoteStyle.button.heavy, height: RemoteStyle.button.heavy)
                    Spacer()
                    VerticalButtonBox(
                        defaultImage:Asset.remote.channel,
                        upImage:Asset.remote.channelUp,
                        downImage:Asset.remote.channelDown
                    ){ evt in
                        self.action(.channelMove( evt == .up ? 1 : -1 ))
                        
                    }
                    .frame(width: RemoteStyle.ui.verticalButton.width,
                           height: RemoteStyle.ui.verticalButton.height)
                }
                .frame(height: RemoteStyle.ui.uiBoxHeight)
                
                
                HStack(alignment: .center, spacing: 0){
                    EffectButton(defaultImage: Asset.remote.mute, effectImage: Asset.remote.muteOn)
                    { _ in
                        self.action(.mute(true))
                    }
                    .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                    Spacer()
                    EffectButton(defaultImage: Asset.remote.vibrate, effectImage: Asset.remote.vibrateOn,  useVibrate : false)
                    { _ in
                        
                        let vibration = !self.setup.remoconVibration
                        self.setup.remoconVibration = vibration
                        if vibration {
                            UIDevice.vibrate()
                        }
                        self.appSceneObserver.event = .toast(
                            vibration ? String.alert.remoconVibrationOn : String.alert.remoconVibrationOff
                        )
                    }
                    .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                    Spacer()
                    EffectButton(defaultImage: Asset.remote.text, effectImage: Asset.remote.textOn)
                    { _ in
                        self.action(.inputMessage)
                    }
                    .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                    Spacer()
                    EffectButton(defaultImage: Asset.remote.chNumber, effectImage: Asset.remote.chNumberOn)
                    { _ in
                        self.action(.inputChannel)
                    }
                    .frame(width: RemoteStyle.button.medium, height: RemoteStyle.button.medium)
                    
                }
                
            }
            .padding(.all, RemoteStyle.margin.regular)
        }
        .modifier(MatchParent())
    }//body
    
    
    
    
}




#if DEBUG
struct RemoteCon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            RemoteCon(){ evt in
                
            }
        }
        .frame(width: 320, height:740)
        .background(Color.brand.bg)
        .environmentObject(Pairing())
    }
}
#endif
