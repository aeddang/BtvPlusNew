//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine


extension PlayerGrade {
    
    static let marginFull:CGFloat  = SystemEnvironment.isTablet ? 10 : 4
    static let margin:CGFloat  = SystemEnvironment.isTablet ? 6 : 3
    
    static let iconSizeFull:CGFloat  = SystemEnvironment.isTablet ? 80 : 48
    static let iconSize:CGFloat  = SystemEnvironment.isTablet ? 56 : 26
    
    static let iconMarginFull:CGFloat  = SystemEnvironment.isTablet ? 10 : 4
    static let iconMargin:CGFloat  = SystemEnvironment.isTablet ? 6 : 3
    
    static let iconTextSizeFull:CGFloat  = SystemEnvironment.isTablet ? Font.size.thinExtra : Font.size.tinyExtra
    static let iconTextSize:CGFloat  = SystemEnvironment.isTablet ? Font.size.micro : Font.size.microExtra
    
    static let textSizeFull:CGFloat  = SystemEnvironment.isTablet ? Font.size.lightExtra : Font.size.thinExtra
    static let textSize:CGFloat  = SystemEnvironment.isTablet ? Font.size.tiny : Font.size.tinyExtra
}

struct PlayerGrade: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var data:PlayGradeData
    @State var isFullScreen:Bool = false
    @State var isShowing:Bool = true
    @State var isUiShowing:Bool = false
    var body: some View {
        VStack( alignment :.leading,spacing:0){
            Spacer().modifier(MatchHorizontal(height: 0))
            HStack(alignment: .top, spacing: self.isFullScreen ? Self.iconMarginFull : Self.iconMargin){
                if let icon = self.data.icon {
                    Image(icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width:self.isFullScreen ? Self.iconSizeFull : Self.iconSize,
                            height:self.isFullScreen ? Self.iconSizeFull : Self.iconSize)
                }
                ForEach(self.data.grades) { grade in
                    
                    VStack(alignment: .center, spacing: Dimen.margin.micro){
                        Image(grade.icon)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            
                            .frame(
                                width:self.isFullScreen ? Self.iconSizeFull : Self.iconSize,
                                height:self.isFullScreen ? Self.iconSizeFull : Self.iconSize)
                        Text(grade.text)
                            .modifier(BoldTextStyle(size: self.isFullScreen ? Self.iconTextSizeFull : Self.iconTextSize,
                                                    color: Color.app.white))
                            
                    }
                }
            }
            .padding(.top,
                     self.isUiShowing
                        ? self.isFullScreen
                            ? PlayerUI.uiRealHeightFullScreen : PlayerUI.uiRealHeight
                        : 0
                     )
            .padding(.bottom, self.isFullScreen ? Dimen.margin.lightExtra : Dimen.margin.thinExtra)
            if let text = self.data.text {
                HStack(alignment :.top, spacing: 0){
                    Text(text).modifier(BoldTextStyle(
                                            size: self.isFullScreen ? Self.textSizeFull : Self.textSize,
                                            color: Color.app.white))
                        .padding(.leading, SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.thin)
                }
                .background(
                    HStack{
                        Spacer().modifier(MatchVertical(width: SystemEnvironment.isTablet ? 4 : 3))
                            .background(Color.brand.primary)
                        Spacer()
                    }
                )
            }
            Spacer()
            if let info = self.data.gradeInfo {
                Text(info)
                    .modifier(MediumTextStyle(
                                        size: self.isFullScreen ? Self.textSizeFull : Self.textSize,
                                        color: Color.app.white))
                    
                    .multilineTextAlignment(.leading)
                    .padding(.bottom,
                             self.isUiShowing
                                ? self.isFullScreen
                                    ? PlayerUI.uiRealHeightFullScreen : PlayerUI.uiRealHeight
                                : 0
                             )
            }
            
        }
        
        .modifier(MatchParent())
        .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
        .opacity(self.isShowing ? 1 : 0)
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    self.isUiShowing = true
                default : self.isUiShowing = false
                }
            }
        }
        .onReceive(self.viewModel.$time){ t in
            if self.isShowing {
                if t >= self.viewModel.openingTime {
                    withAnimation { self.isShowing = false }
                }
            } else {
                if t < self.viewModel.openingTime {
                    withAnimation { self.isShowing = true }
                }
            }
        }
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
            
    }//body
    
    
   
    
}


#if DEBUG
struct PlayerGrade_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerGrade(
                data:PlayGradeData().setDummy()
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
