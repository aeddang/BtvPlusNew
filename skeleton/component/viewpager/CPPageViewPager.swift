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
    @ObservedObject var pageObservable: PageObservable
    @ObservedObject var viewModel:ViewPagerModel
    var pages: [PageObject]
    @Binding var texts: [String]?
    @Binding var index: Int
    
    var useGesture = true
    var isHighPriority = true
    @State private var isPageReady:Bool = false
    
    init(
        pageObservable:PageObservable,
        viewModel:ViewPagerModel? = nil,
        pages:[PageObject],
        texts:Binding<[String]?>? = nil,
        index:Binding<Int>,
        useGesture:Bool? = nil,
        isHighPriority:Bool? = nil
    )
    {
        self.pageObservable = pageObservable
        self.viewModel = viewModel ?? ViewPagerModel()
        self.pages = pages
        self._texts = texts ?? .constant(nil)
        self._index = index
        self.useGesture = useGesture ?? true
        self.isHighPriority = isHighPriority ?? true
        self.viewModel.index = self.index
    }
    
    init(
        pageObservable:PageObservable,
        viewModel:ViewPagerModel? = nil,
        pages:[PageObject],
        texts:[String]? = nil,
        index:Binding<Int>,
        useGesture:Bool? = nil,
        isHighPriority:Bool? = nil
    )
    {
        self.pageObservable = pageObservable
        self.viewModel = viewModel ?? ViewPagerModel()
        self.pages = pages
        self._texts = .constant(texts)
        self._index = index
        self.useGesture = useGesture ?? true
        self.isHighPriority = isHighPriority ?? true
        self.viewModel.index = self.index
    }

    var body: some View {
        VStack(spacing:0){
            if self.isPageReady {
                if self.texts != nil {
                    CPTabDivisionNavigation(
                        viewModel: self.viewModel,
                        buttons:
                           NavigationBuilder(index:self.$index, marginH:Dimen.margin.regular)
                               .getConstantNavigationButtons(texts:self.texts!),
                        index: self.$index
                    )
                    .background(Color.app.white)
                    .frame(height:Dimen.tab.regular)
                    
                }
                if self.isHighPriority {
                    SwipperPageHighPriority(
                        pageObservable: self.pageObservable,
                        viewModel: self.viewModel,
                        pages: self.pages,
                        index: self.$index,
                        useGesture: self.useGesture)
                }else{
                    SwipperPage(
                        pageObservable: self.pageObservable,
                        viewModel: self.viewModel,
                        pages: self.pages,
                        index: self.$index,
                        useGesture: self.useGesture)
                }
                
            }else{
                Spacer()
            }
            
        }
        .onReceive( self.pageObservable.$status ){ stat in
            switch stat {
            case . transactionComplete : do {
                    withAnimation(Animation.easeIn(duration: PageSceneDelegate.CHANGE_DURATION)){
                        self.isPageReady = true
                    }
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
        .onReceive(self.viewModel.$event){ evt in
            guard let event = evt else { return }
            switch event {
                case .move(let idx) : self.index = idx
            }
        }
    }
}


