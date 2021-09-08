//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct PlayerDisable: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    @State var text:String = String.player.disable
    @State var isShow:Bool = false
    var body: some View {
        ZStack{
            Text(self.text)
                .modifier(MediumTextStyleKids(
                    size: Font.sizeKids.mediumExtra,
                    color: Color.app.white)
                )
        }
        .modifier(MatchParent())
        .background(Color.transparent.black70)
        .opacity(self.isShow ? 1 : 0)
        .onReceive(self.viewModel.$currentQuality){ _ in
            withAnimation{self.isShow = false}
        }
        .onReceive(self.viewModel.$btvPlayerEvent){ evt in
            switch evt {
            case .disablePreview :
                withAnimation{self.isShow = true}
            default : break
            }
        }
        .onAppear{
            
        }
    }//body
}



