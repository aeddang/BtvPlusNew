//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


struct SelectBox: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    @Binding var index: Int
    var buttons: [SelectBtnData]
    let action: (_ idx:Int) -> Void
    
    @State var safeAreaBottom:CGFloat = 0
    
    var body: some View {
        VStack{
            
            VStack (alignment: .leading, spacing:0){
                VStack(alignment: .leading, spacing:0){
                    ForEach(self.buttons) { btn in
                        SelectButton(
                            text: btn.title ,
                            tipA: btn.tipA, tipB: btn.tipB,
                            index: btn.index,
                            isSelected: btn.index == self.index){idx in
                            
                            self.index = idx
                            self.action(idx)
                        }
                    }
                }
                FillButton(
                    text: String.app.close,
                    isSelected: true
                ){idx in
                    withAnimation{
                        self.isShowing = false
                    }
                    
                }
            }
            .padding(.top, Dimen.margin.mediumExtra)
            .padding(.bottom, self.safeAreaBottom)
            .background(Color.app.blue)
            .offset(y:self.isShowing ? 0 : 200)
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            //if self.editType == .nickName {return}
            withAnimation{
                self.safeAreaBottom = pos
            }
        }
    }
}
