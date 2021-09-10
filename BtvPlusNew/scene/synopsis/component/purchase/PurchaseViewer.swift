//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct PurchaseViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var componentViewModel:PageSynopsis.ComponentViewModel = PageSynopsis.ComponentViewModel()
    var data:PurchaseViewerData
    @State var option:String = ""
    @State var showInfo:Bool = false
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.light) { 
            if self.data.serviceInfo != nil {
                HStack{
                    Text(self.data.serviceInfo!)
                        .modifier(BoldTextStyle( size: Font.size.light, color:Color.app.white ))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal,  Dimen.margin.thin)
                .modifier( MatchHorizontal(height:Dimen.button.medium))
                .overlay(Rectangle().strokeBorder( Color.app.greyExtra , lineWidth: 1 ))
                if self.data.serviceInfoDesc != nil {
                    Text(self.data.serviceInfoDesc!)
                        .modifier(MediumTextStyle( size: Font.size.light, color:Color.app.white ))
                }
               
            }
            if self.data.isInfo || self.data.isOption {
                Spacer().modifier(LineHorizontal())
            }
            if self.data.isInfo {
                HStack(spacing:Dimen.margin.thinExtra){
                    if self.data.infoIcon != nil {
                        Image( self.data.infoIcon! )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.medium)
                    }
                    if self.data.infoLeading != nil && self.data.infoTrailing != nil{
                        Text(self.data.infoLeading!)
                            .font(.custom(Font.family.bold, size: Font.size.light))
                            .foregroundColor(Color.brand.primary)
                        + Text(self.data.infoTrailing!)
                            .font(.custom(Font.family.bold, size: Font.size.light))
                            .foregroundColor(Color.app.white)
                    }
                    else if self.data.infoLeading != nil {
                        Text(self.data.infoLeading!)
                            .modifier(BoldTextStyle( size: Font.size.light, color:Color.brand.primary ))
                            .lineLimit(1)
                            
                    }
                    else if let infoTrailing = self.data.infoTrailing {
                        Text(infoTrailing)
                            .modifier(BoldTextStyle( size: Font.size.light ))
                            .lineLimit(1)
                    }
                    if let sub = self.data.infoTrailingSub {
                        Text(sub)
                            .modifier(MediumTextStyle( size: Font.size.thin, color:Color.app.greyLight))
                            .lineLimit(1)
                        
                       
                    }
                    if self.data.infoTip != nil {
                        if SystemEnvironment.isTablet {
                            HStack(spacing:Dimen.margin.tiny){
                                Button(action: {
                                    withAnimation { self.showInfo.toggle() }
                                }){
                                    Image( Asset.icon.info )
                                        .renderingMode(.original).resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Tooltip(
                                    title: self.data.infoLeading,
                                    text: self.data.infoTip
                                )
                                .opacity( self.showInfo ? 1.0 : 0)
                            }
                        } else {
                            VStack(spacing:0){
                                Tooltip(
                                    title: self.data.infoLeading,
                                    text: self.data.infoTip
                                )
                                .opacity( self.showInfo ? 1.0 : 0)
                                .padding(.top, -(Tooltip.size.height+Dimen.margin.thinExtra))
                                //.padding(.leading, -(Tooltip.size.width - Dimen.icon.tiny)/2)
                                Button(action: {
                                    withAnimation { self.showInfo.toggle() }
                                }){
                                    Image( Asset.icon.info )
                                        .renderingMode(.original).resizable()
                                        .scaledToFit()
                                        .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                        }
                        
                    }
                }
                
            }//info
            if self.data.isOption {
                SortButton(
                    title: self.data.optionTitle,
                    text: self.option,
                    isFocus: false,
                    isFill: true,
                    bgColor: Color.brand.bg){
                    
                    self.appSceneObserver.select = .select((self.tag, self.data.options), self.data.optionIdx)
                }
                .buttonStyle(BorderlessButtonStyle())
                .onReceive(self.appSceneObserver.$selectResult){ result in
                    guard let result = result else { return }
                    switch result {
                        case .complete(let type, let idx) : do {
                            if type.check(key: self.tag){
                                self.data.optionIdx = idx
                                self.option = self.data.options[idx]
                                if let watchOptions = self.data.watchOptions {
                                    self.componentViewModel.uiEvent = .changeOption(watchOptions[idx])
                                }
                            }
                        }
                    }
                }
            }//option
            
            if self.data.isInfo || self.data.isOption {
                Spacer().modifier(LineHorizontal())
            }
            
            if self.data.purchasBtnTitle != nil {
                FillButton(
                    text: self.data.purchasBtnTitle!,
                    subText : self.data.purchasBtnSubTitle
                ){_ in
                    self.componentViewModel.uiEvent = .purchase
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .modifier(ContentHorizontalEdges())
        .onAppear{
            if self.data.isOption {
                self.option = self.data.options[self.data.optionIdx]
            }
        }
    }//body
}



#if DEBUG
struct PurchaseViewer_Previews: PreviewProvider {

    static var previews: some View {
        VStack{
            PurchaseViewer(
                data:PurchaseViewerData(type: .btv).setDummy()
            )
            .environmentObject(DataProvider())
            .environmentObject(PagePresenter())
            .environmentObject(AppSceneObserver())
            .environmentObject(Pairing())
        }.background(Color.brand.bg)
    }
}
#endif

