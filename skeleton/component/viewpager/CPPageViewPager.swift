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
    var titles: [String]?
    var primaryColor:Color = Color.app.white
    var useGesture = true
    var usePull:Axis? = nil
    var pageOn:((_ idx:Int) -> Void)? = nil
    
    @State var isPageReady:Bool = false
    @State var isPageApear:Bool = false
    @State var tabs:[NavigationButton] = []
    var body: some View {
        VStack(spacing:0){
            if self.isPageReady {
                CPTabDivisionNavigation(
                    viewModel: self.viewModel,
                    buttons: self.tabs,
                    primaryColor: self.primaryColor
                )
                .modifier(MatchHorizontal(height:Dimen.tab.regular))
                SwipperView(
                    viewModel: self.viewModel,
                    pages: self.pages,
                    coordinateSpace: .global,
                    usePull : self.usePull
                    )
                    .modifier(MatchParent())
                    .onAppear(){
                        guard let pageOn = self.pageOn else {return}
                        pageOn(self.viewModel.index)
                        self.isPageApear = true
                    }
            }else{
                Spacer()
            }
            
        }
        .onReceive(self.viewModel.$index){ idx in
            if !self.isPageApear { return }
            guard let pageOn = self.pageOn else {return}
            pageOn(idx)
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
        .onAppear{
            guard let titles = self.titles else{return}
            self.tabs = NavigationBuilder(index:self.viewModel.index, marginH:Dimen.margin.regular)
                .getNavigationButtons(texts:titles, color: self.primaryColor)
        }
        
    }
}


