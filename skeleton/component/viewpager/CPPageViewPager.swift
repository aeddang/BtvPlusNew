//
//  PageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct CPPageViewPager: PageComponent {
    @ObservedObject var pageObservable: PageObservable = PageObservable()
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var pages: [PageViewProtocol]
    var texts: [String]?
    var useGesture = true
    var pageOn:((_ idx:Int) -> Void)? = nil
    
    @State var index: Int = 0
    @State private var isPageReady:Bool = false
    init(
        pageObservable: PageObservable,
        viewModel:ViewPagerModel = ViewPagerModel(),
        pages: [PageObject],
        texts: [String]?,
        useGesture:Bool = true,
        pageOn: @escaping (_ idx:Int) -> Void
    ) {
        self.pages = pages.map{ PageFactory.getPage($0) }
        self.texts = texts
        self.useGesture = useGesture
        self.pageOn = pageOn
    }
    
    var body: some View {
        VStack(spacing:0){
            if self.isPageReady {
                if self.texts != nil {
                    CPTabDivisionNavigation(
                        viewModel: self.viewModel,
                        buttons:
                           NavigationBuilder(index:self.index, marginH:Dimen.margin.regular)
                               .getNavigationButtons(texts:self.texts!),
                        index: self.$index
                    )
                    .frame(height:Dimen.tab.regular)
                    
                }
                SwipperView(
                    pages: self.pages,
                    index: self.$index) {
                    guard let pageOn = self.pageOn else {return}
                    pageOn(self.index)
                }
            }else{
                Spacer()
            }
            
        }
        .onReceive( self.pageObservable.$status ){ stat in
            switch stat {
            case . transactionComplete :
                withAnimation(Animation.easeIn(duration: PageSceneDelegate.CHANGE_DURATION)){
                    self.isPageReady = true
                }
            default : do {}
            }
        }
        .onReceive( [self.index].publisher ){ idx in
            if self.viewModel.index == idx { return }
            withAnimation{
                self.viewModel.index = idx
                if self.viewModel.index != self.index {
                    self.index = idx
                }
            }
        }
        .onReceive(self.viewModel.$request){ evt in
            guard let event = evt else { return }
            switch event {
            case .move(let idx) : withAnimation{self.index = idx}
            case .jump(let idx) : self.index = idx
            default : break
            }
        }
    }
}


