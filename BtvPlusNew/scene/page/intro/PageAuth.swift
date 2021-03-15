//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
struct AuthItem:View {
    let title:String
    let text:String
    let icon:String
    let isSelectable:Bool
    var body: some View {
        HStack(spacing: Dimen.margin.regular){
            Image(self.icon)
                .renderingMode(.original).resizable()
                .scaledToFit()
                .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
            VStack(alignment: .leading, spacing: Dimen.margin.tinyExtra){
                HStack(spacing: Dimen.margin.micro){
                    Text(self.title)
                        .modifier(BoldTextStyle(size: Font.size.light, color: Color.app.white))
                    if self.isSelectable {
                        Text("("+String.app.select+")")
                            .modifier(BoldTextStyle(size: Font.size.light, color: Color.app.grey))
                    }
                }
                Text(self.text)
                    .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.greyLight))
            }
        }
        .padding(.vertical, Dimen.margin.regular)
    }
}


struct PageAuth: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text(String.pageText.authTitle)
                .modifier(MediumTextStyle(size: Font.size.boldExtra, color: Color.app.white))
                .padding(.top, self.sceneObserver.safeAreaTop)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Dimen.margin.heavyExtra)
            Text(String.pageText.authText)
                .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyLight))
                .padding(.top, Dimen.margin.regular)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Dimen.margin.regular)
            Spacer().modifier(LineHorizontal())
                .modifier(ContentHorizontalEdges())
                .padding(.top, 74)
            AuthItem(
                title: String.app.mic,
                text: String.pageText.authTextMic,
                icon: Asset.icon.mic,
                isSelectable: true)
                .padding(.horizontal, Dimen.margin.regular)
            Spacer().modifier(LineHorizontal())
                .modifier(ContentHorizontalEdges())
            AuthItem(
                title: String.app.location,
                text: String.pageText.authTextLocation,
                icon: Asset.icon.location,
                isSelectable: true)
                .padding(.horizontal, Dimen.margin.regular)
            Spacer().modifier(LineHorizontal())
                .modifier(ContentHorizontalEdges())
            Spacer()
            FillButton(
                text: String.pageText.authBtn,
                isSelected: true
            ){_ in
                
                self.pageSceneObserver.event = .initate
            }
            .padding(.bottom, self.sceneObserver.safeAreaBottom)
        }
        .padding(.vertical, Dimen.margin.regular)
        .modifier(PageFull())
        
        .onAppear{
            
        }
        
    }//body
    
    
    
}


#if DEBUG
struct PageAuth_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageAuth().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .frame(width: 375, height: 440, alignment: .center)
        }
    }
}
#endif

