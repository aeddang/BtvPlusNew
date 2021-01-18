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
    @Binding var pages: [PageViewProtocol]
    @State var index: Int = 0
    var cornerRadius:CGFloat = 0
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SwipperView(pages: self.$pages, index: self.$index){
                 guard let action = self.action else {return}
                 action(self.index)
            }
            .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
            if !self.pages.isEmpty {
                HStack(spacing: Dimen.margin.thin) {
                    ForEach(0..<self.pages.count) { index in
                        CircleButton(
                            isSelected: self.index == index ,
                            index:index )
                        { idx in
                            self.index = idx
                        }
                    }
                }
                .padding(.horizontal, Dimen.margin.medium)
                .padding(.vertical, Dimen.margin.thin)
            }
        }
        .onReceive( [self.index].publisher ){ idx in
            if self.viewModel.index == idx { return }
            self.viewModel.index = idx
        }
        .onReceive(self.viewModel.$event){ evt in
            guard let event = evt else { return }
            switch event {
                case .move(let idx) : self.index = idx
            }

        }
    }
}

#if DEBUG
struct ImageViewPager_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            CPImageViewPager(
                pages: .constant(
                   [
                     ImageItem(imageNamed: Asset.noImgBanner),
                     ImageItem(imageNamed: Asset.noImgBanner),
                     ImageItem(imageNamed: Asset.noImgBanner)
                   ]
                )
            )
            .frame(width:375, height: 170, alignment: .center)
        }
    }
}
#endif
