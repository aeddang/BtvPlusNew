//
//  EditButton.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/02.
//

import Foundation
import SwiftUI

struct EditButton: PageView {
    var icon:String?
    var text:String
    var action:()->Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack(alignment:.center, spacing: Dimen.margin.tinyExtra){
                if let icon = self.icon {
                    Image(icon)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                }
                Text(text)
                    .modifier(BoldTextStyle(size: Font.size.lightExtra))
            }
        }
        .buttonStyle(BorderlessButtonStyle())
    }//body
}
