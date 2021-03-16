//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

struct PageIntro: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    let pages: [PageViewProtocol] = [
        ResourceItem(asset: Asset.source.intro01),
        ResourceItem(asset: Asset.source.intro02),
        ResourceItem(asset: Asset.source.intro03)
    ]
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            SwipperView(
                viewModel : self.viewModel,
                pages: self.pages,
                index: self.$index
                )
            if self.pages.count > 1 {
                HStack(spacing: 0) {
                    Text((self.index+1).description.toFixLength(2))
                        .modifier(NumberMediumTextStyle(size: Font.size.lightExtra, color: Color.brand.primary))
                        .fixedSize(horizontal: true, vertical: true)
                    HStack(spacing: 0) {
                        Spacer()
                            .modifier(MatchVertical(width:self.leading))
                            .background(Color.brand.primary)
                            .fixedSize(horizontal: true, vertical: false)
                        Spacer()
                            .modifier(MatchVertical(width:self.trailing))
                            .background(Color.transparent.white20)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .frame( height: Dimen.line.regular)
                    .padding(.horizontal, Dimen.margin.tiny)
                    Text((self.pages.count).description.toFixLength(2))
                        .modifier(NumberMediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyLight))
                    
                }
                .padding(.horizontal, Dimen.margin.lightExtra)
                .frame( height:70)
            }
            if self.index < (self.pages.count - 1) {
                FillButton(
                    text: String.button.skip,
                    isSelected: true
                ){_ in
                    self.viewModel.request = .next
                }
            } else {
                HStack(spacing: 0) {
                    FillButton(
                        text: String.button.home,
                        isSelected: true,
                        bgColor:Color.app.blueLightExtra
                    ){_ in
                        self.pageSceneObserver.event = .initate
                    }
                    
                    FillButton(
                        text: String.button.appInit,
                        isSelected: true
                    ){_ in
                        self.pageSceneObserver.event = .initate
                        
                    }
                   
                }
            }
        }
        .padding(.vertical, Dimen.margin.regular)
        .modifier(PageFull())
        .onReceive( [self.index].publisher ){ idx in
            if self.viewModel.index == idx { return }
            self.viewModel.index = idx
            self.setBar(idx:idx)
        }
        .onAppear{
            self.setBar(idx:self.index)
        }
        
    }//body
    
    private func setBar(idx:Int){
        let count = self.pages.count
        let size = Dimen.bar.regular
        let idx = self.index + 1
        withAnimation{
            self.leading = size * CGFloat(idx)
            self.trailing = size * CGFloat(count - idx)
        }
    }
    
}


#if DEBUG
struct PageIntro_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageIntro().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .frame(width: 325, height: 640, alignment: .center)
        }
    }
}
#endif

