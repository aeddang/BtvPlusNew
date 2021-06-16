//
//  SkeletonBlock.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/12.
//

import Foundation
import SwiftUI

extension SkeletonBlock{
    static let dataBindingDelay:Double = 0.5
}

struct SkeletonBlock:View {
    let len:Int
    let spacing:CGFloat
    var size:CGSize = CGSize()
    var body :some View {
        ScrollView(.horizontal){
            HStack(alignment: .top, spacing: spacing ){
                ForEach(0..<len,id: \.self) { _ in
                    Rectangle()
                        .frame(width: size.width, height: size.height)
                        .opacity(0.3)
                }
            }
            .padding(.leading, Dimen.margin.thin)
        }
    }
}
