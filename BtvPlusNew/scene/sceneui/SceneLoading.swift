//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct SceneLoading: PageComponent {
    var loadingInfo:[String]
    var body: some View {
        VStack {
            VStack(spacing:Dimen.margin.tiny){
                ForEach(self.loadingInfo, id: \.self ) { text in
                    Text( text )
                        .lineSpacing(Font.spacing.regular)
                        .modifier(MediumTextStyle( size: Font.size.bold ))
                }
            }
            .modifier(MatchParent())
            Spacer().modifier(MatchParent())
        }
    }
}


