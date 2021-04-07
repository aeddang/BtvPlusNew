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
    var useGesture = true
    var pageOn:((_ idx:Int) -> Void)? = nil
    
    @State var isPageReady:Bool = false
    @State var isPageApear:Bool = false
    var body: some View {
        VStack(spacing:0){
            if self.isPageReady {
                if self.titles != nil {
                    CPTabDivisionNavigation(
                        viewModel: self.viewModel,
                        buttons:
                            NavigationBuilder(index:self.viewModel.index, marginH:Dimen.margin.regular)
                               .getNavigationButtons(texts:self.titles!)
                    )
                    .frame(height:Dimen.tab.regular)
                }
                SwipperView(
                    viewModel: self.viewModel,
                    pages: self.pages)
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
        
    }
}


