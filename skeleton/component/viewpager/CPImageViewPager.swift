//
//  ImageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct CPImageViewPager: PageComponent {
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var pages: [PageViewProtocol]
    var cornerRadius:CGFloat = 0
    var useButton:Bool = false
    @State var index: Int = 0
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SwipperView(
                viewModel:self.viewModel,
                pages: self.pages) {
               
                guard let action = self.action else {return}
                action(self.index)
            }
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            if self.useButton && self.pages.count > 1 {
                HStack(spacing: Dimen.margin.tiny) {
                    ForEach(0..<self.pages.count) { index in
                        CircleButton(
                            isSelected: self.index == index ,
                            index:index )
                        { idx in
                            withAnimation{ self.index = idx }
                        }
                    }
                }
                .padding(.horizontal, Dimen.margin.medium)
                .padding(.vertical, Dimen.margin.thin)
            }
        }
        .onReceive( self.viewModel.$index ){ idx in
            self.index = idx
        }
        /*
        .onReceive(self.viewModel.$request){ evt in
            guard let event = evt else { return }
            switch event {
            case .move(let idx) : withAnimation{ self.index = idx }
            case .jump(let idx) : self.viewModel.index  = idx
            case .next : self.viewModel.index = min(self.index+1, self.pages.count-1)
            default : break
            }
        }
        */
    }
}

#if DEBUG
struct ImageViewPager_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            CPImageViewPager(
                pages:
                   [
                     ImageItem(imagePath: Asset.test),
                     ImageItem(imagePath: Asset.test),
                     ImageItem(imagePath: Asset.test)
                   ]
                
            )
            .frame(width:375, height: 170, alignment: .center)
        }
    }
}
#endif
