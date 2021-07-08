//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

extension ExamProgress {
    static let height:CGFloat = SystemEnvironment.isTablet ? 16 : 10
}

struct ExamProgress: PageView {
    var value: Float = 0.3
    
    var paddingTop:CGFloat = SystemEnvironment.isTablet ? 5 : 3
    var height:CGFloat = Self.height
    var color:Color = Color.app.yellow
    var radius:CGFloat = DimenKids.radius.tiny

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top){
                ZStack(alignment: .leading) {
                    Spacer()
                        .modifier(MatchParent())
                    ZStack(alignment: .topTrailing) {
                        Spacer()
                            .modifier(MatchParent())
                            .background(self.color)
                            .mask(
                                RoundedRectangle(cornerRadius: self.radius)
                            )
                            .padding(.top, self.paddingTop)
                        Spacer()
                            .frame(width: self.height, height: 3)
                            .background(Color.app.white.opacity(0.3))
                            .mask(
                                RoundedRectangle(cornerRadius: self.radius)
                            )
                            .padding(.top, DimenKids.margin.micro)
                            .padding(.trailing,  DimenKids.margin.tiny)
                    }
                    
                    .background(self.color.opacity(0.7))
                    .mask(
                        RoundedRectangle(cornerRadius: self.radius)
                    )
                    .frame(width:geometry.size.width*CGFloat(self.value), height: self.height)
                }
                .frame(width:geometry.size.width, height:self.height)
                .background(Color.app.white)
                .mask(
                    RoundedRectangle(cornerRadius: self.radius)
                )
            }
        }
    }
    
}
#if DEBUG
struct ExamProgress_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ExamProgress(
                value: 0.6
            )
        }
        .frame(width: 300, height: 300)

    }
}
#endif
