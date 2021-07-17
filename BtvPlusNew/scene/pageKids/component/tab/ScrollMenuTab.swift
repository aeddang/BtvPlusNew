//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct ScrollMenuTab: PageComponent {
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    var tabIdx:Int = 0
    var tabs:[String] = []
    var scrollTabSize:Int = 3
    var tabWidth:CGFloat = 100
    var tabColor:Color = Color.app.ivoryDeep
    var bgColor:Color = Color.kids.bg
    var marginHorizontal:CGFloat = DimenKids.margin.regular
    var isDivision:Bool = true
    var body: some View {
        if self.tabs.count > self.scrollTabSize || !self.isDivision {
            ZStack{
                ScrollView(.horizontal, showsIndicators: false){
                    if self.isDivision {
                    MenuTab(
                        viewModel: self.viewModel,
                        buttons: self.tabs,
                        selectedIdx: self.tabIdx,
                        bgColor: self.tabColor,
                        isDivision: true)
                        .frame(width: self.tabWidth * CGFloat(self.tabs.count))
                        .padding(.horizontal, self.marginHorizontal)
                    } else {
                        MenuTab(
                            viewModel: self.viewModel,
                            buttons: self.tabs,
                            selectedIdx: self.tabIdx,
                            bgColor: self.tabColor,
                            isDivision: false)
                            .padding(.horizontal, self.marginHorizontal)
                    }
                }
                HStack(spacing:0){
                    LinearGradient(
                        gradient:Gradient(colors: [self.bgColor, self.bgColor.opacity(0)]),
                        startPoint: .leading, endPoint: .trailing)
                        .modifier(MatchVertical(width:self.marginHorizontal))
                    Spacer()
                    LinearGradient(
                        gradient:Gradient(colors: [self.bgColor.opacity(0), self.bgColor]),
                        startPoint: .leading, endPoint: .trailing)
                        .modifier(MatchVertical(width:self.marginHorizontal))
                }
                .frame(height:SystemEnvironment.isTablet ? DimenKids.tab.thin : DimenKids.tab.light)
            }
        } else {
            MenuTab(
                viewModel: self.viewModel,
                buttons: self.tabs,
                selectedIdx: self.tabIdx,
                bgColor: self.tabColor,
                isDivision: true)
                .frame(width: self.tabWidth * CGFloat(self.tabs.count))
        }
    }//body
}

