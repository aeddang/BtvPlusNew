//
//  PlayerEffectSeek.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/09.
//

import Foundation
import SwiftUI

struct PlayerEffectSeek: PageComponent{
    var isFullScreen:Bool = false
    
    var message:String? = nil
    var textSeeking:String =  ""
    var textTime:String =  ""
    var showSeeking:Bool = false
    
    var body: some View {
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
    }
}


struct PlayerEffectSeekKids: PageComponent{
    var isFullScreen:Bool = false
    
    var message:String? = nil
    var textSeeking:String =  ""
    var textTime:String =  ""
    var showSeeking:Bool = false
    
    var body: some View {
        ZStack{
            Spacer()
                .modifier(MatchParent())
                .background(Color.app.black)
                .opacity(self.showSeeking ? 0.5 : 0)
            
            if self.showSeeking {
                VStack(spacing:Dimen.margin.tiny){
                    Text(self.textSeeking)
                        .modifier(BoldTextStyleKids(
                                    size: self.isFullScreen ? Font.sizeKids.black : Font.sizeKids.regularExtra,
                                color: Color.app.white)
                        )
                    Text(self.textTime)
                        .modifier(BoldTextStyleKids(
                                size: self.isFullScreen ? Font.sizeKids.lightExtra : Font.sizeKids.micro,
                                color: Color.app.greyLight)
                        )
                }
            }
            
            if self.message != nil {
                Text(self.message!)
                    .modifier(BoldTextStyleKids(
                                size: self.isFullScreen ? Font.sizeKids.bold : Font.sizeKids.regular,
                            color: Color.app.white)
                    )
                    .padding(.bottom,  self.isFullScreen ? KidsPlayerUI.paddingFullScreen : KidsPlayerUI.padding)
            }
        }
    }
}
