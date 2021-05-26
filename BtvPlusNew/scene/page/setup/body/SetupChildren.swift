//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupChildren: PageView {
    var more: () -> Void
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupChildren).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: String.pageText.setupChildrenHabit,
                    subTitle: String.pageText.setupChildrenHabitText,
                    more:{
                        self.more()
                        //self.setupWatchHabit()
                    }
                )
            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupChildren_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupChildren(){
                
            }
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
