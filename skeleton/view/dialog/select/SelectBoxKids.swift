//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

extension SelectBoxKids {
    static let idealWidth:CGFloat = SystemEnvironment.isTablet ? 565: 294
    static let maxWidth:CGFloat = SystemEnvironment.isTablet ? 565: 294
    static let scrollNum:Int = 4
}
struct SelectBoxKids: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    @Binding var index: Int
    var buttons: [SelectBtnData]
    let action: (_ idx:Int) -> Void
    
    @State var safeAreaBottom:CGFloat = 0
    
    var body: some View {
        VStack{
            VStack( spacing:DimenKids.margin.thin ){
                if self.buttons.count > Self.scrollNum {
                    ScrollView{
                        SelectBoxKidsBody(index: self.$index, buttons: self.buttons, action: self.action)
                    }
                } else {
                    SelectBoxKidsBody(index: self.$index, buttons: self.buttons, action: self.action)
                }
                RectButtonKids(
                    text: String.app.close,
                    isSelected: true
                ){idx in
                    withAnimation{
                        self.isShowing = false
                    }
                }
            }
            .modifier(ContentBox())
        }
        .frame(
            minWidth: 0,
            idealWidth: Self.idealWidth,
            maxWidth: Self.maxWidth,
            minHeight: 0,
            maxHeight: .infinity
        )
        
        .padding(.all, DimenKids.margin.heavy)
       
    }
}

struct SelectBoxKidsBody: PageComponent{
    @Binding var index: Int
    var buttons: [SelectBtnData]
    let action: (_ idx:Int) -> Void
    var body: some View {
        VStack(alignment: .center, spacing:0){
            ForEach(self.buttons) { btn in
                SelectButtonKids(
                    text: btn.title ,
                    tipA: btn.tipA, tipB: btn.tipB,
                    index: btn.index,
                    isSelected: btn.index == self.index){idx in
                    
                    self.index = idx
                    self.action(idx)
                }
                .padding(.all, DimenKids.stroke.mediumExtra )
            }
        }
    }
}
