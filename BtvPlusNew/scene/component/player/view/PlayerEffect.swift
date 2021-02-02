//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine

struct PlayerEffect: PageView{
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State var imgBrightness:String = Asset.player.brightnessLv0
    @State var imgVolume:String = Asset.player.volumeOn
    
    @State var textBrightness:String = "0"
    @State var textVolume:String =  "0"
    @State var textSeeking:String =  ""
    @State var textTime:String =  ""
    
    @State var showBrightness:Bool = false
    @State var showVolume:Bool = false
    @State var showSeeking:Bool = false
    
    var body: some View {
        ZStack{
            ZStack{
                if self.showSeeking {
                    VStack(spacing:Dimen.margin.thinExtra){
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
                Spacer()
                    .modifier(MatchParent())
                    .background(Color.app.black)
                    .opacity(self.showSeeking ? 0.5 : 0)
            }
            HStack(spacing:0){
                ZStack{
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
                    }
                    Spacer()
                        .modifier(MatchParent())
                        .background(Color.app.white)
                        .opacity(self.showBrightness ? 0.2 : 0)
                }
                ZStack{
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
                    }
                    Spacer()
                        .modifier(MatchParent())
                        .background(Color.app.white)
                        .opacity(self.showVolume ? 0.2 : 0)
                }
                
            }
        }
        .modifier(MatchParent())
        .onReceive(self.viewModel.$brightness){ brightness in
            let value = min(brightness*100.0, 100)
            let lv = Int( ceil( value / 100 * 5 ) )
            self.imgBrightness = Asset.brightnessList[lv]
            self.textBrightness = Double(value).toInt().description
            self.delayBrightnessHidden()
        }
        .onReceive(self.viewModel.$volume){ volume in
            let value = min(volume*100.0, 100.0)
            let lv = Int( ceil( value / 100 * 3 ) )
            self.imgVolume = Asset.volumeList[lv]
            self.textVolume = Double(value).toInt().description
            self.delayVolumeHidden()
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
            
    }//body
    
    
    @State var effectVolume:AnyCancellable?
    func delayVolumeHidden(){
        if !self.showVolume {
            withAnimation{ self.showVolume = true }
        }
        self.effectVolume?.cancel()
        self.effectVolume = Timer.publish(
            every: 1.5, on: .current, in: .common)
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
            every: 1.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.effectBrightness?.cancel()
                withAnimation{ self.showBrightness = false }
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
