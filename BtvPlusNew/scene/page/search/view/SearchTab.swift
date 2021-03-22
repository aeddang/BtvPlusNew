//
//  SearchBar.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/19.
//

import Foundation
import SwiftUI
struct SearchTab: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    
    var isFocus:Bool = false
    @Binding var isVoiceSearch:Bool
    @Binding var keyword:String
    
    var inputChanged: ((_ text:String) -> Void)? = nil
    var inputCopmpleted: ((_ text:String) -> Void)? = nil
    var goBack: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing:Dimen.margin.thinExtra){
            Button(action: {
                AppUtil.hideKeyboard()
                self.goBack?()
            }) {
                Image(Asset.icon.back)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimen.icon.regular,
                           height: Dimen.icon.regular)
            }
            HStack(spacing:Dimen.margin.tiny){
                FocusableTextView(
                    text: self.$keyword,
                    isfocus: self.isFocus,
                    textModifier:BoldTextStyle(size: Font.size.lightExtra).textModifier,
                    inputChanged: {text, _ in
                        self.inputChanged?(text)
                    },
                    inputCopmpleted : { text in
                        self.inputCopmpleted?(text)
                    }
                )
                .modifier(MatchParent())
                .clipped()
                .padding(.top, 1)
                
                
                Button(action: {
                    self.keyword = ""
                }) {
                    Image(Asset.icon.searchDelete)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.tiny,
                               height: Dimen.icon.tiny)
                }
                Button(action: {
                    withAnimation{ self.isVoiceSearch = true }
                    AppUtil.hideKeyboard()
                }) {
                    Image(Asset.icon.searchMic)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.regularExtra,
                               height: Dimen.icon.regularExtra)
                }
            }
            .background(Color.app.blueLight)
            .overlay(
               Rectangle()
                .stroke(
                    self.isFocus ? Color.app.white : Color.app.blueLight,
                    lineWidth: Dimen.stroke.regular )
            )
            .modifier(MatchHorizontal(height: Dimen.tab.light))
        }
    }
}
