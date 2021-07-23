//
//  MonthlyInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/22.
//

import Foundation
import SwiftUI

struct FloatRecommandData{
    let playType:KidsPlayType
    let text:String
    let isMonthlyReport:Bool
    let diagnosticReportType:DiagnosticReportType?
    let isDiagnosticReportCompleted:Bool 
}
extension FloatRecommand {
    static let btnSize = CGSize(
        width: SystemEnvironment.isTablet ? 284 : 175,
        height: SystemEnvironment.isTablet ? 94 : 58)
    
    static let openBtnSize = CGSize(
        width: SystemEnvironment.isTablet ? 212 : 131,
        height: SystemEnvironment.isTablet ? 84 : 52)
}

struct FloatRecommand:PageComponent {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @Binding var isClose:Bool
    var data:FloatRecommandData
    var body :some View {
        VStack(alignment: .trailing, spacing:DimenKids.margin.micro){
            Spacer().modifier(MatchHorizontal(height:0))
            if self.isClose {
                Button(action: {
                    withAnimation{ self.isClose = false}
                }) {
                    ZStack{
                        Image(AssetKids.shape.floatingButtonBg)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .modifier(MatchParent())
                        VStack(spacing:DimenKids.margin.micro){
                            if let kid = self.pairing.kid?.nickName {
                                Text(kid)
                                    .modifier(BoldTextStyleKids(
                                                size: Font.sizeKids.tinyExtra,
                                                color: Color.app.yellowLight))
                                    
                            }
                            Text(String.button.testResult)
                                .modifier(BoldTextStyleKids(
                                            size: Font.sizeKids.thinExtra,
                                            color: Color.app.white))
                                
                        }
                    }
                    .frame(
                        width: Self.openBtnSize.width,
                        height: Self.openBtnSize.height)
                    .modifier(Grow())
                }
            } else {
                Button(action: {
                    withAnimation{ self.isClose = true}
                }) {
                    Image(AssetKids.icon.closePop)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(
                        width: DimenKids.icon.mediumExtra,
                        height: DimenKids.icon.mediumExtra)
                    .modifier(Grow())
                }
            }
            if !self.isClose {
                HStack(spacing:DimenKids.margin.thin){
                    Text(data.text)
                        .modifier(MediumTextStyleKids(size: Font.sizeKids.lightExtra, color: Color.app.brownDeep))
                        .multilineTextAlignment(.leading)
                    
                    if self.data.isMonthlyReport || self.data.diagnosticReportType != nil {
                        Spacer().modifier(
                            LineVertical( width:DimenKids.stroke.light, color:Color.app.black)
                        )
                        .frame(height:Self.btnSize.height)
                        
                        if self.pairing.kid == nil {
                            Button(action: {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.pairing, animationType: .opacity)
                                )
                            }) {
                                Image(AssetKids.image.goRegistProfile)
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .frame(
                                    width: Self.btnSize.width,
                                    height: Self.btnSize.height)
                            }
                        }else if self.data.isMonthlyReport {
                            Button(action: {
                                self.pagePresenter.openPopup(
                                    PageKidsProvider
                                        .getPageObject(.kidsMyMonthly)
                                        .addParam(key: .type, value: self.data.playType)
                                )
                            }) {
                                Image(AssetKids.image.goMonthlyResult)
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .frame(
                                    width: Self.btnSize.width,
                                    height: Self.btnSize.height)
                            }
                        } else if let diagnosticReportType = self.data.diagnosticReportType {
                            Button(action: {
                                self.pagePresenter.openPopup(
                                    PageKidsProvider
                                        .getPageObject(.kidsMyDiagnostic)
                                        .addParam(key: .type, value: diagnosticReportType )
                                )
                            }) {
                                Image(self.data.isDiagnosticReportCompleted
                                    ? diagnosticReportType.resultButton
                                    : diagnosticReportType.startButton
                                )
                                .renderingMode(.original).resizable()
                                .scaledToFit()
                                .frame(
                                    width: Self.btnSize.width,
                                    height: Self.btnSize.height)
                            }

                        }
                    }
                }
                .padding(.all, DimenKids.margin.regular)
                .background(Color.app.white)
                .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
                .modifier(Grow())
            }
        }
        .padding(.bottom, self.isClose ? 0 : DimenKids.margin.thin + self.sceneObserver.safeAreaBottom)
        .modifier(ContentHorizontalEdgesKids())
    }

}

#if DEBUG
struct FloatRecommand_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            FloatRecommand(
                isClose: .constant(true),
                data: FloatRecommandData(
                            playType: .english,
                            text: "testdcscdscsdcdsacdcac",
                            isMonthlyReport: false,
                            diagnosticReportType: .english,
                            isDiagnosticReportCompleted:true))
                .environmentObject(PagePresenter())
                .environmentObject(Pairing())
                .environmentObject(PageSceneObserver()).frame(width:320,height:200)

        }
    }
}
#endif
