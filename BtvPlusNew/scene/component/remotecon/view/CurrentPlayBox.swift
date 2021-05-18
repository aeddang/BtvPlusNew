//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
struct CurrentPlayBox: PageComponent {
    var data:RemotePlayData? = nil
    var reflash: (() -> Void)
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0){
                if let data = self.data {
                    HStack(alignment: .center, spacing: RemoteStyle.margin.thin){
                        VStack(alignment: .leading, spacing: 0){
                            if data.isEmpty {
                                Text(String.remote.playEmpty)
                                    .modifier(BoldTextStyle(size: RemoteStyle.fontSize.subTitle, color: Color.app.grey))
                            } else if data.isError{
                                Text(String.remote.playError)
                                    .modifier(BoldTextStyle(size: RemoteStyle.fontSize.subTitle, color: Color.app.grey))
                            } else {
                                if let title = data.subTitle {
                                    Text(title)
                                        .modifier(BoldTextStyle(size: RemoteStyle.fontSize.subTitle, color: Color.app.grey))
                                        .padding(.bottom, RemoteStyle.margin.thin)
                                }
                                if let title = data.title {
                                    HStack(alignment: .top, spacing: RemoteStyle.margin.tiny){
                                        Text(title)
                                            .modifier(BoldTextStyle(size: RemoteStyle.fontSize.title, color: Color.app.white))
                                            .lineLimit(1)
                                            .padding(.bottom, RemoteStyle.margin.tiny)
                                        if let icon = data.restrictAgeIcon {
                                            Image(icon)
                                                .renderingMode(.original)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:RemoteStyle.icon.age, height: RemoteStyle.icon.age)
                                        }
                                    }
                                }
                                if let text = data.subText {
                                    HStack(alignment: .center, spacing: RemoteStyle.margin.tiny){
                                        Text(text)
                                            .modifier(BoldTextStyle(size: RemoteStyle.fontSize.subText, color: Color.app.grey))
                                        
                                        if let isOnAir = data.isOnAir {
                                            Image(isOnAir ? Asset.remote.onair : Asset.remote.vod)
                                                .renderingMode(.original).resizable()
                                                .scaledToFit()
                                                .frame(
                                                    width: RemoteStyle.icon.onAir.width,
                                                    height: RemoteStyle.icon.onAir.height)
                                        }
                                    }
                                }
                            }
                            Spacer().modifier(MatchHorizontal(height: 0))
                        }
                        EffectButton(defaultImage: Asset.remote.refresh, effectImage: Asset.remote.refresh)
                        { _ in
                            self.reflash()
                        }
                        .frame(width: RemoteStyle.button.light, height: RemoteStyle.button.light)
                    }
                    .modifier(MatchParent())
                        
                    if let progress = data.progress {
                        ZStack(alignment: .leading){
                            Spacer().modifier(MatchParent())
                                .background(Color.app.white.opacity(0.1))
                            Spacer().modifier(MatchVertical(width:geometry.size.width * CGFloat(progress)))
                                .background(Color.brand.primary)
                        }
                        .modifier(MatchHorizontal(height:Dimen.line.regular))
                    }
                }// if data
            }//vstack
        }//geo
    }//body
}




#if DEBUG
struct CurrentPlayBox_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            CurrentPlayBox(){
                
            }
        }
        .frame(width: 320, height:240)
        .background(Color.brand.bg)
    }
}
#endif
