//
//  VoiceRecorder.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
struct CurrentPlayBox: PageComponent {
    @State var progress:Float? = 0.5
    @State var title:String? = "title"
    @State var subTitle:String? = "subTitle"
    @State var subText:String? = "subText"
    @State var restrictAgeIcon: String? = nil
    @State var isOnAir:Bool? = true
    @State var isEmpty:Bool = false
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0){
                HStack(alignment: .center, spacing: RemoteStyle.margin.thin){
                    VStack(alignment: .leading, spacing: 0){
                        if self.isEmpty {
                            Text(String.remote.playEmpty)
                                .modifier(BoldTextStyle(size: RemoteStyle.fontSize.subTitle, color: Color.app.grey))
                        } else {
                            if let title  = self.subTitle {
                                Text(title)
                                    .modifier(BoldTextStyle(size: RemoteStyle.fontSize.subTitle, color: Color.app.grey))
                                    .padding(.bottom, RemoteStyle.margin.thin)
                            }
                            if let title  = self.title {
                                HStack(alignment: .center, spacing: RemoteStyle.margin.tiny){
                                    Text(title)
                                        .modifier(BoldTextStyle(size: RemoteStyle.fontSize.title, color: Color.app.white))
                                        .lineLimit(1)
                                        .padding(.bottom, RemoteStyle.margin.tiny)
                                    if let icon = self.restrictAgeIcon {
                                        Image(icon)
                                            .renderingMode(.original)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width:RemoteStyle.icon.age, height: RemoteStyle.icon.age)
                                    }
                                }
                            }
                            if let text  = self.subText {
                                HStack(alignment: .center, spacing: RemoteStyle.margin.tiny){
                                    Text(text)
                                        .modifier(BoldTextStyle(size: RemoteStyle.fontSize.subText, color: Color.app.grey))
                                    if self.isOnAir == true {
                                        Image(Asset.remote.onair)
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
                        
                    }
                    .frame(width: RemoteStyle.button.light, height: RemoteStyle.button.light)
                }
                .modifier(MatchParent())
                if let progress = self.progress {
                    ZStack(alignment: .leading){
                        Spacer().modifier(MatchParent())
                            .background(Color.app.white.opacity(0.1))
                        Spacer().modifier(MatchVertical(width:geometry.size.width * CGFloat(progress)))
                            .background(Color.brand.primary)
                    }
                    .modifier(MatchHorizontal(height:Dimen.line.regular))
                    
                }
            }
        }
    }//body
}




#if DEBUG
struct CurrentPlayBox_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            CurrentPlayBox()
        }
        .frame(width: 320, height:240)
        .background(Color.brand.bg)
    }
}
#endif
