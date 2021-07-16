//
//  SkeletonBlockKids.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/16.
//

import Foundation
import SwiftUI

extension SkeletonBlockKids{
    static let dataBindingDelay:Double = 0.25
}

struct SkeletonBlockKids:View {
    let len:Int
    let spacing:CGFloat
    var size:CGSize = CGSize()
    var body :some View {
        ScrollView(.horizontal){
            HStack(alignment: .top, spacing: spacing ){
                ForEach(0..<len,id: \.self) { _ in
                    RoundedRectangle(cornerRadius: DimenKids.radius.light)
                        .frame(width: size.width, height: size.height)
                        .opacity(0.3)
                }
            }
            .modifier(ContentHorizontalEdgesKids())
        }
    }
}
